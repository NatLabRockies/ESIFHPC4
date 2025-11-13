using PowerSystems
using PowerSimulations
using Logging
using Dates
using Ipopt
using HydroPowerSimulations
using Logging
using BenchmarkTools
using DataFrames
using CSV

# Constants
const PSI = PowerSimulations
const PSY = PowerSystems

# Setup benchmark output directory
benchmark_output_dir = joinpath(@__DIR__, "benchmark_results")
mkpath(benchmark_output_dir)
benchmark_name = "activsg200_acopf"

# # Output simulation directory
sim_name = "ill"
sim_folder = mkpath(joinpath(sim_name * "-sim"))

function configure_ED_template(sys, horizon, interval)
    PSY.transform_single_time_series!(sys, horizon, interval)

    # Create a `template`
    template = template_economic_dispatch(network=NetworkModel(ACPPowerModel, use_slacks=true))

    set_device_model!(template, Line, StaticBranchUnbounded)
    set_device_model!(template, TapTransformer, StaticBranchUnbounded)
    set_device_model!(template, MonitoredLine, StaticBranch)
    set_device_model!(template, ThermalStandard, ThermalBasicDispatch)
    set_device_model!(template, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, TwoTerminalHVDCLine, HVDCTwoTerminalLossless)

    return template
end

function create_simulation_model(sys_RT, solver_ED, template_rt)
    sim_name = "ill"
    
    models = SimulationModels(
        decision_models=[
            DecisionModel(
                template_rt,
                sys_RT,
                name="RT",
                optimizer=solver_ED,
                optimizer_solve_log_print=true,
                system_to_file=false,
                check_numerical_bounds=false,
                calculate_conflict=true,
                store_variable_names=true,
                resolution = Dates.Hour(1),
                warm_start=false,
            ),
        ]
    )

    sequence = SimulationSequence(
        models=models,
        feedforwards=Dict(),
        ini_cond_chronology = InterProblemChronology(),
    )

    steps = 24*7
    sim = Simulation(
        name=sim_name * "-test",
        steps=steps,
        models=models,
        sequence=sequence,
        simulation_folder=sim_name * "-sim",
        initial_time=DateTime("2017-08-03T12:00:00"),
    )
    
    return sim
end

function benchmark_build_and_execute(sys_RT, solver_ED, template_rt)
    # Create a fresh simulation for each benchmark run
    fresh_sim = create_simulation_model(sys_RT, solver_ED, template_rt)
    build!(fresh_sim,
        console_level=Logging.Info,
        file_level=Logging.Debug,
        recorders=[:simulation],
    )
    execute!(fresh_sim, enable_progress_bar=false)
    return fresh_sim
end

function analyze_results(sim)
    results = SimulationResults(sim)
    ed_results = get_decision_problem_results(results, "RT")
    
    return (results=results, ed_results=ed_results)
end

function generate_benchmark_report(
    timing_summary::DataFrame, 
    samples::Int,
    max_time_seconds::Int,
    output_dir::String,
    benchmark_name::String
)
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    
    # Save CSV file
    CSV.write(joinpath(output_dir, "$(benchmark_name)_timing_$(timestamp).csv"), timing_summary)
    
    # Create benchmark summary report
    summary_file = joinpath(output_dir, "$(benchmark_name)_summary_$(timestamp).txt")
    open(summary_file, "w") do io
        println(io, "# PowerSimulations.jl ACTIVSg200 ACOPF Benchmark Summary")
        println(io, "Run date: $(now())")
        println(io, "")
        println(io, "## System Information")
        println(io, "Julia version: $(VERSION)")
        println(io, "CPU model: $(Sys.cpu_info()[1].model)")
        println(io, "CPU cores: $(Sys.CPU_THREADS)")
        println(io, "Total memory: $(round(Sys.total_memory() / 1024^3, digits=2)) GB")
        println(io, "")
        println(io, "## Benchmark Configuration")
        println(io, "Samples per benchmark: $samples")
        println(io, "Max time per benchmark: $max_time_seconds seconds")
        println(io, "")
        println(io, "## Benchmark Results")
        println(io, "")
        println(io, "### Execution Time (seconds)")
        for row in eachrow(timing_summary)
            println(io, "- $(row.component): $(round(row.time_seconds, digits=4))")
        end
        println(io, "- Total: $(round(sum(timing_summary.time_seconds), digits=4))")
        println(io, "")
        println(io, "### Memory Usage")
        for row in eachrow(timing_summary)
            if row.memory_bytes > 0
                println(io, "- $(row.component): $(round(row.memory_bytes / 1024^2, digits=2)) MB")
            end
        end
        println(io, "")
        println(io, "### Allocations")
        for row in eachrow(timing_summary)
            if row.allocations > 0
                println(io, "- $(row.component): $(row.allocations) allocations")
            end
        end
    end
    
    return (csv_file = joinpath(output_dir, "$(benchmark_name)_timing_$(timestamp).csv"),
            summary_file = summary_file,
            timestamp = timestamp)
end

function run_simulation()

    usts_system_path_RT = joinpath(@__DIR__, "input_data", "ACTIVSg200", "sys.json")

    sys_RT = PSY.System(usts_system_path_RT; assign_new_uuids = true)

    solver_ED = optimizer_with_attributes(
        Ipopt.Optimizer,
        # "linear_solver" => "ma27",
        "print_level" => 5,
    )

    horizon_RT = Dates.Hour(1)
    interval_RT = Dates.Hour(1)
    template_rt = configure_ED_template(sys_RT, horizon_RT, interval_RT)

    models = SimulationModels(
        decision_models=[
            DecisionModel(
                template_rt,
                sys_RT,
                name="RT",
                optimizer=solver_ED,
                optimizer_solve_log_print=true,
                system_to_file=false,
                check_numerical_bounds=false,
                calculate_conflict=true,
                store_variable_names=true,
                resolution = Dates.Hour(1),
                warm_start=false,
            ),
        ]
    )

    sequence = SimulationSequence(
        models=models,
        feedforwards=Dict(),
        ini_cond_chronology = InterProblemChronology(),
    )

    steps = 24*7
    sim = Simulation(
        name=sim_name * "-test",
        steps=steps,
        models=models,
        sequence=sequence,
        simulation_folder=sim_name * "-sim",
        initial_time=DateTime("2017-08-03T12:00:00"),
    )

    build!(sim,
        console_level=Logging.Info,
        file_level=Logging.Debug,
        recorders=[:simulation],
    )
    execute!(sim, enable_progress_bar=false) # Execute the simulation

    results = SimulationResults(sim);
    ed_results = get_decision_problem_results(results, "RT") # ED stage result metadata

    @show ed_results

    return nothing
end

function run_benchmark(;
    samples = 1,  # Number of samples for all benchmarks
    max_time_seconds = 3000  # Maximum time to spend on each benchmark
)
    # Setup path
    usts_system_path_RT = joinpath(@__DIR__, "input_data", "ACTIVSg200", "sys.json")
    
    # Benchmark system loading
    @info "Benchmarking system loading..."
    load_system_func() = PSY.System(usts_system_path_RT; assign_new_uuids = true)
    system_load_bench = @benchmark $load_system_func() samples=samples evals=1 seconds=max_time_seconds 
    system_load_time = minimum(system_load_bench.times) / 1e9
    sys_RT = load_system_func()  # Get the actual result
    
    # Benchmark solver setup
    @info "Benchmarking solver setup..."
    solver_setup_func() = optimizer_with_attributes(
        Ipopt.Optimizer,
        "print_level" => 5,
    )
    solver_setup_bench = @benchmark $solver_setup_func() samples=samples evals=1 seconds=max_time_seconds
    solver_setup_time = minimum(solver_setup_bench.times) / 1e9
    solver_ED = solver_setup_func()
    
    # Benchmark template creation
    @info "Benchmarking template creation..."
    horizon_RT = Dates.Hour(1)
    interval_RT = Dates.Hour(1)
    template_creation_bench = @benchmark $configure_ED_template($sys_RT, $horizon_RT, $interval_RT) samples=samples evals=1 seconds=max_time_seconds
    template_creation_time = minimum(template_creation_bench.times) / 1e9
    template_rt = configure_ED_template(sys_RT, horizon_RT, interval_RT)
    
    # Benchmark model creation
    @info "Benchmarking Simulation model creation..."
    model_creation_bench = @benchmark $create_simulation_model($sys_RT, $solver_ED, $template_rt) samples=samples evals=1 seconds=max_time_seconds
    model_creation_time = minimum(model_creation_bench.times) / 1e9
    
    # Benchmark build and execute together
    @info "Benchmarking build and execute phases..."    
    build_execute_bench = @benchmark $benchmark_build_and_execute($sys_RT, $solver_ED, $template_rt) samples=samples evals=1 seconds=max_time_seconds
    build_execute_time = minimum(build_execute_bench.times) / 1e9
    
    # Run build and execute once for the main simulation for results analysis
    sim = benchmark_build_and_execute(sys_RT, solver_ED, template_rt)
    
    # Benchmark result analysis
    @info "Benchmarking results analysis..."
    analysis_bench = @benchmark $analyze_results($sim) samples=samples evals=1 seconds=max_time_seconds
    analysis_time = minimum(analysis_bench.times) / 1e9
    analysis_results = analyze_results(sim)
    results = analysis_results.results
    
    # Create timing summary
    timing_summary = DataFrame(
        component = ["System Loading", "Solver Setup", "Template Creation", 
                   "Model Creation", "Build+Execute", "Result Analysis"],
        time_seconds = [system_load_time, solver_setup_time, template_creation_time,
                       model_creation_time, build_execute_time, analysis_time],
        memory_bytes = [
            system_load_bench.memory,
            solver_setup_bench.memory,
            template_creation_bench.memory,
            model_creation_bench.memory,
            build_execute_bench.memory,
            analysis_bench.memory
        ],
        allocations = [
            system_load_bench.allocs,
            solver_setup_bench.allocs,
            template_creation_bench.allocs,
            model_creation_bench.allocs,
            build_execute_bench.allocs,
            analysis_bench.allocs
        ]
    )
    
    # Generate reports
    report_files = generate_benchmark_report(timing_summary, samples, max_time_seconds, 
                                            benchmark_output_dir, benchmark_name)
    
    # Return results
    return Dict(
        "sim" => sim,
        "results" => results,
        "timing" => timing_summary,
        "report_files" => report_files,
        "benchmarks" => Dict(
            "system_load" => system_load_bench,
            "solver_setup" => solver_setup_bench,
            "template_creation" => template_creation_bench,
            "model_creation" => model_creation_bench,
            "build_execute" => build_execute_bench,
            "analysis" => analysis_bench
        )
    )
end

# Run the benchmark with default settings
@info "Starting benchmark for ACTIVSg200 ACOPF"
benchmark_results = run_benchmark()

# Alternative: Run with faster testing (fewer samples)
# benchmark_results = run_benchmark(samples = 1, max_time_seconds = 60)

# Alternative: Run with high accuracy (more samples)
# benchmark_results = run_benchmark(samples = 10, max_time_seconds = 6000)

@info "Benchmark completed and saved to $(benchmark_output_dir)"

# Extract sim and results for compatibility
sim = benchmark_results["sim"]
results = benchmark_results["results"]

# Print summary of results
println("\nBenchmark Summary:")
println("=================")
println("Component\t\tTime (s)\tMemory (MB)\tAllocations")
for row in eachrow(benchmark_results["timing"])
    memory_mb = row.memory_bytes > 0 ? round(row.memory_bytes / 1024^2, digits=2) : "N/A"
    allocs = row.allocations > 0 ? string(row.allocations) : "N/A"
    println("$(rpad(row.component, 16))\t$(round(row.time_seconds, digits=4))\t\t$(memory_mb)\t\t$(allocs)")
end
println("$(rpad("Total", 16))\t$(round(sum(benchmark_results["timing"].time_seconds), digits=4))")
println("\nDetailed results saved to: $(benchmark_output_dir)")