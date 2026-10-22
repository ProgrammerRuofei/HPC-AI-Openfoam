# Four-node PMPI rank and partition analysis: 181908113.gadi-pbs

Read-only analysis of the preserved Scotch 10_decomposePar.log, rank-host-map.txt, and four SHA-256-validated PMPI archives. No new PBS job was submitted.

Configuration: Gadi normalsr, four Sapphire Rapids nodes, 416 MPI ranks (104/node), GCC 16.2.0, private Open MPI 5.0.10, loaded ucx/1.18.1 and ucc/1.4.4, OpenFOAM v2512, fixed ~65M-cell occDrivAerStaticMesh, Scotch, 150 steps. This is an unscored diagnostic: 1.993566906751678 s/step, Cd 0.29187594927465327, PBS exit 0, 246.83 SU.

The steady columns sum PMPI 10-second buckets whose start is at least 70 s after MPI_Init. This excludes the ~64 s one-time startup MPI_Barrier while rank 0 compiled the coded function object. This cutoff is an analysis convention, not an exact solver-phase timestamp. PMPI durations include waiting and do not measure network transmission alone.

## Integrity checks

- 416 rank rows, 416 full reports, 416 bucket reports, four hosts with 104 ranks each.
- 2307 unique symmetric rank-pair boundaries; each rank neighbor-face sum equals its logged processor-face total.
- 352 rank-pair boundaries cross a node; 300065 unique faces cross a node out of 2690403 unique processor faces.
- The full-rank and 10-second PMPI counters reconciled with zero mismatches in the source archive check.
- Existing v2 full reports contain 914,203,155 `MPI_Isend` and 914,203,155 `MPI_Irecv` calls globally; blocking `MPI_Send` and `MPI_Recv` are 820,455 each. Per-rank send/receive counts need not match because ranks communicate with different peers. These reports do not contain per-peer payload bytes.

## Rank-level findings

- Cells/rank: 152,358–158,841; CV 0.73%.
- Processor faces/rank: 5,152–24,462; CV 29.87%.
- Cross-node faces/rank: 0–10,472.
- Pearson r with steady MPI_Waitall: cells 0.032; total processor faces 0.481; cross-node faces 0.350. Correlation is descriptive, not proof of a network bottleneck.
- The 206 ranks with at least one cross-node face average 21.398 s of steady Waitall; the 210 ranks without one average 17.365 s. Node means range from 17.340 s (node 2) to 22.811 s (node 1). These groups also differ in partition surface and workload, so this comparison does not isolate network cost.

| Rank | Node | Cells | Processor faces | Cross-node faces | Steady Waitall s | Steady Allreduce s |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 112 | 1 | 156,870 | 13,791 | 0 | 32.613 | 20.891 |
| 285 | 2 | 155,484 | 10,656 | 825 | 31.524 | 19.867 |
| 282 | 2 | 158,427 | 12,674 | 6,887 | 30.940 | 14.958 |
| 200 | 1 | 157,491 | 18,618 | 0 | 29.950 | 18.182 |
| 111 | 1 | 158,001 | 16,289 | 4,186 | 29.897 | 18.647 |
| 175 | 1 | 157,270 | 18,372 | 1,719 | 29.553 | 17.034 |
| 4 | 0 | 156,079 | 17,002 | 4,861 | 28.878 | 17.570 |
| 9 | 0 | 158,458 | 16,998 | 5,440 | 28.810 | 17.214 |
| 203 | 1 | 155,484 | 10,933 | 0 | 28.722 | 25.057 |
| 283 | 2 | 156,231 | 14,431 | 6,305 | 28.582 | 17.647 |

Rank 112 has the highest steady Waitall (32.613 s) but zero direct cross-node faces. This rules out a simple explanation that only ranks with remote neighbors wait longest. Neighbor load, collective synchronization, and CPU placement remain possible contributors.

## Zero-SU placement thought experiment (2026-10-22)

Using only the saved rank-pair face graph, a deterministic greedy sequence
of 15 pairwise rank swaps between node groups preserved exactly 104 ranks
in each of four groups. It reduced weighted cross-node processor faces from
300,065 to 262,385, a **12.56%** reduction of cross-node faces. Relative to
all 2,690,403 unique processor faces, the reduction is only **1.40%**.
This is a graph-cut estimate, not a tested rankfile or runtime result. It
does not account for physical-core affinity, memory locality, collectives,
message size, or the node-local JOBFS processor layout. Given the modest
fraction of total faces and rank 112's high Waitall with no remote neighbor,
it is not enough evidence on its own to spend a four-node run on remapping.

## Source evidence

- PBS job: 181908113.gadi-pbs.
- Remote evidence: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-pmpi-v2/181908113.gadi-pbs/evidence/.
- Raw reports: four archives in sibling pmpi-raw/, hashes in evidence/pmpi-raw.sha256.
- Generated tables: pmpi-181908113-ranks.csv and pmpi-181908113-rank-edges.csv.
