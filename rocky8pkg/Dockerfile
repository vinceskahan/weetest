
#----------------------------------------------------
# note: yum commands have to run as root
# so we do not use 'USER weewx' below
#----------------------------------------------------

FROM rockylinux:8 as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker logging
COPY logging.additions /tmp/logging.additions

RUN yum install -y wget epel-release \
    && yum install -y python39 python39-pip python39-devel \
    && rm -rf /usr/share/doc                           \
    && rm -rf /usr/share/man                           \
    && rm -rf /usr/share/locale/[a-d]*                 \
    && rm -rf /usr/share/locale/[f-z]*                 \
    && rm -rf /usr/share/locale/e[a-m]*                \
    && rm -rf /usr/share/locale/e[o-z]*                \
    && python3.9 -m pip install --upgrade pip          \
    && python3.9 -m venv /home/weetest/weetest-venv    \
    && . /home/weetest/weetest-venv/bin/activate       \
    && pip3.9 install pytest

# remove StdPrint so LOOP isn't sent to stdout
FROM base as v4rpm
RUN yum install -y http://weewx.com/downloads/released_versions/weewx-4.10.2-1.el8.noarch.rpm \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /etc/weewx/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /etc/weewx/weewx.conf \
    && cat /tmp/logging.additions >> /etc/weewx/weewx.conf 

# this runs weewxd
FROM v4rpm  as run
CMD /usr/bin/weewxd

# run a mounted unittest script from the weetest-venv
FROM v4rpm as test
CMD ["/home/weetest/weetest-venv/bin/python3", "/home/weetest/tests/test.py"]

