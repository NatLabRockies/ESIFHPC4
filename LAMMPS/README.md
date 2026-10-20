## Licensing
LAMMPS is open-source software licensed under the GPLv3. 

Description
-----------
This benchmark was generated using LAMMPS version 22-Jul-2025. The source code for this version is available from [https://github.com/lammps/lammps/releases/tag/stable_22Jul2025](https://github.com/lammps/lammps/releases/tag/stable_22Jul2025). Although we do not specify usage of a particular LAMMPS release, a recent version is preferred. 

This benchmark performs short simulations of a 35% LiCl solution pre-equlibrated to 300 K and 1 atm with about 0.75 million atoms in a cubic cell, ~20 nm on a side. We supply a LAMMPS parameter file `data.begin.bz2`. This compressed file must be uncompressed before any test runs, for example using `bunzip2 data.begin.bz2`. It contains coordinates and velocities of the atoms.

There are 3 benchmark sizes: small, medium, and large. The medium and large sizes are generated programatically via the LAMMPS `replicate` input flag in each respective input file, while the small benchmark uses the structure 'as-is' in the `data.begin` file. The medium size replicates data.begin into a 2x2x2 supercell and the large a 8x8x8. Each benchmark size is located in a separate directory with its own `lammps.in` file read by the `lmp` executable. 

For time performance benchmarks, only the medium and large benchmarks are required in the response. The small size is only provided for debugging/testing and optional responses. 

The benchmarks' timestep is all 1 fs. Thermodynamic summary quantities, such as the total system energy, are evaluated every $N_t$ timesteps, where $N_t$ is specified by the thermo_print LAMMPS input tag. The total number of timesteps each benchmark runs for is $10 N_t$ so that the number of thermodynamic evaluations is consistent among all jobs. The total number of timesteps taken in each benchmark can thus be increased by increasing $N_t$. $N_t$ is the only value in the LAMMPS input files that can be modified by the Offeror. It cannot be decreased, and may only be increased if a longer trajectory would better showcase the Offeror's system/performance. $N_t$ was selected such that all benchmarks ran in under ~10 minutes on NLR's Kestrel machine using the fewest resources that can hold each benchmark in memory. 

For the correctness validation part of the response, we only require 2 short medium benchmark runs, 1 for a Standard node and 1 for an Accelerated node. See the section below for further details and requirements. A directory with reference results and a validation script are provided in the `medium-validation` directory.

Sample Slurm scripts have also been provided for reference in `sample-slurm-scripts`. 

How to Build
------------
Optional libraries or packages included in the LAMMPS distribution (*e.g.*, the Intel package) may be used for all tests in the reporting spreadsheet.

LAMMPS can be built by following the instructions at [https://lammps.sandia.gov/doc/Install.html](https://docs.lammps.org/Build.html). For systems with GPUs, a version should be built with the LAMMPS GPU or KOKKOS package. All benchmarks should be run using FP64 for baseline, ported, or optimized submissions. 

How to Run  
---------- 

The total number of timesteps taken in each benchmark can be increased by increasing $N_t$. $N_t$ is the only value in the LAMMPS input files that can be modified by the Offeror. It cannot be decreased, and may only be increased if a longer trajectory would better showcase the Offeror's system/performance. See the Description above for further details about $N_t$.

### Medium benchmark scaling series
The medium benchmark targets message-rate-bound performance
#### CPU-only Submissions
- A strong scaling series of 1, 2, 4, and 8 nodes
- Baseline submissions should use MPI ranks such that the total number of cores used is at least 75% of the physical cores per node, with no OpenMP parallelization (i.e., `OMP_NUM_THREADS=1`). Optional optimized submissions may use any number of MPI ranks and/or OpenMP threads.
#### Accelerated Submissions
- A strong scaling series of 1, 2, 4, and 8 devices.
- If the offered accelerated nodes contain 8 or more devices, then one 8-device result must be returned in which the devices are divided across two nodes (i.e., 4 devices per node).

### Large benchmark scaling series
The large benchmark is intended to test multi-node performance
#### CPU-only Submissions
- N, 2N, and 4N node scaling series, where N may be chosen by the offeror (though can simply be N=1)
- Baseline submissions should use MPI ranks such that the total number of cores used is at least 75% of the physical cores per node, with no OpenMP parallelization (i.e., `OMP_NUM_THREADS=1`). Optional optimized submissions may use any number of MPI ranks and/or OpenMP threads.
#### Accelerated Submissions
- N, 2N, and 4N node scaling series, where N may be chosen by the offeror (though can simply be N=1)
- Baseline submissions should use all devices per node. Optional optimized submissions may use any number of devices per node.


How to Validate
---------------
Molecular dynamics simulations involve solving coupled partial differential equations and are thus Lyapunov unstable. As such, exact numerical reproducibility is challenging and not practical. Differences among systems can be reduced however by running using the same number of processors. In recognition of this, we are requesting validation only on two specific runs specifically targeted at validation. The performance results from these validation runs are not to be entered into the reporting sheet. The two runs should both use the `medium-validation/lammps.in`, with 64 MPI ranks, and `OMP_NUM_THREADS=1`. One should be run on a Standard node and one should be run on an Accelerated node. Sample Slurm scripts are provided in `medium-validation` directory. 

A script named `validate.py` is provided to validate system temperature and total energy data from the output of each of these runs against those obtained by NLR. The Offeror should run this script with the first argument as the path to the output file of a validation run, and the second argument the path to the provided directory `NLR_results` containing reference data. The general usage when running the script from the `medium-validation` directory is:

`./validate.py your_lammps_output_file_name.out NLR-results/lammps.out`

This script will print the temperature and energy for the reference NLR results and Offeror's validation run after 100 timesteps. These values should be approximately 300 and -8.9e+07, respectively. The next line gives the relative error between the NLR reference output provided by NLR in `medium-validation/NLR-results/lammps.out`) and the output from the test run. Reasonable relative deviations are less than 10<sup>-4</sup> for temperature and 10<sup>-5</sup> for energy. The validation script prints either "Run validated successfully" or "Run was NOT validated", depending on whether deviations are less than or greater than these thresholds, respectively.

Reporting Results
-----------------
For the Spreadsheet response, the target performance numbers are "s/timestep" (the inverse of "timesteps/s") as reported in the LAMMPS standard output stream. In addition to these values, the MPItasks, total number of steps that have been run, Loop time (s), and % CPU Usage must be included as well. Example logfile output looks like:

`Loop time of 105.823 on 96 procs for 2500 steps with 744000 atoms`

`Performance: 2.041 ns/day, 11.758 hours/ns, 23.624 timesteps/s, 17.576 Matom-step/s`

`93.8% CPU use with 96 MPI tasks x 1 OpenMP threads`

In this case, the MPI tasks is 96, number-of-steps is 2500, % CPU usage is 93.8, the loop time is 105.823 seconds, the speed is 23.624 timesteps/s, and the performance is 1/23.624 = 0.0423 s/timestep.

For convenience, we have provided a collection script that facilitates reporting by reading in a list of LAMMPS output file paths and printing a summary table:

`./collect-perf-results.py file1.out file2.out ...`

All NLR results can be collected via the helper script `summarize_nlr_results.sh`.

A summary of NLR's standard node results is shown below. These results were generated using dual socket Intel Xeon Sapphire Rapids CPU nodes with 96 MPI tasks per node and `OMP_NUM_THREADS=1`.

| Benchmark | NumberOfNodes | MPItasks | Nsteps | LoopTime(s) | %CPUusage | Performance(timesteps/s) | Performance(s/timestep) |
|:---------:|:-------------:|:--------:|:------:|:-----------:|:---------:|:------------------------:|:-----------------------:|
|   Small   |       1       |    96    |  2500  |   105.823   |    93.8   |          23.624          |          0.0423         |
|   Small   |       2       |    192   |  2500  |    59.086   |    95.3   |          42.311          |          0.0236         |
|   Small   |       4       |    384   |  2500  |    81.790   |    98.2   |          30.566          |          0.0327         |
|   Medium  |       1       |    96    |  1500  |   512.447   |    96.0   |           2.927          |          0.3416         |
|   Medium  |       2       |    192   |  1500  |   266.000   |    97.4   |           5.639          |          0.1773         |
|   Medium  |       4       |    384   |  1500  |   137.532   |    97.8   |          10.907          |          0.0917         |
|   Large   |       4       |    384   |   100  |   578.232   |    98.6   |           0.173          |          5.7803         |
|   Large   |       8       |    768   |   100  |   307.673   |    98.8   |           0.325          |          3.0769         |

A summary of NLR's accelerated node results is shown below. These results were generated using dual socket nodes with AMD Genoa CPU and four NVIDIA H100 SXM GPUs with 80 GB memory using 32 MPI tasks per node and all GPUs on each node and `OMP_NUM_THREADS=1`.

| Benchmark | NumberOfGPUs | MPItasks | Nsteps | LoopTime(s) | %CPUusage | Performance(timesteps/s) | Performance(s/timestep) |
|:---------:|:------------:|:--------:|:------:|:-----------:|:---------:|:------------------------:|:-----------------------:|
|   Small   |       4      |    32    |  2500  |    41.609   |    90.1   |          60.084          |          0.0166         |
|   Small   |       8      |    64    |  2500  |    27.442   |    92.5   |          91.101          |          0.0110         |
|   Medium  |       4      |    32    |  1500  |   123.490   |    86.4   |          12.147          |          0.0823         |
|   Medium  |       8      |    64    |  1500  |    68.617   |    89.5   |          21.861          |          0.0457         |
|   Medium  |      16      |    128   |  1500  |    43.620   |    92.6   |          34.387          |          0.0291         |
|   Medium  |      32      |    256   |  1500  |    26.965   |    94.3   |          55.628          |          0.0180         |
|   Large   |      32      |    256   |   100  |    77.151   |    96.9   |           1.296          |          0.7716         |
|   Large   |      48      |    384   |   100  |    52.242   |    96.3   |           1.914          |          0.5225         |
|   Large   |      64      |    512   |   100  |    41.950   |    96.0   |           2.384          |          0.4195         |

## What Must be Returned
LAMMPS output logs containing the standard LAMMPS output, timestep logs, and final timing reports for any jobs in the reporting sheet (both for validation and new hardware performance testing) should be included in the File Response. As part of the file response, include all the build environment, source, and make files used to build on the target platform, input files and run scripts. 

Benchmark 'Test' (in the Offeror Run Type column) results returned by the Offeror should include in the reporting spreadsheet the number of time steps the job takes (Nsteps), the final Loop Time (LoopTime(s)), the % CPU usage (%CPUusage), the Performance in timesteps/s (Performance(timesteps/s)), and the Performance in s/timestep (Performance(s/timestep); calculated as simply the inverse of Performance in timestep/s). The loop time can be found from the LAMMPS output file after the lsat timestep from the line starting with "Loop time". The Performance values can be found from the LAMMPS output file after the Loop Time line from the line starting with "Performance:". The % CPU usage values can be found from the LAMMPS output file after the Performance summary line from the line containing "CPU use". The hardware configuration (i.e. the number of elements from each pool of computational resources) and category of response (Baseline [as-is], Ported, Optimized) needed to achieve the estimated timings must also be provided (Node Class, Code, Benchmark Size, Number of Nodes, Number of Devices (if applicable), and Number of MPI Tasks).

Below is a summary list of the minimum set of requested runs:

For Validation:
* Medium benchmark single run, standard nodes
* Medium benchmark single run, accelerated nodes

For Performance:
* Medium benchmark scaling series, standard nodes
* Medium benchmark scaling series, accelerated nodes
* Large benchmark scaling series, standard nodes
* Large benchmark scaling series, accelerated nodes

For 'Projection' results on future hardware, the Offeror should enter any relevant hardware values relevant to reporting performance (e.g., node counts and/or number of devices), along with the Performance(timesteps/s) and Performance(s/timestep) columns. The projected LoopTime(s) (i.e., including I/O time) and %CPUusage values for these benchmarks are optional to return by the Offeror. 

