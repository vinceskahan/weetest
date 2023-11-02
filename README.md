
## weewx v5 testing via docker

Each of the subdirectories here are for building variants
to test weewx with.   See the README in each for details,
as each is in a varying state of automation/quality/completeness.

Each pip image uses a non-privileged weewx:weewx user
with uid=1234 and gid=1234 for reuse in these configurations

Webserver ports in docker-compose files:
* deb11pip:  - "8701:80"
* rocky8pip: - "8801:80"
* rocky9pip: - "8901:80"
* leap15.4pip: - "9101:80"

