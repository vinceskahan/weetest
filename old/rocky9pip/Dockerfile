#-----------------------------------------------
# Build into an image ala:
#    docker build -t somename:latest .
#
# To run a shell to log into a container running
# this image:
#    docker run --rm -it somename:latest bash
#-----------------------------------------------

FROM rockylinux:9.2 as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker logging
COPY logging.additions /tmp/logging.additions

RUN yum install -y epel-release python3-pip \
    && yum install -y python3 wget python3-devel gcc \
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
#--- this would be the install steps

USER weewx

#(future)
#for f in /home/weewx/adds/*.zip
#do
	#weectl extension install ${f}
    #### a test might be to run 'weectl extension list' and look for it
#done

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

RUN python3 -m venv /home/weewx/weewx-venv \
    && . /home/weewx/weewx-venv/bin/activate \
    && pip3 install weewx==5.0b15             \
    && weectl station create --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx-data/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx-data/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx-data/weewx.conf \
    && weectl extension install /home/weewx/adds/belchertown.zip \
    && weectl extension list

# test reconfigure
RUN /home/weewx/weewx-venv/bin/weectl station reconfigure --no-prompt \
  --location="pip3 testing rocky9"

#---- or build the production image
# docker build -t deb11pip:latest .
FROM base as run
CMD /home/weewx/weewx-venv/bin/weewxd


#----- run the test suite after copying it into place ---
# docker build --target test -t deb11pip:testing .
# docker run --rm deb11pip:testing
# echo $? for exit status of the container's test script
#
# (then examine the test script output)
FROM base as test
COPY test.sh /tmp
CMD ["bash", "/tmp/test.sh"]
