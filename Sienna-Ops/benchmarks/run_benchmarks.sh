#!/bin/bash
#SBATCH --job-name=sienna
#SBATCH --partition=short
#SBATCH --time=04:00:00
#SBATCH --account=hpcapps
#SBATCH --nodes=1
#SBATCH --output=sienna_benchmarks_%j.out
#SBATCH --error=sienna_benchmarks_%j.err
##SBATCH --qos=high

# Load required modules
module load julia
module load xpressmp

export OMP_NUM_THREADS=$1

JULIA_THREADS=$2

# Set working directory to the benchmarks folder
cd /projects/msoc/kpanda/ESIFHPC4/ESIFHPC4/Sienna-Ops/benchmarks

# Instantiate the Julia environment
echo "Instantiating Julia environment..."
julia --project=. -e "using Pkg; Pkg.instantiate()"

# Attempt to install optional dependencies if available
echo "Attempting to install optional dependencies..."
julia --project=. -e "
using Pkg
optional_packages = [\"HSL_jll\", \"HSL\", \"Xpress\"]
for pkg in optional_packages
    try
        Pkg.add(pkg)
        println(\"✓ Successfully installed \$pkg\")
    catch e
        @warn \"✗ Could not install \$pkg: \$e\"
    end
end
"

# Run the benchmark suite
echo "Starting Sienna benchmarks..."

echo "Running RTS UC benchmark..."
julia --threads=$JULIA_THREADS --project=. small/run_RTS_UC.jl > fout_RTS_UC_${OMP_NUM_THREADS}_${JULIA_THREADS}.out 2>&1

echo "Running RTS UC-ED benchmark..."
julia --threads=$JULIA_THREADS --project=. small/run_RTS_UC-ED.jl > fout_RTS_UC-ED_${OMP_NUM_THREADS}_${JULIA_THREADS}.out 2>&1

echo "Running parallel simulation benchmark..."
julia --threads=$JULIA_THREADS --project=. small/run_parallel_simulation.jl > fout_parallel_simulation_${OMP_NUM_THREADS}_${JULIA_THREADS}.out 2>&1

echo "Running ACTIVSg200 ED benchmark..."
julia --threads=$JULIA_THREADS --project=. small/run_ACTIVSg200_ED.jl > fout_ACTIVSg200_ED_${OMP_NUM_THREADS}_${JULIA_THREADS}.out 2>&1

echo "Running CATS benchmark..."
julia --threads=$JULIA_THREADS --project=. medium/run_CATS.jl > fout_CATS_${OMP_NUM_THREADS}_${JULIA_THREADS}.out 2>&1

echo "Running EST UC benchmark..."
julia --threads=$JULIA_THREADS --project=. medium/run_EST_UC.jl > fout_EST_UC_${OMP_NUM_THREADS}_${JULIA_THREADS}.out 2>&1

echo "All benchmarks completed!"
