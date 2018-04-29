#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

export SHA=$(cd "${SH_DIR}" && git rev-parse HEAD)

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/test.sh"
