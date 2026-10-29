# ICX 2025.3.2 / private Intel MPI 2021.19 / OpenFOAM v2512

This Gadi candidate uses the site ICX 2025.3.2 compiler with the previously verified private Intel MPI 2021.19 and libfabric 2.6.13 archive. The OpenFOAM build is `182566723.gadi-pbs` (Exit 0, 84.03 SU, real Scotch, six benchmark apps, private MPI linkage). The 5-rank Scotch tutorial smoke is `182569572.gadi-pbs` (Exit 0, 0.15 SU, Time 20 / End).

The four-node scored-case candidate was submitted **once** as `182570171.gadi-pbs` using `run_baseline_4n_scotch_v1.pbs`. Its initial PBS state was Q. It requests four normalsr Sapphire Rapids nodes and 416 ranks (104 per node), Scotch, 150 steps, and an unchanged ~65M-cell occDrivAerStaticMesh source. PBS one-hour request caps cost at approximately 832 SU. Completion and actual cost are pending; see [progress](../../../progress/2026-10-29-gadi-icx20253-impi202119-4n.md).

## Completed four-node result

Job `182570171.gadi-pbs` passed PBS Exit 0, script marker, complete 416-rank Scotch preparation/solver chain and `Time = 150`/`End`. Its coded average was **1.986731759946308 s/step**, final Cd **0.29187621680415826**, PBS walltime **00:17:38**, charged **244.52 SU**. Four SPR hosts each carried 104 ranks. The original logs and SHA-256 verified local receipt are indexed in `planning/evidence/gadi-pbs-script-snapshot/logs/182570171.gadi-pbs/README.md` in the main local checkout. This is one candidate run; no repeat was submitted.
