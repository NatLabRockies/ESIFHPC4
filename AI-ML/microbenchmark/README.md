# AI-ML: GPU-GPU Collective Test

## Purpose and Description

This benchmark is intended to stress GPU-GPU (or accelerator-accelerator) network communication relevant to AI training through the use of an appropriate collective communication library (CCL). The exact implementation of this benchmark depends on the target's hardware architecture. For example, because Kestrel (NREL's current flagship system) hosts NVIDIA H100 GPUs, we implement AllReduce tests using [NCCL](https://developer.nvidia.com/nccl). Running AllReduce on any equivalent CCL for other hardware is satisfactory for this benchmark.

## Licensing Requirements

None.

## Other Requirements

None.

## How to build

See the Slurm script [`build_nccl_cxi.sh`](./build_nccl_cxi.sh) for reference instructions on how we built NCCL with CXI-enabled libfabric on Kestrel. Note the use of a custom Open Fabrics Initiative (OFI) plugin to enable the use of HPE Slingshot communication protocols, which is needed because NCCL assumes an InfiniBand interconnect by default. This step may not be necessary depending on your hardware and network configuration.

## Run Definitions and Requirements

On Kestrel, the maximum out-of-place bus bandwidth is ~45.7 GB/s as measured by NCCL AllReduce. See "Benchmark test results to report and files to return" below for reference.

## How to run

See [`run_nccl_cxi.sh`](./run_nccl_cxi.sh) for an example submission script of running `all_reduce_perf` on Kestrel from the official [nccl-tests](https://github.com/NVIDIA/nccl-tests/tree/master) repository.

The specific implementation of the CCL benchmark depends on the proposed hardware. Some non-exhaustive examples are below:

* NCCL tests: https://github.com/NVIDIA/nccl-tests 
* RCCL tests: https://github.com/ROCm/rccl-tests
* Intel OneCCL tests: https://www.intel.com/content/www/us/en/docs/oneccl/benchmark-user-guide/2021-14/benchmark.html 

Offerors may choose another implementation, but must report exactly how it was built & run, including relevant scripts.

### Tests

Two types of runs are requested to satisfy this benchmark: single-node and multi-node. In total, the requirements from 5 individual CCL configurations are described below. For each configuration, we ask for 5 replicate runs, for a total of 25 AllReduce runs.

#### Single-node

To demonstrate intra-node CCL performance, each collective should be run across all available accelerated devices within a single node.

#### Multi-node

To demonstrate inter-node CCL performance, each collective should be run in four jobs with increasingly large node counts *n* (in which *n* >= 2).

## Run Rules

For all configurations described above, the collective test should scan from 8B to 4GB message sizes, incrementing by a factor of 2. For example:

```
all_reduce_perf -b 8 -e 4G -f 2
```

**Options:**
- `-b`: Minumum size in bytes
- `-e`: Maximum size in bytes
- `-f`: Increment factor


## Benchmark test results to report and files to return

**File response:** We request the raw data associated with each CCL run, demonstrating the bandwidth and latency for each message size. An example logfile is provided [below](#allreduce-reference).

**Spreadsheet response:** We request the out-of-place and in-place bandwidth and latency to be reported in a spreadsheet (template below) for the following message sizes:
* 524288
* 33554432
* 4294967296

### AllReduce reference

Below are AllReduce results from Kestrel when running [`all_reduce_perf`](https://github.com/NVIDIA/nccl-tests/tree/master) built with the [custom NCCL+CXI plugin](https://github.com/NERSC/nccl-ofi-plugin) (described in 'How to build') to enable the use of the HPE Slingshot interconnect. This example output represents a run of 64 GPU devices across 16 nodes:

**Spreadsheet Template:**

|System|Replicate|Collective Operation|Command|Number of devices|Number of nodes|Message size (B)|Out-of-Place Latency (uS)|Out-of-Place Algorithmic Bandwidth (GB/s)|Out-of-Place Bus Bandwidth (GB/s)|In-Place Latency (uS)|In-Place Algorithmic Bandwidth (GB/s)|In-Place Bus Bandwidth (GB/s)|
|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|
|Reference (Kestrel)|1|AllReduce|all_reduce_perf -b 8 -e 4G -f 2|64|16|524288|835.3|0.63|1.24|462.2|1.13|2.23|
|Reference (Kestrel)|1|AllReduce|all_reduce_perf -b 8 -e 4G -f 2|64|16|33554432|2973.4|11.29|22.22|2636.4|12.73|25.06|
|Reference (Kestrel)|1|AllReduce|all_reduce_perf -b 8 -e 4G -f 2|64|16|4294967296|184959|23.22|45.72|185005|23.22|45.71|

**Logfile Example:**

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