#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt


###############################################################################
###############################################################################
#general settings to modify to show new data for Offeror
data_filename = 'results-summary.xlsx'
benchmarkers = ['NREL','example_benchmarker']
node_categories = ['Standard','Accelerated']

###############################################################################
###############################################################################

#the rest of this script can be modified if needed, but may facilitate any 
#data plotting for Offeror

all_data = pd.read_excel(f'{data_filename}')

#dict of benchmark sizes with colors to plot them with
benchmark_sizes = {
    'Small': {'color': 'm'},
    'Medium': {'color': 'dodgerblue'},
    'Large': {'color': 'orange'},
    }
for node_category in node_categories:
    
    #initialize plot and lists for legend
    fig = plt.figure(figsize=(5,4), dpi=150)
    ax = fig.add_subplot(111)
    lines = []
    labels = []

    for benchmarker in benchmarkers:
        for benchmark_size in benchmark_sizes:
            #downselect dataframe data rows
            size_data = all_data.loc[(all_data['Node Category'] == node_category) & 
                                     (all_data['Benchmarker'] == benchmarker) & 
                                     (all_data['Problem Size'] == benchmark_size)
                                     ]
            if len(size_data) == 0:
                #then there is no data for this combo of settings
                continue
        
            xvals = size_data['CPU or GPU Nodes Used']
            yvals = size_data['Epsilon Benchmark Time (seconds)']
            
            #change line settings to provide contrast with NREL baseline results
            alpha = 0.9
            markersize = 10
            linewidth = 4
            linestyle = '-'
            dashes = (1,0)
            if benchmarker == 'NREL':
                alpha = 0.5
                markersize = 8
                linewidth = 3
                linestyle = '--'
                dashes = (2,0.5)
            my_line, = ax.plot(xvals, yvals, color=benchmark_sizes[benchmark_size]['color'], 
                               markersize=markersize, marker='o', linewidth=linewidth, 
                               zorder=10, clip_on=False, alpha=alpha, 
                               linestyle=linestyle, dashes=dashes)
            if benchmarker == 'NREL':
                #only store lines/labels for the legend once
                lines.append(my_line)
                labels.append(benchmark_size)
        
    ax.legend(tuple(lines), tuple(labels), loc='best', fontsize=11)
    
    ax.set_title('BerkeleyGW Si epsilon\nbenchmarks')
    ax.grid(axis='both', color='gainsboro', linewidth=0.5, zorder=1)
    
    #format axes
    xlim = [0.25,1024]
    ylim = [8,2048]
    ax.set_xscale('log', base=2)
    ax.set_yscale('log', base=2)
    ax.set_xlabel(f'Number of {node_category} nodes', fontsize=14)
    ax.set_ylabel('Job time w/o IO (s)', fontsize=14)
    ax.set_xlim(xlim)
    ax.set_xticks([0.25,1,4,16,64,256,1024])
    ax.set_xticklabels([r'$\frac{1}{4}$',1,4,16,64,256,1024])
    ax.set_ylim(ylim)
    ax.set_yticks([8,32,128,512,2048])
    ax.set_yticklabels([8,32,128,512,2048])
    [ax.spines[x].set_zorder(2) for x in ax.spines]
    ax.set_aspect('equal')
    plt.xticks(fontsize=14)
    plt.yticks(fontsize=14)

    #add diagonal gridlines
    for m in [4**e for e in [1,2,3,4,5,6,7,8,9,10]]:
        ax.plot([xlim[0],xlim[0]*m],[ylim[0]*m,ylim[0]], color='gainsboro', marker=None, linewidth=0.5, zorder=1)

    plt.tight_layout()
    plt.savefig(f'bgw-{node_category}-scaling-summary.png')
    plt.show()



