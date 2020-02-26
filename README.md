# aspect-mpiio-issue
Repository to reproduce mpi-io issue with aspect and deal.ii

The UC Davis peloton-II cluster has an MPI installation (OpenMPI 4.0.1) that was compiled without support for MPI-IO. The rationale for doing so is essentially that
1. MPI-IO output on NFS mounts may be incorrect due to file locking. See discussion here:

2. Even if the output is correct, performance will not be very good over NFS.

I do not disagree with either of these points necessarily. Ideally we should be able to compile aspect and its dependencies without MPI-IO support and run models with correct output.
We should also be able to use either VTU or hdf files for output
We should also be able to write checkpoint files and resume computations from them.

The docker container provided here starts from a Ubuntu image and adds:
 - openmpi-4.0.2 compiled without mpiio (--disable-ompio)
 - deal.ii (v9.1.1 was used) 
 - hdf5
 - trilinos

