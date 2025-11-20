#!/bin/bash -l

set -ex

BENCHMARK_DIR=/scratch/${USER}/amr-wind-benchmark/amr-wind-benchmark-cpu
mkdir -p ${BENCHMARK_DIR}
cd ${BENCHMARK_DIR}

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
    python3 amr-wind-average.py -f amr-wind-time-$i.txt >> amr-wind-avg.txt
    rm amr-wind-time-$i.txt
    ((i=i+1))
done
EOL

# Generate build script
cat >build-amr-wind-benchmark-cpu.sh <<'EOL'
#!/bin/bash -l
set -ex
git clone --depth=1 --shallow-submodules --branch v3.8.0 --recursive https://github.com/Exawind/amr-wind.git
cmake -B amr-wind-build \
	-DCMAKE_CXX_COMPILER:STRING=CC \
	-DCMAKE_C_COMPILER:STRING=cc \
	-DAMR_WIND_ENABLE_MPI:BOOL=ON \
	-DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON \
	-DAMR_WIND_ENABLE_TESTS:BOOL=ON \
	amr-wind
nice cmake --build amr-wind-build --parallel
EOL

# Generate run script
cat >run-amr-wind-benchmark-cpu.sh <<'EOL'
#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30

set -ex

export FI_MR_CACHE_MONITOR=memhooks
export FI_CXI_RX_MATCH_MODE=software
export MPICH_SMP_SINGLE_COPY_MODE=NONE
export MPICH_OFI_NIC_POLICY=NUMA
FIXED_ARGS="nodal_proj.bottom_atol=-1 mac_proj.bottom_atol=-1 time.fixed_dt=0.5 time.max_step=20 ABL.stats_output_frequency=-1 time.plot_interval=-1 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=128 amrex.use_profiler_syncs=0 amrex.async_out=0 amr.max_level=1 tagging.labels=g1 tagging.g1.type=GeometryRefinement tagging.g1.shapes=b1 tagging.g1.b1.type=box tagging.g1.b1.origin=0.0 0.0 384.0 tagging.g1.b1.xaxis=1.0e8 0.0 384.0 tagging.g1.b1.yaxis=0.0 1.0e8 384.0 tagging.g1.b1.zaxis=0.0 0.0 256.0"
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*72))
cd amr-wind-build/test/test_files/abl_godunov
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=64 64 64 geometry.prob_hi=1024.0 1024.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=128 128 64 geometry.prob_hi=2048.0 2048.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=256 256 64 geometry.prob_hi=4096.0 4096.0 1024.0
srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=512 512 64 geometry.prob_hi=8192.0 8192.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=1024 1024 64 geometry.prob_hi=16384.0 16384.0 1024.0
#srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=2048 2048 64 geometry.prob_hi=32768.0 32768.0 1024.0
EOL

# Build AMR-Wind
bash build-amr-wind-benchmark-cpu.sh

# Submit run script
sbatch -J amr-wind-benchmark-cpu-1 -N 1 -p debug run-amr-wind-benchmark-cpu.sh; for i in {1..7}; do sbatch -J amr-wind-benchmark-cpu-$((2**i)) -N $((2**i)) -p hbw run-amr-wind-benchmark-cpu.sh; done
