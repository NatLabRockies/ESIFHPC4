#!/bin/bash
#SBATCH --job-name lmp.std4
#SBATCH --nodes=4	
#SBATCH --time=4:00:00
#SBATCH --tasks-per-node=96
#SBATCH --account=hpcapps
#SBATCH --error=std.err
#SBATCH --output=std.out
#SBATCH --exclusive

#Sample run on NREL's Kestrel
#Requesting 4 nodes with 96 tasks per node.  
#Load modules
module load lammps/072225-intel-mpich
#Required for baseline
export OMP_NUM_THREADS=1

ntasks=$SLURM_NTASKS
run_cmd="srun -n $ntasks"

lmp_path=lmp
input_path=../input
run_name=(small medium large xlarge)

#This parameter makes job longer to have >300s wall time
#Adjust it if necessary
scale=$((SLURM_JOB_NUM_NODES*2))

echo Run $ntasks MPI ranks without GPU
for name in "${run_name[@]}"
do
	echo Run $name 
	line=`grep "thermo_print equal" $input_path/$name.in`
	IFS=', ' read -r -a array <<< "$line"
	old_step="${array[3]}"
	new_step=$((old_step*scale))
	sed "s/thermo_print equal $old_step/thermo_print equal $new_step/" $input_path/$name.in > $name.in
	diff $name.in $input_path/$name.in 
	time $run_cmd $lmp_path -in $name.in >& $name.log
	grep Loop $name.log
	grep day $name.log   
done

echo Results are in std.out 

