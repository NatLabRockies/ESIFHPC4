#!/bin/bash

set -e

i=1
for file in $(ls -d1 amr-wind-benchmark* | sort -V); do
    echo "$file"
    grep ^WallClockTime "$file" | awk '{print $NF}' > amr-wind-time-$i.txt
    python3 amr-wind-average.py -f amr-wind-time-$i.txt >> amr-wind-avg.txt
    rm amr-wind-time-$i.txt
    ((i=i+1))
done
