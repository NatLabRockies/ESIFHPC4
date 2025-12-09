# AMR-Wind

## Description

AMR-Wind is a massively parallel, block-structured adaptive-mesh, incompressible flow solver for wind turbine and wind farm simulations. It depends on the AMReX library that provides mesh data structures, mesh adaptivity, and linear solvers to handle its governing equations. This software is part of the ExaWind ecosystem, and is available [here](https://github.com/exawind/AMR-Wind). The AMR-Wind benchmark is very sensitive to MPI performance due to all-reduce and all-to-all type MPI operations within AMReX's builtin MLMG solvers in which AMR-Wind utilizes. MPI performance is the bottleneck for AMR-Wind since AMR-Wind does little computation per cell.

## Licensing

AMR-Wind is licensed under BSD 3-clause license. The license is included in the source code repository, [LICENSE](https://github.com/Exawind/amr-wind/blob/main/LICENSE).

## Building

AMR-Wind utilizes the AMReX library and therefore runs on CPUs, or NVIDIA, AMD, or Intel GPUs. AMR-Wind uses CMake for its local build system. Explicit instructions for building AMR-Wind are provided in this repo as shown in the scripts we used to run the benchmark, while more general information for building AMR-Wind can be found [here](https://exawind.github.io/amr-wind/user/build.html). In this repo we provide the build scripts that were used to run the benchmarks shown in the plot for CPUs, GPUs, as well as GPU-aware MPI. These scripts also show exactly how the benchmarks were run to obtain results on the Kestrel machine, where the specific cases will be discussed in the next section.

This script runs on the CPUs using the CPU benchmark case and performs a strong scaling. Our best performance on the Kestrel machine uses 72 ranks per node with specific process bindings shown in the scripts. AMR-Wind is configured in this case to run calculatons for 20 timesteps and perform no I/O:
[amr-wind-benchmark-cpu.sh](amr-wind-benchmark-cpu.sh)

This script runs on the CPUs using the CPU benchmark case using a single run on 4 nodes. AMR-Wind is configured in this case to run calculatons for 20 timesteps and perform plot output at step 20. This plot output contains the physical quantities involved in the simulation:
[amr-wind-benchmark-cpu-verify.sh](amr-wind-benchmark-cpu-verify.sh)

This script is meant to run on GPUs using the GPU benchmark case which has 4x the number of cells as the CPU case. Again, it runs for 20 timesteps with no I/O and performs a strong scaling using 1 MPI rank per GPU:
[amr-wind-benchmark-gpu.sh](amr-wind-benchmark-gpu.sh)

This is the same as the previous GPU case but with GPU-aware MPI enabled on Kestrel:
[amr-wind-benchmark-gpu-aware.sh](amr-wind-benchmark-gpu-aware.sh)

This is the same as the previous GPU case but is run as a single simulation with plot output done at timestep 20:
[amr-wind-benchmark-gpu-verify.sh](amr-wind-benchmark-gpu-verify.sh)

## Run Definitions and Requirements

### Benchmark Case

We create a benchmark case on top of our standard `abl_godunov` regression test by adding runtime parameters on the command line. This case is designed to be either weak-scaled or strong scaled. This simulation runs a simple atmospheric boundary layer (ABL) that stays fixed in the Z dimension, but can be scaled arbitrarily in the X and Y dimensions. We also add a single refinement level across the middle of the domain to complete the exercising of the full AMR algorithm. Below, we show the CPU case done as a weak scaling merely to show that if different sizes of the simulation make more sense to run on other machines, this is the way we would weak scale it:

```
srun amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=64 64 64 geometry.prob_hi=1024.0 1024.0 1024.0
srun amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=128 128 64 geometry.prob_hi=2048.0 2048.0 1024.0
srun amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=256 256 64 geometry.prob_hi=4096.0 4096.0 1024.0
srun amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=512 512 64 geometry.prob_hi=8192.0 8192.0 1024.0
srun amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=1024 1024 64 geometry.prob_hi=16384.0 16384.0 1024.0
srun amr_wind abl_godunov.inp ${FIXED_ARGS} amr.n_cell=2048 2048 64 geometry.prob_hi=32768.0 32768.0 1024.0
```

## Running

The [run-all.sh](run-all.sh) script shows the nodes on the Kestrel machine in which each script of the specific benchmark was run. Note the scripts are provided as a blueprint of how our reference results were obtained and it is not expected they are to be followed exactly on other hardware. After building with the steps shown in the provided scripts. The scripts also show how the strong scaling was run. Once the simulations completed, the averaging scripts were run, then the total number of cells in the simulation were added together and divided by the number of CPU cores or GPUs. The average time per timestep was then plotted against the cells per CPU core or GPU. 

To get the average of the time per timestep for our strong scaling plot, we used two scripts that focus on averaging the `Total` time per timestep over 20 timesteps. One bash script to extract the AMR-Wind wallclock times for all cases run and one python script to find the mean. These are also generated from within the scripts provided in this repo. Once the cases are run, one can use `bash amr-wind-average.sh` in each directory to generate an `amr-wind-avg.txt` file with the average time per timestep of each case. The number of cells in the AMR-Wind simulations is reported at the start of the simulation with the number of cells for each level. These numbers can be added together and divided by the number of CPU cores or GPUs in which the case was using to get the cells per CPU core or GPU. For our results, this calculation was done manually and put into the [LaTeX plot code](amr-wind-strong-scaling-abl.tex). This shows exactly how our results were plotted from the information in the logs from the Kestrel benchmark runs, relating the time per timestep to the number of cells per core or GPU.

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
    bash amr-wind-average.py -f amr-wind-time-$i.txt >> amr-wind-avg.txt
    rm amr-wind-time-$i.txt
    ((i=i+1))
done
```

AMR-Wind is able to run on different GPUs using the CMake configuration parameters: `AMR_WIND_ENABLE_CUDA`, `AMR_WIND_ENABLE_ROCM`, or `AMR_WIND_ENABLE_SYCL`, for NVIDIA, AMD, or Intel GPUs, respectively. GPU-aware MPI is also available in AMReX, and therefore AMR-Wind, which can benefit performance. The GPU-aware MPI library can be injected and linked during the CMake build however one sees fit. During runtime AMReX provides a `amrex.use_gpu_aware_mpi` parameter which can be set to 1 (`amrex.use_gpu_aware_mpi=1`) on the command line as shown in our example script.

Although AMR-Wind is able to utilize threading through OpenMP, it is not typically used and development of OpenMP in AMR-Wind has seen little effort. Therefore, we are only interested in performance for flat MPI without threading.

### Verification

To verify that the results are close to expected, we compare the physical quantities of the plots output from AMR-Wind at time step 20 from our reference case running on 4 nodes in both the CPU and GPU cases. The AMReX tool used for comparing two plots is the `amrex_fcompare` executable, which is built automatically in the verify scripts. The location of `amrex_fcompare` is in `amr-wind-build/submods/amrex/Tools/Plotfile/amrex_fcompare`. The input for this program is two plotfiles and the output is a norm of the differences between all the variables in each AMR level in the simulation. Note the output from AMR-Wind on the CPUs is generally deterministic between runs. However, when running AMR-Wind on GPUs, output is nondeterministic, making it more difficult to understand if the results are sufficiently within bounds.

We provide a reference plot file from both our CPU case and GPU case, in which to compare. To use `fcompare`, it can run in serial as such:

```
/path/to/amr-wind-benchmark-cpu-verify/amr-wind-build/submods/amrex/Tools/Plotfile/amrex_fcompare amr_wind_cpu_reference_plt00020 /other/path/to/amr-wind-benchmark-cpu-verify/amr-wind-build/test/test_files/abl_godunov/plt00020
```

Note `fcompare` is an MPI application so it can be run with multiple ranks when the plot files are large. We expect differences due to different machines and compilers, etc. We expect the differences to be small for CPUs, but larger for GPUs. Although tolerances can be provided to fcompare to make it a boolean check, rather, we request that the output of fcompare is provided so it can be intepreted by a human. The same can be done for the GPU case using the provided GPU reference plot file.

Output from fcompare when running the CPU case on the reference machine and comparing it to the CPU reference plot can be seen [here](amr-wind-benchmark-kestrel-results/amr-wind-benchmark-cpu-fcompare-results.txt). Note it's deterministic between runs and it was run with multiple MPI ranks.

Output from fcompare when running the GPU case on the reference machine and comparing it to the GPU reference plot can be seen [here](amr-wind-benchmark-kestrel-results/amr-wind-benchmark-gpu-fcompare-results.txt). Note it's nondeterministic between runs, but close to machine precision when run twice on the same machine.

Also of note, when AMR-Wind is built for the GPU, `fcompare` from that build will run on the GPU as well. We used the CPU `fcompare` executable for comparing our both our CPU and GPU plot files in these benchmarks to be consistent.

## Rules

* Any optimizations would be allowed in the code, build, and task configuration as long as the offeror would provide a high-level description of the optimization techniques used and their impact on performance in the response.
* The offeror can use accelerator-specific compilers and libraries.
* We request that at least 90% of CPU cores on CPU nodes are utilized.
* We run 1 rank per GPU for AMR-Wind, however if running multiple ranks per GPU is beneficial, that would be allowed.

## Benchmark test results to report and files to return

The output from all the runs used to create the plot of the results from the Kestrel machine are provided [here](amr-wind-benchmark-kestrel-results) as a reference.

The AMR-Wind-specific information should be provided in the Excel spreadsheet which includes the other benchmarks, in the AMR-Wind tab.

Below is the plot of the results of the Kestrel reference system. Note the "naive" case is only shown to help display that Kestrel requires a very specific 72 rank per node configuration with specific process bindings on nodes with 2 network interconnect devices to achieve good performance for AMR-Wind. The "ideal" lines illustrate perfect linear scaling in each case.

![AMR-Wind Strong Scaling](https://github.com/NREL/ESIFHPC4/blob/main/AMR-Wind/amr-wind-strong-scaling-abl.tex.png?raw=true)
