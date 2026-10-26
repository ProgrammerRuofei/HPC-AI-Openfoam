# Gadi ICX 2026.2 / Intel MPI 2021.19 / Scotch run registry

| PBS job | Configuration | Workload | Outcome | Walltime | SU | Cd | seconds/step |
|---|---|---|---|---:|---:|---:|---:|
| `182194314.gadi-pbs` | ICX/ICPX 2026.2.0; Intel MPI 2021.19.0; OpenFOAM v2512; private Intel MPI `libmpi.so.12`; four Gadi `normalsr` Sapphire Rapids nodes, 104 CPUs and intended ranks per node, 416 ranks total; Intel MPI default binding; Scotch `[416]` | Pinned official ~65M-cell `occDrivAerStaticMesh`, unchanged source, mesh, `fvSchemes`, `fvSolution`; 150 steps requested | Failed at cross-node rank-map `MPI_Init` / `MPIDI_OFI_mpi_init_hook` after completed Scotch decomposition; no solver run | 11:22 | 157.62 | N/A | N/A |
| `182291934.gadi-pbs` | ICX/ICPX 2026.2.0; private Intel MPI 2021.19.0; libfabric 2.6.13/OFI; OpenFOAM v2512; private `libmpi.so.12`; four Gadi `normalsr` Sapphire Rapids nodes, 104 bound CPUs and ranks per node, 416 ranks total; Intel MPI default core binding; Scotch `[416]` | Pinned official ~65M-cell `occDrivAerStaticMesh`, unchanged source, mesh, `fvSchemes`, `fvSolution`; 150 steps | **Completed:** PBS Exit 0, rank map 416/416, full preparation and solver chain `End`, `Time = 150`, pass marker; final Cd in band | 17:14 | 238.97 | 0.29187621680415826 | 2.004062486355705 |

The failed `182194314.gadi-pbs` cannot be used as a scored baseline. The first fatal error is in
Intel MPI's OFI initialization; its specific provider/root cause is
unconfirmed. `rank-host-map.txt` is empty, so the intended per-node rank
layout and binding were not observed in running MPI ranks. The one-node
5-rank smoke `182194237.gadi-pbs` passed separately and does not establish
cross-node Intel MPI compatibility. Original logs, stage files and PBS
stdout remain in the job-keyed evidence and submit-log paths documented in
`progress/2026-10-25-gadi-icx20262-impi202119-4n.md`.

The successful v3 job's retained stdout and job-keyed evidence are listed
in `progress/2026-10-26-gadi-icx20262-impi202119-4n-v3.md`. The coded
average covers 149 measured steps. Against the two accepted GCC 16.2.0 /
Open MPI 5.0.10 / UCX 1.18.1 / UCC 1.4.4 Scotch runs (1.991194389201344
and 1.988625920 s/step, Cd 0.29187594927465327), this result was
approximately 0.65–0.78% slower. One whole-stack observation cannot
establish a stable ranking or attribute the difference to the compiler
or MPI. No repeat was authorized or submitted.
