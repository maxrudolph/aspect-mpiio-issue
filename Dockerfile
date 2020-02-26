from ubuntu:bionic
MAINTAINER Max Rudolph <maxrudolph@ucdavis.edu>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y upgrade
RUN apt-get -y install sudo wget build-essential cmake subversion git \
    lsb-release \
    automake autoconf gfortran \
    libblas-dev liblapack-dev libblas3 liblapack3 \
    libsuitesparse-dev libtool libboost-all-dev \
    splint tcl tcl-dev environment-modules

RUN apt-get -y install libblas-dev liblapack-dev libblas3 liblapack3
RUN apt-get -y install gfortran
RUN apt-get -y remove openmpi-bin openmpi-common

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
RUN make -j 16 install
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
     --packages="hdf5 p4est trilinos dealii" \
     -j 16
     
# compile and install aspect
WORKDIR /build
RUN git clone https://github.com/geodynamics/aspect.git
WORKDIR /build/aspect
RUN mkdir build
WORKDIR /build/aspect/build
RUN cmake -D DEAL_II_DIR=/opt/dealii-toolchain/deal.II-v9.1.1 ..
RUN make debug
RUN make -j 16
RUN mkdir /aspect_run
RUN useradd -ms /bin/bash aspect

RUN sudo apt-get install -y openssh-server binutils
RUN sudo /etc/init.d/ssh start
EXPOSE 22/tcp