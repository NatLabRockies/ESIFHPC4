#!/bin/zsh

set -e

#CPU login node
ssh kl3.hpc.nlr.gov 'bash -s' < kynema-sgf-benchmark-cpu.sh
ssh kl3.hpc.nlr.gov 'bash -s' < kynema-sgf-benchmark-cpu-verify.sh

#GPU login node
ssh kl5.hpc.nlr.gov 'bash -s' < kynema-sgf-benchmark-gpu.sh
ssh kl5.hpc.nlr.gov 'bash -s' < kynema-sgf-benchmark-gpu-aware.sh
ssh kl5.hpc.nlr.gov 'bash -s' < kynema-sgf-benchmark-gpu-verify.sh
