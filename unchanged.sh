#!/bin/bash

# List all the docker volumes which have not been used for 7 days

volume_names=$(docker volume ls --quiet --filter 'name=cyber_dojo_')
for volume_name in ${volume_names}; do
  changers=$(docker run --rm -it -v ${volume_name}:/sandbox cyberdojo/collector sh -c "find /sandbox/** -mtime -7")
  if [ "${changers}" = "" ]; then
    echo ${volume_name}
  fi
done
