#!/bin/bash

#SBATCH --account=hpcapps 
#SBATCH --nodes=1
#SBATCH --gpus=2 
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --time=02:00:00
#SBATCH --job-name=vasp-bench2
#SBATCH --mem=170G

export MPICH_GPU_SUPPORT_ENABLED=1

module load vasp/6.5.1
module list &> mlist

time srun vasp_gam |& tee gga.out