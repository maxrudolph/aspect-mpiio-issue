from ubuntu:bionic
MAINTAINER Max Rudolph <maxrudolph@ucdavis.edu>

# Set number of build threads here:
ENV BUILD_THREADS=24
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y upgrade
RUN apt-get -y install --no-install-recommends \
    sudo wget build-essential cmake subversion git \
    lsb-release \
    automake autoconf gfortran \
    libblas-dev liblapack-dev libblas3 liblapack3 \
    libsuitesparse-dev libtool libboost-all-dev \
    splint tcl tcl-dev environment-modules \
    libblas-dev liblapack-dev libblas3 liblapack3 \
    gfortran \
    openssh-server binutils \ 
    ca-certificates

# Ensure that openmpi is NOT installed
RUN apt-get -y remove openmpi-bin openmpi-common
RUN apt-get -y autoremove

# download, build, and install mpi WITHOUT MPI-IO
RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.2.tar.gz
RUN mkdir /build
WORKDIR /build
RUN tar -xzf /openmpi-4.0.2.tar.gz
WORKDIR /build/openmpi-4.0.2
RUN ./configure --prefix=/opt/openmpi-4.0.2 \
    --enable-mpi1-compatibility \
    --disable-io-romio \
    --disable-io-ompio
RUN make -j $BUILD_THREADS install
ENV PATH="/opt/openmpi-4.0.2/bin:${PATH}"

# download candi to install p4est, dealii, trilinos, hdf5
WORKDIR /build
RUN git clone https://github.com/dealii/candi.git
WORKDIR /build/candi
RUN CC=/opt/openmpi-4.0.2/bin/mpicc \
    CXX=/opt/openmpi-4.0.2/bin/mpic++ \
    ./candi.sh \
     --platform=deal.II-toolchain/platforms/supported/ubuntu18.platform \
     --prefix=/opt/dealii-toolchain \
     --packages="p4est trilinos dealii" \
     -j $BUILD_THREADS
     
# compile and install aspect
WORKDIR /build
RUN git clone https://github.com/geodynamics/aspect.git
WORKDIR /build/aspect
RUN mkdir build
WORKDIR /build/aspect/build
RUN cmake -D DEAL_II_DIR=/opt/dealii-toolchain/deal.II-v9.1.1 ..
RUN make debug
RUN make -j $BUILD_THREADS
RUN mkdir /aspect_run

# Quick last minute package changes:
RUN apt-get -y --no-install-recommends install nano 

RUN apt-get -y remove openssh-server
RUN apt-get -y --no-install-recommends install openssh-server
RUN mkdir /var/run/sshd

# Some of this is necessary to get sshd working, which in turn is needed for mpi
# Working passwordless rsh is required even if communicationi s via shared memory
EXPOSE 22/tcp

# Setup non-root user
RUN adduser --disabled-password --gecos '' aspect
RUN adduser aspect sudo; echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER aspect
# generate and trust a RSA key:
RUN ssh-keygen -q -t rsa -N '' -f /home/aspect/.ssh/id_rsa
RUN cat /home/aspect/.ssh/id_rsa.pub >> /home/aspect/.ssh/authorized_keys
# Trust localhost:
RUN ssh-keyscan -t rsa localhost >> /home/aspect/.ssh/known_hosts
ADD run_aspect.sh /home/aspect/run_aspect.sh

# Execute the script to run aspect
CMD [ "bash", "/home/aspect/run_aspect.sh"]]
