# AI-ML: "Scientific AI" Workload

## Purpose and Description

The purpose of this benchmark is to capture a 'typical scientific AI' workload performed by researchers at NLR, in which image segmentation tasks are common for various scientific purposes. As such, we employ a [DeepCAM model training implementation from MLCommons](https://github.com/mlcommons/hpc_results_v3.0), which segments long-term weather data from a large number of relatively small files. Due to the fact that NLR's current flagship HPC system, Kestrel, uses [NVIDIA accelerator hardware](https://www.nrel.gov/hpc/kestrel-system-configuration), note that our reference implementation is based on the NVIDIA submission to [MLCommons HPC Results v3.0](https://github.com/mlcommons/hpc_results_v3.0/tree/main/NVIDIA/benchmarks/deepcam/implementations/pytorch).

## How to build

### Step 1: PyTorch environment

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
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130

# Approach 2: AMD ROCm-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.3

# Approach 3: Intel XPU-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu

# Approach 4: CPU-only torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

*Any version of PyTorch that might be optimized for a targeted hardware architecture is acceptable for this benchmark, as long as the distribution is widely available and its results can be reproduced on any system hosting the hardware in question.*

### Step 2: DeepCAM

Install the DeepCAM Python package dependencies from pip and/or conda on inside the PyTorch environment from step 1:

```
conda activate $ENV_NAME

# 
echo "h5py
basemap
wandb
sympy
filelock
fsspec
jinja2
networkx
mlperf-logging
git+https://github.com/NVIDIA/mlperf-common.git
nvidia-ml-py
cupy
" > deepcam-requirements.txt
pip install -r deepcam-requirements.txt

# DALI
pip install --extra-index-url https://pypi.nvidia.com --upgrade nvidia-dali-cuda130

# mpi4py
mpicc=`which mpicc` pip install mpi4py --no-cache-dir

# io_helpers - from NVIDIA DeepCAM MLCommons HPC v3.0 submission folder
cd deepcam-mlcommons-hpcv3/io_helpers
python setup.py clean
python setup.py install

# APEX
if [ ! -d apex ]; then
     git clone https://github.com/NVIDIA/apex
fi
cd apex
APEX_CPP_EXT=1 APEX_CUDA_EXT=1 pip install -v --no-build-isolation --disable-pip-version-check .
```

The training scripts for DeepCAM do not require any special installation once the above environment is created. For convenience, this repository contains a lightly modified version of [the NVIDIA submission to MLCommons HPC Results v3.0](https://github.com/mlcommons/hpc_results_v3.0/tree/main/NVIDIA/benchmarks/deepcam/implementations/pytorch) (`./deepcam-mlcommons-hpcv3`) to enable DeepCAM to run with newer versions (>=2.3.0) of PyTorch (specifically, by updating `MultiStepLRWarmup` in `schedulers.py` to reflect the newer API). As demonstrated in the chunk above, the `io_helpers` package can also be installed from the submitted NVIDIA implementation folder.

### Step 3: Download and preprocess training data

Input training data can be downloaded via Globus using the [endpoint linked here](https://app.globus.org/file-manager?origin_id=0b226e2c-4de0-11ea-971a-021304b0cca7&origin_path=%2F). Note that the training data requires roughly 10TB of storage and contains HDF5-formatted files for training, validation, and test splits. 

Before a training run following MLCommons HPC Results v3.0, note that the HDF5-formatted input data must be preprocessed into numpy format. Please see [`preprocess-deepcam-data.sh`](./preprocess-deepcam-data.sh) for instructions on how to preprocess the input data accordingly.

### Kestrel build example

See the Slurm script [`prep-env-kestrel.sh`](prep-env-kestrel.sh) for reference instructions on how we created the appropriate PyTorch environment to run the DeepCAM benchmark following the general guidance above. Note that on Kestrel, we explicitly compile torch against a system module for NCCL that is configured to work with the HPE Slingshot network (`nccl/2.21.5_cuda124`) rather than using a precompiled version from pip. This step may not be necessary depending on your hardware and network configuration.

## Run Definitions and Requirements

## How to run

Once the training dataset has been prepared and the PyTorch environment has been set up, submitters may follow [`run-deepcam-kestrel.sh`](./run-deepcam-kestrel.sh) as an example for how to run the model. We require that submitters run this benchmark in a multi-node fashion using all available accelerators per node. Specifically, we require a submission using *N* nodes\*, 2\**N* nodes, and 4\**N* nodes to demonstrate multi-node scaling. 

\* *N* = The smallest possible number of nodes that can fit a DeepCAM training run. *N* is allowed to equal 1.

### Tests

## Run Rules

There are three types of tests possible for this benchmark: *baseline*, *ported*, and *optimized*. Please see the ESIFHPC4 repo's [top-level README](../../README.md#draft-definitions-for-baselineas-is-ported-and-optimized-runs) for the constraints associated with each type of run.

To run the DeepCAM benchmark, modify/rename the provided `run_and_time_kestrel.sh` script and `config_kestrel.sh` file appropriately based on guidance below. Note that this script assumes access to a Slurm scheduler and is launched as a job via `sbatch submit_kestrel.sh`. **If an alternative job scheduler is instead preferred, submitters are welcome to modify the launcher line `srun --overlap -u -N ${SLURM_NNODES} -n ${SLURM_NTASKS} -c ${SLURM_CPUS_PER_TASK} --cpu_bind=cores --gres=gpu:${SLURM_GPUS_ON_NODE}` as needed.** Lines under `# Load DeepCAM environment` will need to be modified to reflect the submitter's specific DeepCAM environment setup.

### Baseline submissions

For *baseline* submissions, please use the following default runtime parameters set in [`config_kestrel.sh`](./config_kestrel.sh), which is what we deploy on Kestrel. You will need to set the variables marked under `# user inputs` appropriately (e.g., input/output locations for the run). 

Training scripts for *baseline* submissions must be forked from a [DeepCAM model training implementation hosted by MLCommons HPC Results v3.0](https://github.com/mlcommons/hpc_results_v3.0/tree/main). Using additional Python packages (i.e., anything other than what is required for PyTorch and the DeepCAM training scripts) is *not* allowed for baseline submissions.

The following environment variables set in [`config_kestrel.sh`](./config_kestrel.sh) **can** be freely modified as necessary for *baseline* submissions (and are marked with `# CAN CHANGE FOR BASELINE`):

| Variable           | Description                    | Default Kestrel value  |
| :--                | :--                            | :--            |
| `STAGE_DIR_PREFIX` | Path to data staging directory | Stages input data to this directory (e.g., one on a faster filesystem or local node SSD.) If this variable is not set, then data staging does not occur (default). |
| `WIREUP_METHOD`    | Method for distributed process communication | Options are 'nccl-slurm' (default), 'nccl-openmpi', 'nccl-file', 'mpi', or 'dummy' |
| `DGXNGPU`          | Number of accelerators per node | `4` |

### Ported submissions

For *ported* submissions, the *baseline* parameters must be used, though training code modifications necessary to port the code to a new/different device architecture are also permitted. As described in the repository's [top-level README](../../README.md#draft-definitions-for-baselineas-is-ported-and-optimized-runs), *ported* submissions should not be reported without *baseline*, unless *baseline* is not possible.

### Optimized submissions

*Optimized* submissions are encouraged (though optional). For *optimized* submissions, the parameters used above, "mutable" hyperparameters (see below), and the code itself are allowed to be modified to best optimize performance and demonstrate hardware capabilities. We require that any of these changes are reported and reproduceable.

"Mutable" hyperparameters are allowed to be changed in [`config_kestrel.sh`](./config_kestrel.sh) for optimized submissions. These hyperparameters include: 

| Variable           | Description                               | Default Kestrel value  |
| :--                | :--                                       | :--                    |
| `LOCAL_BATCH_SIZE` | Per-accelerator batch size                | `8`                    |
| `OPTIMIZER`        | Learning rate optimizer                   | `MixedPrecisionLAMB`   |
| `START_LR`         | Starting learning rate                    | `0.001`                |
| `LR_SCHEDULE_TYPE` | Learning rate scheduler type              | `cosine_annealing`     |
| `LR_WARMUP_STEPS`  | Number of LR warmup steps                 | `0`                    |
| `LR_WARMUP_FACTOR` | Learning rate multiplier for warmup stage | `1`                    |
| `WEIGHT_DECAY`     | Strength of L2 regularization             | `0.2`                  | 
| `MAX_THREADS`      | Number of data loading threads            | `4`                    |

By contrast, "fixed" hyperparameters are *not* allowed to be changed from the baseline options; these include `LOGGING_FREQUENCY` and `BATCHNORM_GROUP_SIZE`.

## Benchmark test results to report and files to return

Noting the time required (in minutes) to reach 82% validation accuracy satisfies this benchmark. 

For each submission, we request the following information (using unoptimized Kestrel reference data as an example):

| Run Type  | Nodes used | Accelerators per node | Local Batch Size | LR Scheduler | Start LR | Optimizer          | Time Required* (minutes) | Epochs Required* |
| :---      | :---       | :---                  | :---             | :---         | :---     | :---               | :---                     | :--              |
| baseline  | 4          | 4                     | 8                | multistep    | 0.001    | MixedPrecisionLAMB | 83                       | 9                |
| optimized | *N*        | *N*                   | *N*              | *scheduler*  | *N*      | *optimizer*        | *N*                      | *N*              |

\* Time or epochs required to reach 82% evaluation accuracy target.

**We will provide a convenience wrapper script to extract the data requested to be reported from a DeepCAM submission at a later date.**

## References and useful links

* [Unoptimized (baseline) DeepCAM implementation from MLCommons](https://github.com/mlcommons/hpc/tree/main/deepcam)
* [Exascale Deep Learning for Climate Analytics paper](https://arxiv.org/pdf/1810.01993)
* [NERSC10 DeepCAM reference](https://gitlab.com/NERSC/N10-benchmarks/deepcam)