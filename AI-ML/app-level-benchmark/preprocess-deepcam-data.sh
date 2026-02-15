#!/bin/bash
#SBATCH -A hpcapps
#SBATCH -J preprocess-deepcam-data
#SBATCH -t 01:00:00
#SBATCH -p shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH -c 1
#SBATCH --mem-per-cpu=2G
#SBATCH -o %x-%j.out 

# create small local environment for data preprocessing
ml mamba
eval "$(conda shell.bash hook)"
ENV_NAME=`pwd`/preprocess-env
if [ ! -d $ENV_NAME ]; then
    PYTHON_VERSION=3.12
    mamba create -y \
        --prefix $ENV_NAME \
        python=$PYTHON_VERSION mpi4py h5py
    conda activate $ENV_NAME
else
    conda activate $ENV_NAME
fi

# Convert data from HDF5 to numpy format
DATA_IN=/projects/hpcapps/mselensk/deepcam/All-Hist/
DATA_OUT=/projects/hpcapps/mselensk/deepcam/numpy
NUM_TASKS=$SLURM_NTASKS

# source code
cd deepcam-mlcommons-hpcv3
mkdir -p $DATA_OUT
cp ${DATA_IN}/stats.h5 ${DATA_OUT}/
mpirun -np ${NUM_TASKS} python src/utils/convert_hdf52npy.py --input_directory=${DATA_IN}/train      --output_directory=${DATA_OUT}/train
mpirun -np ${NUM_TASKS} python src/utils/convert_hdf52npy.py --input_directory=${DATA_IN}/validation --output_directory=${DATA_OUT}/validation
