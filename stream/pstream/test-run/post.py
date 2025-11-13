#!/usr/bin/env python3
import os
# pull out our important data from each of the GPU output files
command="cat strm.0* | egrep 'STREAM|Copy|Scale|Add|Triad' | sed 's/STREAM Benchmark implementation in CUDA on device//' | sed 's/of/ /' | awk '{print $1,$2}'"
run=os.popen(command,"r")
f=run.readlines()

# we are glint to join  5 lines into 1
kmax=5
# our header
print("NODE,GPU,Copy,Scale,Add,Triad")
k=""
j=0
for l in f:
	l=l.rstrip()
	k=k+" "+l
	j=j+1
	if(j == kmax):
		k=k.split()
		print(k[1],k[0],k[3],k[5],k[7],k[9],sep=",")
		k=""
		j=0
