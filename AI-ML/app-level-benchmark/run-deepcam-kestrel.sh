#!/bin/bash
#SBATCH -A esifapps
#SBATCH -p gpu-h100
#SBATCH -t 06:00:00
#SBATCH -o %j-%x.out
#SBATCH -e %j-%x.err
#SBATCH -J train_deepcam_kestrel
#SBATCH --nodes 4 
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=32 # note that Kestrel GPU nodes have 128 CPU cores
#SBATCH --mem=700G
#SBATCH --gres=gpu:4
#SBATCH --exclusive

# Set batch size and learning rate
LOCAL_BATCH_SIZE=8
START_LR=1e-3

echo "========================"
echo "Number of devices   : $(( $SLURM_NNODES * $SLURM_GPUS_ON_NODE))"
echo "Local Batch Size    : $LOCAL_BATCH_SIZE"
echo "Start Learning Rate : $START_LR"
echo "========================"

# Load modules and activate PyTorch environment
module load mamba nccl/2.21.5_cuda124 cudnn gcc-native/12.1 openmpi/4.1.6-gcc # good for 2.7.0 torch
DEEPCAM_WORK_DIR=/scratch/$USER/DeepCAM-testing
TORCH_VERSION='2.7.0'
ENV_NAME=$DEEPCAM_WORK_DIR/deepcam-torch${TORCH_VERSION}-reference-env
eval "$(conda shell.bash hook)" && conda activate $ENV_NAME

# Memory optimization
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# I/O Performance optimizations
export OMP_NUM_THREADS=4                    # Optimal for CPU-intensive preprocessing
export CUDA_DEVICE_ORDER=PCI_BUS_ID         # Consistent GPU ordering

# HDF5 I/O optimizations
export HDF5_USE_FILE_LOCKING=FALSE          # Avoid file locking issues in parallel

# Use SLURM-provided TMPDIR (points to local NVMe), fallback to /tmp
export TMPDIR=${TMPDIR:-/tmp}



# Let Slingshot handle NCCL optimizations automatically
# NCCL flags removed for Slingshot compatibility
totalranks=$(( ${SLURM_NNODES} * ${SLURM_NTASKS_PER_NODE} ))
cpus_per_task=$(( ${SLURM_CPUS_ON_NODE} / ${rankspernode} ))

# number of data loader workers
# Rule of thumb: 2-4 workers per GPU, but not more than available CPU cores
workers_per_gpu=4

# DeepCAM params
run_tag="deepcam_${totalranks}ranks_job${SLURM_JOB_ID}"
data_dir_prefix="/scratch/${USER}/deepcam/All-Hist"
output_dir="/scratch/${USER}/deepcam_runs/kestrel/${run_tag}"

mkdir -p $output_dir


# Clone reference training code
if [ ! -d hpc ]; then
    git clone git@github.com:mlcommons/hpc.git
fi
cd hpc/deepcam/src/deepCam

# Launch training
srun --overlap -u -N ${SLURM_NNODES} -n ${totalranks} -c ${cpus_per_task} --cpu_bind=cores --gres=gpu:$SLURM_GPUS_ON_NODE \
     python train.py \
     --wireup_method "nccl-slurm-pmi" \
     --run_tag ${run_tag} \
     --data_dir_prefix ${data_dir_prefix} \
     --output_dir ${output_dir} \
     --max_inter_threads ${workers_per_gpu} \
     --model_prefix "classifier" \
     --optimizer "AdamW" \
     --start_lr ${START_LR} \
     --lr_schedule type="multistep",milestones="1200",decay_rate="0.5" \
     --lr_warmup_steps 0 \
     --lr_warmup_factor $(( ${SLURM_NNODES} / $LOCAL_BATCH_SIZE )) \
     --weight_decay 1e-2 \
     --logging_frequency 0 \
     --save_frequency 400 \
     --max_epochs 200 \
     --local_batch_size $LOCAL_BATCH_SIZE |& tee -a ${output_dir}/train.out
