#!/bin/bash -l
set -ex
module load cuda
#GCC 12 can't handle the default zen4 target so we use zen3
module load craype-x86-milan
git clone --depth=1 --shallow-submodules --branch v3.8.0 --recursive https://github.com/Exawind/amr-wind.git
export CXXFLAGS="-I${MPICH_DIR}/include -L${MPICH_DIR}/lib -lmpi ${PE_MPICH_GTL_DIR_nvidia90} ${PE_MPICH_GTL_LIBS_nvidia90}"
cmake -B amr-wind-build \
	-DAMR_WIND_ENABLE_MPI:BOOL=ON \
	-DAMR_WIND_ENABLE_CUDA:BOOL=ON \
	-DCMAKE_CUDA_ARCHITECTURES:STRING=90 \
	-DAMR_WIND_ENABLE_TESTS:BOOL=ON \
	-DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON \
	-DMPI_HOME:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3\
       	-DMPI_CXX_COMPILER:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3/bin/mpicxx \
	-DMPI_C_COMPILER:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3/bin/mpicc \
	-DCMAKE_CXX_COMPILER:STRING=CC \
	-DCMAKE_C_COMPILER:STRING=cc \
	amr-wind
nice cmake --build amr-wind-build --parallel 8
