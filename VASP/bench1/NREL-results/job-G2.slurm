#!/bin/bash

#SBATCH --account=hpcapps
#SBATCH --nodes=1
#SBATCH --gpus=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --job-name=vasp-bench1
#SBATCH --mem=170G

export MPICH_GPU_SUPPORT_ENABLED=1

module load vasp/6.5.1
module list &> mlist

#HSE
time srun vasp_std |& tee hse.out

