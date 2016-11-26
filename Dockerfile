# cyberdojo/runner exposes port 4557 ...
FROM cyberdojo/runner
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY collect /etc/periodic/daily/

# For testing
COPY cron-env    /home
COPY run-as-cron /home

# -f    foreground
# -d 8  log to stderr, log level 8 (default)
CMD [ "crond", "-f", "-d", "8" ]
