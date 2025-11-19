# AMR-Wind

## Description

AMR-Wind is a massively parallel, block-structured adaptive-mesh, incompressible flow solver for wind turbine and wind farm simulations. It depends on the AMReX library that provides mesh data structures, mesh adaptivity, and linear solvers to handle its governing equations. This software is part the exawind ecosystem, is available [here](https://github.com/exawind/AMR-Wind). The AMR-Wind benchmark is very sensitive to MPI performance.

## Licensing

AMR-Wind is licensed under BSD 3-clause license. The license is included in the source code repository, [LICENSE](https://github.com/Exawind/amr-wind/blob/main/LICENSE).

## Building

AMR-Wind utilizes the AMReX library and therefore runs on CPUs, or NVIDIA, AMD, or Intel GPUs. AMR-Wind uses CMake. General instructions for building AMR-Wind are provided in this repo through the scripts used to run the benchmark at NREL, and also found [here](https://exawind.github.io/amr-wind/user/build.html). In this repo we provide the build scripts that were used to run the benchmarks shown in the plot for CPUs, GPUs, as well as GPU-aware MPI. These scripts also show how the benchmarks were run, which will be discussed in the next section.

[amr-wind-benchmark-cpu.sh](amr-wind-benchmark-cpu.sh)
[amr-wind-benchmark-cpu-verify.sh](amr-wind-benchmark-cpu-verify.sh)
[amr-wind-benchmark-gpu.sh](amr-wind-benchmark-gpu.sh)
[amr-wind-benchmark-gpu-aware.sh](amr-wind-benchmark-gpu-aware.sh)
[amr-wind-benchmark-gpu-verify.sh](amr-wind-benchmark-gpu-verify.sh)

## Run Definitions and Requirements

### Benchmark Case

We create a benchmark case on top of our standard `abl_godunov` regression test by adding runtime parameters on the command line. This case is designed to be either weak-scaled or strong scaled. This simulation runs a simple atmospheric boundary layer (ABL) that stays fixed in the Z dimension, but can be scaled arbitrarily in the X and Y dimensions. We also add a single refinement level across the middle of the domain to complete the exercising of the AMR algorithm.

## Running

The [run-all.sh](run-all.sh) script shows the nodes on the NREL Kestrel machine in which each script of the specific benchmark was run. After building with the steps shown in the provided scripts. The scripts also show how the strong scaling was run. To get the average of the time per timestep for our strong scaling plot, we used two scripts. One bash script to extract the AMR-Wind wallclock times for all cases run and one python script to find the mean. These are also generated from the scripts provided in this repo. Once the cases are run, one can use `bash amr-wind-average.sh` in each directory to generate an `amr-wind-avg.txt` file with the average time per timestep of each case. The number of cells in the AMR-Wind simulations is reported at the start of the simulation with the number of cells for each level. These numbers can be added together and divided by the number of CPU cores or GPUs in which the case was using to get the cells per CPU core or GPU. The LaTeX plot code is also provided as a reference of how the results were plotted using the results from the Kestrel benchmark runs, showing the time per timestep and number of cells per core or GPU.

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

AMR-Wind is able to run on different GPUs using the CMake configuration parameters: `AMR_WIND_ENABLE_CUDA`, `AMR_WIND_ENABLE_ROCM`, or `AMR_WIND_ENABLE_SYCL`, for NVIDIA, AMD, or Intel GPUs, respectively. GPU-aware MPI is also available in AMReX, and therefore AMR-Wind, which can benefit performance. The GPU-aware MPI library can be injected and linked during the CMake build however one sees fit. During runtime AMReX provides a `amrex.use_gpu_aware_mpi` parameter which can be set to 1 (`amrex.use_gpu_aware_mpi=1`) on the command line as shown in our example script.

The offeror should reveal any potential for performance optimization on the target system that provides an optimal task configuration by running As-is and Optimized cases. On CPU nodes, the As-is case will saturate all available cores per node to establish baseline performance and expose potential computational bottlenecks and memory-related latency issues. The Optimized case will saturate at least 70% of cores per node and will include configurations exploring strategies to identify opportunities for reducing latency. On GPU nodes, the As-is case will saturate all GPUs per node to evaluate GPU compute and memory bandwidth performance. The Optimized case will saturate all GPUs per node, along with optimizations focusing on minimizing data transfers and leveraging GPU-specific memory features, aiming to reveal opportunities for reducing end-to-end latency.

### Validation

Will write this next.

## Rules

* Any optimizations would be allowed in the code, build and task configuration as long as the offeror would provide a high-level description of the optimization techniques used and their impact on performance in the Text response.
* The offeror can use accelerator-specific compilers and libraries.

## Benchmark test results to report and files to return

The following AMR-Wind-specific information should be provided:

Will also write this next.
