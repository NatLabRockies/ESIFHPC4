#!/bin/bash
#SBATCH --job-name num_std
#SBATCH --nodes=1
#SBATCH --time=4:00:00
#SBATCH --tasks-per-node=64
#SBATCH --account=hpcapps
#SBATCH --error=std.err
#SBATCH --output=std.out

#Sample run on NREL's Kestrel
#Requesting 1 nodes with 64 tasks per node.  
#Load modules
module load lammps/072225-intel-mpich 
#Required for baseline
export OMP_NUM_THREADS=1

ntasks=$SLURM_NTASKS
echo MPI run with $ntasks ranks
run_cmd="srun -n $ntasks"

lmp_path=lmp
input_path=../input
run_name=(medium_numerical_test)

echo Run $ntasks MPI ranks without GPU
for name in "${run_name[@]}"
do
	echo Run $name 
	cp $input_path/$name.in .
	time $run_cmd $lmp_path -in $name.in >& $name.log
	../validate.sh $name.log ../NREL_results	
done

 

