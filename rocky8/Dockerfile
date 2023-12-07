
#-------------------------------------------------------------------------
#
# rocky8 Dockerfile
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

FROM rockylinux:8.8 as base
MAINTAINER Vince Skahan "vinceskahan@gmail.com"

# we'll need this later for Docker to suppress needing syslog
COPY logging.additions /tmp/logging.additions

# need epel for v4 pkg cheetah and v5 python39, pip39 in derivative builds
# add wget just in case it's needed later
# and try to do a little docs for size
RUN yum install -y wget epel-release \
    && yum install -y python3-cheetah \
    && rm -rf /usr/share/doc  \
    && rm -rf /usr/share/man

#-------------------------------------------------------------
# install v5pip over the base image above
#-------------------------------------------------------------

FROM base as v5pip

# the os python 3.6.8 is too old for v5 so add 3.9
# need gcc for compiling CT3
# also set up weewx user/group/homedir
RUN yum install -y python39 python39-pip python39-devel python3-cheetah gcc \
    && groupadd -r weewx                 \
    && useradd -r -g weewx weewx         \
    && mkdir /home/weewx                 \
    && chown -R weewx:weewx /home/weewx  \
    && chmod -R 755 /home/weewx 

# install and configure weewx using an unprivileged user
#    setting debug=1 can't be done via weectl so use sed
#    StdPrint is removed to stop LOOP from being logged to stdout
#    append logging stanza so we don't look for syslogd at runtime
#

USER weewx
RUN python3.9 -m venv /home/weewx/weewx-venv \
    && . /home/weewx/weewx-venv/bin/activate \
    && pip3.9 install weewx==5.0b15     \
    && weectl station create --no-prompt \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /home/weewx/weewx-data/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /home/weewx/weewx-data/weewx.conf \
    && cat /tmp/logging.additions >> /home/weewx/weewx-data/weewx.conf

# do some cleanup as root for size
#
# note: deleting the rpm/dnf stuff will prevent use of rpm moving forward

USER root
RUN yum remove -y gcc 

# run the daemon unprivileged
#  - this will block you from running commands as root via bash interactively
USER weewx
CMD /home/weewx/weewx-venv/bin/weewxd

#---- additional example typical test scenario ---
FROM v5pip as v5pip-test
COPY test.py /tmp
CMD ["python3.9", "/tmp/test.py"]

#-------------------------------------------------------------
# install v4 pkg over the base image above
#-------------------------------------------------------------

FROM base as v4pkg

# alternately force it in one step
####RUN yum install -y http://weewx.com/downloads/released_versions/weewx-4.10.2-1.el8.noarch.rpm \

# install and configure weewx
#    python3-cheetah doesn't get brought in by the 4.10.2-1.el8 weewx rpm it seems
#    set debug=1
#    remove StdPrint so LOOP isn't sent to stdout
#    append logging stanza so we don't look for syslogd at runtime
RUN yum install -y python3-cheetah \
    && rpm --import https://weewx.com/keys.html \
    && curl -s https://weewx.com/yum/weewx-el8.repo | tee /etc/yum.repos.d/weewx.repo \
    && yum install -y weewx-4.10.2 \
    && sed -i -e s:debug\ =\ 0:debug\ =\ 1: /etc/weewx/weewx.conf \
    && sed -i -e s:weewx.engine.StdPrint,:: /etc/weewx/weewx.conf \
    && cat /tmp/logging.additions >> /etc/weewx/weewx.conf 

CMD weewxd

#-------------------------------------------------------------
# install v4 setup.py over the base image above
#-------------------------------------------------------------
# coming soon

FROM base as v4setup
RUN yum install -y python3 python3-pip python3-configobj python3-pillow python3-pyserial python3-pyusb gcc python3-devel \
    && pip3 install cheetah3 pyephem \
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

