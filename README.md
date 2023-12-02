
## weewx v5 testing via docker

Each of the subdirectories here are for building variants
to test weewx with.   See the README in each for details,
as each is in a varying state of automation/quality/completeness.

Each pip image uses a non-privileged weewx:weewx user
with uid=1234 and gid=1234 for reuse in these configurations

Webserver ports in docker-compose files:
* deb11pip:     - "8701:80"
* deb12pip:     - "9301:80"
* rocky8pip:    - "8801:80"
* rocky8pkg:    - "8811:80"
* rocky9pip:    - "8901:80"
* leap15.4pip:  - "9101:80"
* tweed15.4pip: - "9201:80"

Possible operations (examples):
*   make up-deb11pip - bring one weewx/nginx pair up in docker-compose
*   make down-deb11pip - and tear it down in an orderly manner
*   make test-deb11pip - run its test script and exit
*   make up-all - bring up 'all' known config weewx/nginx pairs
*   make down-all - and tear any running weewx/nginx pairs down
*   make test-all - test all known configs

Run 'make' for current full syntax...

