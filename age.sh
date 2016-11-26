#!/bin/bash

# Artificially ages the files in the given docker volume by
# setting their mtime to more than 7 days ago.

volume_name=$1
docker run --rm -it -v ${volume_name}:/sandbox cyberdojo/ruby sh -c "touch -d 201611121314 /sandbox/**"
