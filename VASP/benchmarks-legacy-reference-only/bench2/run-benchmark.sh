#!/bin/bash

#name run directory by date and run_name
date=$(date '+%m-%d')     #date
#date=$(date '+%m-%d-%T') #date with time
run_name=bench2_vasp6.4.2
rundir=${date}-${run_name}s

#Create directory, copy inputs and start run
if [ ! -d "$rundir" ]; then # Only continue if the directory does not exists
    
    #create run directory
    mkdir $rundir
    
    #copy inputs
    cp input/* $rundir
    cp job.slurm $rundir
    
    #enter directory and submit job
    cd $rundir
    echo $PWD
    sbatch job.slurm
    cd ..

else
    echo "$rundir exists, skipping"
fi

