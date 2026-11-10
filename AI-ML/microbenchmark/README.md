# AI-ML: GPU-GPU Collective Test

## Purpose and Description

This benchmark is intended to stress *GPU-GPU* (or more generally, *accelerator-accelerator*) network communication relevant to AI training through the use of an appropriate collective communication library (CCL). The exact implementation of this benchmark depends on the target's hardware architecture. For example, because Kestrel (our current flagship system) hosts NVIDIA H100 GPUs, our AllReduce tests utilize [NCCL](https://developer.nvidia.com/nccl). Running AllReduce utilizing any equivalent, readily available, and actively maintained CCL is satisfactory for this benchmark (e.g., NCCL, RCCL, or OneCCL). For guidelines on specific benchmark test implementations, please see [How to Run](#how-to-run).

## Licensing Requirements

None.

## Other Requirements

None.

## How to Build

Exact build instructions will depend on the chosen CCL implementation and hardware. For a specific example, please see the Slurm script [`build_nccl_cxi.sh`](./build_nccl_cxi.sh) for reference instructions on how we built NCCL with CXI-enabled libfabric on Kestrel. Note the use of a custom Open Fabrics Initiative (OFI) plugin to enable the use of HPE Slingshot communication protocols, which is needed because NCCL assumes an InfiniBand interconnect by default. This step may not be necessary depending on your hardware and network configuration.

## Run Definitions and Requirements

### How to Run

The specific implementation of the CCL benchmark depends on the proposed hardware. If the vendor has published an open-source implementation of tests that utilize their corresponding CCL, this implementation should be used in the baseline response. For example:

* NCCL tests: https://github.com/NVIDIA/nccl-tests 
* RCCL tests: https://github.com/ROCm/rocm-systems/tree/develop/projects/rccl-tests
* Intel OneCCL tests: https://www.intel.com/content/www/us/en/docs/oneccl/benchmark-user-guide/2021-14/benchmark.html

If an open-source implementation of CCL tests is not available, then the offeror may provide another implementation, but must report exactly how it was built & run, including the source code and any relevant scripts. The implementation must follow the rules outlined in the "baseline/ported/optimized" definitions in the technical specifications. Specifically, the implementation cannot use unknown or unpublished libraries, and any language interface or architecture-specific language constructs used must be well-documented and publicly available at the time of machine arrival.

### Tests

Two types of runs are requested to satisfy this benchmark: single-node and multi-node. In total, the requirements from four individual CCL configurations are described below. For each configuration, we ask for 5 replicate runs, for a total of 20 AllReduce runs. The final reporting table will reflect an aggregation of [the median timings and bandwidth values for the desired message sizes](#benchmark-test-results-to-report-and-files-to-return).

#### Single-node

To demonstrate intra-node CCL performance, each collective should be run across all available accelerated devices within a single node (see table below for details).

#### Multi-node

To demonstrate inter-node CCL performance, each collective should be run in three sets of multi-node jobs: 1. using 2 nodes, 2. using 15% of nodes proposed by the offerer, and 3. requesting the number of nodes *N* expected to saturate network bandwidth (see table below for details).

#### Summary of Requested Tests

In total, four tests (each consisting of 5 replicates) are required for this benchmark:

**Baseline/Ported Submissions**

*Baseline* and *ported* submissions should run a CCL AllReduce on 1, 2, 15% of nodes proposed by the offeror, and the minimal number *N* nodes required to achieve maximum out-of-place bus bandwidth across the system at the largest message size requested for the benchmark (4294967296). For this submission type, it is required to fix 1 rank per accelerator, and 1 CPU core per rank.

| Test          | Nodes Used  | Ranks Used        | CPU Cores per Rank | RDMA invoked | Number of Replicate Runs |
| :--           |:--          |:--                | :--                | :--          | :--                      |
| AllReduce     | 1           | 1 per accelerator | 1                  | If possible  | 5                        |
| AllReduce     | 2           | 1 per accelerator | 1                  | If possible  | 5                        |
| AllReduce     | 15%\*\*     | 1 per accelerator | 1                  | If possible  | 5                        |
| AllReduce     | *N*\*\*\*   | 1 per accelerator | 1                  | If possible  | 5                        |

**Optimized Submissions**

*Optimized* submissions should run a CCL AllReduce on 1, 2, 15% of nodes proposed by the offeror, and the minimal number *N* nodes required to achieve maximum out-of-place bus bandwidth across the system at the largest message size requested for the benchmark (4294967296). For this submission type, it is required to fix 1 rank per accelerator, though submitters are welcome to freely choose *N* CPU cores per rank.

| Test          | Nodes Used  | Ranks Used        | CPU Cores per Rank | RDMA invoked | Number of Replicate Runs |
| :--           |:--          |:--                | :--                | :--          | :--                      |
| AllReduce     | 1           | 1 per accelerator | *n*\*              | If possible  | 5                        |
| AllReduce     | 2           | 1 per accelerator | *n*\*              | If possible  | 5                        |
| AllReduce     | 15%\*\*     | 1 per accelerator | *n*\*              | If possible  | 5                        |
| AllReduce     | *N*\*\*\*   | 1 per accelerator | *n*\*              | If possible  | 5                        |


- \*For optimized submissions only, the offeror is allowed to freely choose the number of CPU cores per rank.
- \*\*15% of nodes proposed by offeror.
- \*\*\**N* refers to the number of nodes that achieves maximum out-of-place bus bandwidth across the system at the maximum message size (4294967296). On Kestrel, *N*=4.

### Run Rules

Any run must utilize all available accelerators on each node. For all configurations described above, the collective test should scan message sizes between 8B to 4GB, increasing by a factor of 2. The reducing operation must be `sum`, and the highest precision that is natively supported on the hardware (e.g., `double`) must be used. See [`run_nccl_cxi.sh`](./run_nccl_cxi.sh) for an example submission script of running `all_reduce_perf` on Kestrel from the official [nccl-tests](https://github.com/NVIDIA/nccl-tests/tree/master) repository following these rules.

## Benchmark Test Results to Report and Files to Return

**File response:** We request the raw data (including the command used to launch the CCL operation, the log file, and the run's submission script) associated with each CCL run be provided, demonstrating the bandwidth and latency for each message size. An example logfile is provided [below](#logfile-example-from-kestrel-reference-run-using-nccl). Additionally, any environment variables, fabric settings, and/or CCL configuration settings necessary to reproduce the results should be provided. The offeror should distinguish between parameters which may be set by an unprivileged user from those which would be globally set by system adminstrators. We specifically request that submitters who are offering accelerators capable of Remote Direct Memory Access (RDMA) should note whether they invoked GPU RDMA (e.g., by setting a variable such as `NCCL_NET_GDR_LEVEL=PHB`).

**Spreadsheet response:** We request the median out-of-place and in-place bandwidth and timings from five replicate runs of each case [described above](#summary-of-requested-tests), as well as high-level information about the system the benchmark was run on, to be reported in a spreadsheet (template [below](#spreadsheet-template)) for the following message sizes (in bytes):

- 8
- 524288
- 33554432
- 4294967296

**Results parsing script**: To facilitate reporting requirements, we provide a script as an example to parse and summarize NCCL AllReduce performance data in the necessary format. This script may have to be adapted by the offerer as necessary. Please refer to [`log-parser/README.md`](./log-parser/README.md) for more information on how to use this script.

### AllReduce Reference

Below are AllReduce results from Kestrel when running [`all_reduce_perf`](https://github.com/NVIDIA/nccl-tests/tree/master) built with the [custom NCCL+CXI plugin](https://github.com/NERSC/nccl-ofi-plugin) (described in [How to Build](#how-to-build)) to enable the use of the HPE Slingshot interconnect. This example output represents a run of 64 GPU devices across 16 nodes:

#### Spreadsheet Template 

See [spreadsheet-template.md](./spreadsheet-template.md) for example Kestrel data that is appropriately formatted for this benchmark response. Note that this template can also be generated from the embedded [log parsing utility](./log-parser/README.md) using the provided example files.

#### Logfile Example from Kestrel Reference Run Using NCCL

```
#
#                                                              out-of-place                       in-place
#       size         count      type   redop    root     time   algbw   busbw #wrong     time   algbw   busbw #wrong
#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            (us)  (GB/s)  (GB/s)
           8             2     float     sum      -1    59.83    0.00    0.00      0    50.15    0.00    0.00      0
          16             4     float     sum      -1    48.52    0.00    0.00      0    48.03    0.00    0.00      0
          32             8     float     sum      -1    49.18    0.00    0.00      0    48.92    0.00    0.00      0
          64            16     float     sum      -1    57.47    0.00    0.00      0    56.21    0.00    0.00      0
         128            32     float     sum      -1    56.61    0.00    0.00      0    57.15    0.00    0.00      0
         256            64     float     sum      -1    58.16    0.00    0.01      0    57.66    0.00    0.01      0
         512           128     float     sum      -1    60.88    0.01    0.02      0    61.13    0.01    0.02      0
        1024           256     float     sum      -1    68.15    0.02    0.03      0    72.95    0.01    0.03      0
        2048           512     float     sum      -1    76.24    0.03    0.05      0    71.22    0.03    0.06      0
        4096          1024     float     sum      -1    101.5    0.04    0.08      0    72.00    0.06    0.11      0
        8192          2048     float     sum      -1    92.31    0.09    0.17      0    292.2    0.03    0.06      0
       16384          4096     float     sum      -1    108.3    0.15    0.30      0    137.8    0.12    0.23      0
       32768          8192     float     sum      -1    174.0    0.19    0.37      0    102.1    0.32    0.63      0
       65536         16384     float     sum      -1    185.4    0.35    0.70      0    160.0    0.41    0.81      0
      131072         32768     float     sum      -1    482.6    0.27    0.53      0    235.5    0.56    1.10      0
      262144         65536     float     sum      -1    309.3    0.85    1.67      0    314.1    0.83    1.64      0
      524288        131072     float     sum      -1    835.3    0.63    1.24      0    462.2    1.13    2.23      0
     1048576        262144     float     sum      -1   1426.9    0.73    1.45      0   1380.6    0.76    1.50      0
     2097152        524288     float     sum      -1   2987.6    0.70    1.38      0   2825.5    0.74    1.46      0
     4194304       1048576     float     sum      -1   2305.9    1.82    3.58      0   2646.1    1.59    3.12      0
     8388608       2097152     float     sum      -1   2419.0    3.47    6.83      0   2418.1    3.47    6.83      0
    16777216       4194304     float     sum      -1   2202.9    7.62   14.99      0   1750.6    9.58   18.87      0
    33554432       8388608     float     sum      -1   2973.4   11.29   22.22      0   2636.4   12.73   25.06      0
    67108864      16777216     float     sum      -1   3152.7   21.29   41.91      0   3175.2   21.14   41.61      0
   134217728      33554432     float     sum      -1   6239.5   21.51   42.35      0   6235.4   21.53   42.38      0
   268435456      67108864     float     sum      -1    12425   21.60   42.53      0    12427   21.60   42.53      0
   536870912     134217728     float     sum      -1    23352   22.99   45.26      0    23229   23.11   45.50      0
  1073741824     268435456     float     sum      -1    49081   21.88   43.07      0    46386   23.15   45.57      0
  2147483648     536870912     float     sum      -1    92587   23.19   45.66      0    92579   23.20   45.67      0
  4294967296    1073741824     float     sum      -1   184959   23.22   45.72      0   185005   23.22   45.71      0

```

