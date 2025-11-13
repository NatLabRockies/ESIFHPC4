# OSU Microbenchmarks

## Purpose and Description
The OSU Microbenchmark collection represents a suite of tests used to measure MPI performance in distributed computing systems. The tests include examples such as checking latency (ping-pong), measuring bandwidth rates across pairs of processes, collective tests, and other device based tests. The benchmarks are written in three different programming languages: C, Java, and Python. We use these tests to measure the performance of MPI functions on NREL HPC systems. The primary tests used are: latency, multi-bandwidth/multi-rate, all-to-all, and all-reduce. These tests are to be run both on standard CPU architecture and an accelerated architecture.

## Licensing Requirements

The OSU Microbenchmark collection is available under BSD licensing. Further information can be located here: https://mvapich.cse.ohio-state.edu/static/media/mvapich/LICENSE-OMB.txt

## Other Requirements
We require that two MPI distributions be tested - an MPI distribution of the vendors choice, and then any open-source distribution of MPI, such as MPICH or OpenMPI.

## How to build

We require a version of the OSU Micro-Benchmarks >= 7.4. The micro-benchmarks are downloaded from the following webpage: https://mvapich.cse.ohio-state.edu/benchmarks/ - the micro-benchmarks are compiled according to a standard 'configure' 'make' 'make install' pipeline. An example build/configuration script is located in the 'osu-scripts' directory, labelled as 'build.sh'. With a valid MPI distribution installed, the build script should install the Micro-benchmarks without any further configuration steps. As the final step, the executables for the required OSU Micro-benchmarks are copied to the current working directory.

## How to run

Example scripts for both CPU and Accelerated architectures are provided in the 'osu-scripts' directory, where there are example scripts provided for each OSU Micro-benchmark that is required. Note, these scripts are formatted for the SLURM Job Scheduler, but this is not a requirement, they can be modified to fit PBS/QSUB/others as necessary. Run requirements are listed below



## Run Definitions and Requirements

### CPU Architecture Run Requirements
A successful run of the OSU Micro-benchmarks is defined as a run of all four defined tests (alltoall, allreduce, latency, osu_mbw_mr) executed across the two requested MPI distributions on CPU architecture. Minimum requirements are listed below.


| Test          | Description                    | Nodes Used | Ranks Used          |
|---------------|--------------------------------|------------|---------------------|
| osu_latency   | Latency (Ping-Pong)            | 2          | 1 Per Node          |
| osu_mbw_mr    | Multi-Bandwidth & Message Rate | 2          | 80% Available Cores |
| osu_allreduce | All Reduce MPI Operations      | All        | 80% Available Cores |
| osu_alltoall  | All-To-All MPI Operations      | All        | 1 Per Nic           |

### Accelerated Run Requirements

A successful run of the OSU Micro-benchmarks on an accelerated architecture is defined as a run of the following two defined tests (alltoall, osu-mbw-mr) executed across the two requested MPI distributions on an accelerated architecture. Minimum requirements are listed below. If the number of NICs in a test system are greater than the number of accelerators, use one rank per NIC in place of accelerators.

| Test          | Description                    | Nodes Used | Ranks Used        |
|---------------|--------------------------------|------------|-------------------|
| osu_mbw_mr    | Multi-Bandwidth & Message Rate | 2          | 1 Per Accelerator |
| osu_alltoall  | All-To-All MPI Operations      | All        | 1 Per Accelerator |



## Benchmark data/results to return

### CPU Architecture
The OSU micro-benchmarks are required to be run to a message size of 65536kb (65mb), and for each micro-benchmark to be run a minimum of 5 times each in order to collect an average of the associated results. When the results from a given test are output, a table will be displayed containing the relevant information for the relevant OSU benchmark. Latency, Allreduce, and Alltoall will return latency information associated with the given operations, the Multi-bandwidth/message rate test will return a table that contains both the bandwidth and number of messages successfully sent at a given message size. 

### Accelerated Architecture
The OSU micro-benchmarks are required to be run to a message size of 524288kb (524mb), and for each micro-benchmark to be run a minimum of 5 times each in order to collect an average of the associated results. When the results from a given test are output, a table will be displayed containing the relevant information for the relevant OSU benchmark. The only two OSU tests that need to be run for accelerated architecture are All-to-All and Multi-Bandwidth & Message Rate

### Results To Return
Example results generated by the tests are located in the directory 'example-results' and are labelled according to OSU micro-benchmark. The average of results for each message size for each test should be returned in the associated benchmark reporting spreadsheet. 



