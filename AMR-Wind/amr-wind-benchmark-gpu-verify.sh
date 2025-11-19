#!/bin/bash -l

set -ex

BENCHMARKS_DIR=/scratch/${USER}/amr-wind-benchmark
mkdir -p ${BENCHMARKS_DIR}
cd ${BENCHMARKS_DIR}
mkdir amr-wind-benchmark-gpu-verify
cd amr-wind-benchmark-gpu-verify

# Generate average script
cat >amr-wind-average.py <<'EOL'
#!/usr/bin/env python3

import argparse
import pandas as pd
import numpy as np

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="A simple averaging tool")
    parser.add_argument(
        "-f",
        "--fnames",
        help="Files to average",
        required=True,
        nargs="+",
        type=str,
    )
    args = parser.parse_args()

    for fname in args.fnames:
        data = pd.read_csv(fname, sep="\\s+", skiprows=0, header=None)
        array = data.to_numpy()
        print(np.mean(array[:]))
EOL

# Generate average script
cat >amr-wind-average.sh <<'EOL'
#!/bin/bash

set -e

i=1
for file in $(ls -d1 amr-wind-benchmark* | sort -V); do
    echo "$file"
    grep ^WallClockTime "$file" | awk '{print $NF}' > amr-wind-time-$i.txt
    ./amr-wind-average.py -f amr-wind-time-$i.txt >> amr-wind-avg.txt
    rm amr-wind-time-$i.txt
    ((i=i+1))
done
EOL

# Generate build script
cat >build-amr-wind-benchmark-gpu.sh <<'EOL'
#!/bin/bash -l
set -ex
module load cuda
#GCC 12 can't handle the default zen4 target so we use zen3
module load craype-x86-milan
git clone --depth=1 --shallow-submodules --branch v3.8.0 --recursive https://github.com/Exawind/amr-wind.git
cmake -B amr-wind-build \
	-DAMR_WIND_ENABLE_MPI:BOOL=ON \
	-DAMR_WIND_ENABLE_CUDA:BOOL=ON \
	-DCMAKE_CUDA_ARCHITECTURES:STRING=90 \
	-DAMR_WIND_ENABLE_TESTS:BOOL=ON \
	-DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON \
	-DMPI_HOME:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3 \
	-DMPI_CXX_COMPILER:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3/bin/mpicxx \
	-DMPI_C_COMPILER:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3/bin/mpicc \
	amr-wind
cmake --build amr-wind-build --parallel 8
EOL

cat >run-amr-wind-benchmark-gpu-verify.sh <<'EOL'
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
FIXED_ARGS="nodal_proj.bottom_atol=-1 mac_proj.bottom_atol=-1 time.fixed_dt=0.5 time.max_step=20 ABL.stats_output_frequency=-1 time.plot_interval=20 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=128 amrex.use_profiler_syncs=0 amrex.async_out=0 amr.max_level=1 tagging.labels=g1 tagging.g1.type=GeometryRefinement tagging.g1.shapes=b1 tagging.g1.b1.type=box tagging.g1.b1.origin=0.0 0.0 384.0 tagging.g1.b1.xaxis=1.0e8 0.0 384.0 tagging.g1.b1.yaxis=0.0 1.0e8 384.0 tagging.g1.b1.zaxis=0.0 0.0 256.0"
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
cd amr-wind-build/test/test_files/abl_godunov
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=64 64 64 geometry.prob_hi=1024.0 1024.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=128 128 64 geometry.prob_hi=2048.0 2048.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=256 256 64 geometry.prob_hi=4096.0 4096.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=512 512 64 geometry.prob_hi=8192.0 8192.0 1024.0
srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=1024 1024 64 geometry.prob_hi=16384.0 16384.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=2048 2048 64 geometry.prob_hi=32768.0 32768.0 1024.0
EOL

# Build AMR-Wind
bash build-amr-wind-benchmark-gpu-verify.sh

# Submit run script
sbatch -J amr-wind-benchmark-gpu-verify-4 -N 4 run-amr-wind-benchmark-gpu-verify.sh
