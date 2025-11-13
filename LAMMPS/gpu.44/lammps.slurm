#!/bin/bash
#SBATCH --job-name g44
#SBATCH --nodes=4 		#Request 4 nodes
#SBATCH --gres=gpu:4		#Request 4 GPU per node
#SBATCH --tasks-per-node=32 	#Running 32 MPI tasks per node
#SBATCH --time=4:00:00
#SBATCH --account=hpcapps
#SBATCH --error=std.err
#SBATCH --output=std.out

#Sample run on NREL's Kestrel
#Requesting 4 nodes with 4 GPUs per node and 32 tasks per node.  
#Load modules
module load lammps/072225-gpu
#Required for baseline
export OMP_NUM_THREADS=1

ntasks=$SLURM_NTASKS
taskpernode=$SLURM_NTASKS_PER_NODE
run_cmd="srun --ntasks $ntasks --tasks-per-node=$taskpernode"

lmp_path=lmp
input_path=../input
run_name=(small medium large xlarge)

ngpus=$((SLURM_GPUS_ON_NODE))

#This parameter makes job longer to have >300s wall time
#Adjust it if necessary
scale=$((SLURM_JOB_NUM_NODES*ngpus))

gpu_opt="-sf gpu -pk gpu $ngpus"

echo Run $ntasks MPI ranks with $ngpus GPU per node
echo task per node is $taskpernode
for name in "${run_name[@]}"
do
	echo Run $name 
	line=`grep "thermo_print equal" $input_path/$name.in`
	IFS=', ' read -r -a array <<< "$line"
	old_step="${array[3]}"
	new_step=$((old_step*scale))
	sed "s/thermo_print equal $old_step/thermo_print equal $new_step/" $input_path/$name.in > $name.in
	diff $name.in $input_path/$name.in 
	time $run_cmd $lmp_path $gpu_opt -in $name.in >& $name.$taskpernode.log
	grep Loop $name.$taskpernode.log
	grep day $name.$taskpernode.log   
done

echo Results are in std.out 



