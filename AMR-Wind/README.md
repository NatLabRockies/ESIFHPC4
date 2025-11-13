# AMR-Wind

## Description

AMR-Wind is a massively parallel, block-structured adaptive-mesh, incompressible flow solver for wind turbine and wind farm simulations. It depends on the AMReX library that provides mesh data structures, mesh adaptivity, and linear solvers to handle its governing equations. This software is part the exawind ecosystem, is available [here](https://github.com/exawind/AMR-Wind). The AMR-Wind benchmark is very sensitive to MPI performance.

## Licensing

AMR-Wind is licensed under BSD 3-clause license. The license is included in the source code repository, [LICENSE](https://github.com/Exawind/amr-wind/blob/main/LICENSE).

## Building

AMR-Wind utilizes the AMReX library and therefore runs on CPUs, or NVIDIA, AMD, or Intel GPUs. AMR-Wind uses CMake. General instructions for building AMR-Wind are provided below and also found [here](https://exawind.github.io/amr-wind/user/build.html). Below we demonstrate building for CPUs:

```
set -e
set -x
git clone --depth=1 --shallow-submodules --branch v3.7.0 --recursive https://github.com/Exawind/amr-wind.git
cmake -B amr-wind-build -DAMR_WIND_ENABLE_MPI:BOOL=ON -DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON -DAMR_WIND_ENABLE_TESTS:BOOL=ON amr-wind
cmake --build amr-wind-build --parallel
```

## Run Definitions and Requirements

### Benchmark Case

We create a benchmark case on top of our standard `abl_godunov` regression test by adding runtime parameters on the command line. This case is designed to be either weak-scaled or strong scaled. This simulation runs a simple atmospheric boundary layer (ABL) that stays fixed in the Z dimension, but can be scaled arbitrarily in the X and Y dimensions. We also add a single refinement level across the middle of the domain to complete the exercising of the AMR algorithm.

## Running

After building with the steps above. Here we demonstrate a weak scaling on CPUs with a generic MPI implementation:
```
set -e
set -x
FIXED_ARGS="time.fixed_dt=0.5 time.max_step=20 ABL.stats_output_frequency=-1 time.plot_interval=5 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=128 amrex.use_profiler_syncs=0 amrex.async_out=0 amr.max_level=1 tagging.labels=g1 tagging.g1.type=GeometryRefinement tagging.g1.shapes=b1 tagging.g1.b1.type=box tagging.g1.b1.origin=0.0 0.0 384.0 tagging.g1.b1.xaxis=1.0e8 0.0 384.0 tagging.g1.b1.yaxis=0.0 1.0e8 384.0 tagging.g1.b1.zaxis=0.0 0.0 256.0"
cd amr-wind-build/test/test_files/abl_godunov
mpirun -np <np> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=32 32 64 geometry.prob_hi=512.0 512.0 1024.0
mpirun -np <np> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=64 64 64 geometry.prob_hi=1024.0 1024.0 1024.0
mpirun -np <np> ../../../amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=128 128 64 geometry.prob_hi=2048.0 2048.0 1024.0
...
```

AMR-Wind is also able to run on GPUs using the CMake configuration parameters: `AMR_WIND_ENABLE_CUDA`, `AMR_WIND_ENABLE_ROCM`, or `AMR_WIND_ENABLE_SYCL`, for NVIDIA, AMD, or Intel GPUs, respectively. GPU-aware MPI is also available in AMReX, and therefore AMR-Wind, which can benefit performance. The GPU-aware MPI library can be injected and linked during the CMake build however one sees fit. During runtime AMReX provides a `amrex.use_gpu_aware_mpi` parameter which can be set to 1 (`amrex.use_gpu_aware_mpi=1`) on the command line.

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
