# MACE

## Purpose and Description

This benchmark evaluates the performance of MACE, a machine learning interatomic potential (MLIP) framework, on molecular dynamics tasks involving water. It covers both the training (fine-tuning) and inference (MD simulation and RDF calculation) phases.

Specifically, the benchmark fine-tunes the pre-trained `mace-mpa-0-medium.model` using provided ab initio molecular dynamics (AIMD) data of liquid water. After fine-tuning, the benchmark evaluates model quality by performing molecular dynamics simulations with the trained MLIPs and comparing the resulting radial distribution functions (RDFs) against experimental water data. 

This benchmark is useful for our procurement efforts because it tests PyTorch-based machine learning workflows at the application level, in contrast to more general ML benchmarks. Additionally, workloads involving machine-learned interatomic potentials are expected to grow significantly in coming years as these methods enable highly computationally efficient materials simulations, making this benchmark relevant for future HPC system capability and performance evaluations.

## Licensing Requirements

MACE is distributed under the MIT License, Copyright (c) 2022 ACEsuit/mace. This license grants free use, modification, distribution, and sublicensing rights, provided that the copyright notice and license are included in all copies or substantial portions of the software.

For the most up-to-date licencing requirements, please review and abide by:

https://github.com/ACEsuit/mace/blob/main/LICENSE.md 

## Other Requirements

- Python >= 3.7
- PyTorch >= 1.12 

## How to build

1. Install Pytorch for appropriate platform and follow verification to ensure Pytorch was installed correctly (see: https://pytorch.org/get-started/locally/)

2. Install MACE (see: https://github.com/ACEsuit/mace?tab=readme-ov-file#installation)

```
pip install --upgrade pip
pip install mace-torch
```

## Run Definitions and Requirements

Specifics of the runs and their success criteria/acceptable thresholds

## How to run

1. Fine tuning the `mace-mpa-0-medium.model` using provided ab initio molecular dynamics data of liquid water.

The results of AIMD runs using the SCAN functional are provided in `water-S.xyz`. This file has the extended xyz format, and contains 3300 frames of data. These frames first need to 

### Tests

List specific tests here

## Run Rules

In addition to the general ESIF-HPC-4 benchmarking rules, detail any extra benchmark-specific rules

## Benchmark test results to report and files to return

Describe what results and information the offerer should return, beyond what is detailed in the benchmarking reporting sheet
