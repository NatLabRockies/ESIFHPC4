# Stream

## Purpose and Description

This benchmark test collection measures sustainable memory bandwidth on CPU and accelerator devices using STREAM.

The benchmark scope in this repository is:
1. CPU STREAM test (required)
2. Accelerator-based stream test (required)
3. CPU affinity verification using MPI+OpenMP STREAM TRIAD (`pstream`, optional)

Reference implementations included in this repository:
- `stream/stream.org/` contains C and Fortran CPU STREAM implementations (`stream.c`, `stream.f`) and a complete worked example in `stream/stream.org/testrun1/`.
- `stream/pstream/pstream.c` extends STREAM to expose task/thread/core placement quality.
- `stream/pstream/stream.cu` and `stream/pstream/mstream.cu` provide single-GPU and MPI multi-GPU STREAM-style runs.

Offerers may use equivalent implementations such as BabelStream, https://github.com/uob-hpc/babelstream, or vendor-optimized versions, but must follow the run definitions and reporting requirements below and return all build/run artifacts used to generate reported numbers.

## Licensing Requirements

Open source per https://www.cs.virginia.edu/stream/FTP/Code/LICENSE.txt

## How to build

Build procedures for the reference implementations are described in the source directories. Complete examples can be found in the test-run directories.  

## Run Definitions and Requirements

### Test 1: CPU STREAM test - required

Additional information on Test 1 may be found in `stream/stream.org/README.md` of this repository, including build and run instructions, reporting instructions, and example scripts for our provided reference implementations. The script `post.py` found at `stream/stream.org/testrun1/post.py` may be used to process the output files and report results. Instructions on using `post.py` are found in `stream/stream.org/README.md`.

For baseline submissions, the following test configurations should be reported:

Run configurations using the following memory size requirements:
1. Default STREAM memory size
2. A large-memory case using at least 80% of total RAM on a node.

With the following thread count requirements:
- Run thread counts from 1 to all available cores on-node at evenly-spaced intervals such that six different thread counts are reported (e.g., on the reference machine, we run stream with 1, 24, 44, 64, 84, and 104 threads). If the number of cores on the machine is not divisible by six, then 1 thread, and threads corresponding to all available cores should be used, with four additional thread counts chosen at as evenly-as-possible intervals. 

Results for all of Copy, Scale, Add, and Triad should be returned.

These results should be returned for all offered CPU node types, including the host CPU of accelerated nodes.

For baseline results, CPU Stream source code must either come from `stream/stream.org` within this repository, or directly from https://www.cs.virginia.edu/stream/, or  https://github.com/uob-hpc/babelstream. Note that our `stream/stream.org` contains minor source code modifications to `stream.f` to enable larger array sizes and fix a format statement. Any source code changes made to https://www.cs.virginia.edu/stream/ source (i.e., similar format/array size fixes), these changes must be reported. The offeror must use the STREAM kernels as implemented in the source code and not compile the source so that it utilizes external kernel implementations.

For optional optimized submissions, any core count/thread count may be used and any vendor-optimized kernel or stream implementation may be used, while using the above memory size requirements.

### Test 2: Accelerator-based STREAM test - required

Additional information on Test 2 may be found in `stream/pstream/gpustream.md` of this repository. 

We provide reference accelerator-based STREAM implementations for CUDA and HIP in `stream/pstream` under `stream.cu`/`mstream.cu` and `stream.hip`/`mstream.hip`. Note that these implementations are not required to be used. If an offeror wishes to submit a GPU STREAM test using their own implementation they may do so. It is not a requirement that the GPU STREAM submission be CUDA or HIP based. We provide these example implementations for reference.

The offeror must:
- Use an array size large enough to occupy at least 80% of each GPU memory.
- Return results for all of Copy, Scale, Add, Triad

Note that `mstream.cu` and `mstream.hip` are reference implementations for an optional MPI-based STREAM that executes on all available devices simultaneously. If the offeror wishes to return a parallel stream that utilizes all devices simultaneously, either via our provided reference implementations or through their own implementation, they may do so, but are not required.

### Test 3: CPU Affinity Verification (`pstream`) - optional

We provide `pstream` here for convenience. It is a STREAM-based reference implementation for demonstrating correct processor affinity behavior, as mentioned in the Technical Specifications.

Additional information on Test 3 may be found in `stream/pstream/pstream.md`.


## Benchmark Test Results to Report and Files to Return

### Spreadsheet response

Provide:
- CPU STREAM: Copy, Scale, Add, and Triad with thread counts, array size, rate (MB/s), and timings reported
- Accelerator-based STREAM: Copy, Scale, Add, and Triad with number of GPUs (if applicable/if using `mstream`), array size, rate, and timings reported
- `pstream` (optional): report the number of MPI tasks and threads per task used alongside the rate (triad only) and affinity


### File response

Include all artifacts for reported runs:
- Source modifications (if any)
- Build scripts/Makefiles
- Job scripts
- Output files

### Text response

If applicable, describe any tuning, source modification, and execution details needed to reproduce results, including thread/process placement controls and affinity settings