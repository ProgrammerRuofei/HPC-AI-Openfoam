# ICX 2025.3.2 / Intel MPI 2021.19 / Scotch run registry

| Job | Configuration | PBS status | Coded s/step | Cd | Actual SU | Evidence |
| --- | --- | --- | ---: | ---: | ---: | --- |
| `182570171.gadi-pbs` | Gadi normalsr, four SPR 8470Q nodes, 416 ranks / 104 per node; site ICX 2025.3.2, private Intel MPI 2021.19 / libfabric 2.6.13, OpenFOAM v2512, Scotch, fixed ~65M-cell occDrivAerStaticMesh, 150 steps | PBS Exit 0; pass marker, four preparation and solver End, Time 150, hashes, 416-rank map and coefficient validated | **1.986731759946308** | **0.29187621680415826** | **244.52** | [progress](../../progress/2026-10-29-gadi-icx20253-impi202119-4n.md); raw receipt in main local checkout (path below) |

Instrumented/profile and tutorial runs are separate from this candidate result. Final scoring validity requires PBS Exit 0, pass marker, scientific hash checks, four hosts each with 104 ranks, all preparation and solver End markers, Time 150, coded wall-clock timing and coefficient.dat Cd.

This is one successful candidate run, not a repeat. Its PBS walltime was 00:17:38. The successful ICX 2026.2 / Intel MPI 2021.19 Scotch run `182291934.gadi-pbs` measured 2.004062486 s/step, about 0.865% slower, but the builds and possible runtime/binding controls differ. The ICX 2025.3.2 / Open MPI 5.0.10 Scotch two-run mean was 1.975959161 s/step, about 0.54% faster than this Intel MPI point; the MPI and communication configurations differ. Neither small gap isolates a compiler or MPI effect.

Local raw receipt: `planning/evidence/gadi-pbs-script-snapshot/logs/182570171.gadi-pbs/README.md` in the main checkout; those uncommitted original logs are preserved separately from this isolated branch.
