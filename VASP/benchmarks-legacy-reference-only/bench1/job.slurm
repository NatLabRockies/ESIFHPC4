#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=104
#SBATCH --cpus-per-task=1
#SBATCH --time=8:00:00
#SBATCH --account=esifapps
#SBATCH --job-name=vasp-bench1

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

#GW
mkdir gw; cp INCAR-gw KPOINTS  POSCAR  POTCAR gw
cd gw
cp INCAR-gw INCAR
time srun -n 64 --ntasks-per-node=32 vasp_std  |& tee gw.out
cp OUTCAR OUTCAR-gw
cd ..
