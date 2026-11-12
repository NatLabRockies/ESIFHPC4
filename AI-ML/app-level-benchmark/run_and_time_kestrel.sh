#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2020-2023 NVIDIA CORPORATION. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

# Load DeepCAM environment
module load pytorch
ENV_NAME=/kfs2/projects/esifapps/reframe-universal-envs/deepcam-env
eval "$(conda shell.bash hook)"
conda activate $ENV_NAME

# CONFIG_DIR is the folder containing the config files (assumes they are in the same folder as this run script)
export CONFIG_DIR=$(dirname "$(realpath $0)")

# config*.sh controls many environment variables
# make sure the correct config file for the intended scenario is loaded!
source ${CONFIG_DIR}/config_scenario1.sh
# source ${CONFIG_DIR}/config_scenario2.sh 

# go to training code directory
cd deepcam-mlcommons-hpcv3/src/deepCam

export LAUNCH_CMD="srun --overlap -u -N ${SLURM_NNODES} -n ${SLURM_NTASKS} -c ${SLURM_CPUS_PER_TASK} --gres=gpu:${SLURM_GPUS_ON_NODE}"
echo "Launching with: ${LAUNCH_CMD}"
${LAUNCH_CMD} ${LOGGER:-} ${PROFILE_CMD} ${DEBUG_CMD} $(which python) ${RUN_CMD}; ret_code=$?

if [[ $ret_code != 0 ]]; then exit $ret_code; fi