# AI-ML: "Scientific AI" Workload

## Purpose and Description

The purpose of this benchmark is to capture a 'typical scientific AI' workload performed by researchers at NREL, in which image segmentation tasks are common for various scientific purposes. As such, we employ a [DeepCAM model training implementation from MLCommons](https://github.com/mlcommons/hpc/tree/main/deepcam) to segment climate data from HDF5-formatted files. 

## How to build

Submitters are welcome to install PyTorch and the dependencies for DeepCAM into any reproducible environment (e.g., Python/conda virtual environments, containers, etc.). The instructions here describe a typical approach installing Python 3.12 within a baremetal `conda` environment as an example.

First, create a conda environment:

```
ENV_NAME=./deepcam-env
ml mamba
mamba create -y \
    --prefix $ENV_NAME \
    python=3.12
```

Next, activate the environment and choose **one** of the following approaches based on your hardware configuration to install PyTorch into your environment (taken from the [PyTorch documentation](https://pytorch.org/get-started/locally/)). If CUDA or ROCm versions of PyTorch are targeted, the appropriate GPU software environment should also be made available. **Note: although specific versions are listed in the `--index-url` as examples, we do not require any particular version of PyTorch or its dependencies to satisfy this benchmark.**

```
# Activate environment
conda activate $ENV_NAME

# Approach 1: NVIDIA CUDA-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Approach 2: AMD ROCm-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.3

# Approach 3: Intel XPU-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu

# Approach 4: CPU-only torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

*Any version of PyTorch that might be optimized for a targeted hardware architecture is acceptable for this benchmark, as long as the distribution is widely available and its results can be reproduced on any system hosting the hardware in question.*

Finally, install the DeepCAM Python package dependencies from pip and/or conda:

```
conda activate $ENV_NAME
echo "
apex
h5py
warmup-scheduler @ git+https://github.com/ildoonet/pytorch-gradual-warmup-lr
mlperf-logging @ git+https://github.com/mlperf/logging.git
" > deepcam-ref-requirements.txt
pip install -r deepcam-ref-requirements.txt
```

### Download and preprocess training data

Input training data can be downloaded via Globus using the [endpoint linked here](https://app.globus.org/file-manager?origin_id=0b226e2c-4de0-11ea-971a-021304b0cca7&origin_path=%2F). Note that the training data requires roughly 10TB of storage and contains HDF5-formatted files for training, validation, and test splits.

### Kestrel build example

See the Slurm script [`prep-env-kestrel.sh`](prep-env-kestrel.sh) for reference instructions on how we created the appropriate PyTorch environment to run the DeepCAM benchmark following the general guidance above. Note that on Kestrel, we explicitly compile torch against a system module for NCCL that is configured to work with the HPE Slingshot network (`nccl/2.21.5_cuda124`) rather than using a precompiled version from pip. This step may not be necessary depending on your hardware and network configuration.

## Run Definitions and Requirements

## How to run

Once the training dataset has been prepared and the PyTorch environment has been set up, submitters may follow [`run-deepcam-kestrel.sh`](./run-deepcam-kestrel.sh) as an example for how to run the model. We require that submitters run this benchmark in a multi-node fashion using all available accelerators per node. Specifically, we require a submission using *N* nodes\*, 2\**N* nodes, and 4\**N* nodes to demonstrate multi-node scaling. 

\* *N* = The smallest possible number of nodes that can fit a DeepCAM training run. *N* is allowed to equal 1.

### Tests

## Run Rules

There are three types of tests possible for this benchmark: *baseline*, *ported*, and *optimized*. Please see the ESIFHPC4 repo's [top-level README](../../README.md#draft-definitions-for-baselineas-is-ported-and-optimized-runs) for the constraints associated with each type of run.

### Baseline submissions

For *baseline* submissions, please use the following default runtime parameters, which is what we deploy on Kestrel. You will need to set the placeholder variables appropriately.

Training scripts for *baseline* submissions must be forked from the [DeepCAM model training implementation hosted by MLCommons](https://github.com/mlcommons/hpc/tree/main/deepcam). Using additional Python packages (i.e., anything other than what is required for PyTorch and the DeepCAM training scripts) is *not* allowed for baseline submissions.

**For baseline submissions, submitters are welcome to modify the `--wireup_method` runtime option as necessary.**

```
# Local batch size
LOCAL_BATCH_SIZE=8
# Number of data loader workers
workers_per_gpu=4

# Run training
srun --overlap -u -N ${SLURM_NNODES} -n ${totalranks} -c ${cpus_per_task} --cpu_bind=cores --gres=gpu:$SLURM_GPUS_ON_NODE \
     python train.py \
     --wireup_method "nccl-slurm-pmi" \
     --run_tag ${run_tag} \
     --data_dir_prefix ${data_dir_prefix} \
     --output_dir ${output_dir} \
     --max_inter_threads ${workers_per_gpu} \
     --model_prefix "classifier" \
     --optimizer "AdamW" \
     --start_lr ${START_LR} \
     --lr_schedule type="multistep",milestones="1200",decay_rate="0.5" \
     --lr_warmup_steps 0 \
     --lr_warmup_factor $(( ${SLURM_NNODES} / $LOCAL_BATCH_SIZE )) \
     --weight_decay 1e-2 \
     --logging_frequency 0 \
     --save_frequency 400 \
     --max_epochs 200 \
     --local_batch_size $LOCAL_BATCH_SIZE |& tee -a ${output_dir}/train.out
```

### Ported submissions

For *ported* submissions, the *baseline* parameters must be used, though training code modifications necessary to port the code to a new/different device architecture are also permitted. As described in the repository's [top-level README](../../README.md#draft-definitions-for-baselineas-is-ported-and-optimized-runs), *ported* submissions should not be reported without *baseline*, unless *baseline* is not possible.

### Optimized submissions

*Optimized* submissions are encouraged (though optional). For *optimized* submissions, the parameters used above, "mutable" hyperparameters (see below), and the code itself are allowed to be modified to best optimize performance and demonstrate hardware capabilities. We require that any of these changes are reported and reproduceable.

"Mutable" hyperparameters are allowed to be changed for optimized submissions. These hyperparameters include: `--optimizer`, `--start_lr`, `--lr_schedule`, `--lr_warmup_steps`, `--lr_warmup_factor`, and `--weight_decay`. Additionally, the `--max_inter_threads` option is allowed to be changed for optimized submissions. By contrast, "fixed" hyperparameters are *not* allowed to be changed from the baseline options; these include: `--save_frequency`, `--gradient_accumulation_frequency`, `--logging_frequency` and `--batchnorm_group_size`.

## Benchmark test results to report and files to return

Noting the time required (in minutes) to reach 82% validation accuracy satisfies this benchmark. For each submission, we request the following information (using unoptimized Kestrel reference data as an example):

| Run Type  | Nodes used | Accelerators per node | Local Batch Size | LR Scheduler | Start LR | Optimizer   | Time Required* (minutes) | Epochs Required* |
| :---      | :---       | :---                  | :---             | :---         | :---     | :---        | :---                     | :--              |
| baseline  | 4          | 4                     | 8                | multistep    | 1e-3     | AdamW       | 276                      | 26               |
| optimized | *N*        | *N*                   | *N*              | *scheduler*  | *N*      | *optimizer* | *N*                      | *N*              |

\* Time or epochs required to reach 82% evaluation accuracy target.

## References and useful links

* [Unoptimized (baseline) DeepCAM implementation from MLCommons](https://github.com/mlcommons/hpc/tree/main/deepcam)
* [Exascale Deep Learning for Climate Analytics paper](https://arxiv.org/pdf/1810.01993)
* [NERSC10 DeepCAM reference](https://gitlab.com/NERSC/N10-benchmarks/deepcam)