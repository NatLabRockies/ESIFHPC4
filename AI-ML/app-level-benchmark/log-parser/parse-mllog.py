import pandas as pd
import numpy as np
import json
import re
import os
import argparse
import plotly.express as px
import plotly.graph_objects as go

parser = argparse.ArgumentParser(
    prog="DeepCAM Log Parser",
    description="Simple MLCommons log parser for DeepCAM",
    epilog="See here for more information: https://github.com/NatLabRockies/ESIFHPC4/tree/main/AI-ML/app-level-benchmark"
    )

parser.add_argument("-l", "--logfile", type=str, help="Path to MLCommons log file. File must contain lines starting with ':::MLLOG'")
parser.add_argument("-o", "--output_folder", type=str, help="Path to output folder for summary CSVs and visualizations.")
parser.add_argument("-t", "--submission_type", type=str, help="Type of benchmark submission according to ESIF-HPC-4 run rules. Can be one of 'baseline', 'ported', or 'optimized'.")
parser.add_argument("-s", "--scenario", type=int, help="ESIF-HPC-4 runtime scenario for the DeepCAM benchmark. Options: 1=Measuring time per train step. 2=Measuring time to target evaluation accuracy.")
args = parser.parse_args()
log_file        = args.logfile
output_basepath = args.output_folder
submission_type = args.submission_type
scenario        = args.scenario

# Validate inputs
var_list = [log_file, output_basepath, scenario]
for var in var_list:
    if var is None:
        raise ValueError("Error: Not enough arguments passed. Run 'python parse-mllog.py --help' for more information.")
if scenario not in [1, 2]:
    raise ValueError("Invalid benchmark scenario chosen!")

def extract_global_vars(df, global_var):
    '''
    Extract input global variable from training run.
    '''
    try:
        var = df[df['key'] == global_var].value.reset_index(drop=True).loc[0]
    except:
        var = pd.NA
    return var

def calc_epoch_time(df, col_type, time_col='ts_utc'):
    '''
    Returns a Series summarizing seconds per (training or evaluation) epoch for a DeepCAM run.

    df = pd.DataFrame object
    col_type = one of 'epoch' (i.e., training) or 'eval' (i.e., evaluation)
    time_col = name of df column containing timestamp data
    '''
    epoch_df = df
    diff_col = "seconds"
    epoch_df = df[(df['key'] == f'{col_type}_start') | (df['key'] == f'{col_type}_stop')].reset_index(drop=True)
    epoch_df[diff_col] = pd.to_timedelta(epoch_df[time_col] - epoch_df[time_col].shift(1))
    epoch_df = epoch_df[epoch_df['key'] == f'{col_type}_stop'].reset_index(drop=True)
    seconds_per_epoch = epoch_df[diff_col].dt.total_seconds()
    out_df = pd.DataFrame()
    out_df['epoch'] = epoch_df['training_epoch'].astype(int)
    out_df['seconds_per_epoch'] = seconds_per_epoch
    return out_df

def calc_average_epoch_time(epoch_df):
    metrics = epoch_df['seconds_per_epoch'].agg({
        'median',
        'mean',
        'std',
    })
    return metrics


# Define grouping keys
time_key = "time_ms"
metadata_key = "metadata"
epoch_key = "epoch_num"
step_key = "step_num"

records = []
with open(log_file, "r") as f:
    for i, line in enumerate(f, start=1):
        if line.startswith(":::MLLOG"):
            # Extract JSON-like object that follows
            match = re.search(r'\{.*\}', line)
            if match:
                try:
                    data = json.loads(match.group(0))
                    timestamp = data.get(time_key, None)
                    # extract generic key-value pairs logged by mlperf
                    key = data.get('key')
                    value = data.get('value')
                    # `metadata_key` contains a json of useful training metadata
                    metadata = data.get(metadata_key, None)
                    n_epoch = metadata.get(epoch_key, None)
                    n_steps = metadata.get(step_key, None)
                    # Add each key-value pair as a separate row
                    if i not in [time_key, metadata_key]:
                        records.append({
                            "timestamp": timestamp,
                            "training_epoch": n_epoch,
                            "training_step": n_steps,
                            "key": key,
                            "value": value
                        })
                except json.JSONDecodeError as e:
                    print(f"JSON parse error for line {i} -- {e}")

df = pd.DataFrame(records)
df["ts_utc"] = pd.to_datetime(df["timestamp"], unit="ms", utc=True).dt.tz_localize(None)

global_variables = [
    'submission_org', 'submission_division', 'submission_status',
    'submission_platform', 'seed', 'number_of_ranks',
    'number_of_nodes', 'accelerators_per_node', 'checkpoint',
    'global_batch_size', 'batchnorm_group_size', 'train_samples',
    'batchnorm_group_stride', 'gradient_accumulation_frequency',
    'data_format', 'shuffle_mode', 'data_oversampling_factor',
    'synchronous_staging', 'precision_mode', 'enable_nhwc',
    'enable_graph', 'enable_jit', 'enable_gds', 'enable_mmap',
    'enable_odirect', 'disable_comm_overlap', 'opt_name', 'opt_lr',
    'opt_step', 'opt_bias_correction', 'opt_betas', 'opt_eps',
    'opt_weight_decay', 'opt_grad_averaging', 'opt_max_grad_norm',
    'scheduler_type', 'scheduler_t_max', 'scheduler_eta_min',
    'scheduler_lr_warmup_steps', 'scheduler_lr_warmup_factor',
]

global_var_df = df[df['key'].isin(global_variables)][['key', 'value']]

training_start = df[(df['training_epoch'] == 1) & (df['key'] == 'epoch_start')].reset_index(drop=True).loc[0]['timestamp']
try:
    target_reached = df[(df['key'] == 'target_accuracy_reached')]
    training_end = target_reached.reset_index(drop=True).loc[0]['timestamp']
    training_secs = ((training_end - training_start)/1000)
    epochs_req = target_reached.reset_index(drop=True).loc[0]['training_epoch']
except:
    training_end = pd.NaT
    training_secs = pd.NaT
    epochs_req = np.nan

num_nodes = extract_global_vars(df, 'number_of_nodes')
accs_per_node = df[(df['key'] == 'accelerators_per_node')].reset_index(drop=True).loc[0]['value']



# Extract first timestamp for basis of filename
jobid = min(df['timestamp'])
filebasebath = os.path.join(output_basepath, 'csvs')
os.makedirs(filebasebath, exist_ok=True)

eval_time = calc_epoch_time(df, 'eval')
train_time = calc_epoch_time(df, 'epoch')
total_eval_time = eval_time['seconds_per_epoch'].sum()
total_train_time = train_time.seconds_per_epoch.sum()

epoch_df = pd.DataFrame()
epoch_df['epoch'] = eval_time['epoch']
epoch_df['eval_seconds'] = eval_time['seconds_per_epoch']
epoch_df['train_seconds'] = train_time['seconds_per_epoch']


metrics = epoch_df['eval_seconds'].agg({
   'median',
   'mean',
   'std',
})
median_epoch_time = f'{metrics["median"]:.2f}'
mean_epoch_time = f'{metrics["mean"]:.2f}'
std_epoch_time = f'{metrics["std"]:.2f}'

train_metrics = calc_average_epoch_time(train_time)
median_train_time = f'{train_metrics["median"]:.2f}'
mean_train_time = f'{train_metrics["mean"]:.2f}'
std_train_time = f'{train_metrics["std"]:.2f}'

# Export CSV timeseries of training metrics per epoch/step
metrics_to_pivot = ['eval_loss', 'train_loss', 'eval_accuracy', 'train_accuracy']
filtered_df = df[df['key'].isin(metrics_to_pivot)]

# Return output as reporting table for scenario 1 or 2
num_nodes = extract_global_vars(df, 'number_of_nodes')
accs_per_node = extract_global_vars(df, 'accelerators_per_node')
total_accs = num_nodes * accs_per_node
local_batch_size = extract_global_vars(df, 'global_batch_size') / total_accs
data_staged_val = extract_global_vars(df, 'stage_dir_prefix')
data_staged = False if pd.isna(data_staged_val) else True

# Output Summary Table
if scenario == 1:
    def calculate_time_per_training_step(df):
        steps = (
            df.sort_values("training_step")
                .drop_duplicates("training_step")
                .loc[:, ["training_step", "timestamp"]]
                .sort_values("training_step")
        )
        steps["step_diff"] = steps["training_step"].diff()
        steps["time_diff_sec"] = steps["timestamp"].diff() / 1000.0
        steps["sec_per_step"] = steps["time_diff_sec"] / steps["step_diff"]
        return steps[~steps['sec_per_step'].isna()]
    steps = calculate_time_per_training_step(df)
    # Summary statistics - time per training step
    # # Note that the timings for the last step of each epoch counts evaluation time, so we exclude that.
    # # We also only consider the timings per training step from the first two epochs, regardless of how many ran during training.
    # steps = steps[steps['training_step'] != steps_per_epoch]
    # for i in np.arange(2,5):
    #   steps = steps[steps['training_step'] != i*(steps_per_epoch+1)]
    step_timing_summary = steps['sec_per_step'].agg({
      'mean_sec_per_step'   : 'mean',
      'stdv_sec_per_step'   : 'std',
      'median_sec_per_step' : 'median',
      'max_sec_per_step'    : 'max',
      'min_sec_per_step'    : 'min'
    })
    output_df = pd.DataFrame({
        'run_type'              : [submission_type], 
        'scenario'              : [scenario], 
        'nodes_used'            : [num_nodes], 
        'accelerators_per_node' : [accs_per_node], 
        'total_accelerators'    : [num_nodes * accs_per_node],
        'local_batch_size'      : [local_batch_size], 
        'data_staged'           : [data_staged], 
        'median_time_per_training_step_secs' : [round(step_timing_summary['median_sec_per_step'],3)]
    })
elif scenario == 2:
    scheduler_type = extract_global_vars(df, 'scheduler_type')
    start_lr = extract_global_vars(df, 'opt_lr')
    opt_name = extract_global_vars(df, 'opt_name')
    target_acc = df[df['key'] == 'target_accuracy_reached'].reset_index().loc[0].value
    if (len(df[df['key'] == 'target_accuracy_reached']) < 1): 
        KeyError("Invalid run! Target evaluation accuracy is not logged. This is required for a valid scenario 2 submission.")
    if target_acc < 0.82:
        KeyError("Invalid run! Target evaluation accuracy of 82% was not reached. This is required for a valid scenario 2 submission.")
    output_df = pd.DataFrame({
        'run_type'              : [submission_type], 
        'scenario'              : [scenario], 
        'nodes_used'            : [num_nodes], 
        'accelerators_per_node' : [accs_per_node], 
        'total_accelerators'    : [num_nodes * accs_per_node],
        'local_batch_size'      : [local_batch_size], 
        'data_staged'           : [data_staged], 
        'lr_scheduler'          : [scheduler_type],
        'start_lr'              : [start_lr], 
        'optimizer'             : [opt_name], 
        'total_time_required_secs' : [total_train_time], 
        'target_acc_reached'    : [target_acc], 
        'epochs_required'       : [max(epoch_df['epoch'])]
    })
else:
    raise ValueError("Invalid benchmark scenario chosen!")

filename = os.path.join(filebasebath, f'{jobid}-{total_accs}GPUs-Scenario{scenario}.csv')
print(f"Writing processed file to {filename} ...")
output_df.to_csv(filename, index=False)