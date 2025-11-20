#!/bin/bash -l
set -ex
git clone --depth=1 --shallow-submodules --branch v3.8.0 --recursive https://github.com/Exawind/amr-wind.git
cmake -B amr-wind-build \
	-DCMAKE_CXX_COMPILER:STRING=CC \
	-DCMAKE_C_COMPILER:STRING=cc \
	-DAMR_WIND_ENABLE_MPI:BOOL=ON \
	-DAMR_WIND_ENABLE_TINY_PROFILE:BOOL=ON \
        -DAMR_WIND_ENABLE_FCOMPARE:BOOL=ON \
	-DAMR_WIND_ENABLE_TESTS:BOOL=ON \
	amr-wind
nice cmake --build amr-wind-build --parallel
