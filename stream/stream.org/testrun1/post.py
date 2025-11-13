#!/usr/bin/env python3
# The following lines need to be modified
# Compilers used
fort="ifc"
c="icc"
# Memory on a node
mem=262993528000
# Results file with a collection of streams runs
infile="results.icx.ifx"
# Output summary file
outfile="STREAM.tab"
# Notes can contain info about the nodes
notes="kestrel nodes"
import sys
import os
import pandas as pd
import io
df=pd.DataFrame(columns=["Compiler","test","% mem","Size","Threads","Rate (MB/s)","Avg time","Min time","Max time","notes"])
for test in ['Add','Copy','Scale','Triad'] :
    command='egrep "Array|XXXX|Number of Threads =|counted" out.dat | sed "s/(elements), Offset = 0 (elements)//" | jlines 3'
    command=command.replace("XXXX",test)
    command=command.replace("out.dat",infile)
    dxf=os.popen(command,"r")
    lines=dxf.readlines()
    for l in lines:
        if l.find(test) == -1 :
            continue
        lang=fort
        if l.find("counted") > -1:
            lang=c
        l=l.split()
        n=[]
        f=[]
        for x in l:
            a=x
            if a.isdigit():
                #print("Integer")
                n.append(int(a))
            elif a.replace('.','',1).isdigit() and a.count('.') < 2:
                #print("Float")
                f.append(float(a))
            else:
                pass
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
