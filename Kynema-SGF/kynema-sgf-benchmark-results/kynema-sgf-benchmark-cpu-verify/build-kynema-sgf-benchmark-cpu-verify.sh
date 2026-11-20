#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30

set -ex
module load cpe-stack
module load PrgEnv-intel
module load craype-x86-spr
git clone --depth=1 --shallow-submodules --recursive https://github.com/Kynema/kynema-sgf.git
cmake -B kynema-sgf-build \
	-DCMAKE_CXX_COMPILER:STRING=CC \
	-DCMAKE_C_COMPILER:STRING=cc \
	-DKYNEMA_SGF_ENABLE_MPI:BOOL=ON \
	-DKYNEMA_SGF_ENABLE_TINY_PROFILE:BOOL=ON \
        -DKYNEMA_SGF_ENABLE_FCOMPARE:BOOL=ON \
	-DKYNEMA_SGF_ENABLE_TESTS:BOOL=ON \
	kynema-sgf
nice cmake --build kynema-sgf-build --parallel
