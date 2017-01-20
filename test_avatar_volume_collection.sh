#!/bin/bash

# tests collect_avatar_volumes.rb script successfully collects
# docker volumes created by DockerAvatarVolumeRunner
# whose most recently edited file is more than 7 days ago.

volume_pattern='cyber_dojo_avatar_volume_runner'

volume_name()
{
  local kata_id=${1}
  local avatar_name=${2}
  echo "${volume_pattern}_${kata_id}_${avatar_name}"
}

assert_all_volumes_includes()
{
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
  list_all_volumes >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${name}
  assert_no_stderr
}

refute_all_volumes_includes()
{
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
  list_all_volumes >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_old_volumes_includes()
{
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
  list_old_volumes >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${name}
  assert_no_stderr
}

refute_old_volumes_includes()
{
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
  list_old_volumes >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

new_avatar()
{
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
  docker volume create --name ${name} > /dev/null
  assertTrue $?
}

old_avatar()
{
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
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
  # TODO:....
  #local cids=$(docker ps --quiet --all --filter "name=${container_pattern}")
  #assertTrue $?
  #for cid in ${cids}; do
  #  local changers=$(docker exec ${cid} sh -c "find /sandboxes/** -mtime -7")
  #  if [ "${changers}" = "" ]; then
  #    docker ps --all --filter "name=${container_pattern}" | grep ${cid}
  #  fi
  #done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

send_into_past()
{
  # Artificially ages the files in the given volume by
  # setting their mtime to more than 7 days ago.
  local kata_id=${1}
  local avatar_name=${2}
  local name=$(volume_name ${kata_id} ${avatar_name})
  docker run \
    --rm \
    --interactive \
    --tty \
    --volume ${name}:/sandboxes:rw \
    cyberdojo/collector \
    sh -c "touch -d 201611121314 /sandboxes/**"
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
    sh -c "cd /home; ./run-as-cron '/etc/periodic/daily/collect_avatar_volumes'" >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_volumes_used_in_last_7_days_are_not_collected()
{
  local kata_id='C71B947EC3'
  local avatar_name='salmon'
  new_avatar ${kata_id} ${avatar_name}
  assert_all_volumes_includes ${kata_id} ${avatar_name}
  refute_old_volumes_includes ${kata_id} ${avatar_name}
  run_cron
  assert_all_volumes_includes ${kata_id} ${avatar_name}
  refute_old_volumes_includes ${kata_id} ${avatar_name}
  old_avatar ${kata_id} ${avatar_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_volumes_not_used_in_last_7_days_are_collected()
{
  local kata_id='9CA2F4B226'
  local avatar_name='salmon'
  new_avatar ${kata_id} ${avatar_name}
  send_into_past ${kata_id} ${avatar_name}
  assert_all_volumes_includes ${kata_id} ${avatar_name}
  assert_old_volumes_includes ${kata_id} ${avatar_name}
  run_cron
  assert_stdout_includes ${name}
  refute_all_volumes_includes ${kata_id} ${avatar_name}
  refute_old_volumes_includes ${kata_id} ${avatar_name}
  # Do not call old_avatar() - it's volume has been collected!
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
