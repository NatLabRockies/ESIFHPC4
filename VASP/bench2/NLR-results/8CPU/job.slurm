#!/bin/bash
#SBATCH --account=hpcapps
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=96
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --job-name=bench2_cpu

module load vasp/6.5.1
module list &> mlist

export OMP_PROC_BIND=spread
export OMP_PLACES=cores
export OMP_STACKSIZE=1G
ulimit -s unlimited
#export I_MPI_FABRICS=shm
export I_MPI_FABRICS=shm:ofi

time srun vasp_gam |& tee hse.out

