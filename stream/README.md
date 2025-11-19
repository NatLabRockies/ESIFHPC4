# Stream

## Purpose and Description

- stream.[c,f] in stream.org are the standard memory bandwith test.
- pstream.c is a variation of stream designed to test the abillity to get good processor affinity.
- mstream.cu and stream.cu are GPU versions of stream.c

The minimum tests to be run are stream.[c,f].  These are found in the directory 
stream.org.  The directory stream.org/testrun1 contains an example run script, 
test.sh, and outputs.  This can be used as the basis for a vendors runs.

If a vendor wishes to provide GPU nodes then stream.cu, or a vendor's similar
code should be run.  The source code, run scripts, environmental setting sould
be provided along with outputs. The program mstream.cu is a simple MPI extension
to stream.cu that can run on a collection of GPUs in parallel.

## Licensing Requirements

Open source

## Other Requirements

mstream.cu and stream.cu require GPUs

## How to build

Build procedures are described in the source directories. Complete examples can be found
in the test-run directories.  

## Run Definitions and Requirements

There are no criteria/acceptable thresholds except for pstream.c It must show that
there is good affinity mapping with no cores oversubscribed.

## How to run

Run procedures are described in the source directories.

### Tests

* stream.c - standard stream bechnmark
* stream.f - standard stream bechnmark
* pstream.c - affinity version of stream benchmark
* stream.cu - GPU stream
* mstream.cu - MPI version of GPU stream

The files in pstream/amd are alpha versions of AMD gpu tests.  The eventual goal is 
to merge these codes with mstream.cu.  Suggestions are welcome.

## Benchmark test results to report and files to return

These are also described in the source directory.
