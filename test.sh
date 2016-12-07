#!/bin/bash

assert_all_volumes_includes()
{
  volume_name=${1}
  list_all_volumes >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${volume_name}
  assert_no_stderr
}

refute_all_volumes_includes()
{
  volume_name=${1}
  list_all_volumes >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${volume_name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_old_volumes_includes()
{
  volume_name=${1}
  list_old_volumes >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${volume_name}
  assert_no_stderr
}

refute_old_volumes_includes()
{
  volume_name=${1}
  list_old_volumes >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${volume_name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

new_avatar()
{
  volume_name=${1}
  docker volume create --name ${volume_name} > /dev/null
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

list_all_volumes()
{
  docker volume ls --quiet --filter 'name=cyber_dojo_'
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

list_old_volumes()
{
  volume_names=$(docker volume ls --quiet --filter 'name=cyber_dojo_')
  assertTrue $?
  for volume_name in ${volume_names}; do
    changers=$(docker run \
      --rm \
      --tty \
      --volume ${volume_name}:/sandbox \
      cyberdojo/collector \
      sh -c "find /sandbox/** -mtime -7")
    if [ "${changers}" = "" ]; then
      echo ${volume_name}
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

send_into_past()
{
  # Artificially ages the files in the given docker volume by
  # setting their mtime to more than 7 days ago.
  volume_name=$1
  docker run \
    --rm \
    --volume ${volume_name}:/sandbox \
    cyberdojo/collector \
    sh -c "touch -d 201611121314 /sandbox/**"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_cron()
{
  docker run \
    --rm \
    --tty \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    cyberdojo/collector \
    sh -c "cd /home; ./run-as-cron '/etc/periodic/daily/collect'" >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_volume_used_in_last_7_days_is_not_collected()
{
  kata_id='C71B947EC3'
  avatar_name='salmon'
  volume_name="cyber_dojo_${kata_id}_${avatar_name}"
  new_avatar ${volume_name}

  assert_all_volumes_includes ${volume_name}
  refute_old_volumes_includes ${volume_name}
  run_cron
  assert_all_volumes_includes ${volume_name}
  refute_old_volumes_includes ${volume_name}
  docker volume rm ${volume_name} > /dev/null
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_volume_not_used_in_last_7_days_is_collected()
{
  kata_id='C9A2F4B226'
  avatar_name='salmon'
  volume_name="cyber_dojo_${kata_id}_${avatar_name}"
  new_avatar ${volume_name}
  send_into_past ${volume_name}
  assert_all_volumes_includes ${volume_name}
  assert_old_volumes_includes ${volume_name}
  run_cron
  assert_stdout_includes ${volume_name}
  refute_all_volumes_includes ${volume_name}
  refute_old_volumes_includes ${volume_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
