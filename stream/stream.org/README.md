STREAM
===

## Licensing
STREAM is licensed per http://www.cs.virginia.edu/stream/FTP/Code/LICENSE.txt.

## Description

STREAM is used to measure the sustainable memory bandwidth of high performance computers.
The code is available from [http://www.cs.virginia.edu/stream/ref.html](http://www.cs.virginia.edu/stream/ref.html)

We provide source code retrieved on : Wed Sep 16 09:36:13 MDT 2020 with changes to the
Fortran version of the code:


1.	Change the format statement<br>
9050 FORMAT (a,f10.1,3 (f10.4,2x))

This change was made to prevent a format overflow.

2. The source was also modified such that all integers are 8 bytes.

3. The array size and repeat count are optionally read from the command line.


## How to Build

An example Makefile is provided in src/. In addition, an example `test.sh` script is included
that builds and runs the benchmark.

The STREAM Triad benchmark uses 3 arrays of size N.
For the C version this can be controlled with `-DSTREAM_ARRAY_SIZE=<array_size>` during compilation,
where `array_size` is the number of elements in the array. For double-precision floats,
then, total array memory (GB) = 3 * STREAM\_ARRAY\_SIZE * 8 (bytes/float) / 1000<sup>3</sup>.
For the Fortran version array size is given on the command line.  

The offeror will build at least cases (1) and (2) of the benchmark. The third run is optional:

1.  default memory size defined in STREAM (_i.e._, not using `-DSTREAM_ARRAY_SIZE=<array_size>`; note that
     the Fortran source code has had a preprocessor definition added that sets the default array size
     to be consistent with the C version); and,

2.  a case which uses 60% of the total DRAM available to a single compute unit.

3.  a vendor-optimized version of the code which uses 60% of the total DRAM available to a single compute unit. 


## How to Run

The STREAM benchmark results must be returned for the following cases: 

 1. Fortran version: Number of threads in the range 1 to the number of cores on a compute unit.
 2. C version: Number of threads in the range 1 to the number of cores on a compute unit.

## Benchmark test results to report and files to return

<ins>Spreadsheet Response</ins>: We want data for all tests, Copy, Add, Scale, Triad for each thread/core counts as
shown in the file testrun1/STREAM.tab. It contains data from the testrun run on NREL's current HPC platform. 

```
head STREAM.tab 
Compiler	test	% mem	Size	Threads	Rate (MB/s)	Avg time	Min time	Max time	notes
icc	Add	 0.091	10000000	1	14841.4	0.016224	0.016171	0.016323	kestrel nodes
icc	Add	 0.091	10000000	24	100585.9	0.00242	0.002386	0.002462	kestrel nodes
icc	Add	 0.091	10000000	44	190039.3	0.001282	0.001263	0.001307	kestrel nodes
icc	Add	 0.091	10000000	64	882425.5	0.000298	0.000272	0.00037	kestrel nodes
icc	Add	 0.091	10000000	84	2242829.8	0.000132	0.000107	0.000209	kestrel nodes
icc	Add	 0.091	10000000	104	3640324.3	0.001012	6.6e-05	0.003417	kestrel nodes
ifc	Add	 0.183	20000000	1	14246.7	0.0338	0.0337	0.0341	kestrel nodes
ifc	Add	 0.183	20000000	24	95429.0	0.0051	0.005	0.0052	kestrel nodes
ifc	Add	 0.183	20000000	44	178639.4	0.0027	0.0027	0.0028	kestrel nodes
```

The script `post.py` pulls data from the output file and compiles it into `STREAM.tab`. 

Tests sould be run on all offered compute unit types. If the vendor offers different
optimization levels for this code, results should be reported in the "notes" field of the output.  

`post.py` has some values which should be set by the vendor.

```
#!/usr/bin/env python3
# The following lines need to be modified
# Compilers used
fort="ifc"
c="icc"
# Memory on a node
mem=262993528000
# Results file with a collection of streams runs
infile="results.icx.ifx"
# Output summary file
outfile="STREAM.tab"
# Notes can contain info about the nodes
notes="kestrel nodes"
```

If the tests are run on more than one configuration the final the spreadsheet submitted should contain a single table with 
data for each type appended below the previous one.  

<ins>File Response</ins>: Scripts, Makefiles, configuration files, environment dump, standard output, and standard error files for each reported run 
and results in tabular form as described above.

<ins>Text Response</ins>: Please describe all runtime settings such as pinning threads to cores, utilizing specific NUMA domains, etc. that impact STREAM results.

## Result validation

Output should indicate a valid solution, as in: 

`Solution Validates!`


