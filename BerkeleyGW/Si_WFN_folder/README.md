# ESIF-HPC4 BerkeleyGW Workflow Input WFN Files

This directory contains the input WFN files for the BerkeleyGW workflow benchmarks.
The matrices are very large in size and are not kept in the repository.
You can find the matrix files at this link to the NERSC10 repository: 

https://portal.nersc.gov/project/m888/nersc10/benchmark_data/BGW_input

You can download them to your local machine using `wget`
The `wget_WFN.sh` script is provided to simplify the download process.

Note that on Kestrel's Lustre filesystems, I/O performance is greatly improved if the destination directory is striped before copying.  


