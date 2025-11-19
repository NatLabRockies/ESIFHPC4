#!/bin/bash

### run on Kestrel CPU-compute node
### adjust pathnames as needed

module load cray-hdf5-parallel

git clone https://github.com/hpc/ior.git <path-to-ior-repo>
cd <path-to-ior-repo>
git fetch --tags
git tag -l
git checkout tags/3.3.0 -b ior-3.3.0

# Generate the configure script
./bootstrap
# Create a separate directory for the build
mkdir build && cd build

# Configure the build. Adjust the --prefix path as needed.
../configure CC=cc MPICC=cc --with-mpiio --with-hdf5 --with-lustre --prefix=<path-to-ior-installation-directory>

# Compile the source code
make

# Install the binaries to the specified location
make install

################## quick install tests

# ### with output to json
# srun -n 104 <path-to-ior-installation-directory>/bin/ior -O summaryFile=summary.json -O summaryFormat=JSON -f <path-to-ESIFHPC4-repo>/IOR/IOR-tests/test1_nn_mpi_io.ior 

# ### with output to stdout
# srun -n 104 <path-to-ior-installation-directory>/bin/ior -f <path-to-ESIFHPC4-repo>/IOR/IOR-tests/test1_nn_mpi_io.ior 