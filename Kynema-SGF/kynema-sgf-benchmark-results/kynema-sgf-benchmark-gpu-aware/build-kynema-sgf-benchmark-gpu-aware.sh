#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30
#SBATCH --partition=gpu-h100s
#SBATCH --gpus-per-node=1
#SBATCH --ntasks-per-node=64
#SBATCH --mem=128GB

set -ex
module load cpe-stack
module load PrgEnv-gnu
module load cuda
#GCC 12 can't handle the default zen4 target so we use zen3
module load craype-x86-milan
git clone --depth=1 --shallow-submodules --recursive https://github.com/Kynema/kynema-sgf.git
export CXXFLAGS="-I${MPICH_DIR}/include -L${MPICH_DIR}/lib -lmpi ${PE_MPICH_GTL_DIR_nvidia90} ${PE_MPICH_GTL_LIBS_nvidia90}"
cmake -B kynema-sgf-build \
	-DKYNEMA_SGF_ENABLE_MPI:BOOL=ON \
	-DKYNEMA_SGF_ENABLE_CUDA:BOOL=ON \
	-DCMAKE_CUDA_ARCHITECTURES:STRING=90 \
	-DKYNEMA_SGF_ENABLE_TESTS:BOOL=ON \
	-DKYNEMA_SGF_ENABLE_TINY_PROFILE:BOOL=ON \
	-DMPI_HOME:STRING=/opt/cray/pe/mpich/8.1.32/ofi/gnu/11.2 \
       	-DMPI_CXX_COMPILER:STRING=/opt/cray/pe/mpich/8.1.32/ofi/gnu/11.2/bin/mpicxx \
	-DMPI_C_COMPILER:STRING=/opt/cray/pe/mpich/8.1.32/ofi/gnu/11.2/bin/mpicc \
	-DCMAKE_CXX_COMPILER:STRING=CC \
	-DCMAKE_C_COMPILER:STRING=cc \
	kynema-sgf
nice cmake --build kynema-sgf-build --parallel 8
