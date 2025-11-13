# AI-ML: "Scientific AI" Workload

## Purpose and Description

The purpose of this benchmark is to capture a 'typical scientific AI' workload performed by researchers at NREL, in which image segmentation tasks are common for various scientific purposes. As such, we employ [the 3D-UNet model implementation from MLCommons](https://github.com/mlcommons/training/tree/master/retired_benchmarks/unet3d/pytorch) to segment three-dimensional images from the publicly available [KiTS19 dataset](https://github.com/neheller/kits19). This benchmark is currently single-node only and does not have multi-node capabilities.

## How to build

Submitters are welcome to install PyTorch and 3D-UNet into any reproducible environment that is desired (e.g., Anaconda virtual environments or a container). The instructions here describe a typical approach using `conda`.

First, create a conda virtual environment:

```
ml mamba
mamba create --prefix=./pytorch-3dunet-env 
```

Next, activate the environment and choose **one** of the following approaches based on your hardware configuration to install PyTorch into your environment (taken from the [PyTorch documentation](https://pytorch.org/get-started/locally/)). Note that if CUDA or ROCM versions of PyTorch are targeted, the appropriate GPU software environment should also be made available:

```
# Activate environment
conda activate ./pytorch-3dunet-env

# Approach 1: NVIDIA CUDA-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Approach 2: AMD ROCM-compatible torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.3

# Approach 3: CPU-only torch
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```

Finally, install 3D-UNet from conda-forge based on instructions from the [3D-UNet source code](https://github.com/wolny/pytorch-3dunet?tab=readme-ov-file#installation).

```
conda install pytorch-3dunet
```

Submitters may find the Kestrel Build Example below to be a helpful starting point for implementing this benchmark.

### Kestrel build example

To concretely demonstrate how to build and run this benchmark, we provide step-by-step instructions we used for our system. Note that on Kestrel, this benchmark targets NVIDIA H100s running with CUDA 12.4-compatible GPU drivers. As such, the installation commands used were the following:

<!-- ```
ml mamba
mamba create --prefix=./pytorch-3dunet-env
conda activate ./pytorch-3dunet-env
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 
pip3 install git+https://github.com/NVIDIA/dllogger#egg=dllogger nibabel scipy
mamba install pytorch-3dunet -y
``` -->

```
ml mamba
eval "$(conda shell.bash hook)"
mamba create --prefix=./pytorch-3dunet-env python
conda activate ./pytorch-3dunet-env
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
pip3 install git+https://github.com/NVIDIA/dllogger#egg=dllogger tqdm requests nibabel scipy https://github.com/mlcommons/logging/archive/refs/tags/1.1.0-rc4.zip
```

Once the environment is built, the KiTS19 dataset needs to be downloaded onto the test machine and preprocessed for model training. Please refer to the [MLCommons 3D-UNet benchmark page](https://github.com/mlcommons/training/tree/master/retired_benchmarks/unet3d/pytorch#steps-to-download-and-verify-data) for step-by-step instructions for how to do so.

These were the commands that were used to download KiTS19 data:

```
conda activate ./pytorch-3dunet
mkdir raw-data-dir
cd raw-data-dir
git clone https://github.com/neheller/kits19
cd kits19
python3 -m starter_code.get_imaging
cd ../..
```

These were the commands that were used to preprocess data. 

**NOTE**: We change the hard-coded location of results from the root-level `/results` folder to `./results` in `main.py` as well as `/data/` to `./data` in `run_and_time.sh`. We have also encountered the error `AssertionError: Invalid hash for case_XXXXX_x.npy.` for several cases when running `preprocess_dataset.py`. As a temporary workaround, we remove the dataset verification entirely, as the benchmark will still run on the unverified cases. Finally, to avoid errors associated with old versions of `scipy` referencing the outdated method `scipy.signal.gaussian`, we update the call to that method in  `runtime/inference.py` to reflect `scipy.signal.windows.gaussian`:

```
conda activate ./pytorch-3dunet
git clone git@github.com:mlcommons/training.git
cd training/retired_benchmarks/unet3d/pytorch
sed -i 's|/results|./results|' main.py
sed -i 's|DATASET_DIR="/data"|DATASET_DIR="./data"|' run_and_time.sh
sed -i 's|verify_dataset(args.results_dir)|print("NOTE: Skipping dataset verification.")|' preprocess_dataset.py
sed -i 's|signal.gaussian|signal.windows.gaussian|' runtime/inference.py
mkdir data
mkdir results
python3 preprocess_dataset.py --data_dir ../../../../raw-data-dir/kits19/data --results_dir ./data
```

On Kestrel, these were the commands that were used to run the benchmark. Note that we change the hard-coded location of data from the root-level `/data` folder to `./data` in run_and_time.sh:

```
bash run_and_time.sh 0
```

Please refer to [`prep-kestrel.sh`](./prep-kestrel.sh) for an example Slurm script to create the appropriate environment on Kestrel following these instructions. Similarly, [`run-kestrel.sh`](./run-kestrel.sh) is an example Slurm script to run the 3D-UNet benchmark on an H100 on Kestrel after `prep-kestrel.sh` successfully completes.


## Run Definitions and Requirements

## How to run

Please follow [the instructions from MLCommons](https://github.com/mlcommons/training/tree/master/retired_benchmarks/unet3d/pytorch#steps-to-run-and-time) on how to run this benchmark once the environment is configured and training data are downloaded and preprocessed.

### Tests

There are two types of tests for this benchmark: as-is and optimized. For as-is tests, use the `run_and_time.sh` script with the default parameters listed below. For optimized tests, these parameters-along with the code-can be changed to optimize performance and demonstrate hardware capabilities.  

Parameters set in `run_and_time.sh`:

```
MAX_EPOCHS=4000
QUALITY_THRESHOLD="0.908"
START_EVAL_AT=500
EVALUATE_EVERY=20
LEARNING_RATE="0.8"
LR_WARMUP_EPOCHS=200
DATASET_DIR="./data"
BATCH_SIZE=2
GRADIENT_ACCUMULATION_STEPS=1
```

## Run Rules

Noting the time required to reach a mean DICE score of `0.908` from a single-node run of 3D-UNet satisfies this benchmark's requirements.

## Benchmark test results to report and files to return

For as-is tests, report the node class (e.g., standard vs. accelerated), run time, and the last recorded DICE score. For optimized tests, report node class, parameters (both updated and unchanged) in `run_and_time.sh`, run time, last recorded DICE score, and also include run notes describing changes made to the run scripts and/or code.

For both as-is and optimized tests, also include the `unet3d.log` file.

