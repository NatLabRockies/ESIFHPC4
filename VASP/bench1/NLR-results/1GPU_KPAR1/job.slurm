#!/bin/bash
#SBATCH --account=hpcapps
#SBATCH --nodes=1
#SBATCH --gpus=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00
#SBATCH --job-name=vasp-bench1
#SBATCH --mem=85G

export MPICH_GPU_SUPPORT_ENABLED=1

module load vasp/6.5.1
module list &> mlist

export OMP_PROC_BIND=spread
export OMP_PLACES=cores
export OMP_STACKSIZE=1G
ulimit -s unlimited
export I_MPI_FABRICS=shm:ofi

#HSE
time srun vasp_std |& tee hse.out

