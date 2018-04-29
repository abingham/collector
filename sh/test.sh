#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

ruby "${ROOT_DIR}/runner_volume_collector_test.rb"