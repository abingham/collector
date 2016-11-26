#!/bin/bash

# List the mtimes of the files in the given docker volume

volume_name=$1
docker run --rm -it -v ${volume_name}:/sandbox cyberdojo/ruby sh -c "cd /sandbox && ls -al"
