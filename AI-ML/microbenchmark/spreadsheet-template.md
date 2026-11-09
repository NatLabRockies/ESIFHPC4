# Spreadsheet Table Template

Generated via the embedded [log parsing utility](./log-parser/README.md) using example Kestrel data.

| Run Type | System | RDMA invoked | CPU cores per rank | Number of devices per node | Number of nodes | Message size (B) | Median Out-of-Place Time (uS) | Median Out-of-Place Algorithmic Bandwidth (GB/s) | Median Out-of-Place Bus Bandwidth (GB/s) | Median In-Place Time (uS) | Median In-Place Algorithmic Bandwidth (GB/s) | Median In-Place Bus Bandwidth (GB/s) | Number of Replicates |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| Baseline | kestrel | No | 1 | 4 | 1 | 8 | 8.24 | 0 | 0 | 8.24 | 0 | 0 | 1 |
| Baseline | kestrel | No | 1 | 4 | 1 | 524288 | 14.98 | 35 | 52.5 | 14.98 | 37.58 | 56.37 | 1 |
| Baseline | kestrel | No | 1 | 4 | 1 | 33554432 | 178.48 | 188 | 282.01 | 178.48 | 187.97 | 281.96 | 1 |
| Baseline | kestrel | No | 1 | 4 | 1 | 4294967296 | 19113 | 224.71 | 337.07 | 19113 | 225.49 | 338.24 | 1 |
| Baseline | kestrel | No | 1 | 4 | 2 | 8 | 28.39 | 0 | 0 | 28.39 | 0 | 0 | 1 |
| Baseline | kestrel | No | 1 | 4 | 2 | 524288 | 135.38 | 3.87 | 6.78 | 135.38 | 3.94 | 6.89 | 1 |
| Baseline | kestrel | No | 1 | 4 | 2 | 33554432 | 1684.5 | 19.92 | 34.86 | 1684.5 | 19.94 | 34.89 | 1 |
| Baseline | kestrel | No | 1 | 4 | 2 | 4294967296 | 129910 | 33.06 | 57.86 | 129910 | 33.09 | 57.91 | 1 |
| Baseline | kestrel | No | 1 | 4 | 24 | 8 | 111.69 | 0 | 0 | 111.69 | 0 | 0 | 1 |
| Baseline | kestrel | No | 1 | 4 | 24 | 524288 | 434.03 | 1.21 | 2.39 | 434.03 | 1.23 | 2.43 | 1 |
| Baseline | kestrel | No | 1 | 4 | 24 | 33554432 | 4075.68 | 8.23 | 16.29 | 4075.68 | 8.25 | 16.33 | 1 |
| Baseline | kestrel | No | 1 | 4 | 24 | 4294967296 | 384990 | 11.16 | 22.08 | 384990 | 11.15 | 22.08 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 8 | 8.2 | 0 | 0 | 8.2 | 0 | 0 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 524288 | 14.77 | 35.49 | 53.23 | 14.77 | 38.25 | 57.38 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 33554432 | 176.95 | 189.63 | 284.44 | 176.95 | 189.16 | 283.74 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 4294967296 | 19061.3 | 225.32 | 337.99 | 19061.3 | 225.78 | 338.67 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 8 | 28.08 | 0 | 0 | 28.08 | 0 | 0 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 524288 | 82.23 | 6.38 | 11.16 | 82.23 | 6.4 | 11.2 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 33554432 | 1117.97 | 30.01 | 52.52 | 1117.97 | 30.1 | 52.68 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 4294967296 | 95678.7 | 44.89 | 78.56 | 95678.7 | 44.89 | 78.56 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 8 | 87.1 | 0 | 0 | 87.1 | 0 | 0 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 524288 | 205.11 | 2.56 | 5.06 | 205.11 | 2.58 | 5.1 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 33554432 | 2728.68 | 12.3 | 24.34 | 2728.68 | 12.32 | 24.38 | 1 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 4294967296 | 321815 | 13.35 | 26.41 | 321815 | 13.35 | 26.42 | 1 |
| Optimized | kestrel | No | 32 | 4 | 1 | 8 | 8.35 | 0 | 0 | 8.35 | 0 | 0 | 1 |
| Optimized | kestrel | No | 32 | 4 | 1 | 524288 | 14.83 | 35.36 | 53.04 | 14.83 | 38.02 | 57.03 | 1 |
| Optimized | kestrel | No | 32 | 4 | 1 | 33554432 | 179.84 | 186.58 | 279.87 | 179.84 | 186.12 | 279.17 | 1 |
| Optimized | kestrel | No | 32 | 4 | 1 | 4294967296 | 19901.7 | 215.81 | 323.71 | 19901.7 | 215.59 | 323.39 | 1 |
| Optimized | kestrel | No | 32 | 4 | 2 | 8 | 17.66 | 0 | 0 | 17.66 | 0 | 0 | 1 |
| Optimized | kestrel | No | 32 | 4 | 2 | 524288 | 120.26 | 4.36 | 7.63 | 120.26 | 4.4 | 7.69 | 1 |
| Optimized | kestrel | No | 32 | 4 | 2 | 33554432 | 1702.29 | 19.71 | 34.49 | 1702.29 | 20.07 | 35.12 | 1 |
| Optimized | kestrel | No | 32 | 4 | 2 | 4294967296 | 129186 | 33.25 | 58.18 | 129186 | 33.28 | 58.24 | 1 |
| Optimized | kestrel | No | 32 | 4 | 24 | 8 | 96.81 | 0 | 0 | 96.81 | 0 | 0 | 1 |
| Optimized | kestrel | No | 32 | 4 | 24 | 524288 | 431.86 | 1.21 | 2.4 | 431.86 | 1.23 | 2.43 | 1 |
| Optimized | kestrel | No | 32 | 4 | 24 | 33554432 | 4038.66 | 8.31 | 16.44 | 4038.66 | 8.3 | 16.43 | 1 |
| Optimized | kestrel | No | 32 | 4 | 24 | 4294967296 | 384768 | 11.16 | 22.09 | 384768 | 11.16 | 22.09 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 8 | 8.61 | 0 | 0 | 8.61 | 0 | 0 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 524288 | 14.94 | 35.08 | 52.63 | 14.94 | 38.44 | 57.65 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 33554432 | 175.35 | 191.36 | 287.03 | 175.35 | 191.47 | 287.21 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 4294967296 | 18925.8 | 226.94 | 340.41 | 18925.8 | 227.09 | 340.64 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 8 | 17.88 | 0 | 0 | 17.88 | 0 | 0 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 524288 | 77.77 | 6.74 | 11.8 | 77.77 | 6.83 | 11.95 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 33554432 | 1116.17 | 30.06 | 52.61 | 1116.17 | 30.12 | 52.71 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 4294967296 | 95308.1 | 45.06 | 78.86 | 95308.1 | 44.99 | 78.73 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 8 | 75.9 | 0 | 0 | 75.9 | 0 | 0 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 524288 | 190.63 | 2.75 | 5.44 | 190.63 | 2.72 | 5.39 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 33554432 | 2715.56 | 12.36 | 24.46 | 2715.56 | 12.36 | 24.47 | 1 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 4294967296 | 321753 | 13.35 | 26.42 | 321753 | 13.35 | 26.42 | 1 |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 8 |  |  |  |  |  |  |  |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 524288 |  |  |  |  |  |  |  |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 33554432 |  |  |  |  |  |  |  |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 4294967296 |  |  |  |  |  |  |  |