# [DRAFT] ESIF-HPC-4 Benchmark Suite 

Contains benchmarks to be run for NREL's ESIF-HPC-4 procurement.

The purpose of the "draft release" on 5/29/2025 is so that we can make our RFP benchmarking plans transparent to all vendors ahead of the RFP. Our hope is that this early draft release will give vendors additional time to work with our team on the benchmarks, especially as we have a few "in-house" codes represented in the suite that may be unfamiliar to vendors.

This early draft release does not represent or guarantee any final form of the suite.

Important Notes:
- This is an in-progress draft release.
	- Different benchmarks in the suite are at various states of "in-progress"
	- Most benchmarks do not have finalized inputs or run requirements as of 5/29/2025
 - Please see the [Planned Changes](#planned-changes) section of this README for changes that we are planning to make/are in development, but have not yet integrated into this repo.
- Benchmarks are divided into "Class A" and "Class B". 
	- "Class A" - Performance-required benchmarks: set of benchmarks for which specific performance targets must be met or exceeded. 
	- "Class B" - Functionality benchmarks: set of benchmarks intended to demonstrate and baseline the functionality, scalability, and software readiness of specific workloads or system features, but no specific performance level will be required. 
- The official version of the benchmark suite will be provided with the RFP.
- Until the official release, we may add or subtract benchmarks, change run requirements, etc.

**"Class A" Applications:**
| Application | Standard | Accelerated | Optimized | Baseline |
|:-----------:|:--------:|:-----------:|:---------:|:-----:|
| [VASP](https://github.com/NREL/ESIFHPC4/tree/main/VASP)        | Yes      | Yes         | Optional  | Yes   |
| [WRF](https://github.com/NREL/ESIFHPC4/tree/main/WRF)         | Yes      | Yes*        | Optional  | Yes   |
| [MLPerf-3DUnet**](https://github.com/NREL/ESIFHPC4/tree/main/AI-ML/app-level-benchmark)| Yes      | Yes         | Optional  | Yes   |
| [AMR-Wind](https://github.com/NREL/ESIFHPC4/tree/main/AMR-Wind)    | Yes      | Yes         | Optional  | Yes   |
| [LAMMPS](https://github.com/NREL/ESIFHPC4/tree/main/LAMMPS)      | Yes      | Yes         | Optional  | Yes   |
| [BerkeleyGW](https://github.com/NREL/ESIFHPC4/tree/main/BerkeleyGW)  | Yes      | Yes         | Optional        | Yes   |

\* WRF acceleration via AceCAST

\** MLPerf-3DUnet can be chosen to run *either* standard or accelerated, though accelerated is preferred.

**"Class B" Applications - functionality only**
| Application | Standard | Accelerated | Optimized | Baseline |
|:-----------:|:--------:|:-----------:|:---------:|:-----:|
| [Sienna](https://github.com/NREL/ESIFHPC4/tree/main/Sienna-Ops)      | Yes      | No          | No        | Yes   |

**Microbenchmarks:**
| Application | Standard | Accelerated | Optimized | Baseline |
|:-----------:|:--------:|:-----------:|:---------:|:-----:|
| [OSU](https://github.com/NREL/ESIFHPC4/tree/main/OSU)         | Yes      | No          | Optional  | Yes   |
| [HPL](https://github.com/NREL/ESIFHPC4/tree/main/HPL)         | Yes      | Yes         | Optional  | Yes   |
| [Stream](https://github.com/NREL/ESIFHPC4/tree/main/stream)      | Yes      | Yes         | Optional  | Yes   |
| [IOR](https://github.com/NREL/ESIFHPC4/tree/main/IOR)         | Yes      | No          | Optional  | Yes   |
| [mdtest](https://github.com/NREL/ESIFHPC4/tree/main/mdtest)      | Yes      | No          | Optional  | Yes   |
| [GPU-GPU collective](https://github.com/NREL/ESIFHPC4/tree/main/AI-ML/microbenchmark)| No | Yes         | Optional  | Yes   |
| FIO***         | Yes      | No          | Optional  | Yes   |

\*** benchmark still in early development; not yet in repo.

## Draft definitions for baseline(as-is), ported, and optimized runs

We have established the following draft definitions for baseline, ported, and optimized runs. These broad "run rules" will apply to all benchmarks, with any exceptions noted in the corresponding benchmark's README. Runs will be categorized according to the following three (draft) categories:
- Baseline (as-is): no code modifications permitted. Library substitutions permitted if these libraries will be available to us at the time of machine arrival. Changes to compilation options generally permitted (some edge cases exist. For example, stream’s compilation option to use custom functions in place of the ones in the stream source would not be allowed) 
- Ported: only source code modifications necessary to port the code to the new architecture are permitted, in addition to allowed baseline changes. This would include addition or modification of directives or pragmas, and/or replacement of existing architecture-specific language constructs (e.g., CUDA <-> HIP) with another well-documented language or interface. Ported should not be reported without baseline, unless baseline is not possible. Changes must be minimal and reproducible. 
- Optimized: in addition to what is allowed for baseline and ported, additional source code changes are permitted under the condition that these changes are made available in a maintainable form by the time of machine arrival. For each benchmark, newer versions of the benchmark source code may be used if these versions are publicly available at the time of machine arrival. Using surrogate models is not permitted. Floating point precision-related optimizations will be handled on a per-benchmark basis. 
- A baseline result is required whenever possible. A ported result may be provided in place of a baseline result if the baseline result is not possible. Ported in addition to baseline is optional and optimized is fully optional. 

## Planned Changes
We have planned/upcoming changes to the suite that have not yet been integrated but are currently in development. We list any major not-yet-integrated changes here. Please note that this list is subject to change, and we make no guarantee that these changes are reflected in the finalized benchmark suite.

- AI/ML: We plan to change the AI application-level benchmark from MLPerf's 3DUnet to MLPerf's DeepCAM benchmark.
- WRF: We plan to remove the AceCAST/GPU portion of WRF, along with any requests for simultaneous/concurrent runs on test hardware.
- VASP: Bench 1 will now focus only on the HSE calculation, with the supercell increased from 16 atoms to 128 atoms. Bench 2 will be a vasp_gam single-kpoint GGA calculation with 1149 atoms, increased from 519 atoms.
- LAMMPS: We are developing an "extra large" size input that should better utilize future hardware.
- AMR-Wind: We plan to remove any requests for simultaneous/concurrent runs on test hardware.

## Changelog

### September 22, 2025
- Removed HPGMG from the suite
- Added "planned changes" section to README
- Added draft definitions for baseline/ported/optimized runs to README

### July 29, 2025
- Removed Q-Chem from the suite
- Moved BerkeleyGW from "Class B" to "Class A"
