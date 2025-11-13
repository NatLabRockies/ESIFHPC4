## Building WRF

0. If possible, request an interactive node so that the eventual compilation step can be executed in parallel. As written, this entire process can be completed in roughly 15 min, so a 60 min node time is conservative and should cover all cases. (started at 3:10)

```bash
salloc -A <allocation_name> -t 60
```

1. Download the source code for WRF and WPS (the wrf pre-processing system)

```bash
wget https://github.com/wrf-model/WRF/releases/download/v4.7.1/v4.7.1.tar.gz
wget https://github.com/wrf-model/WPS/archive/refs/tags/v4.6.0.tar.gz
```

2. Unpack the two `.tar.gz` files downloaded above.

```bash
tar -xvzf v4.6.0.tar.gz 
tar -xvzf v4.7.1.tar.gz 
```

3. Load all necessary modules.

```bash
module purge
module load PrgEnv-gnu/8.5.0 
module load netcdf/4.9.3-cray-mpich-gcc
module load jasper/1.900.1-cray-mpich-gcc
```

4. Set a bunch of environment variables

```bash
export PATH="/usr/bin:${PATH}"
export LD_LIBRARY_PATH="/usr/lib64:${LD_LIBRARY_PATH}"

export WRF_DIR=/scratch/eyoung/wrf_build_test/WRFV4.7.1/
export WPS_DIR=/scratch/eyoung/wrf_build_test/WPS-4.6.0/

export PNETCDF=$PNETCDF_DIR 
export HDF5=$HDF5_DIR
```

5. Configure WRF options

```bash
cd ${WRF_DIR}
./configure
```

At the first prompt, enter `35` to select the option `(dm+sm) GNU (gfortran/gcc)`

```bash
Enter selection [1-83] : 35
```

At the second prompt, enter `1` to select the option for `nesting 1=basic`.

```bash
Compile for nesting? (1=basic, 2=preset moves, 3=vortex following) [default 1]:1
```

5. Compile WRF on 16 cores (max is 20)

```bash
./compile -j 16 em_real
```

If successful, you will see a final output similar to

```bash
build started:   Wed Nov 12 15:14:18 MST 2025
build completed: Wed Nov 12 15:17:30 MST 2025
 
--->                  Executables successfully built                  <---
 
-rwxrwxr-x 1 eyoung eyoung 39826880 Nov 12 15:17 main/ndown.exe
-rwxrwxr-x 1 eyoung eyoung 36185816 Nov 12 15:17 main/real.exe
-rwxrwxr-x 1 eyoung eyoung 35632920 Nov 12 15:17 main/tc.exe
-rwxrwxr-x 1 eyoung eyoung 45807024 Nov 12 15:17 main/wrf.exe
```

6. Next, configure WPS. We will navigate to the WPS directory and perform a similar 2-step process of configuring and compiling the applications.

```bash
cd ${WPS_DIR}
./configure
```

When prompted, enter `3` to select the option for `Linux x86_64, gfortran (dmpar)`
```
Enter selection [1-44] : 3
```

7. Edit the `configure.wps` file created in Step 6. In a file editor of your choice, open `configure.wps` for writing. Find the assignment of `WRF_LIB` on line `44` and add the flag for `fopenmp` on the last line as shown below.

```bash
WRF_LIB         =       -L$(WRF_DIR)/external/io_grib1 -lio_grib1 \
                        -L$(WRF_DIR)/external/io_grib_share -lio_grib_share \
                        -L$(WRF_DIR)/external/io_int -lwrfio_int \
                        -L$(WRF_DIR)/external/io_netcdf -lwrfio_nf \
                        -L$(NETCDF)/lib -lnetcdff -lnetcdf -fopenmp
```

Save and close the file after adding this flag.

8. Finally, compile WPS

```bash
./compile
```



## Submitting Benchmarking Jobs

0. Create copies of the run directories for the profiling sweep, here the `_n02` and `_n04` suffixes represents cases that will be run on 2 and 4 nodes, respectively. Make as many copies as desired, one per each of the cases you would like to run simultaneously and independently.

```bash
cp -r ${WRF_DIR}/run/ ${WRF_DIR}/run_n02
cp -r ${WRF_DIR}/run/ ${WRF_DIR}/run_n04
...
```

1. Download the 2.5 km conus benchmark. Note that this is ~34 GB file and may take 5 to 10 minutes to complete depending on the speed of your connection.

```bash
wget https://www2.mmm.ucar.edu/wrf/users/benchmark/v44/v4.4_bench_conus2.5km.tar.gz
```

2. Unpack the downloaded file from Step 1

```bash
tar -xvzf v4.4_bench_conus2.5km.tar.gz
cd v4.4_bench_conus2.5km
```

3. We will make a slight modification to the provided `namelist.input` file to utilize the parallel netcdf functionality we compiled the WRF executable with. From within the `v4.4_bench_conus2.5km` directory, open the `namelist.input` file for writing in an editor of your choice. Modify the file on lines 24 and 25 to use parallel file writing by changing the value of the `io_form_history` and `io_form_restart` variables from `2` to `11` as shown below.

``` bash
io_form_history                     = 11,
io_form_restart                     = 11,
```

Save and close the file once these two lines have been changed.

3. Still within the `v4.4_bench_conus2.5km` directory, copy all the necessary input files (including the modified `namelist.input` file from Step 3) into all applicable `${WRF_DIR}/run_n02` directories. Note that if you previously completed the steps for Building WRF, you will likely need to reassign the variable `WRF_DIR` to reflect your installation directory.

```bash
cp *.dat *.input *_d01 ${WRF_DIR}/run_n02
cp *.dat *.input *_d01 ${WRF_DIR}/run_n04
...
```

4. Navigate to one of the run directories created in Step 0 and create a new `submit_job.sbatch` script. Shown below is the example for a 2-node run, saved as `${WRF_DIR}/run_n02/submit_job.sbatch`. Additional copies can be created in other run directories, noting that the number of nodes in the header and number of cores specified by `srun -n num_cores` must be modified appropriately.

```bash
#!/bin/bash
#SBATCH --account=hpcapps
#SBATCH --time=4:00:00
#SBATCH --nodes=2
#SBATCH --exclusive
#SBATCH --mem=0

module purge
module load PrgEnv-gnu/8.5.0
module load netcdf/4.9.3-cray-mpich-gcc
module load jasper/1.900.1-cray-mpich-gcc

export OMP_NUM_THREADS=1

srun -n 192 --cpu-bind=rank_ldom ./wrf.exe
```


5. Submit the job

```bash
sbatch submit_job.sbatch
```

## Measuring and Recording Performance

Once the jobs submitted above have finished, each of the run directories will be populated with 