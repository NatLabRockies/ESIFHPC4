#!/bin/bash
#SBATCH --nodes=2
#SBATCH --tasks-per-node=104
#SBATCH --cpus-per-task=1
#SBATCH --time=4:00:00
#SBATCH --account=esifapps
#SBATCH --job-name=vasp-bench2

ml vasp/6.4.2

#GGA
time srun vasp_gam |& tee bench2-gga.out
