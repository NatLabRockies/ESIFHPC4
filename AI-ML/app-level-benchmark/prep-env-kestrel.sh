#!/bin/bash
#SBATCH -A esifapps
#SBATCH -J compile-torch
#SBATCH -t 01:00:00
#SBATCH -p debug
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=80G
#SBATCH --gres=gpu:1
#SBATCH -o %x-%j.out 

### DeepCAM environment installation ###

# Create PyTorch environment in DeepCAM-testing folder
DEEPCAM_WORK_DIR=/scratch/$USER/DeepCAM-testing
mkdir -p $DEEPCAM_WORK_DIR
cd $DEEPCAM_WORK_DIR
TORCH_VERSION='2.7.0'
ENV_NAME=`pwd`/deepcam-torch${TORCH_VERSION}-reference-env


# Load modules and create base Python env
module load mamba nccl/2.21.5_cuda124 cudnn gcc-native/12.1 openmpi/4.1.6-gcc # good for 2.7.0 torch
PYTHON_VERSION=3.12
mamba create -y \
    --prefix $ENV_NAME \
    python=$PYTHON_VERSION
eval "$(conda shell.bash hook)" && conda activate $ENV_NAME

# install mpi4py
mpicc=`which mpicc` pip install mpi4py --no-cache-dir

# Clone PyTorch source code and install packages into Python env
if [ ! -d pytorch ]; then
    git clone --branch v${TORCH_VERSION} https://github.com/pytorch/pytorch.git
fi
cd pytorch
pip install -r requirements.txt
# workaround for import error
echo "import numpy; numpy.version.version" > ${CONDA_PREFIX}/lib/python${PYTHON_VERSION}/site-packages/00-preload-numpy.pth


# Set PyTorch compiliation variables
export CC=$(which gcc)
export CXX=$(which g++)
export MPICH_GPU_SUPPORT_ENABLED=1
export USE_CUDA=1
export CUDA_INCLUDE_DIRS=$CUDA_HOME/include
export USE_CUDNN=1
export USE_CUSPARSELT=1
export USE_XNNPACK=0
export USE_PYTORCH_QNNPACK=0
export USE_MPI=1
export USE_DISTRIBUTED=1
export TORCH_CUDA_ARCH_LIST=9.0
export CFLAGS="-Wno-error=maybe-uninitialized -Wno-error=uninitialized" 
export CXXFLAGS=$CFLAGS
export CPPFLAGS=$CXXFLAGS

# Configure and compile PyTorch against Kestrel's NCCL module
python setup.py clean

NCCL_ROOT_DIR=$NCCL_HOME \
NCCL_LIBRARIES=$NCCL_HOME/lib:$NCCL_HOME/plugin/lib \
NCCL_INCLUDE_DIRS=$NCCL_HOME/include \
USE_SYSTEM_NCCL=1 \
TORCH_C_FLAGS=$CFLAGS \
TORCH_CXX_FLAGS=$CXXFLAGS \
CMAKE_POLICY_VERSION_MINIMUM=3.5 \
MAX_JOBS=20 python setup.py install | tee pytorch-install.log

# Optional: install conda-pack to export and share environment with others on Kestrel
#mamba install conda-pack -y
#conda-pack -p $ENV_NAME -o deepcam-env.tar --ignore-missing-files

# if [ ! -d hpc ]; then
#     git clone git@github.com:mlcommons/hpc.git
# fi

##### DeepCAM dependencies #####
cd $DEEPCAM_WORK_DIR
echo "
apex
h5py
warmup-scheduler @ git+https://github.com/ildoonet/pytorch-gradual-warmup-lr
mlperf-logging @ git+https://github.com/mlperf/logging.git
" > deepcam-ref-requirements.txt
pip install -r deepcam-ref-requirements.txt
