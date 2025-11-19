# AMR-Wind

## Description

AMR-Wind is a massively parallel, block-structured adaptive-mesh, incompressible flow solver for wind turbine and wind farm simulations. It depends on the AMReX library that provides mesh data structures, mesh adaptivity, and linear solvers to handle its governing equations. This software is part the exawind ecosystem, is available [here](https://github.com/exawind/AMR-Wind). The AMR-Wind benchmark is very sensitive to MPI performance.

## Licensing

AMR-Wind is licensed under BSD 3-clause license. The license is included in the source code repository, [LICENSE](https://github.com/Exawind/amr-wind/blob/main/LICENSE).

## Building

AMR-Wind utilizes the AMReX library and therefore runs on CPUs, or NVIDIA, AMD, or Intel GPUs. AMR-Wind uses CMake. General instructions for building AMR-Wind are provided below and also found [here](https://exawind.github.io/amr-wind/user/build.html). Below we demonstrate building for CPUs on our Kestrel machine with this `build.sh` script:

```
#!/bin/bash -l
set -e
set -x
git clone --depth=1 --shallow-submodules --branch v3.7.0 --recursive https://github.com/Exawind/amr-wind.git
cmake -B amr-wind-build -DCMAKE_CXX_COMPILER:STRING=CC -DCMAKE_C_COMPILER:STRING=cc -DAMR_WIND_ENABLE_MPI:BOOL=ON -DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON -DAMR_WIND_ENABLE_TESTS:BOOL=ON amr-wind
cmake --build amr-wind-build --parallel
```

Here we show our build script for Kestrel GPUs including GPU-aware MPI:
```
#!/bin/bash -l
set -e
set -x
module load cuda
module load craype-x86-milan
git clone --depth=1 --shallow-submodules --branch v3.7.0 --recursive https://github.com/Exawind/amr-wind.git
export CXXFLAGS="-I${MPICH_DIR}/include -L${MPICH_DIR}/lib -lmpi ${PE_MPICH_GTL_DIR_nvidia90} ${PE_MPICH_GTL_LIBS_nvidia90}"
cmake -B amr-wind-build -DAMR_WIND_ENABLE_MPI:BOOL=ON -DAMR_WIND_ENABLE_CUDA:BOOL=ON -DAMR_WIND_ENABLE_TESTS:BOOL=ON -DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON -DMPI_HOME:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3 -DMPI_CXX_COMPILER:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3/bin/mpicxx -DMPI_C_COMPILER:STRING=/opt/cray/pe/mpich/8.1.28/ofi/gnu/10.3/bin/mpicc -DCMAKE_CUDA_ARCHITECTURES:STRING=90 amr-wind
cmake --build amr-wind-build --parallel 8
```

## Run Definitions and Requirements

### Benchmark Case

We create a benchmark case on top of our standard `abl_godunov` regression test by adding runtime parameters on the command line. This case is designed to be either weak-scaled or strong scaled. This simulation runs a simple atmospheric boundary layer (ABL) that stays fixed in the Z dimension, but can be scaled arbitrarily in the X and Y dimensions. We also add a single refinement level across the middle of the domain to complete the exercising of the AMR algorithm.

## Running

After building with the steps above. Here we demonstrate a strong scaling on the NREL Kestrel CPUs with this `run.sh` script:
```
#!/bin/bash -l

#Strong scaling submitted as such:
#sbatch -J amr-wind-benchmark-cpu-1 -N 1 -p debug run.sh; for i in {1..7}; do sbatch -J amr-wind-benchmark-cpu-$((2**i)) -N $((2**i)) -p hbw run.sh; done

#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30

set -e
set -x

export FI_MR_CACHE_MONITOR=memhooks
export FI_CXI_RX_MATCH_MODE=software
export MPICH_SMP_SINGLE_COPY_MODE=NONE
export MPICH_OFI_NIC_POLICY=NUMA
FIXED_ARGS="nodal_proj.bottom_atol=-1 mac_proj.bottom_atol=-1 time.fixed_dt=0.5 time.max_step=20 ABL.stats_output_frequency=-1 time.plot_interval=-1 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=128 amrex.use_profiler_syncs=0 amrex.async_out=0 amr.max_level=1 tagging.labels=g1 tagging.g1.type=GeometryRefinement tagging.g1.shapes=b1 tagging.g1.b1.type=box tagging.g1.b1.origin=0.0 0.0 384.0 tagging.g1.b1.xaxis=1.0e8 0.0 384.0 tagging.g1.b1.yaxis=0.0 1.0e8 384.0 tagging.g1.b1.zaxis=0.0 0.0 256.0"

TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*72))

cd amr-wind-build/test/test_files/abl_godunov

srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=72 --distribution=block:block --cpu_bind=rank_ldom ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=512 512 64 geometry.prob_hi=8192.0 8192.0 1024.0
...
```

Here we demonstrate a strong scaling on the NREL Kestrel GPUs using GPU-aware MPI with this `run.sh` script:
```
#!/bin/bash -l

#Strong scaling submitted as such:
#sbatch -J amr-wind-benchmark-gpu-1 -N 1 run.sh; for i in {1..5}; do sbatch -J amr-wind-benchmark-gpu-$((2**i)) -N $((2**i)) run.sh; done

#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30
#SBATCH --partition=gpu-h100s
#SBATCH --gpus-per-node=4
#SBATCH --ntasks-per-node=128
#SBATCH --exclusive
#SBATCH --mem=0

set -e
set -x

module load cuda
export FI_MR_CACHE_MONITOR=memhooks
export FI_CXI_RX_MATCH_MODE=software
export MPICH_SMP_SINGLE_COPY_MODE=NONE
export MPICH_GPU_SUPPORT_ENABLED=1
FIXED_ARGS="nodal_proj.bottom_atol=-1 mac_proj.bottom_atol=-1 time.fixed_dt=0.5 time.max_step=20 ABL.stats_output_frequency=-1 time.plot_interval=-1 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=512 amrex.use_profiler_syncs=0 amrex.async_out=0 amr.max_level=1 tagging.labels=g1 tagging.g1.type=GeometryRefinement tagging.g1.shapes=b1 tagging.g1.b1.type=box tagging.g1.b1.origin=0.0 0.0 384.0 tagging.g1.b1.xaxis=1.0e8 0.0 384.0 tagging.g1.b1.yaxis=0.0 1.0e8 384.0 tagging.g1.b1.zaxis=0.0 0.0 256.0 amrex.use_gpu_aware_mpi=1"
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
cd amr-wind-build/test/test_files/abl_godunov
srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --ntasks-per-node=4 --gpus-per-node=4 --gpu-bind=closest ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=1024 1024 64 geometry.prob_hi=16384.0 16384.0 1024.0
```

Note we can weak scale the benchmark case in the X and Y dimensions with these examples if necessary:
```
srun <parameters> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=64 64 64 geometry.prob_hi=1024.0 1024.0 1024.0
srun <parameters> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=128 128 64 geometry.prob_hi=2048.0 2048.0 1024.0
srun <parameters> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=256 256 64 geometry.prob_hi=4096.0 4096.0 1024.0
srun <parameters> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=512 512 64 geometry.prob_hi=8192.0 8192.0 1024.0
srun <parameters> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=1024 1024 64 geometry.prob_hi=16384.0 16384.0 1024.0
srun <parameters> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=2048 2048 64 geometry.prob_hi=32768.0 32768.0 1024.0
```

To get the average of the time per timestep for our strong scaling plot, we used two scripts. One bash script to extract the AMR-Wind wallclock times and one python script to do the mean.

amr-wind-average.py:
```
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
```

amr-wind-average.sh:
```
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
```

AMR-Wind is also able to run on different GPUs using the CMake configuration parameters: `AMR_WIND_ENABLE_CUDA`, `AMR_WIND_ENABLE_ROCM`, or `AMR_WIND_ENABLE_SYCL`, for NVIDIA, AMD, or Intel GPUs, respectively. GPU-aware MPI is also available in AMReX, and therefore AMR-Wind, which can benefit performance. The GPU-aware MPI library can be injected and linked during the CMake build however one sees fit. During runtime AMReX provides a `amrex.use_gpu_aware_mpi` parameter which can be set to 1 (`amrex.use_gpu_aware_mpi=1`) on the command line as shown in our example.

The offeror should reveal any potential for performance optimization on the target system that provides an optimal task configuration by running As-is and Optimized cases. On CPU nodes, the As-is case will saturate all available cores per node to establish baseline performance and expose potential computational bottlenecks and memory-related latency issues. The Optimized case will saturate at least 70% of cores per node and will include configurations exploring strategies to identify opportunities for reducing latency. On GPU nodes, the As-is case will saturate all GPUs per node to evaluate GPU compute and memory bandwidth performance. The Optimized case will saturate all GPUs per node, along with optimizations focusing on minimizing data transfers and leveraging GPU-specific memory features, aiming to reveal opportunities for reducing end-to-end latency.

### Validation

Need to think about this, but I'm not really concerned about validation.

## Rules

* Any optimizations would be allowed in the code, build and task configuration as long as the offeror would provide a high-level description of the optimization techniques used and their impact on performance in the Text response.
* The offeror can use accelerator-specific compilers and libraries.

## Benchmark test results to report and files to return

The following AMR-Wind-specific information should be provided:

* For reporting scaling and throughput studies, use the harmonic mean of the `Time spent in Evolve` wall-clock times from output logs in the Spreadsheet (`report/amr-wind-benchmark.csv`).
* As part of the File response, please return job-scripts and their outputs, and log files from each run.
* Include in the Text response a description of any optimization done.
