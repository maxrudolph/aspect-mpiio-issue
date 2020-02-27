#!/bin/bash
set -x
WORKDIR=`pwd`

docker build -t mpiio . && \
docker run -v $PWD/aspect_run:/aspect_run \
       --shm-size=2g \
       --cap-add=SYS_ptrace \
	-i \
	-t mpiio
