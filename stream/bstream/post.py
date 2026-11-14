#!/usr/bin/env python3
import sys
import os
import pandas as pd
import io
# The following lines need to be modified
# Compilers name comes from the input file name
# Memory on a node
mem=262993528000
#mem=1055716516000
# Results file with a collection of streams runs
infile="babel.gcc"
if len(sys.argv) > 1: infile=sys.argv[1]
# Output summary file
outfile=infile+".tab"
# Notes can contain info about the nodes
notes="kestrel regular"
df=pd.DataFrame(columns=["Compiler","test","% mem","Size","Threads","Rate (MB/s)","Avg time","Min time","Max time","notes"])
for test in ['Add','Copy','Mul','Triad'] :
    command='egrep "Array|XXXX|Number of Threads =|counted" out.dat | sed "s/(elements), Offset = 0 (elements)//" | paste - - -'
    command='egrep "Array|XXXX|OMP_NUM_THREADS|elements" out.dat | paste - - - -'
    command=command.replace("XXXX",test)
    command=command.replace("out.dat",infile)
    dxf=os.popen(command,"r")
    lines=dxf.readlines()
    for l in lines:
        lang=infile
        l=l.split()
        n=[]
        f=[]
        t=int(       l[1])
        elements=int(l[5])
        size=float(  l[8])
        rate=float(  l[11])
        mint=float(  l[12])
        maxt=float(  l[13])
        avet=float(  l[14])
        n.append(elements)
        n.append(t)
        f.append(rate)
        f.append(avet)
        f.append(mint)
        f.append(maxt)

        nbytes=n[0]*8*3
        precent=100.0*(nbytes/mem)
        string_capture = io.StringIO()
        print("%6.3f" % precent,file=string_capture,end="")
        outline=[lang,test,string_capture.getvalue()]
        for x in n:
            outline.append(str(x))
        for x in f:
            outline.append(str(x))
        outline.append(notes)
        df.loc[len(df)]=outline
        outline=str(outline)
        outline=outline.replace("'","")
        outline=outline.replace("[","")
        outline=outline.replace("]","")   


df.to_csv(outfile, index = False,sep='\t')
