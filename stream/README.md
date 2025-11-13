# Stream

## Purpose and Description

- stream.[c,f] in stream.org are the standard memory bandwith test.
- pstream.c is a variation of stream designed to test the abillity to get good processor affinity.
- mstream.cu and stream.cu are GPU versions of stream.c

## Licensing Requirements

Open source

## Other Requirements

mstream.cu and stream.cu require GPUs

## How to build

Build procedures are described in the source directories. Complete examples can be found
in the test-run directories

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
