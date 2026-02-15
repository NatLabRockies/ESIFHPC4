#!/bin/bash
#SBATCH -A esifapps
#SBATCH -p gpu-h100s
#SBATCH -t 02:00:00 
#SBATCH -J train_deepcam
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=32
#SBATCH --mem=700G
#SBATCH --gres=gpu:4
#SBATCH -o $LOGDIR/%j-%x.out
#SBATCH -e $LOGDIR/%j-%x.err
#SBATCH --exclusive

# Make these Slurm variables available to run_and_time_kestrel.sh
export SLURM_NTASKS_PER_NODE=$SLURM_NTASKS_PER_NODE
export SLURM_NNODES=$SLURM_NNODES
export SLURM_CPUS_ON_NODE=$SLURM_CPUS_ON_NODE
export SLURM_GPUS_ON_NODE=$SLURM_GPUS_ON_NODE

bash run_and_time_kestrel.sh
