#!/bin/bash

# user inputs
export DATA_DIR_PREFIX=${DATA_DIR_PREFIX:-"/scratch/$USER/deepcam_numpy_preprocessed14Jan26"} # path to preprocessed numpy-formatted data
export OUTPUT_DIR="/scratch/$USER/DeepCAM-testing/results/$SLURM_JOB_ID" # output directory for training logs

#### BASELINE/PORTED: CAN CHANGE THESE! ####
export STAGE_DIR_PREFIX=${STAGE_DIR_PREFIX:-""} # If this variable is missing, no data staging occurs.
export WIREUP_METHOD=${WIREUP_METHOD:-"nccl-slurm"}
export DGXNGPU=${DGXNGPU:-4} # Number of accelerators per node
export MAX_THREADS=${MAX_THREADS:-4} # Number of data loading threads per node
export LOCAL_BATCH_SIZE=${LOCAL_BATCH_SIZE:-16} # Per-accelerator batch size (`DGXNGPU`\*`NUMBER_OF_NODES`\*`LOCAL_BATCH_SIZE` must equal `128`
####

#### BASELINE/PORTED: DO NOT CHANGE THESE! ####
export LOGGING_FREQUENCY=${LOGGING_FREQUENCY:-0} # Must be set to 0 for 'Scenario 2'
export MAX_EPOCHS=${MAX_EPOCHS:-50} # Must be set to 50 for 'Scenario 2'
export START_LR=${START_LR:-0.001} # Starting learning rate. Roughly 10X lower than target end LR.
export LR_SCHEDULE_TYPE=${LR_SCHEDULE_TYPE:-"multistep"} # Learning rate scheduler type
export LR_WARMUP_STEPS=${LR_WARMUP_STEPS:-0} # Not necessary to set for 'Scenario 1'
export OPTIMIZER=${OPTIMIZER:-"MixedPrecisionLAMB"} # Learning rate optimizer
export WEIGHT_DECAY=${WEIGHT_DECAY:-0.01} # L2 regularization factor - 0.2 is good for AdamW, 0.01 good for LAMB
# These variables are only required if LR_SCHEDULE_TYPE="multistep":
if [[ $LR_SCHEDULE_TYPE == 'multistep' ]]; then
    export LR_MILESTONES=${LR_MILESTONES:-8192} # Default for global batch size 128
    export LR_DECAY_RATE="0.1"
fi
export LOCAL_VALIDATION_BATCH_SIZE=${LOCAL_VALIDATION_BATCH_SIZE:-$LOCAL_BATCH_SIZE} # Per-accelerator evaluation batch size (same as training size)
####

# common configuration settings
# note: CONFIG_DIR is set in run_and_time.sh
source ${CONFIG_DIR}/config_common.sh