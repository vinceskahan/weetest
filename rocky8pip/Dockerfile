#-----------------------------------------------
# Build into an image ala:
#    docker build -t somename:latest .
#
# To run a shell to log into a container running
# this image:
#    docker run --rm -it somename:latest bash
#-----------------------------------------------
#
# rocky8 has an old python by default so this is a little customized accordingly
#  - we add epel and install python39 and python39-pip and python39-devel
#  - and we call python3.9 and pip3.9 explicitly below

FROM rockylinux:8.8 as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker logging
COPY logging.additions /tmp/logging.additions

# for rocky8 need to specify python39 to get a recent enough version

RUN yum install -y epel-release python39 python39-pip python39-devel \
    && yum install -y wget \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && rm -rf /usr/share/locale/[a-d]*                 \
    && rm -rf /usr/share/locale/[f-z]*                 \
    && rm -rf /usr/share/locale/e[a-m]*                \
    && rm -rf /usr/share/locale/e[o-z]* \
    && groupadd -r weewx -g 1234               \
    && useradd -r -g weewx weewx -u 1234       \
    && mkdir -p /home/weewx/adds \
    && cd /home/weewx/adds\
    && wget -nv https://github.com/poblabs/weewx-belchertown/archive/refs/heads/master.zip -O belchertown.zip \
    && chown -R weewx:weewx /home/weewx \
    && chmod -R 755 /home/weewx 

# at this point you have a reusable starting point
# with the syslog additions in /tmp
# and a downloaded skin in /home/weewx/adds

#--- run the rest unprivileged ---
USER weewx

# install and configure weewx
#    create a default station then reconfigure with weectl
#       setting debug=1 can't be done via weectl
#       logging additions are needed due to no syslog in a docker image
#       and StdPrint is removed to stop LOOP from being logged to stdout
#
# note this installs an additional extension
# which is accessible at http://hostname:port/Belchertown
# in addition to the default Seasons skin at the top
# of the web doc root

RUN python3.9 -m venv /home/weewx/weewx-venv \
    && . /home/weewx/weewx-venv/bin/activate \
    && pip3.9 install weewx==5.0b15     \
    && weectl station create --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx-data/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx-data/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx-data/weewx.conf \
    && weectl extension install /home/weewx/adds/belchertown.zip \
    && weectl extension list

# test reconfigure
RUN /home/weewx/weewx-venv/bin/weectl station reconfigure --no-prompt \
  --location="pip3 testing rocky8"

#---- typical runtime system ---
FROM base as run
CMD /home/weewx/weewx-venv/bin/weewxd

#---- typical test system ---
FROM base as test
COPY test.sh /tmp
CMD ["bash", "/tmp/test.sh"]

