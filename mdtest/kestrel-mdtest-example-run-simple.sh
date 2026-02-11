#!/bin/bash
#SBATCH --job-name=mdtest
#SBATCH --time=01:00:00
#SBATCH --nodes=16


mdtest=/path/to/mdtest

exponent=20

# It is important to note that the total number of ranks must be a power of 2.

# example Test A
for ranks in 1 2 4 8 16 32; do
z=0
n=$(( 2**exponent / (ranks * SLURM_NNODES) ))
srun -N 16 --ntasks-per-node=$ranks $mdtest -a=POSIX -F -C -T -N 1 -r -n=$n -z=0 -d=`pwd`
done


# example Test B
for ranks in 1 4 8 16 32 64; do
I=16
n=$(( 2**exponent / (ranks * SLURM_NNODES) ))
srun -N 16 --ntasks-per-node=$ranks $mdtest -a=POSIX -F -C -T -N 1 -r -n=$n -z=0 -I=$I -d=`pwd`
done

# example Test C
for ranks in 1 4 8 16 32 64; do
z=0
n=$(( 2**exponent / (ranks * SLURM_NNODES) ))
srun -N 16 --ntasks-per-node=$ranks $mdtest -a=POSIX -F -C -T -N 1 -r -n=$n -z=0 -u -d=`pwd`
done