#!/bin/bash

#This file sets the paths for all BGW executable, library and input-data.
#It will need to be modified for each install site.
#To minimize the number of files that must be updated with this path data,
#all of the jobscripts will source this file.
#
#Jobscripts will still need to be updated to match
#a) your queue system, or
#b) your compute node configuration.

#Make sure to update the E4_BGW variable here
#E4_BGW=/path/to/berkeleygw-workflow
E4_BGW=
if [[ -z "${E4_BGW}" ]]; then
    echo "The E4_BGW variable is not defined."
    echo "Please also set E4_BGW in site_path_config.sh and try again."
    exit 0
fi

#libraries... you may need to add FFTW, or Scalapack/ELPA, or others
HDF_LIBPATH=
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HDF_LIBPATH

#executables
BGW_DIR=$E4_BGW/BerkeleyGW/bin

#input data
Si_WFN_folder=$E4_BGW/Si_WFN_folder
Si214_WFN_folder=$Si_WFN_folder/Si214/WFN_file/
Si510_WFN_folder=$Si_WFN_folder/Si510/WFN_file/
Si998_WFN_folder=$Si_WFN_folder/Si998/WFN_file/

#any modules that should be loaded at runtime
#module swap PrgEnv-gnu PrgEnv-nvhpc

