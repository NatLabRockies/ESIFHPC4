#!/bin/bash
#SBATCH -p gpu-h100
#SBATCH -A esifapps
#SBATCH -t 00:15:00
#SBATCH -N 1
#SBATCH -n 32
#SBATCH --mem-per-cpu=2G
#SBATCH --gpus=1
#SBATCH -o nccl-build-%j.out

set -e

# Set version of NCCL (with format vX.XX.X-X; if this is not set then
# default = v2.27.7-1)
NCCL_VERSION=$1
# Set version of NCCL OFI plugin from AWS (with format vX.XX.X; if this is 
# not set then default = v1.16.0)
OFI_PLUGIN_VERSION=$2

export NCCL_VERSION=${NCCL_VERSION:-"v2.27.7-1"}
export OFI_PLUGIN_VERSION=${OFI_PLUGIN_VERSION:-"v1.19.0"}

echo "Building NCCL version $NCCL_VERSION with aws-ofi-nccl version $OFI_PLUGIN_VERSION"

# Load dependencies
GCC_VERSION=14.2.0
CUDA_VERSION=13.2
LIBFABRIC_VERSION="shs-12.0.2"
ml gcc/$GCC_VERSION cuda/$CUDA_VERSION
ml shs-libfabric/${LIBFABRIC_VERSION} # enables GDRCopy support. sets LIBFABRIC_HOME
# hwloc is only needed for newer versions of the AWS OFI plugin
ml hwloc

# Installation folder
software_dir=/nopt/nlr/apps/kestrel-gpu/software
SOFTWARE_NAME=nccl
export INSTALL_DIR="$software_dir/${SOFTWARE_NAME}/shs-libfabric/cuda-${CUDA_VERSION}/${NCCL_VERSION}"
mkdir -p $INSTALL_DIR

# remove old repos that may exist
if [ ! -d nccl-build ]; then
    mkdir -p nccl-build
fi
cd nccl-build
rm -rf *

# POSIX-compliant method (may require 'readlink -f' or similar on some systems)
echo "Install directory: ${INSTALL_DIR}"
export PLUGIN_DIR=$INSTALL_DIR/plugin
export NCCL_HOME=$INSTALL_DIR

# Kestrel uses H100s. Therefore, we need to target the compute_90/sm_90 NVCC_GENCODE
# export MPICH_GPU_SUPPORT_ENABLED=0
export NVCC_GENCODE="-gencode=arch=compute_90,code=sm_90"
export CRAY_CPU_TARGET=x86-64 
export N=$SLURM_CPUS_ON_NODE

echo ========== BUILDING NCCL ==========
if [ ! -e nccl ]; then
    git clone --branch $NCCL_VERSION https://github.com/NVIDIA/nccl.git
    cd nccl
    make -j $N PREFIX=$NCCL_HOME src.build
    make -j $N PREFIX=$NCCL_HOME build
    make PREFIX=$NCCL_HOME install
    cd ..
else
    echo Skipping ... nccl directory already exists
fi

echo ========== BUILDING OFI PLUGIN ==========
if [ ! -e aws-ofi-nccl ]; then
    git clone -b $OFI_PLUGIN_VERSION https://github.com/aws/aws-ofi-nccl.git
    cd aws-ofi-nccl
    ./autogen.sh
    ./configure --with-cuda=$CUDA_HOME --with-libfabric=$LIBFABRIC_HOME --prefix=$PLUGIN_DIR --with-hwloc=$NREL_HWLOC_ROOT --disable-tests
    make -j $N install
    cd ..
else
    echo Skipping ... aws-ofi-nccl directory already exists
fi

echo ========== BUILDING NCCL TESTS ==========
if [ ! -e nccl-tests ]; then
    git clone https://github.com/NVIDIA/nccl-tests.git
    cd nccl-tests
    make -j $N MPI=1 CC=cc CXX=CC
    cd ..
else
    echo Skipping ... nccl-tests directory already exists
fi

echo
echo ========== DONE ==========
echo
echo "NCCL is installed in $NCCL_HOME"
echo "NCCL tests are installed in `pwd`/nccl-tests/build"
echo