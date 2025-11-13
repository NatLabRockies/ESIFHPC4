#!/bin/bash
help1="Usage: validate.bash [calculation directory]. Make sure your python is version 3!"
if [ $# -ne 1 ]; then
	echo $help1;
	exit
fi
for i in gga hse 
do
	python validate.py $1 $i
done

