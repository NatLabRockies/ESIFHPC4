#!/bin/bash

# Create DeepCAM environment

# Load PyTorch module
module --ignore_cache load "pytorch/2.12"

# Create venv that inherits from PyTorch module packages
DEEPCAM_ENV_NAME="${DEEPCAM_ENV_NAME:-./deepcam-env}"
python -m venv ${DEEPCAM_ENV_NAME} --system-site-packages
source ${DEEPCAM_ENV_NAME}/bin/activate
echo "Using Python: $(which python)"

# Install DeepCAM dependencies
echo "h5py
basemap
wandb
sympy
filelock
fsspec
jinja2
networkx
mlperf-logging
git+https://github.com/NVIDIA/mlperf-common.git
nvidia-ml-py
" > deepcam-requirements.txt
pip install -r deepcam-requirements.txt

# Install dali/cupy versions based on detected cuda version
CUDA_VERSION=$(nvidia-smi --version | grep "CUDA Version" | sed "s|.*: ||" | sed "s|\.[0-9]||")
if [ $CUDA_VERSION == '12' ]; then
    CUDA_SUFF=cuda120
elif [ $CUDA_VERSION == '13' ]; then
    CUDA_SUFF=cuda130
fi
# CuPy
pip install cupy-cuda${CUDA_VERSION}x
# DALI - optional
pip install --extra-index-url https://pypi.nvidia.com --upgrade nvidia-dali-${CUDA_SUFF}

# install IO Helpers package
PARENT_FOLDER=$(pwd)
cd deepcam-mlcommons-hpcv3/io_helpers
python setup.py clean
python setup.py install
cd $PARENT_FOLDER

# APEX is required for LAMB optimizer
if [ ! -d apex ]; then
     git clone https://github.com/NVIDIA/apex
fi
cd apex
MAX_JOBS=$SLURM_CPUS_ON_NODE APEX_CPP_EXT=1 APEX_CUDA_EXT=1 pip install -v --no-cache-dir --no-build-isolation --disable-pip-version-check .