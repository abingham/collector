#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
cd ${ROOT_DIR}
docker-compose --file ${ROOT_DIR}/docker-compose.yml build