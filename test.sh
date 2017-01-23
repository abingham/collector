#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
ruby ${my_dir}/runner_volume_collector_test.rb