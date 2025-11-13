# IOR

Source code: [https://github.com/hpc/ior](https://github.com/hpc/ior/releases/tag/4.0.0)

Documentation: https://ior.readthedocs.io/en/latest/

## Purpose and Description

IOR is designed to measure parallel file system I/O performance through a variety of potential APIs. This parallel program performs writes and reads to/from files and reports the resulting throughput rates. 

We use this benchmark to understand the performance of the proposed file systems.

## Licensing Requirements

IOR is licensed under GPLv2, see [here](https://github.com/hpc/ior?tab=License-1-ov-file)

## How to build

Documentation on installation [here](https://ior.readthedocs.io/en/latest/userDoc/install.html).

See example build script used to build IOR on Kestrel, `kestrel-example-build-script.sh`

These tests require MPI and HDF5.

## Run Definitions and Requirements

We define four IOR tests. Sample input files for these tests can be found in the IOR-tests folder. Note that test 4 is under development and not yet available as of August 1, 2025.

1. Fully sequential, large-transaction reads and writes, file-per-process, POSIX and MPI-IO
2. Fully sequential, large-transaction reads and writes, single file, MPI-IO only
3. Random, small transaction reads and writes, file-per-process, POSIX-only
4. HDF5 test meant to replicate the IO patterns of the [Rev](https://github.com/NREL/reV) application

For all tests:
- Repeat for each offered filesystem
- The size of the file must exceed 1.5x the aggregate RAM available
- Allow segment count to vary in order to fulfill the 1.5x RAM requirement
- Only the maximum, reproducible transfer rate achieved should be reported.
- Optimizations that would allow for page caching are not allowed.

For tests 1 and 2:
- Execute on a single node, 15% of offered nodes, and the number of nodes that results in max bandwidth.
- The single node test and the 15% of nodes test must be run with 80% of available cores subscribed. In addition, the vendor can optionally execute these tests with an optimal number of available cores, if this number is less than 80% of available cores.
- Transfer and block size can be changed to achieve optimal performance
- At least 80% of the node's RAM must be pre-populated (i.e. `memoryPerNode = 80%` or higher)

For test 3:
- Execute with POSIX only
- Execute on 15% of offered nodes only
- Transfer and block size cannot be changed
- At least 80% of the node's RAM must be pre-populated (i.e. `memoryPerNode = 80%` or higher)

In all cases, changes related to tuning must be practical for production utilization of the filesystem. For example, tuning that optimizes random I/O at the expense of large streaming I/O would not be practical for our expected mixed workload. The Offeror shall include details of any optimizations used to run these benchmarks, and distinguish parameters which may be set by an unprivileged user from those which would be globally set by system administrators.

## How to run

A sample input for each of the four tests is provided in the `IOR/IOR-tests/` folder.

For a full set of IOR inputs, see [IOR options](https://ior.readthedocs.io/en/latest/userDoc/options.html)

## Benchmark test results to report and files to return

In addition to items enumerated in the General Benchmark Instructions,

the Text response should include a high-level description of optimizations that would permit NREL to understand and replicate the optimized runs, as well as a description of:
- Relevant client and server features (node and processor counts, processor models, memory size, speed, OS)
- Client and server configuration settings important to understand performance
- Network interface options
- File system configuration options
- Storage and configuration for each file system
- Network fabric used to connect servers, clients, and storage
- Network configuration settings

The file response should include all and only those log files corresponding to runs with performance numbers in the Spreadsheet response
