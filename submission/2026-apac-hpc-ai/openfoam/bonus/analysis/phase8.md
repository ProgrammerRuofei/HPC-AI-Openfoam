# Phase 8: simpleFoam MPI profile

These runs load a PMPI library on `simpleFoam` only. The preparation
chain is not profiled. Compute is the mean rank wall time minus the
mean time inside the wrapped MPI calls. Profile runs are analysis
evidence. They do not replace the unprofiled contest quote.

## Compute and MPI

| Compiler | Nodes | Ranks | Original s/step | Profiled s/step | Overhead | Cd | Compute | MPI |
|----------|------:|------:|----------------:|----------------:|---------:|---:|--------:|----:|
| AOCC 5.0 | 1 | 128 | 13.307 | 13.316 | +0.07% | 0.4364 | 83.06% | 16.94% |
| GCC 15.2 | 1 | 128 | 13.293 | 13.338 | +0.34% | 0.4336 | 84.46% | 15.54% |
| ICX 2025.1 | 1 | 128 | 13.333 | 13.360 | +0.20% | 0.4353 | 86.93% | 13.07% |
| AOCC 5.0 | 2 | 256 | 6.379 | 6.396 | +0.26% | 0.3271 | 79.71% | 20.29% |
| GCC 15.2 | 2 | 256 | 6.374 | 6.374 | +0.01% | 0.3308 | 81.56% | 18.44% |
| ICX 2025.1 | 2 | 256 | 6.389 | 6.401 | +0.19% | 0.3305 | 84.45% | 15.55% |
| AOCC 5.0 PgoUse | 4 | 512 | 2.868 | 2.879 | +0.38% | 0.2800 | 75.78% | 24.22% |
| GCC 15.2 | 4 | 512 | 2.880 | 2.899 | +0.65% | 0.2795 | 77.29% | 22.71% |
| ICX 2025.1 | 4 | 512 | 2.898 | 2.892 | -0.22% | 0.2832 | 81.37% | 18.63% |

## Dominant MPI calls

| Compiler | Nodes | Top three by mean rank time | Top three by mean count |
|----------|------:|-----------------------------|-------------------------|
| AOCC 5.0 | 1 | MPI_Barrier 53.20s, MPI_Waitall 26.09s, MPI_Allreduce 18.31s | MPI_Isend 560,515, MPI_Irecv 560,515, MPI_Allreduce 64,143 |
| GCC 15.2 | 1 | MPI_Barrier 40.12s, MPI_Waitall 27.92s, MPI_Allreduce 18.96s | MPI_Isend 549,350, MPI_Irecv 549,350, MPI_Allreduce 64,078 |
| ICX 2025.1 | 1 | MPI_Barrier 27.85s, MPI_Waitall 20.26s, MPI_Allreduce 19.81s | MPI_Isend 560,217, MPI_Irecv 560,217, MPI_Allreduce 64,082 |
| AOCC 5.0 | 2 | MPI_Barrier 57.49s, MPI_Waitall 28.92s, MPI_Allreduce 26.39s | MPI_Isend 1,105,123, MPI_Irecv 1,105,123, MPI_Allreduce 126,084 |
| GCC 15.2 | 2 | MPI_Barrier 42.00s, MPI_Waitall 30.32s, MPI_Allreduce 25.82s | MPI_Isend 1,143,720, MPI_Irecv 1,143,720, MPI_Allreduce 126,038 |
| ICX 2025.1 | 2 | MPI_Allreduce 27.63s, MPI_Barrier 25.06s, MPI_Waitall 25.02s | MPI_Isend 1,116,350, MPI_Irecv 1,116,350, MPI_Allreduce 125,932 |
| AOCC 5.0 PgoUse | 4 | MPI_Barrier 57.90s, MPI_Allreduce 29.24s, MPI_Waitall 26.56s | MPI_Isend 2,135,262, MPI_Irecv 2,135,262, MPI_Allreduce 233,418 |
| GCC 15.2 | 4 | MPI_Barrier 43.50s, MPI_Allreduce 31.92s, MPI_Waitall 28.81s | MPI_Isend 2,095,828, MPI_Irecv 2,095,828, MPI_Allreduce 233,390 |
| ICX 2025.1 | 4 | MPI_Allreduce 28.46s, MPI_Barrier 27.59s, MPI_Waitall 22.28s | MPI_Isend 2,141,633, MPI_Irecv 2,141,633, MPI_Allreduce 233,278 |

## Interpretation

- MPI share increases as the run scales from 1 to 4 nodes for all three compilers.
- AOCC has the lowest unprofiled 4-node time, but its measured MPI share is the highest of the three 4-node profiles.
- `MPI_Barrier`, `MPI_Allreduce`, and `MPI_Waitall` dominate time. `MPI_Isend` and `MPI_Irecv` dominate call count.
- Each run makes one timed `MPI_Barrier`. Its large time shows a final global synchronization and rank skew, not frequent barriers.
- Small negative overhead is run noise. Use the original unprofiled times for the contest score.

## APS hardware-counter probe

APS 2024.0 was tested on Aspire2A in job `25725694`. Collection
stopped before the smoke program because VTune could not recognize
the AMD processor microarchitecture. No 4-node APS jobs were run.
The PMPI results above are the Phase 8 evidence.

The ISC26 Iris result (91.2% compute / 8.8% MPI) is historical.
It is not an Aspire2A result and is not used as this year's score.

Machine-readable call data is in `results/profiles.csv`.
