
# Sienna

## Purpose and Description

- The Sienna framework is an open-source ecosystem for simulation and optimization of modern energy systems. It is designed to model, solve, and analyze scheduling problems and dynamic simulations of quasi-static infrastructure systems.
- Sienna consists of three main modules:
  - **Sienna\Data**: Supports efficient intake and use of energy systems input data, including multiple file formats, time series representations, and unit system conversions.
  - **Sienna\Ops**: Enables simulation of system scheduling, including unit commitment, economic dispatch, automatic generation control, and nonlinear optimal power flow.
  - **Sienna\Dyn**: Simulates power system dynamic responses to perturbations, including phasor simulations, electromagnetic transients, and small-signal stability.
- The framework applies advanced computer science, visualization, applied mathematics, and computational science to create a flexible modeling environment for energy systems.

Users running this benchmark will be interacting primarily with `PowerSystems.jl` and `PowerSimulations.jl` packages from the Sienna framework.
`PowerSystem.jl` is the package that is used for creating and storing the power system that is being modeled. It stores the system as a JSON file and uses an H5 file to store timeseries data.
`PowerSimulations.jl` uses the `sys.json` created and loaded into the memory by PowerSystems.jl to create a simulation model and solve it using an MILP or NLP solver such as HiGHS, IPOPT, or Xpress Optimizer.

## Licensing Requirements

Sienna is open-source software. Licensing details for its components can be found on the [Sienna GitHub repository](https://github.com/NREL-Sienna). 

One of the benchmarks, `medium/run_CATS.jl` relies on Xpress Optimizer which is a commercial solver that will require a license to solve. The benchmarker may chose to substitute Xpress with any other MILP optimizer of their choice, e.g., Gurobi. We should note that the optimization problem may not converge with the open source HiGHS solver.

## Other Requirements

- Sienna requires Julia as the primary programming language and depends on several Julia packages, including `PowerSimulations.jl` and `PowerSystems.jl`.
- For large-scale simulations, an appropriate optimization solver (e.g., JuMP-compatible solvers) is required.

## How to build and Run

Instructions to build and install Sienna components:

1. Install Julia from [JuliaLang.org](https://julialang.org/).

### Option 1: Use an existing Project.toml file
2. Instantiate the `Project.toml` file in this directory. On 
the terminal, assuming that you are in the same directory as this
README.md, run
   ```shell
   julia --project=.
   ```
   ```julia
   ] instantiate
   ```
   This should install all the packages needed to run the benchmark

### Option 2: Build your own Julia environment

2. Add the required packages using the Julia package manager:
   ```julia
   ] add PowerSimulations PowerSystems HydroPowerSimulations
   ```

3. For the latest development version, use:
   ```julia
   ] add PowerSimulations
   ```
4. Add requisite solvers
   ```julia
   ] add HiGHS IPOPT
   ```

5. Run the benchmarks as follows
   ```shell
   julia --threads=auto --project=. small/run_RTS_UC.jl
   julia --threads=auto --project=. small/run_RTS_UC-ED.jl
   julia --project=. small/run_parallel_simulation.jl
   julia --threads=auto --project=. small/run_ACTIVSg200_ED.jl
   julia --threads=auto --project=. medium/run_CATS.jl
   julia --threads=auto --project=. medium/run_EST_UC.jl
   ```

### Option 3:

5. Modify and run the sbatch file `run_benchmarks.sh` as follows

   ```shell
   sbatch run_benchmarks.sh 1 1 
   sbatch run_benchmarks.sh 104 auto
   ```

   Note: The fist argument after `run_benchmarks.sh` specifies `OMP_NUM_THREADS` to be used, the second argument specifies how many threads julia should be started with. By default, Julia uses only one thread. setting number of threads to `auto` means that Julia will set the number of threads to be equal to the number of cores on the system.

## Run Definitions and Requirements

- The benchmarks include:
  - Unit Commitment and Economic Dispatch simulations using `PowerSimulations.jl`.
- The input data for these simulations is compatible with `PowerSystems.jl < v5.0`. The systems will have to be recreated for `PowerSystems v5.0`

## Run Rules

At the very least,

- The Benchmarks are single node only and must be run sequentially so as to not fight for resources.
- GPU-compatible Optimizers that are compatible with Julia JuMP may be exercised on GPU nodes. 

## Benchmark test results to report and files to return

The benchmark creates timing, memory, and allocation data that can be inspected visually for comparison.
