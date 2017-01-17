#!/bin/bash

container_pattern='cyber_dojo_avatar_volume_runner'

container_name()
{
  local kata_id=${1}
  local avatar_name=${2}
  echo "${container_pattern}_${kata_id}_${avatar_name}"
}

assert_all_containers_includes()
{
  local name=$(container_name $1 $2)
  list_all_containers >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${name}
  assert_no_stderr
}

refute_all_containers_includes()
{
  local name=$(container_name $1 $2)
  list_all_containers >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_old_containers_includes()
{
  local name=$(container_name $1 $2)
  list_old_containers >${stdoutF} 2>${stderrF}
  assert_stdout_includes ${name}
  assert_no_stderr
}

refute_old_containers_includes()
{
  local name=$(container_name $1 $2)
  list_old_containers >${stdoutF} 2>${stderrF}
  refute_stdout_includes ${name}
  assert_no_stderr
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

new_avatar()
{
  local name=$(container_name $1 $2)
  docker run \
    --detach \
    --interactive \
    --tty \
    --name=${name} \
    --volume /sandboxes \
    cyberdojofoundation/gcc_assert \
    sh -c "mkdir /sandboxes/${name} && sleep 1m" > /dev/null

  assertTrue $?
}

old_avatar()
{
  local cid=$(docker ps --quiet --all --filter "name=${container_pattern}")
  assertTrue $?
  docker rm --force --volumes ${cid} > /dev/null
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

list_all_containers()
{
  docker ps --all --filter "name=${container_pattern}"
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

list_old_containers()
{
  local cids=$(docker ps --quiet --all --filter "name=${container_pattern}")
  assertTrue $?
  for cid in ${cids}; do
    local changers=$(docker exec ${cid} sh -c "find /sandboxes/** -mtime -7")
    if [ "${changers}" = "" ]; then
      docker ps --all --filter "name=${container_pattern}" | grep ${cid}
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

send_into_past()
{
  # Artificially ages the files in the given docker container by
  # setting their mtime to more than 7 days ago.
  local name=$(container_name $1 $2)
  local cid=$(docker ps --quiet --all --filter "name=${name}")
  assertTrue $?
  docker exec ${cid} sh -c "touch -d 201611121314 /sandboxes/**"
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
    sh -c "cd /home; ./run-as-cron '/etc/periodic/daily/collect'" >${stdoutF} 2>${stderrF}
  assertTrue $?
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_container_used_in_last_7_days_is_not_collected()
{
  local kata_id='C71B947EC3'
  local avatar_name='salmon'
  new_avatar ${kata_id} ${avatar_name}
  assert_all_containers_includes ${kata_id} ${avatar_name}
  refute_old_containers_includes ${kata_id} ${avatar_name}
  run_cron
  assert_all_containers_includes ${kata_id} ${avatar_name}
  refute_old_containers_includes ${kata_id} ${avatar_name}
  old_avatar ${kata_id} ${avatar_name}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

test_container_not_used_in_last_7_days_is_collected()
{
  local kata_id='9CA2F4B226'
  local avatar_name='salmon'
  new_avatar ${kata_id} ${avatar_name}
  send_into_past ${kata_id} ${avatar_name}
  assert_all_containers_includes ${kata_id} ${avatar_name}
  assert_old_containers_includes ${kata_id} ${avatar_name}
  run_cron
  assert_stdout_includes ${name}
  refute_all_containers_includes ${kata_id} ${avatar_name}
  refute_old_containers_includes ${kata_id} ${avatar_name}
  # Do not call old_avatar() - it's container has been collected!
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

. ./shunit2_helpers.sh
. ./shunit2
