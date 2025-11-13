#!/bin/bash


### Example build script for OSU-Benchmarks - Accelerated, NVIDIA
### Downloads, configures, and builds OSU Micro-benchmarks 
### SOFTWARE REQUIREMENTS: PrgEnv-nvhpc, cuda, craype-accel-nvidia90


### Downloads latest version of OSU Micro-benchmarks
wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5-1.tar.gz


## Extracts OSU Micro-benchmarks into working directory

tar -xvzf osu-micro-benchmarks-7.5-1.tar.gz

### Removes tar 
rm osu-micro-benchmarks-7.5-1.tar.gz

### Switches into Micro-benchmark directory
cd osu-micro-benchmarks-7.5-1

### Configures Microbenchmark Installation - installs into 'osu-microbenchmarks-install' directory in parent directory
### We configure using mpicc from nvhpc
### Load craype-accel-nvidia90 to target the proper accelerator
### Make sure CUDA libraries are loaded

ml PrgEnv-nvhpc
ml craype-accel-nvidia90
ml cuda

./configure \
 --prefix=$PWD/../osu-microbenchmarks-install-accelerated \
 --enable-cuda \
 --with-cuda=$CUDA_HOME \
 CC=mpicc \
 CXX=mpicxx \
 LDFLAGS="-L/opt/cray/pe/mpich/8.1.28/gtl/lib -lmpi_gtl_cuda" \


### Makes package then installs into directory specified above
### Single-threaded, add -j option for multithreaded build/install
### Executables will be located in libexec folder in the mpi folder
make
make install 


### Switch out of Micro-benchmark directory
cd ..

### Copy accelerated executables into current working directory
cp osu-microbenchmarks-install-accelerated/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency $PWD/osu_latency_accelerated
cp osu-microbenchmarks-install-accelerated/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_mbw_mr $PWD/osu_mbw_mr_accelerated
cp osu-microbenchmarks-install-accelerated/libexec/osu-micro-benchmarks/mpi/collective/osu_allreduce $PWD/osu_allreduce_accelerated
cp osu-microbenchmarks-install-accelerated/libexec/osu-micro-benchmarks/mpi/collective/osu_alltoall $PWD/osu_alltoall_accelerated




