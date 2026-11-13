# FIO
## Purpose and Description
FIO (Flexible I/O Tester) is a tool for recreating specific workloads. 
We use it for single target testing from a single system. 
## Licensing Requirements
FIO is published under the GPL v2
## Other Requirements
None
## How to build
Any production version is acceptable. Build with libaio. 
Spack is the easiest way to build FIO with the correct options. To learn Spack, the tuturial readthedocs is recommended: https://spack-tutorial.readthedocs.io/en/latest/
> spack install  fio+libaio
## How to run
Run against local disks and network file systems. For parallel file systems, include only single target runs. 
Edit directory in file.  
Produce the output for each file provided by running the file, for example
> fio random-rw-local --output=random-rw-local.out

Run for 3 tests, random-rw, sequential-read, sequential-write
