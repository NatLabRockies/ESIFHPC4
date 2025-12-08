#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --gpus=4
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH --time=2:00:00
#SBATCH --account=hpcapps
#SBATCH --job-name=vasp-bench1-gpu

source /nopt/nrel/apps/env.sh
export MPICH_GPU_SUPPORT_ENABLED=1

ml vasp/6.4.2

#GGA
mkdir gga; cp INCAR-gga KPOINTS  POSCAR  POTCAR gga
cd gga
cp INCAR-gga INCAR
time srun vasp_std |& tee gga.out
cd ..

#HSE
mkdir hse; cp INCAR-hse KPOINTS  POSCAR  POTCAR hse
cd hse
cp INCAR-hse INCAR
time srun vasp_std |& tee hse.out
cp OUTCAR OUTCAR-hse
cd ..

