#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --gpus=4
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --time=2:00:00
#SBATCH --account=hpcapps
#SBATCH --job-name=vasp-bench2-gpu

source /nopt/nrel/apps/env.sh
export MPICH_GPU_SUPPORT_ENABLED=1

ml vasp/6.4.2

#GGA
time srun vasp_gam |& tee bench2-gga.out
