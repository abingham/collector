# cyberdojo/runner exposes port 4557 ...
FROM cyberdojo/runner
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY collect /etc/periodic/daily/

# -f    foreground
# -d 8  log to stderr, log level 8 (default)
CMD [ "crond", "-f", "-d", "8" ]
