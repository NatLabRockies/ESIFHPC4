#!/bin/bash
#SBATCH -N 4
#SBATCH --job-name=osu-alltoall-accelerated
#SBATCH --ntasks-per-node=4
#SBATCH --partition=gpu-h100s
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --time=01:00:00
#SBATCH --gpus-per-node=4

nodes=4
PPN=4
gpus=4
TYPE=mpi_float

ml nvhpc
ml craype-accel-nvidia90
export MPICH_VERSION_DISPLAY=1
export MPICH_OFI_NIC_VERBOSE=1
export MPICH_ENV_DISPLAY=1
export MPICH_GPU_SUPPORT_ENABLED=1



let RANKS=($nodes * $PPN)



for k in `seq 8`
do
srun -N $nodes -n $RANKS --ntasks-per-node=$PPN --gpus-per-node=$gpus ./osu_alltoall -d cuda -i 5000 D D
done
