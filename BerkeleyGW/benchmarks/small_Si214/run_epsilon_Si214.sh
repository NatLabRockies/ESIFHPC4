#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=00:30:00
#SBATCH --partition=gpu-h100
#SBATCH --gres=gpu:h100:4
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --account=hpcapps
#SBATCH -J bgw_eps_Si214
#SBATCH -o BGW_EPSILON_%j.out


source ../site_path_config.sh

mkdir BGW_EPSILON_$SLURM_JOBID
#../stripe_large BGW_EPSILON_$SLURM_JOBID
cd    BGW_EPSILON_$SLURM_JOBID
ln -s $BGW_DIR/epsilon.cplx.x .
ln -s  ../epsilon.inp .
ln -sfn  ${Si214_WFN_folder}/WFNq.h5      .
ln -sfn  ${Si214_WFN_folder}/WFN_out.h5   ./WFN.h5


ulimit -s unlimited
export OMP_PROC_BIND=true
export OMP_PLACES=threads
export HDF5_USE_FILE_LOCKING=FALSE
export BGW_HDF5_WRITE_REDIST=1
export BGW_WFN_HDF5_INDEPENDENT=1


export OMP_NUM_THREADS=16
srun -n 4 -c 32 --cpu-bind=cores ./epsilon.cplx.x


