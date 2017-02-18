FROM cyberdojo/docker
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY collect_runner_volumes   /etc/periodic/hourly/

COPY runner_volume_collector.rb /home
COPY runner_volume.rb           /home
COPY assert_exec.rb             /home
# For testing
COPY cron-env    /home
COPY run-as-cron /home

# -f    foreground
# -d 8  log to stderr, log level 8 (default)
CMD [ "crond", "-f", "-d", "8" ]
