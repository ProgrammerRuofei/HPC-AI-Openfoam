# ICX 2026.2 / Intel MPI 2021.19 OpenFOAM runtime smoke

| Field | Observed value |
| --- | --- |
| PBS job | `182194237.gadi-pbs`, state F, Exit Status 0 |
| Allocation | Gadi `normalsr`, one Sapphire Rapids node (`gadi-cpu-spr-0466`), 5 CPUs |
| Toolchain | private ICX/ICPX 2026.2.0; private Intel MPI 2021.19.0 |
| Application | OpenFOAM v2512 `simpleFoam`, accepted build `182193515.gadi-pbs` |
| Workload | copied `pitzDaily_fused` tutorial, Scotch `[5]`, five MPI ranks, 20 steps |
| Runtime checks | fresh-job archive and binary hashes, private `libmpi.so.12` link, normal `End` and MPI finalization, coded wall-clock line |
| Marker | `OF2512_ICX20262_IMPI202119_SMOKE_PASS` |
| PBS walltime / actual SU | 51 s / 0.14 SU |

The coded tutorial timing was `0.004161328894736843` s/step. It is a
runtime diagnostic, **not** an official 65M-cell performance score.
There is no Cd result from this tutorial. Raw evidence is in
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119-of2512/evidence/smoke.182194237.gadi-pbs/`;
the independent PBS stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/smoke_openfoam_v2512_v1.pbs.out`.
