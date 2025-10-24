# WRF
## Purpose and Description

The Weather Research and Forecasting model (WRF) from [NCAR](https://www.mmm.ucar.edu/weather-research-and-forecasting-model) is a mesoscale numerical system used in atmospheric research and operational forecasting. [AceCAST] (https://tempoquest.com/acecast/), a commercially available version of WRF, runs on high-performance GPUs. This benchmark stresses the target system cores and memory bandwidth through data movement and IO operations, and measures its effect on application performance and throughput.

## Licensing Requirements

The WRF Model is open-source code in the public domain, and its use is unrestricted. The WRF public domain notice and related information may be found [here](https://www2.mmm.ucar.edu/wrf/users/public.html).

## How to build

Build instructions for any `WRF` and `WPS` can be found [here](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php). Additionally, build instruction for AceCAST can be found [here](https://acecast-docs.readthedocs.io/en/latest/InstallationGuide.html#). For building [WRFv4.6.1 and WPSv4.6.0](https://nrel.github.io/HPC/Documentation/Applications/wrf/) on the reference system, the following programming environment and library modules were loaded. The configuration files for WRF (`script/configure.wrf`) and WPS (`script/configure.wps`) are provided in this repository.

```
1) PrgEnv-gnu/8.5.0    2) cray-mpich/8.1.28  3) cray-libsci/23.12.5
4) zlib/1.3.1	       5) hdf5/1.14.6	     6)  pnetcdf/1.14.0
7) netcdf-c/4.9.3      8) netcdf-fortran/4.6.1
9) libpng/1.6.47       10) jasper/1.900.1

```

## Run Definitions and Requirements

### Tests

The CONUS benchmarks (`CONUS-12km` and `CONUS-2.5km`) will be provided in this repository for testing the performance and throughput of the target system. CONUS-12km will be fitting within a single node’s CPUs or GPUs capacity and exposes processing speed and floating-point capabilities of the compute unit at a node level, while CONUS-2.5km spans multiple nodes and exposes system throughput and performance bottlenecks at a system level. In addition, reference WRF output files (`conus_2.5km/rsl.out.0000.*` and `conus_12km/rsl.out.0000.*`) will be provided for validating your run outputs using the `diffwrf` program. The program will compare your output with the reference output file and generate difference statistics for each field that is not bit-for-bit identical to the reference output. The following command can be issued to obtain differences between the outputs (diffout_tag), where tag is name of a run.

```
$ ${WRF_DIR}/external/io_netcdf/diffwrf wrfout_d01_2019-11-27_00:00:00 wrfout_reference > diffout_tag

```

## How to run
The [Conus2.5km](https://www2.mmm.ucar.edu/wrf/users/benchmark/v44/v4.4_bench_conus2.5km.tar.gz) and [Conus12km](https://www2.mmm.ucar.edu/wrf/users/benchmark/v44/v4.4_bench_conus12km.tar.gz) WRFV4.4 benchmarks will be used for measuring throughput and scaling of WRF on the target system.

* To run WRF on CPUs, copy wrfinput_d01, wrfbdy_d01, namelist.input, and *.dat from the benchmark directory and copy runtime files from `${WRF_DIR}/run/*` in the run directory. The benchmark results can be obtained using `srun` as following:
  
  ```
  $ srun -N <total number of nodes> -n <total number of MPI ranks per node> --ntasks-per-node=<number of MPI ranks per node> ${WRF_DIR}/main/wrf.exe

  ```

* To run AceCAST on GPUs, copy runtime files from `acecast-v4.0.2/acecast/run/*`, and copy wrfinput_d01, wrfbdy_d01, namelist.input, and *.dat files from benchmark directory in the run directory. The benchmark results can be obtained using `mpirun` as following:

  ```
  $ mpirun -n <total number of MPI ranks> -N < Number of MPI ranks per node> --hostfile hostfile ./gpu-launch.sh ./acecast.exe

  ```

The offeror should reveal any potential for performance optimization on the target system that provides an optimal task configuration by running As-is and Optimized cases. On CPU nodes, the As-is case will saturate all available cores per node to establish baseline performance and expose potential computational and memory bottlenecks. The optimized case will saturate at least 90% of cores per node and will include configurations exploring strategies to identify opportunities for reducing inter-node communication, data storage, or other systemic issues. On GPU nodes, the As-is case will saturate all GPUs per node to evaluate GPU compute capabilities and memory bandwidth performance. The Optimized case will saturate all GPUs and CPU threads per node, along with optimizations focusing on minimizing data transfers and leveraging GPU-specific memory features, aiming to reveal opportunities for reducing latency caused by interconnect and file IO operations.

The Offeror should run 4-6 concurrent job instances of the benchmark on the target system. The harmonic-mean of the runtime from the concurrent jobs will be used for reporting strong-scaling results. This repository includes a script (`script/wrf_stats.py`) to obtain runtimes from individual output files. The application throughput can be computed as following: `throughput = allocation factor * node-class count) / (number of nodes * runtime)`. EKY: Make this a single instance, no mean, define summation of time, do we need 12km? maybe not, keep in as debugging aid but not requirement for performance report

## Run Rules

* The Offeror can use any WRFv4.6.x and WPSv4.6.x version, with later gnu or intel compilers and libraries, and change the provided configure scripts as needed. EKY: don't restrict compilers
* The smaller benchmark (`CONUS-12km`) might not scale across compute units within a node, which limits demonstration of future hardware capabilities. In such a case, the offeror may use the larger benchmark (`CONUS-2.5km`) for a single-node test with an accompanying justification for the change in the Text response if the data fits within the available GPU memory and there is sufficient memory bandwidth.
* Any optimizations would be allowed in the code, build and task configuration as long as the offeror would provide a high-level description of the optimization techniques used and their impact on performance in the Text response.

## Benchmark test results to report and files to return

* For scaling and throughput reporting, the harmonic mean of the wallclock time (`Timing for main`) reported in `rsl.out.0000` files should be entered into the Spreadsheet (`report/wrf_benchmark.csv`) response.
* The Text response should include descriptions of optimizations and justification if run outputs vary from Reference outputs provided.
* The file response should include namelist.input, configure.wrf, rsl.error.0000 and rsl.out.0000, and diffout_tag files
