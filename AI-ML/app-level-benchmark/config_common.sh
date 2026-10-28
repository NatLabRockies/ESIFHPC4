#!/bin/bash

# These are common variables for each training scenario. This file should generally not need to be modified,
# except under certain circumstances such as modifying SLURM_* and/or SRUN_* variables if a non-Slurm scheduler is used.

# +++++++++++++++++++++++++++++++++++++++++++++++++ #
####### Start of Variables that CAN be modified #####
# data staging
export STAGE_BATCH_SIZE=${STAGE_BATCH_SIZE:-$LOCAL_BATCH_SIZE} # Per-accelerator data staging batch size (same as training size by default)
export STAGE_MODE="global"
export STAGE_VERIFY=0
export STAGE_FULL_DATA_PER_NODE=0 
export STAGE_USE_DIRECT_IO=0 # note: leads to a segfault on Kestrel when =1
export STAGE_NUM_READ_WORKERS=6    
export STAGE_NUM_WRITE_WORKERS=12 
# scheduler arguments
export ADDITIONAL_SRUN_ARGS="--no-kill"
# data parameters
export DATA_FORMAT=${DATA_FORMAT:-"dali-numpy"} # this can be modified as part of a 'ported' submission
####### End of Variables that CAN be modified #######
# +++++++++++++++++++++++++++++++++++++++++++++++++ #

# create output directory
mkdir -p ${OUTPUT_DIR}

# other learning rate hyperparameters
export LR_T_MAX=9000
export LR_ETA_MIN=0.0
export LR_WARMUP_FACTOR=1.

# immutable data parameters
export SHUFFLE_MODE="global"
export PRECISION_MODE=${PRECISION_MODE:-"amp"}

# staging parameters
if [ ! -z $STAGE_DIR_PREFIX ]; then
  mkdir -p $STAGE_DIR_PREFIX
fi

# this is for some global parameters:
export ADDITIONAL_ARGS="--disable_tuning --enable_graph --disable_comm_overlap"

# direct io settings
export DALI_ODIRECT_ALIGNMENT=4096
export DALI_ODIRECT_LEN_ALIGNMENT=4096

# run parameters
export RUN_TAG=${RUN_TAG:-${SLURM_JOB_ID}}
export ENABLE_IB_BINDING=0

# system parameters
export DGXNNODES=$SLURM_NNODES
export TOTALGPUS=$(( ${DGXNNODES} * ${DGXNGPU} ))
export WALLTIME=01:00:00

# system parameters (optional, not necessary to modify)
export DGXSYSTEM=$(basename $(readlink -f ${BASH_SOURCE[0]}) | sed 's/^config_//' | sed 's/\.sh$//' )
export BASE_COMP_CLOCK=1980 # obtained via nvidia-smi for SXM H100 HBM3
export BASE_MEM_CLOCK=2619  # obtained via nvidia-smi for SXM H100 HBM3

# DO NOT MODIFY THESE VARIABLES - Placeholders
export TRAINING_INSTANCE_SIZE=${TOTALGPUS} # Must equal number of GPUs to use during training
export BATCHNORM_GROUP_SIZE=1
export NEXP=1
export NUM_INSTANCES=1
export gpu_config=${TOTALGPUS}

##### DO NOT MODIFY THESE VARIABLES - parameters for run script based on values set above #####
# LR switch
if [ -z ${LR_SCHEDULE_TYPE} ]; then
    lr_schedule_arg=""
elif [ "${LR_SCHEDULE_TYPE}" == "multistep" ]; then
    lr_schedule_arg="--lr_schedule type=${LR_SCHEDULE_TYPE},milestones=${LR_MILESTONES},decay_rate=${LR_DECAY_RATE}"
elif [ "${LR_SCHEDULE_TYPE}" == "cosine_annealing" ]; then
    lr_schedule_arg="--lr_schedule type=${LR_SCHEDULE_TYPE},t_max=${LR_T_MAX},eta_min=${LR_ETA_MIN}"
fi

# GDS switch
if [ "${ENABLE_GDS}" == "1" ]; then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --enable_gds"
fi

# ignore stop switch
if [ "${MLPERF_POWER_TRAIN_AFTER_RUN_STOP}" == "1" ]; then
    MIN_EPOCHS=${MAX_EPOCHS}
fi

PARAMS=(
    --wireup_method ${WIREUP_METHOD}
    --run_tag ${RUN_TAG}
    --experiment_id ${EXP_ID:-1}
    --data_dir_prefix ${DATA_DIR_PREFIX}
    --output_dir ${OUTPUT_DIR}
    --model_prefix "segmentation"
    --optimizer ${OPTIMIZER}
    --start_lr ${START_LR}
    ${lr_schedule_arg}
    --lr_warmup_steps ${LR_WARMUP_STEPS}
    --lr_warmup_factor ${LR_WARMUP_FACTOR}
    --weight_decay ${WEIGHT_DECAY}
    --logging_frequency ${LOGGING_FREQUENCY}
    --save_frequency 0
    --min_epochs ${MIN_EPOCHS:-0}
    --max_epochs ${MAX_EPOCHS:-200}
    --data_num_threads ${MAX_THREADS:-4}
    --seed ${SEED:-1}
    --batchnorm_group_size ${BATCHNORM_GROUP_SIZE}
    --shuffle_mode "${SHUFFLE_MODE}"
    --data_format "${DATA_FORMAT}"
    --data_oversampling_factor ${DATA_OVERSAMPLING_FACTOR:-1}
    --precision_mode "${PRECISION_MODE}"
    --enable_nhwc
    --local_batch_size ${LOCAL_BATCH_SIZE}
    --local_batch_size_validation ${LOCAL_VALIDATION_BATCH_SIZE}
    ${ADDITIONAL_ARGS}
)

# profile command:
if [ ! -z ${OMPI_COMM_WORLD_RANK} ]; then
    WORLD_RANK=${OMPI_COMM_WORLD_RANK}
elif [ ! -z ${PMIX_RANK} ]; then
    WORLD_RANK=${PMIX_RANK}
elif [ ! -z ${PMI_RANK} ]; then
    WORLD_RANK=${PMI_RANK}
fi
PROFILE_BASE_CMD="nsys profile --mpi-impl=openmpi --trace=cuda,cublas,nvtx,mpi --cuda-graph-trace=node --kill none -c cudaProfilerApi -f true -o ${OUTPUT_DIR}/profile_job${SLURM_JOBID}_rank${WORLD_RANK}"
ANNA_BASE_CMD="nsys profile --trace cuda,nvtx --sample cpu --output ${OUTPUT_DIR}/anna_job${SLURM_JOBID}_rank${WORLD_RANK} --export sqlite --force-overwrite true --stop-on-exit true --capture-range cudaProfilerApi --capture-range-end stop --kill none"
DLPROF_BASE_CMD="dlprof --mode=pytorch --force=true --reports=summary,detail,iteration --nsys_profile_range=true --output_path=${OUTPUT_DIR} --profile_name=dlprof_rank${WORLD_RANK}"
METRICS_BASE_CMD="ncu --target-processes=all --profile-from-start=off --nvtx --print-summary=per-nvtx --csv -f -o ${OUTPUT_DIR}/metrics_rank${WORLD_RANK} --metrics=smsp__sass_thread_inst_executed_op_hadd_pred_on.sum,smsp__sass_thread_inst_executed_op_hmul_pred_on.sum,smsp__sass_thread_inst_executed_op_hfma_pred_on.sum,smsp__sass_thread_inst_executed_op_fadd_pred_on.sum,smsp__sass_thread_inst_executed_op_fmul_pred_on.sum,smsp__sass_thread_inst_executed_op_ffma_pred_on.sum,sm__inst_executed_pipe_tensor.sum"

if [[ ${ENABLE_PROFILING} == 1 ]]; then
    if [[ ${ENABLE_METRICS_COLLECTION} == 1 ]]; then
	echo "Metric Collection enabled"
	if [[ "${WORLD_RANK}" == "0" ]]; then
	    PROFILE_CMD=${METRICS_BASE_CMD}
	else
	    PROFILE_CMD=""
	fi
    elif [[ ${ENABLE_DLPROF} == 1 ]]; then
	echo "Dlprof enabled"
	if [[ "${WORLD_RANK}" == "0" ]]; then
	    PROFILE_CMD=${DLPROF_BASE_CMD}
	else
	    PROFILE_CMD=""
	fi
	PARAMS+=(--profile_markers=dlprof)
    elif [[ ${ENABLE_ANNA} == 1 ]]; then
	echo "ANNA enabled"
	if [[ "${WORLD_RANK}" == "0" ]]; then
	    PROFILE_CMD=${ANNA_BASE_CMD}
	else
	    PROFILE_CMD=""
	fi
	PARAMS+=(--profile_markers=anna)
    else
	echo "Profiling enabled"
	PROFILE_CMD=${PROFILE_BASE_CMD}
    fi
elif [[ ${API_LOGGING} == 1 ]]; then
    echo "ApiLog enabled"
    if [ ${SLURM_PROCID} == 0 ]; then
	PROFILE_CMD="apiLog.sh"
    else
	PROFILE_CMD=""
    fi
else
    PROFILE_CMD=""
fi

if [[ ${DEBUG_MEMCHECK} == 1 ]]; then
    echo "Debugging enabled"
    DEBUG_CMD="compute-sanitizer --tool=memcheck"
else
    DEBUG_CMD=""
fi

IB_BIND=''
if [[ "${SLURM_JOB_NUM_NODES}" -gt 1 && "${ENABLE_IB_BINDING}" -eq 1 ]]; then
  IB_BIND='--ib=single'
fi
BIND_BASE_CMD="bindpcie --cpu=exclusive ${IB_BIND} --"
BIND="${BIND_CMD:-${BIND_BASE_CMD}}"

if [ "$LOGGER" = "apiLog.sh" ];
then
  LOGGER="${LOGGER} -p MLPerf/${MODEL_NAME} -v ${FRAMEWORK}/train/${DGXSYSTEM}"
  readonly node_rank="${SLURM_NODEID:-0}"
  readonly local_rank="${LOCAL_RANK:=${SLURM_LOCALID:=${OMPI_COMM_WORLD_LOCAL_RANK:-}}}"
  if [ "$node_rank" -eq 0 ] && [ "$local_rank" -eq 0 ];
  then
    LOGGER=$LOGGER
  else
    LOGGER=""
  fi
fi

# do we cache data
if [ ! -z ${DATA_CACHE_DIRECTORY} ]; then
    PARAMS+=(--data_cache_directory ${DATA_CACHE_DIRECTORY})
fi

# run script selection:
if [ ! -z ${TRAINING_INSTANCE_SIZE} ]; then
    # echo "Running Multi Instance Training"
    RUN_SCRIPT="./train_instance_oo.py"
    PARAMS+=(--training_instance_size ${TRAINING_INSTANCE_SIZE})

    if [ ! -z ${STAGE_DIR_PREFIX} ]; then
	PARAMS+=(
	    --stage_dir_prefix ${STAGE_DIR_PREFIX}
	    --stage_num_read_workers ${STAGE_NUM_READ_WORKERS:-1}
	    --stage_num_write_workers ${STAGE_NUM_WRITE_WORKERS:-1}
	    --stage_batch_size ${STAGE_BATCH_SIZE:--1}
	    --stage_mode ${STAGE_MODE:-"node"}
	    --stage_max_num_files ${STAGE_MAX_NUM_FILES:--1}
	)
	# do we need to verify the staging results
	if [ "${STAGE_VERIFY:-0}" -eq 1 ]; then
	    PARAMS+=(--stage_verify)
	fi
	if [ "${STAGE_ONLY:-0}" -eq 1 ]; then
	    echo "WARNING: You are about to run a staging only benchmark"
	    PARAMS+=(--stage_only)
	fi
	if [ "${STAGE_FULL_DATA_PER_NODE:-0}" -eq 1 ]; then
	    PARAMS+=(--stage_full_data_per_node)
	fi
	if [ "${STAGE_ARCHIVES:-0}" -eq 1 ]; then
	    PARAMS+=(--stage_archives)
	fi
	if [ "${STAGE_USE_DIRECT_IO:-0}" -eq 1 ]; then
	    PARAMS+=(--stage_use_direct_io)
	fi
	if [ "${STAGE_READ_ONLY:-0}" -eq 1 ]; then
	    PARAMS+=(--stage_read_only)
	fi
    fi
else
    echo "Running Single Instance Training"
    RUN_SCRIPT="./train.py"
fi

# decide whether to enable profiling
if [ ! -z ${ENABLE_PROFILING} ] && [ ${ENABLE_PROFILING} == 1 ]; then
    echo "Running Profiling"
    if [ ! -z ${TRAINING_INSTANCE_SIZE} ]; then
	RUN_SCRIPT="./train_instance_oo_profile.py"
    else
	RUN_SCRIPT="./train_profile.py"
    fi

    if [ ! -z ${CAPTURE_RANGE_START} ]; then
	PARAMS+=(
	    --capture_range_start ${CAPTURE_RANGE_START}
	    --capture_range_stop ${CAPTURE_RANGE_STOP}
	)
    fi

    if [ ! -z ${PROFILE_FRACTION} ]; then
	PARAMS+=(--profile_fraction ${PROFILE_FRACTION})
    fi
fi

# Export final variables for run_and_time.sh
RUN_CMD="${RUN_SCRIPT} ${PARAMS[@]}"
export RUN_CMD
export LOGGER
export PROFILE_CMD
export DEBUG_CMD