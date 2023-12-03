#---------------------------------------------------------------------------------------
# 'base' is the starting point we add weewx, testing tools, etc. to later below
# this shouldn't change much hypothetically unless testing os updates is needed
#---------------------------------------------------------------------------------------

FROM debian:11-slim as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker logging
COPY logging.additions /tmp/logging.additions

# it looks odd installing things then removing things but python3-venv
# brings in many packages that make the image huge and gcc is needed
# so CT3 will build correctly via pip
#
# add some packages, clean up needless things
# create and configure a weewx user
# stash a copy of a skin/extension for later use
# fix up permissions

# FIXME: the uid:gid likely do not need to be specified here

RUN apt-get update                                  \
    && apt-get install -y python3-pip python3-venv sqlite3 wget gcc \
    && apt-get clean autoclean                         \
    && apt-get autoremove --yes                        \
    && rm -rf /var/lib/{apt,dpkg,cache,log}            \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && rm -rf /usr/share/locale/[a-d]*                 \
    && rm -rf /usr/share/locale/[f-z]*                 \
    && rm -rf /usr/share/locale/e[a-m]*                \
    && rm -rf /usr/share/locale/e[o-z]* \
    && groupadd -r weewx -g 1234        \
    && useradd -r -g weewx weewx -u 1234       \
    && mkdir -p /home/weewx/adds \
    && cd /home/weewx/adds\
    && wget -nv https://github.com/poblabs/weewx-belchertown/archive/refs/heads/master.zip -O belchertown.zip \
    && chown -R weewx:weewx /home/weewx \
    && chmod -R 755 /home/weewx 

CMD "date"

# at this point you have a reusable starting point
# with the syslog additions in /tmp
# and a downloaded skin in /home/weewx/adds

#---------------------------------------------------------------------------------------
# 'build' sets up and installs weewx, running only install/configure steps for weewx
#---------------------------------------------------------------------------------------

FROM base as build
USER weewx

# install and configure weewx
#    create a default station then reconfigure with weectl
#       use sed for setting debug=1 because that can't be done via weectl
#       logging additions are needed due to no syslog in a docker image
#       and StdPrint is removed to stop LOOP from being logged to stdout
#
# note this installs an additional extension
# which is accessible at http://hostname:port/Belchertown
# in addition to the default Seasons skin at the top
# of the web doc root

# TODO: consider adding unittest, paho-mqtt, requests here for future testing needs

RUN python3 -m venv /home/weewx/weewx-venv \
    && . /home/weewx/weewx-venv/bin/activate \
    && pip3 install weewx==5.0.0b15             \
    && weectl station create --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx-data/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx-data/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx-data/weewx.conf \
    && weectl extension install /home/weewx/adds/belchertown.zip \
    && weectl extension list

# test reconfigure
RUN /home/weewx/weewx-venv/bin/weectl station reconfigure --no-prompt \
  --location="deb11-v5-pip testing"

#---------------------------------------------------------------------------------------
# 'run' is a minimal upstream os that runs weewxd
#
# unfortunately we need to add python to the minimal os from upstream
# so the same cleanups as in 'base' apply here
# as well as setting up the weewx user:group to run unprivileged
#
# FIXME: the uid:gid likely do not need to be specified here
#
# approximate size is 195MB for deb11 v5 pip
#---------------------------------------------------------------------------------------

FROM debian:11-slim as run
COPY --from=build /home/weewx /home/weewx
RUN apt-get update                                  \
    && apt-get install -y python3 \
    && apt-get clean autoclean                         \
    && apt-get autoremove --yes                        \
    && rm -rf /var/lib/{apt,dpkg,cache,log}            \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && rm -rf /usr/share/locale/[a-d]*                 \
    && rm -rf /usr/share/locale/[f-z]*                 \
    && rm -rf /usr/share/locale/e[a-m]*                \
    && rm -rf /usr/share/locale/e[o-z]*  \
    && groupadd -r weewx -g 1234        \
    && useradd -r -g weewx weewx -u 1234
USER weewx
CMD ["/home/weewx/weewx-venv/bin/weewxd"]

#---------------------------------------------------------------------------------------
# 'test' is the run image with tests enabled
#
# to use pip here, base this on 'build'           (481 MB for deb11 v5 pip)
# to use just bash for tests, base this on 'run'  (195 MB for deb11 v5 pip)
#---------------------------------------------------------------------------------------

#----- run the test suite after copying it into place ---
# docker build --target test -t deb11pip:testing .
# docker run --rm deb11pip:testing
# echo $? for exit status of the container's test script
#
# (then examine the test script output)
FROM build as test
COPY test.sh /tmp
CMD ["bash", "/tmp/test.sh"]

