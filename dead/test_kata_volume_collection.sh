#!/bin/bash

# tests collect_kata_volumes.rb script successfully collects
# docker volumes created by DockerKataVolumeRunner
# whose most recently edited file is more than 7 days ago.

volume_pattern='cyber_dojo_kata_volume_runner'

volume_name()
{
  local kata_id=${1}
  echo "${volume_pattern}_${kata_id}"
}

assert_all_volumes_includes()
{
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  list_all_volumes >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${name}
  assert_no_stderr
}

refute_all_volumes_includes()
{
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  list_all_volumes >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_old_volumes_includes()
{
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  list_old_volumes >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${name}
  assert_no_stderr
}

refute_old_volumes_includes()
{
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  list_old_volumes >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

new_kata()
{
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  docker volume create --name ${name} > /dev/null
  assertTrue $?
}

old_kata()
{
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  docker volume rm ${name} > /dev/null
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

list_all_volumes()
{
  docker volume ls --quiet --filter "name=${volume_pattern}"
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

list_old_volumes()
{
  local names=$(docker volume ls --quiet --filter "name=${volume_pattern}")
  assertTrue $?
  for name in ${names}; do
  #  local days=$(./days_since_used_runner_volume.rb ${name})
  #  if [ "${days}" -ge "7" ]; then
  #    echo ${name}
  #  fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

send_into_past()
{
  # Artificially ages the files in the given volume by
  # setting their mtime to more than 7 days ago.
  local kata_id=$1
  local name=$(volume_name ${kata_id})
  local sandboxes='/sandboxes'
  docker run \
    --rm \
    --interactive \
    --tty \
    --volume ${name}:${sandboxes}:rw \
    cyberdojo/collector \
    sh -c "touch -d 201611121314.15 ${sandboxes}"
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_cron()
{
  docker run \
    --rm \
    --interactive \
    --tty \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    cyberdojo/collector \
    sh -c "cd /home; ./run-as-cron '/etc/periodic/daily/collect_kata_volumes'" >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_volumes_used_in_last_7_days_are_not_collected()
{
  local kata_id='876ED581ED'
  local avatar_name='hippo'
  new_kata ${kata_id}
  new_avatar ${kata_id} ${avatar_name}
  assert_all_volumes_includes ${kata_id}
  refute_old_volumes_includes ${kata_id}
  run_cron
  assert_all_volumes_includes ${kata_id}
  refute_old_volumes_includes ${kata_id}
  old_avatar ${kata_id} ${avatar_name}
  old_kata ${kata_id}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_volumes_not_used_in_last_7_days_are_collected()
{
  local kata_id='CFC430CAAA'
  local avatar_name='hippo'
  new_kata ${kata_id}
  #new_avatar ${kata_id} ${avatar_name}
  send_into_past ${kata_id}
  assert_all_volumes_includes ${kata_id}
  assert_old_volumes_includes ${kata_id}
  run_cron
  assert_stdout_includes ${name}
  refute_all_volumes_includes ${kata_id}
  refute_old_volumes_includes ${kata_id}
  # Do not call old_avatar() - it's volume has been collected!
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
