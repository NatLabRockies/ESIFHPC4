# HPL

## Purpose and Description
HPL solves a random dense linear system in double precision arithmetic on distributed-memory. It depends on the Message Passing Interface, Basic Linear Algebra Subprograms, or the Vector Signal Image Processing Library. The software is available at the [Netlib HPL benchmark](https://www.netlib.org/benchmark/hpl/) and most vendors including ([Nvidia](https://docs.nvidia.com/nvidia-hpc-benchmarks/HPL_benchmark.html), [AMD](https://www.amd.com/en/developer/zen-software-studio/applications/pre-built-applications.html), and [Intel](https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-linux/2024-1/overview-intel-distribution-for-linpack-benchmark.html) offer hardware-optimized versions of it. The HPL benchmark assesses the floating-point performance by stressing cores and memory of the target system.

## Licensing Requirements

HPL is licensed per the COPYRIGHT notice in the hpl-2.3 folder.

## How to build

The source code of Netlib can be accessed here, [HPL](https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz). Build instructions are in the INSTALL file (top directory) and are summarized below: 
1. Download and extract the source file: `$ gunzip hpl-2.3.tgz; tar -xvf hpl-2.3`.
2. Copy a make file under the setup direcotry: `$ cp setup/Make.<arch> .`.
3. Build HPL: `$ make arch=<arch>`. This should create an executable in the bin/<arch> directory called xhpl.
4. Test the executable: `$ cd bin/<arch> && mpirun -np 4 xhpl`.

Optimized binaries of HPL can be obtained from [Intel-HPL](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-download.html?operatingsystem=linux&linux-install=offline) that is shipped with Intel MKL, [Zen-HPL](https://www.amd.com/en/developer/zen-software-studio/applications/pre-built-applications/zen-hpl-eula.html?filename=amd-zen-hpl-2024_10_08.tar.gz) and [Nvidia-HPL](https://developer.download.nvidia.com/compute/nvidia-hpc-benchmarks/redist/nvidia_hpc_benchmarks_mpich/linux-x86_64/nvidia_hpc_benchmarks_mpich-linux-x86_64-25.02.04-archive.tar.xz). 

## Run Definitions and Requirements

## Tests

Testing will include single-node and multi-node configurations. The single-node test exposes the compute capability of the unit by reducing the effect interconnect at a node level, while the multi-node test measures the overall system performance and exposes scaling and interconnect bottlenecks at the system level. In general, the problem size (`N`) should be tuned to saturate at least 80% of available system memory so that maximum peak performance would be acheived.

## How to run

To execute xhpl on CPUs, MPI with or without OpenMP support are required. The required input is number of nodes, total number of MPI ranks, total number of ranks per node and total number of OpenMP threads per MPI rank. The benchmark results can be obtained with Slurm cluster management: `srun -N <number of nodes> -n <total number of ranks> -c < number of cpus per task> ./xhpl`.

To run xhpl on GPUs, you need GPU-Aware MPI with or without OpenMP support for an optimal performance. The required input is number of nodes, total number of MPI ranks, total number of ranks per node, total number of OpenMP threads per MPI rank, and total number of GPUs per node. The benchmark results can be obtained with Slurm: `srun -N <number of nodes> -n <total number of ranks> --cpus-per-task=< number of CPUs per task> --gpus-per-node=<total number of GPUs per node> ./xhpl`.

The offeror should reveal any potential for performance optimization on the target system that provides an optimal task configuration by running As-is and Optimized cases. The As-is case will saturate at least 90% cores per CPU node to establish baseline performance and expose potential computational bottlenecks within the CPU’s floating-point performance and memory-related issues such as suboptimal memory bandwidth. The optimized case will saturate all NUMA-nodes and threads on the CPU node, and will include configurations exploring strategies for achieving the maximum FLOPS on the target system. On GPU nodes, the optimized case will saturate all GPUs and one thread per node, aiming to reveal opportunities for GPUs and the interconnect performance bottlenecks.

## How to validate

The run output should show that tests sucessfully passed, finished and ended, as in:
```
================================================================================
...
--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   0.000181904482 ...... PASSED
...
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================

```

## Run Rules

* Publicly available, optimized HPL versions or binaries are permitted. 
* Any optimizations would be allowed in the code, compilers and task configuration as long as the offeror would provide a high-level description of the optimization techniques used and their impact on performance in the Text response.
* The offeror could use an HPLv2.3.x or later version with GNU, Intel, or accelerator-specific compilers and libraries.

## Benchmark test results to report and files to return

* File response should include Make.myarch files or script, job submission scripts, stdout and stderr files, an environment dump, and HPL.dat files for each run.
* The Text response should include high-level descriptions of any optimizations and justification if the obtained performance vary from theoretical performance by less than 80%.
* For performance reporting, the performance reported in the output files and the theoretical performance should be entered into the Spreadsheet (`report/HPL_benchmark.csv`) response.