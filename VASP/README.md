# VASP

## Purpose and Description

- The Vienna Ab initio Simulation Package (VASP) is a computational program for atomic-scale materials modeling from first principles. It employs plane wave basis sets, making it particularly well suited for simulating periodic materials systems. 
- VASP is one of the most if not the most widely used software packages on our current HPC system, making its performance optimization a priority.
- *Benchmark 1* represents a typical high-accuracy band structure calculation, involving a multi-stage workflow: bootstrapping from an initial approximate GGA wavefunction, through a hybrid HSE function, to a final band structure from a GW calculation. As a multi-stage job, there are three distinct INCAR files supplied. VASP should be built appropriately for the standard or accelerated hardware and the `vasp_std` executable should be used for this benchmark.
- *Benchmark 2* represents a typical surface catalysis study, featuring a large unit cell with k-point sampling restricted to the Gamma point. It employs a single model chemistry (DFT with a GGA functional), and strong scaling with respect to MPI rank count is of primary interest. VASP should be built appropriately for the target hardware, and the `vasp_gam` executable should be used for this benchmark.

## Licensing Requirements

Must be arranged through developers or a commercial reseller. Please see:

https://www.vasp.at/info/faq/purchase_vasp/

## Other Requirements

- Benchmarks must be run with version 6.5.X.

- Requirements for building VASP 6.X.X can be found here: https://www.vasp.at/wiki/index.php/Installing_VASP.6.X.X

- At the time of writing this, the only accelerated port of vasp is OpenACC. More details on the required software stack can be found here: https://www.vasp.at/wiki/index.php/OpenACC_GPU_port_of_VASP#Software_stack 

## How to build

Instructions to build VASP 6 can be found here:
https://www.vasp.at/wiki/index.php/Installing_VASP.6.X.X

As a high level overview, building VASP typically involves:

1. Starting with a makefile.include template for your architecture (found in the arch folder of the distribution).

2. Making any necessary system-specific modifications.

3. Compile with make.

## How to run

VASP is run by simply calling `srun` on the appropriate executable (`vasp_std` or `vasp_gam`) in a folder in which the appropriate four input files can be found: `INCAR`, `KPOINTS`, `POSCAR`, `POTCAR`.

We have included a sample slurm submission script `job.slurm` for each benchmark, however, the #SBATCH parameters will need to be modified for different systems.  We have also included wrapper scripts to demonstrate how we would run and optimize the KPAR and NCORE parameters for the benchmark (`run-benchmark.sh` and `loop-benchmark.sh`, respecitvely.)

The benchmarks should be run with the Linux "time" command as illustrated in the sample submission scripts and this is the time that must be reported.

The benchmark results must be validated against the results supplied in the NREL-results folder. Python scrips called `validate.py` have been supplied in each folder that will do this. 

More detailed instructions for each benchmark can be found in the `README.md` within each folder. 

## Run Definitions and Requirements

1. Tests

Required: Results must be reported for both bench1 and bench2.

2. Code optimization

Required: Run the benchmark with code as-is or ported (as needed) following the definitions of `as is` and `ported` in the General Benchmark Instructions.

Optional: Results with optimized code may aditionally be reported.

3. Node classes

Required: Results must be reported for both standard nodes and accelerated nodes.

4. Node counts

Required: For each of the above, report results on 1 and 2 nodes/accelerators.

5. OpenMP usage

Required: For each of the above, always report performance without OpenMP (pure MPI). 

Optional: Runs using OpenMP may also be reported.

6. Process/thread placement

Standard runs: Use MPI ranks and threads (where applicable for optional openMP runs) such that the total number of cores used (ranks × threads) is at least 90% of the physical cores per node.

Accelerated runs: Use at least one MPI rank per accelerator. The Offeror is permitted to map ranks within a NUMA domain as desired, subject to limitations given in the General Benchmark Instructions.

For optimized runs, the Offeror is permitted to deviate from the above and instead use whatever core, device, or node count is considered optimal, under any placement scheme.


7. Reporting

For every run, the spreadsheet response should include run times from the Linux "time" command as illustrated in the provided example run script, converted to seconds. The "mpi-ranks" reported should reflect the number of physical cores hosting independent threads of execution, and the "threads" reported should be equal to the number of execution threads, where applicable.

In addition to content enumerated in the General Instructions, please return files OUTCAR and vasprun.xml for every run, as well as all validation output, as part of the File response.

## Additional Run Rules

KPAR and NCORE have great impact on the performance. The Offeror is permitted to vary these parameters to identify the best performance. 
   
## Validation

    a. Validation is achieved via scripts written in Python, version 3 (reference runs were validated with Python 3.7, but the Offeror may use other versions that support these scripts). This lends the validation process a certain degree of platform independence, and validation should be able to pass on any platform with a Python3 implementation, assuming this implementation is done to standard. Aside from the standard libraries alone, the validation process will require the `numpy` module.  
    
    b. The method of validation is described in the README.md file in each benchmark directory. 
    
    c. Neither the validation python scripts nor the reference data may be modified in any way by the Offeror, without prior written permission.   

    d. The directory containing reference data (*i.e.*, the OUTCAR* files) may be transferred to another machine if needed. For example, if the machine used for job execution did not have Python3 installed, the respondent may find it convenient to perform the validation elsewhere.