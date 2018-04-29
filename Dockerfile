FROM  alpine:latest
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby

RUN apk --update --no-cache add \
    openssl ca-certificates \
    ruby ruby-io-console ruby-dev ruby-irb ruby-bundler ruby-bigdecimal \
    bash tzdata

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install docker-client
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Launching a docker app (that itself uses docker) is
# different on different host OS's... eg
#
# OSX 10.10 (Yosemite)
# --------------------
# The Docker-Quickstart-Terminal uses docker-machine to forward
# docker commands to a boot2docker VM called default.
# In this VM the docker binary lives at /usr/local/bin/
#
#    -v /usr/local/bin/docker:/usr/local/bin/docker
#
# Ubuntu 14.04 (Trusty)
# ---------------------
# The docker binary lives at /usr/bin and has a dependency on apparmor 1.1
#
#    -v /usr/bin/docker:/usr/bin/docker
#    -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0 ...
#
# Debian 8 (Jessie)
# -----------------
# The docker binary lives at /usr/bin and has a dependency to apparmor 1.2
#
#    -v /usr/bin/docker:/usr/bin/docker
#    -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.2.0 ...
#
# I originally used docker-compose extension files specific to each OS.
# I now install the docker client _inside_ the image.
# This means there is no host<-container uid dependency.
# But there is a host<-container docker version dependency.
# In practice, the features of docker I use are not exotic and
# I can (and do) ignore this version dependency.
#
# docker 1.11.0+ now relies on four binaries
# See https://github.com/docker/docker/wiki/Engine-1.11.0
# See https://docs.docker.com/engine/installation/binaries/
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARG DOCKER_ENGINE_VERSION

RUN apk --update add curl \
  && curl -OL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_ENGINE_VERSION}.tgz \
  && tar -xvzf docker-${DOCKER_ENGINE_VERSION}.tgz \
  && mv docker/* /usr/bin/ \
  && rmdir docker \
  && rm docker-${DOCKER_ENGINE_VERSION}.tgz \
  && apk del curl

# - - - - - - - - - - - - - - - - -
# git commit sha image is built from
# - - - - - - - - - - - - - - - - -

ARG SHA
RUN echo ${SHA} > /home/sha.txt

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup cron
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
