# ICX 2025.3.2 / Intel MPI 2021.19 / Scotch run registry

| Job | Configuration | PBS status | Coded s/step | Cd | Actual SU | Evidence |
| --- | --- | --- | ---: | ---: | ---: | --- |
| `182570171.gadi-pbs` | Gadi normalsr, four SPR 8470Q nodes, 416 ranks / 104 per node; site ICX 2025.3.2, private Intel MPI 2021.19 / libfabric 2.6.13, OpenFOAM v2512, Scotch, fixed ~65M-cell occDrivAerStaticMesh, 150 steps | Initially Q; awaiting final validation | pending | pending | pending | [progress](../../progress/2026-10-29-gadi-icx20253-impi202119-4n.md) |

Instrumented/profile and tutorial runs are separate from this candidate result. Final scoring validity requires PBS Exit 0, pass marker, scientific hash checks, four hosts each with 104 ranks, all preparation and solver End markers, Time 150, coded wall-clock timing and coefficient.dat Cd.
