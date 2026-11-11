#!/usr/bin/env python3
"""NCCL AllReduce per‑run analysis script.

This script processes a *single* NCCL benchmark output file (e.g. ``rfm_job.out``)
and optionally its matching submission script (``rfm_job.sh``).  It extracts the
performance metrics, infers whether RDMA/GDR was used, and can emit a CSV table
matching the format used by the batch analyser.

Usage::

    python nccl_analysis_single.py <log_file> [options]

Positional arguments:

    log_file            Path to a single NCCL benchmark log file.

Optional arguments:

    --script SCRIPT     Path to the corresponding submission script.  If omitted,
                        the script will look for ``rfm_job.sh`` in the same
                        directory as ``log_file``.
    --run-type TYPE     Run type description for the CSV output (default: ``Baseline``).
    --system NAME       System name for the CSV output (default: ``unknown``).
    --rdma-used                 Include a "RDMA invoked" column derived from the script.
    --rdma-variable VAR        Name of the environment variable in the script that holds the RDMA flag (default: NCCL_NET_GDR_LEVEL).
    --csv FILE                  Write the CSV table to ``FILE``.
    --output FILE               Save an interactive Plotly HTML figure to ``FILE``.
    --title TITLE               Title for the Plotly figure (default constructed from ``log_file``).

The script follows the same column ordering as ``nccl_analysis.py``:

    Run Type | System | Number of Replicates | RDMA invoked | CPU cores per rank |
    Min byte size | Max byte size | Increment factor | Number of devices |
    Number of nodes | NICs per node | Message size (B) |
    Median Out-of-Place Time (uS) | Median Out-of-Place Algorithmic Bandwidth (GB/s) |
    Median Out-of-Place Bus Bandwidth (GB/s) | Median In-Place Time (uS) |
    Median In-Place Algorithmic Bandwidth (GB/s) | Median In-Place Bus Bandwidth (GB/s)
"""

import argparse
import os
import re
import pandas as pd
import numpy as np
import plotly.express as px

# ---------------------------------------------------------------------------
# Helper functions (copied/trimmed from the batch version)
# ---------------------------------------------------------------------------

def extract_nccl_perf_results(files):
    """Parse NCCL performance data from a list of log files.

    Returns a ``pandas.DataFrame`` with one row per performance entry.
    The columns are compatible with the batch script.
    """
    dfs = []
    for file_path in files:
        file_data = []
        num_nodes = None
        posted_pkts = np.nan
        blocked_pkts = np.nan

        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                # Performance table rows contain 'sum' or 'none'
                if re.search(r".*sum", line) or re.search(r".*none", line):
                    file_data.append(line.strip())

                # Number of nodes: "Num. nodes: <int>"
                if re.search(r"Num\.\s*nodes", line, re.IGNORECASE):
                    try:
                        num_nodes = int(line.split(":")[1].strip())
                    except Exception:
                        num_nodes = None

                # Network packet telemetry if available
                if "parbs_tarb_pi_posted_pkts" in line:
                    try:
                        posted_pkts = int(line.strip().split()[6])
                    except Exception:
                        posted_pkts = np.nan

                if "parbs_tarb_pi_posted_blocked_cnt" in line:
                    try:
                        blocked_pkts = int(line.strip().split()[6])
                    except Exception:
                        blocked_pkts = np.nan

        # Parse the performance rows collected above
        byte_size = []
        element_size = []
        datatype = []
        latency = []
        oop_alg_bw = []
        oop_bus_bw = []
        ip_alg_bw = []
        ip_bus_bw = []
        congestion = []

        for result_line in file_data:
            parts = result_line.split()
            if len(parts) < 12:
                continue
            try:
                b_size = int(parts[0])
                el_size = int(parts[1])
                dt = parts[2]
                lat = float(parts[5])
                o_alg = float(parts[6])
                o_bus = float(parts[7])
                i_alg = float(parts[10])
                i_bus = float(parts[11])
            except (ValueError, IndexError):
                continue

            byte_size.append(b_size)
            element_size.append(el_size)
            datatype.append(dt)
            latency.append(lat)
            oop_alg_bw.append(o_alg)
            oop_bus_bw.append(o_bus)
            ip_alg_bw.append(i_alg)
            ip_bus_bw.append(i_bus)
            try:
                congestion.append(float(int(blocked_pkts) / int(posted_pkts)))
            except Exception:
                congestion.append(np.nan)

        if byte_size:
            dfs.append(
                pd.DataFrame(
                    {
                        "folder_path": os.path.dirname(os.path.abspath(file_path)),
                        "num_nodes": num_nodes,
                        "byte_size": byte_size,
                        "element_size": element_size,
                        "datatype": datatype,
                        "latency_us": latency,
                        "out_of_place_algbw": oop_alg_bw,
                        "out_of_place_busbw": oop_bus_bw,
                        "in_place_algbw": ip_alg_bw,
                        "in_place_busbw": ip_bus_bw,
                        "congestion_ratio": congestion,
                    }
                )
            )

    return pd.concat(dfs, ignore_index=True) if dfs else pd.DataFrame()


def extract_script_data(files, rdma_var_name="NCCL_NET_GDR_LEVEL"):
    """Extract script‑level metadata from a list of ``rfm_job.sh``‑style files.

    Returns a DataFrame with ``folder_path``, ``cpus_per_task`` and
    ``nccl_net_gdr_level`` columns.
    """
    dfs = []
    for file_path in files:
        start_bytes = end_bytes = scaling_factor = datatype = None
        cpus_per_task = None
        nccl_net_gdr_level = None

        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if "srun" in line:
                    try:
                        if "-b " in line:
                            start_bytes = line.split("-b ")[1].split()[0]
                        if "-e " in line:
                            end_bytes = line.split("-e ")[1].split()[0]
                        if "-f " in line:
                            scaling_factor = line.split("-f ")[1].split()[0]
                        if "-d " in line:
                            datatype = line.split("-d ")[1].split()[0]
                    except Exception:
                        pass

                # Match --cpus-per-task=N, --cpus-per-task N, or -c N
                if re.search(r"#SBATCH\s+.*(--cpus-per-task|-c)", line):
                    match = re.search(r"(?:--cpus-per-task[=\s]+|-c\s+)(\d+)", line)
                    if match:
                        try:
                            cpus_per_task = int(match.group(1))
                        except Exception:
                            cpus_per_task = None

                if rdma_var_name in line:
                    match = re.search(rf"{re.escape(rdma_var_name)}\s*=\s*([^\s]+)", line)
                    if match:
                        nccl_net_gdr_level = match.group(1).strip('"\'')

        dfs.append(
            pd.DataFrame(
                {
                    "folder_path": [os.path.dirname(os.path.abspath(file_path))],
                    "cpus_per_task": [cpus_per_task],
                    "nccl_net_gdr_level": [nccl_net_gdr_level],
                }
            )
        )

    return pd.concat(dfs, ignore_index=True).drop_duplicates() if dfs else pd.DataFrame()


def _rdma_invoked(val):
    """Convert the raw ``nccl_net_gdr_level`` string to a friendly flag.

    The batch script treats anything other than ``LOC`` (or missing/unknown) as
    RDMA being used.
    """
    if not pd.notna(val) or str(val).lower() in ["unknown", "none", "nan"]:
        return "No"
    return "No" if str(val).strip() == "LOC" else "Yes"

# ---------------------------------------------------------------------------
# Main driver
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Analyze a single NCCL benchmark log file and optionally emit a CSV.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("log_file", help="Path to a single NCCL benchmark output log.")
    parser.add_argument(
        "--script",
        type=str,
        default=None,
        help="Path to the associated submission script (default: look for rfm_job.sh in the same directory).",
    )
    parser.add_argument("--run-type", type=str, default="Baseline", help="Run type for CSV export.")
    parser.add_argument("--system", type=str, default="unknown", help="System name for CSV export.")
    parser.add_argument(
        "--devices-per-node",
        type=int,
        default=None,
        help="Number of devices per node (fills the 'Number of devices' column).",
    )
    parser.add_argument(
        "--rdma-used",
        action="store_true",
        help="Include a 'RDMA invoked' column derived from the script (if available).",
    )
    parser.add_argument(
        "--rdma-variable",
        type=str,
        default="NCCL_NET_GDR_LEVEL",
        help="Name of the environment variable in the script that stores the RDMA flag (default: NCCL_NET_GDR_LEVEL).",
    )
    parser.add_argument(
        "--all-message-sizes",
        action="store_true",
        help="If set, include bandwidth/timing rows for all message sizes; otherwise only the four default sizes (8, 524288, 33554432, 4294967296) are retained.",
    )
    parser.add_argument("--csv", type=str, default=None, help="Path to write the CSV table.")
    parser.add_argument("--output", type=str, default=None, help="Path to save an interactive HTML plot.")
    parser.add_argument("--title", type=str, default=None, help="Title for the Plotly figure.")
    args = parser.parse_args()

    # -------------------------------------------------------------------
    # Load the log file
    # -------------------------------------------------------------------
    if not os.path.isfile(args.log_file):
        print(f"[error] Log file not found: {args.log_file}")
        return

    nccl_df = extract_nccl_perf_results([args.log_file])
    if nccl_df.empty:
        print("[error] No performance data extracted from the log file.")
        return

    # -------------------------------------------------------------------
    # Load the script (if any)
    # -------------------------------------------------------------------
    script_path = args.script
    if script_path is None:
        # Guess the conventional name in the same folder as the log
        guess = os.path.join(os.path.dirname(args.log_file), "rfm_job.sh")
        if os.path.isfile(guess):
            script_path = guess
    if script_path and os.path.isfile(script_path):
        script_df = extract_script_data([script_path], args.rdma_variable)
        # Merge script metadata into the performance DataFrame
        result_df = nccl_df.merge(
            script_df[["folder_path", "cpus_per_task", "nccl_net_gdr_level"]],
            on="folder_path",
            how="left",
        )
    else:
        # No script information – fill defaults
        result_df = nccl_df.copy()
        result_df["cpus_per_task"] = -1
        result_df["nccl_net_gdr_level"] = "unknown"

    # Normalise numeric columns
    result_df["nccl_net_gdr_level"] = result_df["nccl_net_gdr_level"].fillna("unknown")
    result_df["cpus_per_task"] = pd.to_numeric(result_df["cpus_per_task"], errors="coerce").fillna(-1).astype(int)
    result_df["num_nodes"] = pd.to_numeric(result_df["num_nodes"], errors="coerce").fillna(-1).astype(int)

    # -------------------------------------------------------------------
    # Prepare a CSV‑style aggregation (one row per message size)
    # -------------------------------------------------------------------
    # Derive the optional RDMA column
    if args.rdma_used:
        result_df["RDMA invoked"] = result_df["nccl_net_gdr_level"].apply(_rdma_invoked)
    else:
        result_df["RDMA invoked"] = ""

    # Helper columns for CSV layout
    result_df["Message size (B)"] = result_df["byte_size"].astype(int)
    result_df["CPU cores per rank"] = result_df["cpus_per_task"]
    result_df["Number of nodes"] = result_df["num_nodes"]

    # Filter message sizes unless user requests all sizes
    if not args.all_message_sizes:
        allowed_sizes = [8, 524288, 33554432, 4294967296]
        result_df = result_df[result_df["Message size (B)"].isin(allowed_sizes)]

    # Aggregation – for a single run each message size typically appears once,
    # but we keep the same aggregation logic as the batch script for consistency.
    agg_df = result_df.groupby(
        ["RDMA invoked", "Message size (B)", "CPU cores per rank", "Number of nodes"],
        as_index=False,
    ).agg(
        Number_of_Replicates=("latency_us", "count"),
        Median_OOP_Time=("latency_us", "median"),
        Median_OOP_Alg_BW=("out_of_place_algbw", "median"),
        Median_OOP_Bus_BW=("out_of_place_busbw", "median"),
        Median_IP_Time=("latency_us", "median"),
        Median_IP_Alg_BW=("in_place_algbw", "median"),
        Median_IP_Bus_BW=("in_place_busbw", "median"),
    )

    # Add constant/scalar columns required by the CSV format
    agg_df["Run Type"] = args.run_type
    agg_df["System"] = args.system
    # Fill the number of devices per node (if provided)
    agg_df["Number of devices"] = str(args.devices_per_node) if args.devices_per_node is not None else ""
    agg_df["NICs per node"] = ""
    # Use the observed min/max message size for this run
    agg_df["Min byte size"] = int(result_df["Message size (B)"].min())
    agg_df["Max byte size"] = int(result_df["Message size (B)"].max())
    agg_df["Increment factor"] = 2

    # Rename columns to match the exact output spec
    agg_df = agg_df.rename(
        columns={
            "Number_of_Replicates": "Number of Replicates",
            "Median_OOP_Time": "Median Out-of-Place Time (uS)",
            "Median_OOP_Alg_BW": "Median Out-of-Place Algorithmic Bandwidth (GB/s)",
            "Median_OOP_Bus_BW": "Median Out-of-Place Bus Bandwidth (GB/s)",
            "Median_IP_Time": "Median In-Place Time (uS)",
            "Median_IP_Alg_BW": "Median In-Place Algorithmic Bandwidth (GB/s)",
            "Median_IP_Bus_BW": "Median In-Place Bus Bandwidth (GB/s)",
            "Number of devices": "Number of devices per node",
        }
    )

    # Order columns exactly as required
    csv_columns = [
        "Run Type",
        "System",
        "Number of Replicates",
        "RDMA invoked",
        "CPU cores per rank",
        "Min byte size",
        "Max byte size",
        "Increment factor",
        "Number of devices per node",
        "Number of nodes",
        "NICs per node",
        "Message size (B)",
        "Median Out-of-Place Time (uS)",
        "Median Out-of-Place Algorithmic Bandwidth (GB/s)",
        "Median Out-of-Place Bus Bandwidth (GB/s)",
        "Median In-Place Time (uS)",
        "Median In-Place Algorithmic Bandwidth (GB/s)",
        "Median In-Place Bus Bandwidth (GB/s)",
    ]
    csv_out = agg_df[csv_columns]

    if args.csv:
        try:
            csv_out.to_csv(args.csv, index=False)
            print(f"[info] CSV table written to {args.csv}")
        except Exception as e:
            print(f"[error] Could not write CSV: {e}")

    # -------------------------------------------------------------------
    # Optional Plotly visualisation (bus bandwidth vs message size)
    # -------------------------------------------------------------------
    if args.output:
        # Build a simple line plot of out‑of‑place bus bandwidth
        plot_df = agg_df.copy()
        # Plotly expects the numeric column to be called something consistent; we use the median bus BW.
        fig = px.line(
            plot_df,
            x="Message size (B)",
            y="Median Out-of-Place Bus Bandwidth (GB/s)",
            markers=True,
            title=args.title or f"NCCL per‑run bus bandwidth – {os.path.basename(args.log_file)}",
        )
        try:
            fig.write_html(args.output)
            print(f"[info] Plot saved to {args.output}")
        except Exception as e:
            print(f"[error] Could not save plot: {e}")

    # If no explicit output was requested, just print the DataFrame preview
    if not args.csv and not args.output:
        print(csv_out.head())


if __name__ == "__main__":
    main()
