#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30
#SBATCH --partition=gpu-h100s
#SBATCH --gpus-per-node=4
#SBATCH --ntasks-per-node=128
#SBATCH --exclusive
#SBATCH --mem=0

set -ex

module load cuda
export MPICH_GPU_SUPPORT_ENABLED=1
FIXED_ARGS="nodal_proj.bottom_atol=-1 mac_proj.bottom_atol=-1 time.fixed_dt=0.5 time.max_step=20 ABL.stats_output_frequency=-1 time.plot_interval=-1 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=128 amrex.use_profiler_syncs=0 amrex.async_out=0 amr.max_level=1 tagging.labels=g1 tagging.g1.type=GeometryRefinement tagging.g1.shapes=b1 tagging.g1.b1.type=box tagging.g1.b1.origin=0.0 0.0 384.0 tagging.g1.b1.xaxis=1.0e8 0.0 384.0 tagging.g1.b1.yaxis=0.0 1.0e8 384.0 tagging.g1.b1.zaxis=0.0 0.0 256.0 amrex.use_gpu_aware_mpi=1"
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
cd amr-wind-build/test/test_files/abl_godunov
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=none ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=64 64 64 geometry.prob_hi=1024.0 1024.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=none ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=128 128 64 geometry.prob_hi=2048.0 2048.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=none ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=256 256 64 geometry.prob_hi=4096.0 4096.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=none ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=512 512 64 geometry.prob_hi=8192.0 8192.0 1024.0
srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=none ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=1024 1024 64 geometry.prob_hi=16384.0 16384.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=none ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=2048 2048 64 geometry.prob_hi=32768.0 32768.0 1024.0
