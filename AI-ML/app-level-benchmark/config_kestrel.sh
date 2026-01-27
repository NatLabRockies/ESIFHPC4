#!/bin/bash

# user inputs
export DATA_DIR_PREFIX="/scratch/$USER/deepcam/numpy" # path to preprocessed numpy-formatted data
export OUTPUT_DIR="/scratch/$USER/DeepCAM-testing/results/$SLURM_JOB_ID" # output directory for training logs

# system parameters
export DGXNGPU=4            # CAN CHANGE FOR BASELINE: Number of accelerators per node 
export DGXSYSTEM=$(basename $(readlink -f ${BASH_SOURCE[0]}) | sed 's/^config_//' | sed 's/\.sh$//' )
export BASE_COMP_CLOCK=1980 # for logging purposes only - obtained via nvidia-smi for SXM H100 HBM3
export BASE_MEM_CLOCK=2619  # for logging purposes only - obtained via nvidia-smi for SXM H100 HBM3

# hyperparameters
export WIREUP_METHOD="nccl-slurm" # CAN CHANGE FOR BASELINE
export LOCAL_BATCH_SIZE=8
export START_LR=0.001
export OPTIMIZER="MixedPrecisionLAMB"
export LR_SCHEDULE_TYPE="cosine_annealing"
export LR_T_MAX=9000
export LR_ETA_MIN=0.0
export LR_WARMUP_STEPS=0
export LR_WARMUP_FACTOR=1.
export WEIGHT_DECAY=0.2
export BATCHNORM_GROUP_SIZE=1
export TRAINING_INSTANCE_SIZE=$(( $SLURM_GPUS_ON_NODE * $SLURM_NNODES ))

# data parameters
export SHUFFLE_MODE="global"
export DATA_FORMAT="dali-numpy"
export PRECISION_MODE="amp"
export LOCAL_VALIDATION_BATCH_SIZE=8

# staging parameter
export STAGE_DIR_PREFIX= # CAN CHANGE FOR BASELINE
export STAGE_BATCH_SIZE=8
export STAGE_MODE="global"
export STAGE_VERIFY=0
export STAGE_FULL_DATA_PER_NODE=0
export STAGE_USE_DIRECT_IO=0
#export STAGE_USE_DIRECT_IO=1 # note: this leads to a segfault on Kestrel
export STAGE_NUM_READ_WORKERS=2
export STAGE_NUM_WRITE_WORKERS=8

# misc args
export ADDITIONAL_SRUN_ARGS="--no-kill"
export ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --enable_graph --disable_comm_overlap"

# this should never be exceeded by any benchmark
export MAX_EPOCHS=50

# this is for some global parameters:
export ADDITIONAL_ARGS="--disable_tuning"

# auxiliary parameters
export LOGGING_FREQUENCY=0

# direct io settings
export DALI_ODIRECT_ALIGNMENT=4096
export DALI_ODIRECT_LEN_ALIGNMENT=4096

# run parameters
export NEXP="${NEXP:-10}"

# number of experiments
export NEXP=1
export NUM_INSTANCES=256

# system parameters
export DGXNNODES=$SLURM_NNODES
export WALLTIME=01:00:00

# final things
if [ ! -z $STAGE_DIR_PREFIX ]; then
    mkdir -p $STAGE_DIR_PREFIX
fi
