# VASP

## Purpose and Description

- The Vienna Ab initio Simulation Package (VASP) is a computational program for atomic-scale materials modeling from first principles. It employs plane wave basis sets, making it particularly well suited for simulating periodic materials systems. 
- VASP is one of the most if not the most widely used software packages on our current HPC system, making its performance optimization a priority.
- *Benchmark 1* represents a typical high-accuracy hybrid-functional calculation using the HSE exchange–correlation functional. The workload consists of a single `INCAR` and no longer includes the previous multi-stage GGA→HSE→GW sequence. VASP should be built appropriately for the standard or accelerated hardware, and the `vasp_std` executable should be used for this benchmark.
- *Benchmark 2* represents a typical surface catalysis study, featuring a large unit cell with k-point sampling restricted to the Gamma point. It employs a single model chemistry (DFT with a GGA functional), and strong scaling with respect to MPI rank count is of primary interest. VASP should be built appropriately for the target hardware, and the `vasp_gam` executable should be used for this benchmark.

## Licensing Requirements

Must be arranged through developers or a commercial reseller. Please see:
https://www.vasp.at/info/faq/purchase_vasp/

## Other Requirements

- Benchmarks must be run with at least version 6.5.X because we have found numerical differences in the results for Benchmark 2 with earlier versions of VASP. 
- Requirements for building VASP 6.X.X can be found here: https://www.vasp.at/wiki/index.php/Installing_VASP.6.X.X
- Offerors may use a compiler toolchain of their choice provided benchmark validation criteria are met.
- At the time of writing this, the only accelerated port of vasp is OpenACC. More details on the required software stack can be found here: https://www.vasp.at/wiki/index.php/OpenACC_GPU_port_of_VASP#Software_stack 

## How to build

Instructions to build VASP 6 can be found here:
https://www.vasp.at/wiki/index.php/Installing_VASP.6.X.X

As a high level overview, building VASP typically involves:
1. Starting with a makefile.include template for your architecture (found in the arch folder of the distribution).
2. Making any necessary system-specific modifications.
3. Compile with `make`.

## How to run

VASP is run by simply calling the appropriate parallel launcher (e.g. `srun`, `mpirun`, etc.) on the appropriate executable (`vasp_std` or `vasp_gam`) in a folder in which the appropriate four input files can be found: `INCAR`, `KPOINTS`, `POSCAR`, `POTCAR`.

We have included a sample Slurm submission script `job.slurm` for each benchmark within the `NLR-results` folders, however, other systems using Slurm may need different `#SBATCH` parameters. 

The benchmarks should be run with the Linux `time` command as illustrated in the sample submission scripts and this is the time that must be reported.

The benchmark results must be validated against the results supplied in the `NLR-results` folder, see validation section below. 

## Run Definitions and Requirements

### Tests
* Required: Results must be reported for both bench1 and bench2.

### Code optimization
* Required: Run the benchmark with code as-is or ported (as needed) following the definitions of "as-is" and "ported" in the General Benchmark Instructions.
* *Optional: Results with optimized code may aditionally be reported.*

### Node classes
* Required: Results must be reported for accelerated nodes and optionally for standard nodes.

### Node counts
* Required: For each of the above, report results on the smallest possible hardware configuration (e.g., one compute node or one device) and 2x this configuration. If possible, we are also interested in 4x this configuration.

### OpenMP usage
* Required: For each of the above, always report performance without OpenMP (pure MPI). 
* *Optional: Runs using OpenMP may also be reported.*

### Process/thread placement
* Standard runs: Use MPI ranks and threads (where applicable for optional openMP runs) such that the total number of cores used (ranks × threads) is at least 90% of the physical cores per node.
* Accelerated runs: Use at least one MPI rank per accelerator. The Offeror is permitted to map ranks within a NUMA domain as desired, subject to limitations given in the General Benchmark Instructions.
* For optimized runs, the Offeror is permitted to deviate from the above and instead use whatever core, device, or node count is considered optimal, under any placement scheme.

### Reporting

For every run, the spreadsheet response should include run times from the Linux `time` command as illustrated in the provided example run script, converted to seconds. The "mpi-ranks" reported should reflect the number of physical cores hosting independent threads of execution, and the "threads" reported should be equal to the number of execution threads, where applicable.

In addition to content enumerated in the General Instructions, please return files `OUTCAR` and `vasprun.xml` for every run, as well as all validation output, as part of the File response.

## Additional Run Rules

Parallelization parameters can have a significant impact on performance. The Offeror is allowed to vary the following parameters to determine the optimal settings: `KPAR`, `NCORE`, `NSIM`, and `NBLOCK_FOCK`. No other parameters can be changed because they can alter the numerical results of the calculation. 
*Note:* Because Benchmark 2 is a Gamma-point-only calculation, `KPAR` should be set to 1.

While fully converged runs are required for final reporting, shorter runs may be desired during performance tuning (e.g. of parallelization parameters or other testing). In such cases, the maximum number of SCF iterations may be reduced (e.g., to 5 by setting `NELM = 5` in the INCAR file) to reduce time-to-solution during testing. Note that the input `NELMIN = 3` enforces a minimum of 3 SCF steps. **Important: the results from these truncated runs will not be suitable for validation.**

To check if a calculation has converged, search for "aborting loop because EDIFF is reached" in the OUTCAR. 

## Validation

1. **Required Files:** The Offeror will provide `OUTCAR` and `VASP.xml` for each calculation. These files will be used to verify that the Offeror followed the prescribed instructions and did not modify any calculation settings beyond those explicitly permitted (i.e., `NCORE` for bench 1 and bench 2 and `KPAR` for bench 1).
2. **Validation Method:** Validation will consist of comparing the reported final electronic energy (TOTEN) and, for bench 1, the band gap (fundamental gap) from the submitted OUTCAR files against the corresponding reference values.
3. **Acceptance Criteria:** A converged calculation will be considered valid if the final energy and, when relevant, the band gap agree with the reference values within a tolerance of 1E-3 eV. We have tested our benchmarks on different architectures and have found that this tolerance is suitable for our benchmarks, which are quite numerically challenging due to their size.
4. **Reference Data:** The reference data will be provided to the Offeror for comparison purposes but may not be modified without prior written authorization. The reference directory may be transferred to another system if needed for convenience.

Below is a summary of the results that can be found in the `NLR-results` folder for each benchmark:
| Property            | Bench 1 (eV) | Bench 2 (eV) |
|---------------------|--------------|--------------|
| TOTEN               | -666.3571    | -2531.9038   |
| fundamental gap     | 1.0514       | N/A          |

These quantities can be obtained by searching the `OUTCAR` file of a completed job using:
`grep "TOTEN" OUTCAR | tail -n 1`
`grep "fundamental gap" OUTCAR
