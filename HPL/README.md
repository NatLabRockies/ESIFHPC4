# HPL

## Purpose and Description
HPL solves a random dense linear system in double precision arithmetic on distributed-memory. It depends on the Message Passing Interface, Basic Linear Algebra Subprograms, or the Vector Signal Image Processing Library. The software is available at the [Netlib HPL benchmark](https://www.netlib.org/benchmark/hpl/) and most vendors including [Nvidia](https://docs.nvidia.com/nvidia-hpc-benchmarks/HPL_benchmark.html), [AMD](https://www.amd.com/en/developer/zen-software-studio/applications/pre-built-applications.html), and [Intel](https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-linux/2024-1/overview-intel-distribution-for-linpack-benchmark.html) offer hardware-optimized versions of it. The HPL benchmark assesses both the peak performance and the integrity of the system's hardware, from individual nodes to the entire system.

## Licensing Requirements

Netlib HPL is licensed per the COPYRIGHT notice in the hpl-2.3 folder.

## Build methods
HPL can be obtained in a number of ways.  These include:
* Using open source compilers and libraries and "configure"
* Using predefined make include files, or edits of such
* Downloading optimized binaries or containers

## Example build instructions using all open source components
In our example, we use gcc and openmpi, with openblas compiled against both. We then:
* Download the source, unpack it, and enter the directory
* Load our modules
* Set LDFLAGS to point to our openblas library directory
* ./configure
* make

This procedure is shown in the file test-run/simple.


## How to build using predefined config files

The source code of Netlib can be accessed here, [HPL](https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz). Build instructions are in the INSTALL file (top directory) and are summarized below: 
1. Download and extract the source file: `$ gunzip hpl-2.3.tgz; tar -xvf hpl-2.3`.
2. Copy a make file under the setup directory: `$ cp setup/Make.<arch> .`.
3. Build HPL: `$ make arch=<arch>`. This should create an executable in the bin/<arch> directory called xhpl.
4. Test the executable: `$ cd bin/<arch> && mpirun -np 4 xhpl`.

Optimized binaries of HPL can be obtained from [Intel-HPL](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-download.html?operatingsystem=linux&linux-install=offline) that is shipped with Intel MKL, [Zen-HPL](https://www.amd.com/en/developer/zen-software-studio/applications/pre-built-applications/zen-hpl-eula.html?filename=amd-zen-hpl-2024_10_08.tar.gz) and [Nvidia-HPL](https://developer.download.nvidia.com/compute/nvidia-hpc-benchmarks/redist/nvidia_hpc_benchmarks_mpich/linux-x86_64/nvidia_hpc_benchmarks_mpich-linux-x86_64-25.02.04-archive.tar.xz). 

## Run Validation

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

## How to run

To execute xhpl on CPUs, MPI with or without OpenMP support is required. The required input is number of nodes, total number of MPI ranks, total number of ranks per node and total number of OpenMP threads per MPI rank. For example, with Slurm, benchmark results can be obtained with: `srun -N <number of nodes> -n <total number of ranks> -c < number of cpus per task> ./xhpl`.  

To run xhpl on GPUs, you need GPU-Aware MPI with or without OpenMP support for an optimal performance. The required input is number of nodes, total number of MPI ranks, total number of ranks per node, total number of OpenMP threads per MPI rank, and total number of GPUs per node. For example, with Slurm, benchmark results can be obtained with: `srun -N <number of nodes> -n <total number of ranks> --cpus-per-task=< number of CPUs per task> --gpus-per-node=<total number of GPUs per node> ./xhpl`. 

### Tests

Testing will include single-node and multi-node configurations.

**CPU-only tests:**
For CPU-only nodes, the following scaling series from 1, 2, 4, 8, 16, 32, and 64 nodes should be submitted as part of the baseline results:
- One CPU core per MPI task, with at least 80% of CPU cores per node utilized

    
Optimized CPU-only submissions may use any binding scheme, number of MPI tasks, number of threads, etc.

**Accelerator-based tests:**
For accelerated nodes, the following two scaling series should be submitted as part of the baseline results:
- 1, 2, 4, 8, 16, 32, and 64 nodes, utilizing all devices, with one CPU core per MPI task
- A single-node scaling series of 1, 2, 4, 8, ..., up to all the devices available on the node, with one CPU core per MPI task

## Run Rules

- The problem size must fit at least 80% of CPU or GPU memory
- Publicly available, optimized HPL versions or binaries are permitted for baseline submissions.
- FP64 must be used for all baseline results. Precision must be reported for both baseline and optimized results.

## Benchmark test results to report and files to return

* The Make.myarch files or script, job submission scripts, stdout and stderr files from each run, an environment dump, and HPL.dat files shall be included in the File response.
* The Text response should include high-level descriptions of build and run optimizations.
* For performance reporting, the performance reported in the output files and the theoretical peak performance should be entered into the spreadsheet response.
