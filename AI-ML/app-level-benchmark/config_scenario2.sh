#!/bin/bash

# user inputs
export DATA_DIR_PREFIX=${DATA_DIR_PREFIX:-"/scratch/$USER/deepcam_numpy_preprocessed14Jan26"} # path to preprocessed numpy-formatted data
export OUTPUT_DIR="/scratch/$USER/DeepCAM-testing/results/$SLURM_JOB_ID" # output directory for training logs

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
###### BASELINE/PORTED: Start of Variables that CAN be modified ######
export STAGE_DIR_PREFIX=${STAGE_DIR_PREFIX:-""} # If this variable is missing, no data staging occurs.
export WIREUP_METHOD=${WIREUP_METHOD:-"nccl-slurm"}
export DGXNGPU=${DGXNGPU:-4} # Number of accelerators per node
export MAX_THREADS=${MAX_THREADS:-4} # Number of data loading threads per node
export LOCAL_BATCH_SIZE=${LOCAL_BATCH_SIZE:-16} # Per-accelerator batch size (`DGXNGPU`\*`NUMBER_OF_NODES`\*`LOCAL_BATCH_SIZE` must equal `128`
export ADDITIONAL_ARGS="--disable_tuning --enable_graph --disable_comm_overlap" # additional DeepCAM arguments
####### BASELINE/PORTED: End of Variables that CAN be modified #######
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

#### BASELINE/PORTED: DO NOT CHANGE THESE! ####
export LOGGING_FREQUENCY=${LOGGING_FREQUENCY:-0} # Must be set to 0 for 'Scenario 2'
export MAX_EPOCHS=${MAX_EPOCHS:-50} # Must be set to 50 for 'Scenario 2'
####

# common configuration settings
# note: CONFIG_DIR is set in run_and_time.sh
source ${CONFIG_DIR}/config_common.sh