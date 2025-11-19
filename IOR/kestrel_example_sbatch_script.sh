#!/bin/bash
#SBATCH --account=esifapps
#SBATCH --time=01:00:00  # hh:mm:ss
#### Use only the standard, 256G mem, not-hbw nodes
#SBATCH --nodelist=x[1000-1003]c[0-7]s[0-7]b[0-1]n[0-1],x1004c[1-7]s[0-7]b[0-1]n[0-1],x1008c[4-7]s[0-7]b[0-1]n[0-1]
#SBATCH --job-name=test1_nn_mpi_io_1_kfs2 
#SBATCH --nodes=1  # number of nodes
#SBATCH --output=./test_%j.o
#SBATCH --error=./test_%j.e


module load cray-hdf5-parallel

script_file="<path-to-ior-installation-directory>/bin/ior"
test_dir="<path-to-filesystem-pool:kfs2/kfs3-disk/kfs3-flash>"
test_file="$test_dir/test1_nn_mpi_io.ior"

n_nodes=1
n_tasks_per_node=104
n_tasks=$((n_nodes * n_tasks_per_node))

cd $test_dir
echo "Running on `hostname`"
echo "$(scontrol show job $SLURM_JOB_ID)"

### with output results to .json
srun --kill-on-bad-exit -n $n_tasks $script_file -O summaryFile=ior_output_1_$SLURM_JOB_ID.json -O summaryFormat=JSON -f $test_file


