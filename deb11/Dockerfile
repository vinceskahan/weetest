#-------------------------------------------------------------------------
#
# deb11 Dockerfile
#
# 'base'        = minimal os starting point
#
# 'v5pip'       = with v5 pip installed over base
#
# 'v4pkg'        = with v4 pkg installed over the base
# 'v4setup'      = with v4 installed via setup.py 
#
# to run manually:
#    docker run --rm -it imagename:here [cmd]
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------
# configure a base image we'll derive other variants from
#-------------------------------------------------------------

FROM debian:11-slim as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker to suppress needing syslog
COPY logging.additions /tmp/logging.additions

# we do a little cleanup for size here
# need gcc for compiling CT3
# also set up weewx user/group/homedir
RUN apt-get update                                  \
    && apt-get install -y python3-pip python3-venv sqlite3 wget gcc \
    && apt-get clean autoclean                         \
    && apt-get autoremove --yes                        \
    && rm -rf /var/lib/{apt,dpkg,cache,log}            \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && groupadd -r weewx -g 1234        \
    && useradd -r -g weewx weewx -u 1234       \
    && mkdir -p /home/weewx/adds \
    && cd /home/weewx/adds\
    && chown -R weewx:weewx /home/weewx \
    && chmod -R 755 /home/weewx 

#-------------------------------------------------------------
# install v5pip over the base image above
#-------------------------------------------------------------

FROM base as v5pip

# install and configure weewx using an unprivileged user
#    setting debug=1 can't be done via weectl so use sed
#    StdPrint is removed to stop LOOP from being logged to stdout
#    append logging stanza so we don't look for syslogd at runtime
#

USER weewx
RUN python3 -m venv /home/weewx/weewx-venv \
    && . /home/weewx/weewx-venv/bin/activate \
    && pip3 install weewx==5.0b15     \
    && weectl station create --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx-data/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx-data/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx-data/weewx.conf

CMD /home/weewx/weewx-venv/bin/weewxd

#---- additional example typical test scenario ---
FROM v5pip as v5pip-test
COPY test.py /tmp
CMD ["python3.9", "/tmp/test.py"]

#-------------------------------------------------------------
# install v4 pkg over the base image above
#-------------------------------------------------------------

FROM base as v4pkg

RUN wget -qO - https://weewx.com/keys.html | gpg --dearmor --output /etc/apt/trusted.gpg.d/weewx.gpg \
    && wget -qO - https://weewx.com/apt/weewx-python3.list | tee /etc/apt/sources.list.d/weewx.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y weewx=4.10.2-1 \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /etc/weewx/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /etc/weewx/weewx.conf \
    && cat /tmp/logging.additions >> /etc/weewx/weewx.conf

CMD /usr/bin/weewxd

#-------------------------------------------------------------
# install v4 setup.py over the base image above
#-------------------------------------------------------------

FROM base as v4setup

RUN python3.9 -m pip install CT3 Pillow==9.4.0 configobj \
    && wget http://weewx.com/downloads/released_versions/weewx-4.10.2.tar.gz -O /root/weewx-4.10.2.tar.gz  \
    && cd /root \
    && tar xzf weewx-4.10.2.tar.gz \
    && cd weewx-4.10.2 \
    && python3 ./setup.py build \
    && python3 ./setup.py install --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx.conf 

CMD /home/weewx/bin/weewxd

