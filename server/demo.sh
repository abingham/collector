#!/bin/bash

# Explicitly run what cron would run as cron would run it

docker-compose build
docker-compose up -d
docker exec -it collector_server sh -c "cd /home; ./run-as-cron '/etc/periodic/daily/collect'"