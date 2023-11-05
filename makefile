# -*- makefile -*-
# targets that manage the installer test suite
# Copyright 2023 Vince Skahan, Matthew Wall

DOCKERHOST=localhost
# FIXME: do the weewx uid/gid have to match the uid/gid within docker?
WEEWX_UID=1234
WEEWX_GID=1234

CWD=$(shell pwd)
DOCKER_VERSION=$(shell docker --version)
PYTHON_VERSION=$(shell python -V)
PYTHON2_VERSION=$(shell python2 -V)
PYTHON3_VERSION=$(shell python3 -V)

all: help

help:
	@echo ""
	@echo "options include:"
	@echo "   info: display values for variables that affect these rules"
	@echo ""
	@echo "   up-CONFIG:    start the weewx/nginx pair"
	@echo "   down-CONFIG:  stop the weewx/nginx pair"
	@echo "   test-CONFIG:  test CONFIG and exit"
	@echo ""
	@echo "   for known configs:"
	@echo "    deb11pip"
	@echo "    rocky8pip"
	@echo "    rocky9pip"
	@echo "    leap15pip"
	@echo "    tweed15pip"
	@echo ""

info:
	@echo "     CWD: $(CWD)"
	@echo "    USER: $(USER)"
	@echo "  DOCKER: $(DOCKER_VERSION)"
	@echo "  PYTHON: $(PYTHON_VERSION)"
	@echo " PYTHON2: $(PYTHON2_VERSION)"
	@echo " PYTHON3: $(PYTHON3_VERSION)"

#---------------------------
#
# this uses docker-compose terminology
#  (up = bring up a config, down = tear down a config)
#
# generic target to up a docker configuration.  this requires the following:
#  DOCKER_CFG
#  DOCKER_TGT
#  DOCKER_PORT

# build the latest prod image
#    docker build --target build -t deb11pip:latest .
# build the latest test image
#    docker build --target test  -t deb11pip:test   .

#FIXME: passing in DOCKER_TGT seems to not work after DOCKER_CFT
#       but fortunately DOCKER_TGT seems redundant at this time
up-docker:
	mkdir -p /var/tmp/$(DOCKER_CFG)-archive
	mkdir -p /var/tmp/$(DOCKER_CFG)-html
	chmod -R 777 /var/tmp/$(DOCKER_CFG)-archive
	chmod -R 777 /var/tmp/$(DOCKER_CFG)-html
	echo "target is $(DOCKER_CFG):latest..."

	(cd $(DOCKER_CFG); \
  docker build -t $(DOCKER_TGT):latest --target=build . ; \
  docker-compose up -d)
	@echo "http://$(DOCKERHOST):$(DOCKER_PORT)/"

up-deb11pip:
	DOCKER_CFG=deb11pip DOCKER_TGT=deb11pip DOCKER_PORT=8701 make up-docker

up-rocky8pip:
	DOCKER_CFG=rocky8pip DOCKER_TGT=rocky8pip DOCKER_PORT=8801 make up-docker

up-rocky9pip:
	DOCKER_CFG=rocky9pip DOCKER_TGT=rocky9pip DOCKER_PORT=8901 make up-docker

up-leap15pip:
	DOCKER_CFG=leap15pip DOCKER_TGT=leap15pip DOCKER_PORT=9101 make up-docker

up-tweed15pip:
	DOCKER_CFG=tweed15pip DOCKER_TGT=tweed15pip DOCKER_PORT=9201 make up-docker

# FIXME: on a clean system this fails unless you do a test-all first
# FIXME: but then it actually starts the test image, not the prod image
up-all:
	@echo "starting all configs..."
	make up-deb11pip
	make up-rocky8pip
	make up-rocky9pip
	make up-leap15pip
	make up-tweed15pip

#--- similarly down the docker-compose pair ---
# we only need DOCKER_CFG for the stop action

down-docker:
	@echo "shutting down $(DOCKER_CFG)..."
	(cd $(DOCKER_CFG); \
  docker-compose down)

down-deb11pip:
	DOCKER_CFG=deb11pip make down-docker

down-rocky8pip:
	DOCKER_CFG=rocky8pip make down-docker

down-rocky9pip:
	DOCKER_CFG=rocky9pip make down-docker

down-leap15pip:
	DOCKER_CFG=leap15pip make down-docker

down-tweed15pip:
	DOCKER_CFG=tweed15pip make down-docker

down-all:
	@echo "shutting down all configs..."
	DOCKER_CFG=deb11pip make down-docker
	DOCKER_CFG=rocky8pip make down-docker
	DOCKER_CFG=rocky9pip  make down-docker
	DOCKER_CFG=leap15pip make down-docker
	DOCKER_CFG=tweed15pip make down-docker

#--- similarly test the weewx image ---

# build the test image
#    docker build --target test -t deb11pip:test .
test-docker:
	(cd $(DOCKER_CFG); \
  docker build -t $(DOCKER_CFG):test --target=test . ; \
  docker run -it --rm $(DOCKER_CFG):test \
    )

test-deb11pip:
	DOCKER_CFG=deb11pip DOCKER_TGT=deb11pip make test-docker

test-rocky8pip:
	DOCKER_CFG=rocky8pip DOCKER_TGT=rocky8pip make test-docker

test-rocky9pip:
	DOCKER_CFG=rocky9pip DOCKER_TGT=rocky9pip make test-docker

test-leap15pip:
	DOCKER_CFG=leap15pip DOCKER_TGT=leap15pip make test-docker

test-tweed15pip:
	DOCKER_CFG=tweed15pip DOCKER_TGT=tweed15pip make test-docker

test-all:
	@echo "testing all configs..."
	DOCKER_CFG=deb11pip make test-docker
	DOCKER_CFG=rocky8pip make test-docker
	DOCKER_CFG=rocky9pip  make test-docker
	DOCKER_CFG=leap15pip make test-docker
	DOCKER_CFG=tweed15pip make test-docker

#-------------------------------------------

###
### (cd deb11pip ; \
###     docker build -t deb11pip:test   --target=test  . ; \
###     docker build -t deb11pip:latest --target=build .  \
### )
###
### (cd rocky8pip ; \
###     docker build -t rocky8pip:test   --target=test  . ; \
###     docker build -t rocky8pip:latest --target=build . \
### )
###
### (cd rocky9pip ; \
###     docker build -t rocky9pip:test   --target=test  . ; \
###     docker build -t rocky9pip:latest --target=build . \
### )
###
### (cd leap15pip ; \
###     docker build -t leap15pip:test   --target=test  . ; \
###     docker build -t leap15pip:latest --target=build . \
### )
###
### (cd tweed15pip ; \
###     docker build -t tweed15pip:test   --target=test  . ; \
###     docker build -t tweed15pip:latest --target=build . \
### )
###
