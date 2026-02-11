# mdtest

Source code: https://github.com/hpc/ior

Documentation: https://ior.readthedocs.io/en/latest/index.html

mdtest-specific documentation: https://github.com/hpc/ior/blob/main/doc/mdtest.1

Note that mdtest comes packaged with IOR.

## Purpose and Description

mdtest is designed to characterize metadata performance of a filesystem. 

The purpose of this benchmark is to measure the performance of file metadata operations on each proposed globally accessible file system.

## Licensing Requirements

mdtest is licensed under GPLv2, see [here](https://github.com/hpc/ior?tab=License-1-ov-file).

## How to build

mdtest comes packaged with IOR. Please see the ESIF-HPC-4 IOR page for build information [here](https://github.com/NatLabRockies/ESIFHPC4/tree/main/IOR) and example build instructions on Kestrel [here](https://github.com/NatLabRockies/ESIFHPC4/blob/main/IOR/kestrel_example_build_script.sh). mdtest requires MPI. 

## Run Definitions and Requirements

For each proposed globally accessible file system, the Offeror shall run the following tests:

- Test A: Creating, statting, and removing 2<sup>20</sup> files in a single directory
- Test B: Creating, statting, and removing 2<sup>20</sup> files in separate directories (16 files each, 1-deep)
- Test C: Creating, statting, and removing 2<sup>20</sup> files in separate directories, one MPI task per directory (via `-u` flag)

Each test will be run for the POSIX API. Each of these tests should be run at the following process concurrencies:

- A single process
- The optimal number of MPI processes on a single compute node
- The minimum number of MPI processes on multiple compute nodes that achieves the peak results for the proposed system

MPI ranks must be placed consecutively on nodes, not round-robin or other schemes across nodes. MPI ranks must be evenly distributed on nodes.

Observed benchmark performance shall be obtained from file systems configured as closely as possible to the proposed file systems. If the proposed storage solution includes multiple performance tiers directly accessible by applications, benchmark results shall be provided for all such tiers. The benchmark is intended to measure the capability of the storage subsystem to create, stat, and delete files. The Offeror should not utilize optimizations that cache or buffer file metadata or metadata operations in compute node (client) memory.

## How to run

It is important to note that the total number of ranks for a given run must be a power of 2.

We provide an example script `kestrel-mdtest-example-run-simple.sh` running mdtest on 16 nodes with a slurm scheduler.

## Useful input flags

Available options may be displayed with the "-h" option to mdtest. Useful options include

- `-u` If present, each MPI task works on its own directory
- `-C` Turn on file and directory creation tests
- `-T` Turn on file and directory stat tests
- `-r` Turn on file and directory remove tests
- `-n` number of files and directories per MPI process
- `-d` absolute path to directory in which the test should be run
- `-z=depth` The depth of a hierarchical directory structure below the top-level test directory for each process
- `-I=files_per_dir` number of items per directory per rank in tree
- `-N tasks_per_node` To defeat caching effects. This provides the rank offset for the different phases of the test, such that each test phase (read, stat, delete) is performed on a different node (the task that deletes a file is on a different node than the task that created the file). This parameter must be set equal to the number of MPI processes per node.

## Reporting Results
The `File creation`, `File stat` and `File removal` rates from stdout should be reported. The maximum values for these rates must be reported for all tests. Reporting maximum rates for the same test configuration that come from different runs is not permitted. For example, if the highest observed file creation rate came from a different run than the highest observed stat rate, please report both runs and their corresponding node count/rank count.
 * Rates should be recorded as part of the spreadsheet response.
 * In addition, as part of the File response the Offeror shall provide all output files corresponding to the numbers in the spreadsheet response. If performance projections are made, all output files on which the projections are based must also be provided.
 * For each run reported, the text response should include the mdtest command lines used and the correspondence to the associated table in the Spreadsheet response. 

## Benchmark Platform Description
In addition to the information requested in the General Benchmark instructions, the benchmark report for mdtest should include 
 * The file system configuration and mount options used for testing
 * The storage media and configurations used for each tier of the storage subsystem
 * Network fabric used to connect servers, clients and storage including network configuration settings and topology



