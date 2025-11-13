# PSTREAM benchmark




## Purpose

This code runs a one of the standard stream benchmark tests, TRIAD.  The standard stream 
test is threaded using OpenMP.   This test adds MPI parallelism.  The total number of 
instance of Triad run is the product of the number of MPI tasks/node and the setting for 
OMP\_NUM\_THREADS.

The goal of this test is to show how tasks and threads map to cores.  In particular, we 
desire that  NCORES=(# MPI tasks)*(OMP\_NUM\_THREADS) cores are occupied and no two 
tasks/threads are on the same core.  Thus there  are two outputs, the normal TRIAD output a
and a thread report.  If there are particular command line options or environmental variables 
set to enable optimal placement these should be reported.  

## Typical build and run...

`mpicc -O3 -fopenmp pstream.c -o pstream
`


```
export OMP_NUM_THREADS=52
srun -n 4 --nodes=2 --tasks-per-node=2  ./pstream  -D -F -t 3 -T -s -2 1>pstream.out 2>pstream.triad
```

* -F     Run with a report of Task/thread mapping to nodes/cores
* -t 3   Run stream triad for a minimum of 3 seconds to keep the cores busy
* -T     Print start/end times
* -s -2  Set the scalar for triad to 2=abs(-2) and report on results

NOTE: The triad output is sent to stderr instead of stdout to make it easier to parse.

For a list of options:

```
srun -n 1 ./pstream -h 
```

## Example

```
srun -n 4 --nodes=2 --tasks-per-node=2  ./pstream  -D -F -t 3 -T -s -2 1>pstream.out 2>pstream.triad
```



#### "Sorting" output...


**sort -r pstream.triad**

```
STREAM_ARRAY_SIZE= 10000000
MPI_ID Function    Best Rate MB/s  Avg time     Min time     Max time  Called
     3 triad      290934.4         0.000861     0.000825     0.000946     164
     2 triad      317449.7         0.000781     0.000756     0.000848     172
     1 triad      321300.0         0.000782     0.000747     0.000867     174
     0 triad      315361.2         0.000786     0.000761     0.000843     168
```

This is similar to the normal Triad output but with task ID and the number of 
times the subroutine which runs triad is called.  It called in a loop until the 
run time is greater than the time given on the command line.


**grep ^0 pstream.out | sort -k3,3 -k6,6  > pstream.map**

**grep thread pstream.out ; grep x1000c0s0b0n1 pstream.map | head -3 ; echo ... ; echo ... ; grep x1000c0s0b0n1 pstream.map | tail -3**


```
task    thread             node name  first task    # on node  core
0000      0007         x1000c0s0b0n1        0000         0000  0000
0000      0011         x1000c0s0b0n1        0000         0000  0001
0000      0025         x1000c0s0b0n1        0000         0000  0002
...
...
0001      0019         x1000c0s0b0n1        0000         0001  0101
0001      0027         x1000c0s0b0n1        0000         0001  0102
0001      0035         x1000c0s0b0n1        0000         0001  0103
```

Here we use grep to pull the output for a single node, x1000c0s0b0n1.  The output for
the second node shows the same mappings.

The last column of this output reports the core on which a task/thread
is running.  We are running on nodes with 104 cores, 2 tasks per node,
and 52 threads.  Ideally, each core should be occupied and no core should
have running more than 1 thread.  

For some schedulers, compiler versions, MPI versions... additional environmental variables may 
need to be set to enable such an optimal mapping.  The vendor should provide the necessary 
settings to fully populate all cores with a various values for number of tass and number of 
threads when the two values multiplied together give the number of cores on a node.

## Help output

```
./pstream arguments:
          -h : Print this help message and exit.

no arguments : Print a list of the nodes on which the command is run and exit.

 -f          : When paired with -E, -B, -D print MPI task id and Thread id
               If run with OpenMP threading enabled OMP_NUM_THREADS > 1
               there will be a line per MPI task and Thread.
               If -E, -B, -D are not set then just run for the -t seconds.

 -F          : Add columns to tell first MPI task on a node and the numbering
               of tasks on a node. Should be paired with paired with -E, -B, -D

 -B, -D, -E  : Print thread pinning at 'B'eginning of the run, 'E'nd of the run,
               'D'uring, that is, after the first run of triad.
               Default is to not print thread info.
               With -B and -E  _B/_E will be appended to the node name.
 -t ######## : Time in seconds.  Run TRIAD to slow down the program and run
               for at least the given seconds.

 -s ######## : Constant for TRIAD calculation. If <0 then use abs(s)
               and reports stats for the calculation.

 -T          : Print time/date at the beginning/end of the run.

Typical run:
             mpirun -n 2 ./pstream -F -t 4 -D
 ```
## Running

The makefile does a simple build using mpicc with openmp enabled.

The script "runit" will call make to build the code and then run it. It will run with two
tasks per node on two nodes.  It should set the number of threads so that each node will
be full populated.  Fully populating the node is a requirement.  The test should be run
with various numbers of MPI tasks per node and on at least two nodes.  

## Report requirements

The primary output from the code is stdout.  This gives the mapping of tasks/threads to 
cores.  As we note above the results of the stream test itself is sent to stderr.  This
is a secondary output.  

The examples in test_run, runcpu and runit, produces afile unique.  Unique is a parse of 
the summary output showing the number of cores occupied by the tasks.  This is the 
"spreadsheet" output.  It lists the node names alone with the nubmer of cores.  In a 
successful run the number of cores occupied should be the (ntasks/node * OMP_NUM_THREADS).
We note in this case the run actually failed.  The nodes on which the test were run have
128 cores and less than that number of cores ocuppied indicating that some cores were
over subscribed.  The "fix" is compiler,scheduler,and processor dependent and is normally
specified via command line arguments and environmental variables.  Vendors will supply 
a "working" unique and the settings required to achieve it.




In addition to output from the program it is required to report any command line settings
and/or environmental variables required to get the shown mapping to cores.

The "runit" script has a short block for post processing the outputs to produce a summary.
This includes sorting the stdout to produce pstream.map.  This file can be quickly examined 
to see proper mappings of thread to cores.  The last column should list every core 1 time
for each node.  The summary output is not a required report.




