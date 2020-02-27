# aspect-mpiio-issue
Repository to reproduce mpi-io issue with aspect and deal.ii

The UC Davis peloton-II cluster has an MPI installation (OpenMPI 4.0.1) that was compiled without support for MPI-IO. The rationale for doing so is essentially that
1. MPI-IO output on NFS mounts may be incorrect due to file locking. See discussion here:

2. Even if the output is correct, performance will not be very good over NFS.

These points are well-taken. However, we should be able to run aspect on this system and other University clusters that are similarly condigured with NFS storage for scratch space.


To run the testcase, simply execute:
```./run_example.sh```
This will automatically build a docker image with the correct OpenMPI. If the build is successful, we will run aspect in the docker container. An error will be produced when aspect attempts to write visualization output.
 - Aspect output will appear in ./aspect_run/output-shell_simple_3d
 - The screen output from the run will be stored in ./screen-output

The docker container provided here starts from a Ubuntu (18) image and adds:
 - openmpi-4.0.2 compiled without mpiio (--disable-ompio) and without romio (--disable-romio)
 - deal.ii (v9.1.1 was used) 
 - hdf5
 - trilinos

The container was successfully tested on a workstation running ubuntu 18.04 and Docker version 19.03.5, build 633a0ea838.

