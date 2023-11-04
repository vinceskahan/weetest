
#---------------------------------------------------------------------------------------
#---- build and tag the testing target ----
#---------------------------------------------------------------------------------------

[vince@vinces-Mac-mini deb11pip (refactor *+)]$ docker build --target test -t deb11pip:testing .
[+] Building 0.5s (11/11) FINISHED                                                                                                                                                             docker:desktop-linux
 => [internal] load .dockerignore                                                                                                                                                                              0.0s
 => => transferring context: 2B                                                                                                                                                                                0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                                           0.0s
 => => transferring dockerfile: 3.93kB                                                                                                                                                                         0.0s
 => [internal] load metadata for docker.io/library/debian:11-slim                                                                                                                                              0.4s
 => [base 1/5] FROM docker.io/library/debian:11-slim@sha256:19664a5752dddba7f59bb460410a0e1887af346e21877fa7cec78bfd3cb77da5                                                                                   0.0s
 => [internal] load build context                                                                                                                                                                              0.0s
 => => transferring context: 280B                                                                                                                                                                              0.0s
 => CACHED [base 2/5] COPY logging.additions /tmp/logging.additions                                                                                                                                            0.0s
 => CACHED [base 3/5] RUN apt-get update                                      && apt-get install -y python3-pip python3-venv sqlite3 wget     && apt-get remove -y gcc                               && apt-g  0.0s
 => CACHED [base 4/5] RUN python3 -m venv /home/weewx/weewx-venv     && . /home/weewx/weewx-venv/bin/activate     && pip3 install weewx                 && weectl station create --no-prompt     && sed -i -e  0.0s
 => CACHED [base 5/5] RUN /home/weewx/weewx-venv/bin/weectl station reconfigure --no-prompt   --location="pip3 testing deb11"                                                                                  0.0s
 => [test 1/1] COPY test.sh /tmp                                                                                                                                                                               0.0s
 => exporting to image                                                                                                                                                                                         0.0s
 => => exporting layers                                                                                                                                                                                        0.0s
 => => writing image sha256:f46be2288d77a731d0e6fe590be860b6cae748f04878d66b4beb8bbf93cbc7f7                                                                                                                   0.0s
 => => naming to docker.io/library/deb11pip:testing                                                                                                                                                            0.0s

What's Next?
  1. Sign in to your Docker account → docker login
  2. View a summary of image vulnerabilities and recommendations → docker scout quickview

#---------------------------------------------------------------------------------------
#---- run the testing target, which runs a test script that outputs to stdout/stderr ---
#---------------------------------------------------------------------------------------


[vince@vinces-Mac-mini deb11pip (refactor *+)]$ docker run --rm deb11pip:testing
#----------------------
this is the test script
#----------------------
run test 1
run test 2
exiting 123 to test return status...

#---------------------------------------------------------------------------------------
#---- check the exit status of the test script matches---
#---------------------------------------------------------------------------------------

[vince@vinces-Mac-mini deb11pip (refactor *+)]$ echo $?
123

