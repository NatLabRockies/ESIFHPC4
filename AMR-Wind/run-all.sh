#!/bin/zsh

set -e

#CPU login node
ssh kl1.hpc.nrel.gov 'bash -s' < amr-wind-benchmark-cpu.sh
ssh kl1.hpc.nrel.gov 'bash -s' < amr-wind-benchmark-cpu-verify.sh

#GPU login node
ssh kl5.hpc.nrel.gov 'bash -s' < amr-wind-benchmark-gpu.sh
ssh kl5.hpc.nrel.gov 'bash -s' < amr-wind-benchmark-gpu-aware.sh
ssh kl5.hpc.nrel.gov 'bash -s' < amr-wind-benchmark-gpu-verify.sh
