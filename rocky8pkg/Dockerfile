#-----------------------------------------------
# Build into an image ala:
#    docker build -t somename:latest .
#
# To run a shell to log into a container running
# this image:
#    docker run --rm -it somename:latest bash
#-----------------------------------------------

FROM rockylinux:8 as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker logging
COPY logging.additions /tmp/logging.additions

RUN yum install -y epel-release python3-pip \
    && yum install -y python3 wget python3-cheetah     \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && rm -rf /usr/share/locale/[a-d]*                 \
    && rm -rf /usr/share/locale/[f-z]*                 \
    && rm -rf /usr/share/locale/e[a-m]*                \
    && rm -rf /usr/share/locale/e[o-z]* 

RUN yum install -y http://weewx.com/downloads/released_versions/weewx-4.10.2-1.el8.noarch.rpm \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /etc/weewx/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /etc/weewx/weewx.conf \
    && cat /tmp/logging.additions >> /etc/weewx/weewx.conf 


#---- or build the production image
# docker build -t rocky8pkg:latest .
FROM base as run
CMD /usr/bin/weewxd

#----- run the test suite after copying it into place ---
# docker build --target test -t rocky8pkg:testing .
# docker run --rm rocky8pkg:testing
# echo $? for exit status of the container's test script
#
# (then examine the test script output)
FROM base as test
COPY test.sh /tmp
CMD ["bash", "/tmp/test.sh"]
