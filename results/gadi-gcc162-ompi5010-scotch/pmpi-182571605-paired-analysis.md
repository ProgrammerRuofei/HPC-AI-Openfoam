# Paired four-node PMPI diagnostic: Scotch versus hierarchical (26 8 2)

Read-only analysis of the retained raw reports for `181908113.gadi-pbs` (Scotch) and `182571605.gadi-pbs` (hierarchical). Both use GCC 16.2.0, private Open MPI 5.0.10, OpenFOAM v2512, the pinned 65,334,765-cell case, 416 ranks across four normalsr Sapphire Rapids nodes (104/node), 150 solver steps, the same PMPI v2 interposer and `ppr:104:node` mapping. Neither launch requested explicit binding. Both completed with PBS Exit 0, job-specific pass markers, full preparation-chain and solver `End`, `Time = 150`, and 416 PMPI rank reports. Allocated host identities differ; the exact runtime UCX/collective selection and CPU masks were not recorded with enough detail to isolate their effects. This is a diagnostic comparison, not a scored competition result.

The archived source paths are:

- Scotch: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-pmpi-v2/181908113.gadi-pbs/` (`evidence/` and `pmpi-raw/`); existing [rank table](pmpi-181908113-ranks.csv) and [partition analysis](pmpi-181908113-analysis.md).
- Hierarchical: local raw [job archive](/Users/sofia/Projects/openfoam-aspire2a/planning/evidence/gadi-pbs-script-snapshot/logs/182571605.gadi-pbs/README.md) with original `10_decomposePar.log`, `simpleFoam.log`, `coefficient.dat`, stdout and four `pmpi-raw/node-*.tar.gz` archives; [416-rank table](pmpi-182571605-ranks.csv). All 41 hierarchical raw files matched fresh Gadi SHA-256 hashes after transfer. The four Scotch PMPI archives were also rechecked byte-for-byte against remote SHA-256 for this comparison.

The steady columns sum 10-second PMPI buckets starting at least 70 seconds after `MPI_Init`. This excludes the one-time coded-object startup `MPI_Barrier` (mean 63.80 s Scotch, 67.07 s hierarchical). The cutoff is a common analysis convention, not an exact solver-phase timestamp. Call times are **rank means**, may overlap across ranks, and cannot be added to wall-clock solver time.

| Metric | Scotch `181908113` | Hierarchical `182571605` | Interpretation |
| --- | ---: | ---: | --- |
| Coded solver time, s/step | 1.993567 | 2.060163 | Hierarchical +0.066596 s/step (+3.34%) in these instrumented runs |
| Final Cd | 0.291875949 | 0.287728908 | Both in expected band; decomposition changes numerical result |
| PBS Exit / actual SU | 0 / 246.83 | 0 / 204.53 | Different allocated hosts and run duration; SU is not solver speed |
| Unique processor faces | 2,690,403 | 3,882,476 | Hierarchical +44.31% |
| Unique cross-node faces under recorded rank mapping | 300,065 | 1,067,101 | Hierarchical 3.56×; topology proxy, not measured network bytes |
| Cells/rank CV | 0.73% | 0.00045% | Hierarchical nearly equalizes cell count |
| Processor faces/rank CV | 29.87% | 40.97% | Hierarchical has more surface imbalance |
| Steady `MPI_Waitall`, mean / p95 seconds per rank | 19.362 / 27.576 | 27.636 / 42.874 | Hierarchical +8.274 s mean, broader tail |
| Steady `MPI_Allreduce`, mean / p95 seconds per rank | 20.006 / 24.628 | 21.310 / 24.977 | Hierarchical +1.304 s mean |
| All steady timed MPI calls, mean / p95 seconds per rank | 42.327 / 50.863 | 53.036 / 67.942 | Hierarchical +10.709 s mean |
| Steady `MPI_Isend` / `MPI_Irecv` calls, global | 909,999,496 / 909,999,491 | 834,367,480 / 834,367,480 | Hierarchical makes fewer nonblocking calls; counts alone do not measure traffic volume |
| Steady `MPI_Isend` / `MPI_Irecv` duration, rank-mean seconds | 1.763 / 0.252 | 1.824 / 0.250 | Initiation time is small relative to Waitall |
| Steady blocking `MPI_Send` / `MPI_Recv` calls, global | 809,250 / 809,250 | 818,664 / 818,687 | Small count difference in the selected buckets |
| Steady blocking `MPI_Send` / `MPI_Recv` duration, rank-mean seconds | 0.0016 / 0.0333 | 0.0019 / 0.0431 | Small relative to Waitall and Allreduce |

Hierarchical's largest steady Waitall ranks are 50 (53.495 s), 76 (52.929 s), 102 (52.457 s), 23 (51.268 s) and 388 (50.052 s). Every hierarchical rank has at least one cross-node neighbor under the recorded map, compared with 206 of 416 Scotch ranks. The hierarchical rank-level Pearson correlation of Waitall with processor faces is 0.208 and with cross-node faces is 0.245. These are descriptive associations. `MPI_Waitall` includes waiting for slower peers, and `MPI_Allreduce` includes collective synchronization; neither directly measures network transmission. More cross-node faces, more variable surface, and longer Waitall occur together here, but host variation, binding and rank-local compute may contribute.

Instrumentation overhead should be reported separately from the partition comparison. Relative to the uninstrumented Scotch two-run mean 1.989910155 s/step, the Scotch PMPI run is +0.003657 s/step (+0.18%). Relative to the uninstrumented hierarchical run `182561241` at 2.042666683 s/step, the hierarchical PMPI run is +0.017496 s/step (+0.86%). These are **observed between-run differences**, not controlled pure PMPI overhead estimates. The uninstrumented Scotch mean versus hierarchical single run differs by +0.052757 s/step (+2.65%).

The evidence supports prioritizing partition surface and placement analysis, followed by a controlled run that holds the selected toolchain and binding fixed. It does not prove that network transit alone causes the hierarchical slowdown, nor that reducing faces will necessarily improve solver time.
