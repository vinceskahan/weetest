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
up-docker:
	mkdir -p /var/tmp/$(DOCKER_CFG)-archive
	mkdir -p /var/tmp/$(DOCKER_CFG)-html
	chmod -R 777 /var/tmp/$(DOCKER_CFG)-archive
	chmod -R 777 /var/tmp/$(DOCKER_CFG)-html
	(cd $(DOCKER_CFG); \
  docker build -t $(DOCKER_TGT):latest .; \
  docker-compose up -d)
	@echo "http://$(DOCKERHOST):$(DOCKER_PORT)/"

up-deb11pip:
	DOCKER_CFG=deb11pip DOCKER_TGT=debian11 DOCKER_PORT=8701 make up-docker

up-rocky8pip:
	DOCKER_CFG=rocky8pip DOCKER_TGT=rocky8 DOCKER_PORT=8801 make up-docker

up-rocky9pip:
	DOCKER_CFG=rocky9pip DOCKER_TGT=rocky9 DOCKER_PORT=8901 make up-docker

up-leap15pip:
	DOCKER_CFG=leap15pip DOCKER_TGT=leap15 DOCKER_PORT=9101 make up-docker

up-tweed15pip:
	DOCKER_CFG=tweed15pip DOCKER_TGT=tweed15 DOCKER_PORT=9201 make up-docker

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

#--- similarly test the weewx image ---
# we only need DOCKER_CFG for the stop action

test-all:
	@echo "testing all configs..."
	DOCKER_CFG=deb11pip make test-docker
	DOCKER_CFG=rocky8pip make test-docker
	DOCKER_CFG=rocky9pip  make test-docker
	DOCKER_CFG=leap15pip make test-docker
	DOCKER_CFG=tweed15pip make test-docker
    
test-docker:
	@echo "testing $(DOCKER_CFG)..."
	(cd $(DOCKER_CFG); \
  docker build --target=test -t $(DOCKER_CFG):testing .; \
  docker run --rm -it $(DOCKER_CFG):testing)

test-deb11pip:
	DOCKER_CFG=deb11pip make test-docker

test-rocky8pip:
	DOCKER_CFG=rocky8pip make test-docker

test-rocky9pip:
	DOCKER_CFG=rocky9pip make test-docker

test-leap15pip:
	DOCKER_CFG=leap15pip make test-docker

test-tweed15pip:
	DOCKER_CFG=tweed15pip make test-docker

#-------------------------------------------
