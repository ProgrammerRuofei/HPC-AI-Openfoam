# Gadi ICX 2026.2 / Intel MPI 2021.19 / Scotch run registry

| PBS job | Configuration | Workload | Outcome | Walltime | SU | Cd | seconds/step |
|---|---|---|---|---:|---:|---:|---:|
| `182194314.gadi-pbs` | ICX/ICPX 2026.2.0; Intel MPI 2021.19.0; OpenFOAM v2512; private Intel MPI `libmpi.so.12`; four Gadi `normalsr` Sapphire Rapids nodes, 104 CPUs and intended ranks per node, 416 ranks total; Intel MPI default binding; Scotch `[416]` | Pinned official ~65M-cell `occDrivAerStaticMesh`, unchanged source, mesh, `fvSchemes`, `fvSolution`; 150 steps requested | Failed at cross-node rank-map `MPI_Init` / `MPIDI_OFI_mpi_init_hook` after completed Scotch decomposition; no solver run | 11:22 | 157.62 | N/A | N/A |

This job cannot be used as a scored baseline. The first fatal error is in
Intel MPI's OFI initialization; its specific provider/root cause is
unconfirmed. `rank-host-map.txt` is empty, so the intended per-node rank
layout and binding were not observed in running MPI ranks. The one-node
5-rank smoke `182194237.gadi-pbs` passed separately and does not establish
cross-node Intel MPI compatibility. Original logs, stage files and PBS
stdout remain in the job-keyed evidence and submit-log paths documented in
`progress/2026-10-25-gadi-icx20262-impi202119-4n.md`.
