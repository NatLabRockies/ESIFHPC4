import argparse
import glob

from tabulate import tabulate


def get_command_line_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--rsl_file",
        dest="rsl_filenames",
        action="append",
        required=True,
        help="The path to one or more individual rsl.error.0000 files, or a pattern to match multiple rsl.error.0000 files. Multiple entries can be specified with repeated '--rsl_file' flags. At least one file is required to run this script.",
    )

    return parser.parse_args()


def print_table(data):

    header = [
        "MPI Tasks",
        "Threads",
        "Iterations",
        "Write Time (s)",
        "Total Time (s)",
    ]

    print(tabulate(data, headers=header, floatfmt=".1f", stralign="right"))


def extract_time_from_line(line):
    data = line.strip()
    data = data.split("elapsed")[0]
    data = data.split()[-1]

    timing = float(data)

    return timing


def process_rsl_error_files(rsl_filenames):

    all_benchmark_metrics = []

    for k, filename in enumerate(rsl_filenames):

        total_time = 0.0
        write_time = 0.0
        alt_write_time = 0.0

        num_iterations = 0

        with open(filename, "r") as fp:
            for line in fp:
                if "Timing for main" in line:
                    timing = extract_time_from_line(line)
                    total_time += timing

                    if num_iterations % (60 * 4) == 0:
                        alt_write_time += timing

                    num_iterations += 1

                elif "Timing for Writing" in line:
                    timing = extract_time_from_line(line)
                    write_time += timing

                elif "Ntasks in X" in line:
                    tasks = line.split(",")
                    tasks_x = int(tasks[0].split()[-1])
                    tasks_y = int(tasks[1].split()[-1])
                    num_mpi_tasks = tasks_x * tasks_y

                elif "OMP_GET_MAX_THREADS" in line:
                    num_threads = int(line.split("=")[-1])

        # Wrap all results in a list of lists
        this_benchmark_entry = [
            num_mpi_tasks,
            num_threads,
            num_iterations,
            write_time,
            total_time,
        ]

        all_benchmark_metrics.append(this_benchmark_entry)

    return all_benchmark_metrics


if __name__ == "__main__":
    input_args = get_command_line_args()

    rsl_filenames = input_args.rsl_filenames
    rsl_filenames_expanded = []

    for filename in rsl_filenames:
        # If wildcards are present, find and expand those matching files
        rsl_filenames_expanded.extend(sorted(glob.glob(filename)))

    all_benchmark_metrics = process_rsl_error_files(rsl_filenames_expanded)

    print_table(all_benchmark_metrics)
