# Spreadsheet Table Template

Generated via the embedded [log parsing utility](./log-parser/README.md) using example Kestrel data.

| Run Type | System | RDMA invoked | CPU cores per rank | Number of devices per node | Number of nodes | Message size (B) | Median Out-of-Place Time (uS) | Median Out-of-Place Algorithmic Bandwidth (GB/s) | Median Out-of-Place Bus Bandwidth (GB/s) | Median In-Place Time (uS) | Median In-Place Algorithmic Bandwidth (GB/s) | Median In-Place Bus Bandwidth (GB/s) | Number of Replicates |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| Baseline | kestrel | No | 1 | 4 | 1 | 8 | 8.29 | 0 | 0 | 8.29 | 0 | 0 | 5 |
| Baseline | kestrel | No | 1 | 4 | 1 | 524288 | 14.93 | 35.13 | 52.69 | 14.93 | 38.07 | 57.1 | 5 |
| Baseline | kestrel | No | 1 | 4 | 1 | 33554432 | 177.31 | 189.24 | 283.86 | 177.31 | 190.61 | 285.92 | 5 |
| Baseline | kestrel | No | 1 | 4 | 1 | 4294967296 | 18923.2 | 226.97 | 340.45 | 18923.2 | 226.68 | 340.03 | 5 |
| Baseline | kestrel | No | 1 | 4 | 2 | 8 | 22.82 | 0 | 0 | 22.82 | 0 | 0 | 5 |
| Baseline | kestrel | No | 1 | 4 | 2 | 524288 | 134.74 | 3.89 | 6.81 | 134.74 | 3.89 | 6.81 | 5 |
| Baseline | kestrel | No | 1 | 4 | 2 | 33554432 | 1661.58 | 20.19 | 35.34 | 1661.58 | 20.07 | 35.12 | 5 |
| Baseline | kestrel | No | 1 | 4 | 2 | 4294967296 | 129207 | 33.24 | 58.17 | 129207 | 33.27 | 58.23 | 5 |
| Baseline | kestrel | No | 1 | 4 | 4 | 8 | 48.54 | 0 | 0 | 48.54 | 0 | 0 | 5 |
| Baseline | kestrel | No | 1 | 4 | 4 | 524288 | 211.93 | 2.47 | 4.64 | 211.93 | 2.48 | 4.64 | 5 |
| Baseline | kestrel | No | 1 | 4 | 4 | 33554432 | 1770.2 | 18.96 | 35.54 | 1770.2 | 18.87 | 35.38 | 5 |
| Baseline | kestrel | No | 1 | 4 | 4 | 4294967296 | 224956 | 19.09 | 35.8 | 224956 | 19.15 | 35.91 | 5 |
| Baseline | kestrel | No | 1 | 4 | 24 | 8 | 99.07 | 0 | 0 | 99.07 | 0 | 0 | 5 |
| Baseline | kestrel | No | 1 | 4 | 24 | 524288 | 432.44 | 1.21 | 2.4 | 432.44 | 1.23 | 2.44 | 5 |
| Baseline | kestrel | No | 1 | 4 | 24 | 33554432 | 4115.11 | 8.15 | 16.14 | 4115.11 | 8.15 | 16.14 | 5 |
| Baseline | kestrel | No | 1 | 4 | 24 | 4294967296 | 385838 | 11.13 | 22.03 | 385838 | 11.14 | 22.05 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 8 | 8.31 | 0 | 0 | 8.31 | 0 | 0 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 524288 | 14.95 | 35.07 | 52.61 | 14.95 | 37.97 | 56.95 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 33554432 | 177.06 | 189.51 | 284.26 | 177.06 | 191.01 | 286.51 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 1 | 4294967296 | 18943.3 | 226.73 | 340.09 | 18943.3 | 226.64 | 339.97 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 8 | 26.67 | 0 | 0 | 26.67 | 0 | 0 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 524288 | 79.46 | 6.6 | 11.55 | 79.46 | 6.6 | 11.54 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 33554432 | 1110.88 | 30.21 | 52.86 | 1110.88 | 30.21 | 52.87 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 2 | 4294967296 | 93274.1 | 46.05 | 80.58 | 93274.1 | 46.05 | 80.59 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 4 | 8 | 43.34 | 0 | 0 | 43.34 | 0 | 0 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 4 | 524288 | 117.16 | 4.47 | 8.39 | 117.16 | 4.49 | 8.41 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 4 | 33554432 | 1509.16 | 22.23 | 41.69 | 1509.16 | 22.22 | 41.65 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 4 | 4294967296 | 179748 | 23.89 | 44.8 | 179748 | 23.83 | 44.69 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 8 | 80.61 | 0 | 0 | 80.61 | 0 | 0 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 524288 | 208.29 | 2.52 | 4.98 | 208.29 | 2.53 | 5 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 33554432 | 2726.69 | 12.31 | 24.36 | 2726.69 | 12.29 | 24.33 | 5 |
| Baseline | kestrel | Yes | 1 | 4 | 24 | 4294967296 | 321972 | 13.34 | 26.4 | 321972 | 13.34 | 26.4 | 5 |
| Optimized | kestrel | No | 32 | 4 | 1 | 8 | 8.34 | 0 | 0 | 8.34 | 0 | 0 | 5 |
| Optimized | kestrel | No | 32 | 4 | 1 | 524288 | 14.91 | 35.16 | 52.74 | 14.91 | 38.13 | 57.19 | 5 |
| Optimized | kestrel | No | 32 | 4 | 1 | 33554432 | 176.21 | 190.42 | 285.64 | 176.21 | 190.2 | 285.3 | 5 |
| Optimized | kestrel | No | 32 | 4 | 1 | 4294967296 | 18932.1 | 226.86 | 340.29 | 18932.1 | 227.02 | 340.54 | 5 |
| Optimized | kestrel | No | 32 | 4 | 2 | 8 | 17.97 | 0 | 0 | 17.97 | 0 | 0 | 5 |
| Optimized | kestrel | No | 32 | 4 | 2 | 524288 | 119.53 | 4.39 | 7.68 | 119.53 | 4.42 | 7.74 | 5 |
| Optimized | kestrel | No | 32 | 4 | 2 | 33554432 | 1685.34 | 19.91 | 34.84 | 1685.34 | 19.96 | 34.93 | 5 |
| Optimized | kestrel | No | 32 | 4 | 2 | 4294967296 | 129320 | 33.21 | 58.12 | 129320 | 33.25 | 58.19 | 5 |
| Optimized | kestrel | No | 32 | 4 | 4 | 8 | 37.36 | 0 | 0 | 37.36 | 0 | 0 | 5 |
| Optimized | kestrel | No | 32 | 4 | 4 | 524288 | 197.51 | 2.65 | 4.98 | 197.51 | 2.66 | 4.98 | 5 |
| Optimized | kestrel | No | 32 | 4 | 4 | 33554432 | 1778.53 | 18.87 | 35.37 | 1778.53 | 18.97 | 35.58 | 5 |
| Optimized | kestrel | No | 32 | 4 | 4 | 4294967296 | 225096 | 19.08 | 35.78 | 225096 | 19.22 | 36.03 | 5 |
| Optimized | kestrel | No | 32 | 4 | 24 | 8 | 72.42 | 0 | 0 | 72.42 | 0 | 0 | 5 |
| Optimized | kestrel | No | 32 | 4 | 24 | 524288 | 430.66 | 1.22 | 2.41 | 430.66 | 1.23 | 2.44 | 5 |
| Optimized | kestrel | No | 32 | 4 | 24 | 33554432 | 2763.65 | 12.14 | 24.03 | 2763.65 | 12.11 | 23.98 | 5 |
| Optimized | kestrel | No | 32 | 4 | 24 | 4294967296 | 244872 | 17.54 | 34.71 | 244872 | 17.57 | 34.77 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 8 | 8.38 | 0 | 0 | 8.38 | 0 | 0 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 524288 | 14.88 | 35.24 | 52.86 | 14.88 | 38.13 | 57.19 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 33554432 | 177.69 | 188.84 | 283.26 | 177.69 | 189.95 | 284.92 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 1 | 4294967296 | 18914.2 | 227.08 | 340.61 | 18914.2 | 227.17 | 340.76 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 8 | 16.9 | 0 | 0 | 16.9 | 0 | 0 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 524288 | 75.51 | 6.94 | 12.15 | 75.51 | 7.07 | 12.36 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 33554432 | 1112.28 | 30.17 | 52.79 | 1112.28 | 30.29 | 53 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 2 | 4294967296 | 93231.4 | 46.07 | 80.62 | 93231.4 | 46.07 | 80.62 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 4 | 8 | 33.87 | 0 | 0 | 33.87 | 0 | 0 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 4 | 524288 | 105.49 | 4.97 | 9.32 | 105.49 | 5.02 | 9.41 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 4 | 33554432 | 1498.52 | 22.39 | 41.98 | 1498.52 | 22.38 | 41.97 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 4 | 4294967296 | 179524 | 23.92 | 44.86 | 179524 | 23.94 | 44.89 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 8 | 64 | 0 | 0 | 64 | 0 | 0 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 524288 | 190.55 | 2.75 | 5.45 | 190.55 | 2.73 | 5.41 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 33554432 | 1587.43 | 21.14 | 41.83 | 1587.43 | 21.15 | 41.86 | 5 |
| Optimized | kestrel | Yes | 32 | 4 | 24 | 4294967296 | 204974 | 20.95 | 41.47 | 204974 | 20.95 | 41.46 | 5 |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 8 |  |  |  |  |  |  |  |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 524288 |  |  |  |  |  |  |  |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 33554432 |  |  |  |  |  |  |  |
| (Baseline/Ported/Optimized) | Offered | (Yes/No) | 1 |  |  | 4294967296 |  |  |  |  |  |  |  |