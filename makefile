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
	@echo "options include:"
	@echo "   info: display values for variables that affect these rules"
	@echo ""
	@echo "  deb11pip: run the debian 11 pip installer tests"
	@echo " rocky8pip: run the rocky 8 pip installer tests"

info:
	@echo "     CWD: $(CWD)"
	@echo "    USER: $(USER)"
	@echo "  DOCKER: $(DOCKER_VERSION)"
	@echo "  PYTHON: $(PYTHON_VERSION)"
	@echo " PYTHON2: $(PYTHON2_VERSION)"
	@echo " PYTHON3: $(PYTHON3_VERSION)"

# generic target to run a docker installer test.  this requires the following:
#  DOCKER_CFG
#  DOCKER_TGT
#  DOCKER_PORT
test-docker:
	mkdir -p /mnt/$(DOCKER_CFG)-archive
	mkdir -p /mnt/$(DOCKER_CFG)-html
	chown -R $(WEEWX_UID).$(WEEWX_GID) /mnt/$(DOCKER_CFG)-archive
	chown -R $(WEEWX_UID).$(WEEWX_GID) /mnt/$(DOCKER_CFG)-html
	(cd deb11pip; \
  docker build -t $(DOCKER_TGT):test .; \
  docker-compose up -d)
	@echo "http://$(DOCKERHOST):$(DOCKER_PORT)/"

test-deb11pip:
	DOCKER_CFG=deb11pip DOCKER_TGT=debian11 DOCKER_PORT=8701 make test-docker

test-rocky8pip:
	DOCKER_CFG=rocky8pip DOCKER_TGT=rocky8 DOCKER_PORT=8801 make test-docker
