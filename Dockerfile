FROM cyberdojo/docker
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY collect_avatar_volumes.rb /etc/periodic/daily/
COPY collect_kata_volumes.rb   /etc/periodic/daily/

# For testing
COPY cron-env    /home
COPY run-as-cron /home

# -f    foreground
# -d 8  log to stderr, log level 8 (default)
CMD [ "crond", "-f", "-d", "8" ]
