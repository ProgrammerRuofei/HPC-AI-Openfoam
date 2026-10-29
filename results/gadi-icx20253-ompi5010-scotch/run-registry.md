# Gadi ICX 2025.3.2 / Open MPI 5.0.10 / OpenFOAM v2512 Scotch comparison

## Same-stack hierarchical observation (2026-10-29)

The separate hierarchical `(26 8 2)` job `182562739.gadi-pbs` completed at
**2.040001329684563 s/step**, Cd **0.28772995935173329**, PBS walltime
**00:13:14**, and **183.50 SU**. It used four Sapphire Rapids nodes, 416 ranks
(104 per node), 150 steps, the same ICX 2025.3.2/Open MPI 5.0.10/OpenFOAM
v2512 stack and fixed scientific input. PBS Exit 0, the job-specific pass
marker, all four preparation-stage `End` lines, `simpleFoam` `Time = 150` and
`End`, hash checks, and final `coefficient.dat` Cd were verified from the
[original Gadi evidence](../../progress/2026-10-29-gadi-icx-hierarchical-26x8x2.md).
This one hierarchical observation is about 3.2% slower than the 2025 Scotch
point below. It is not a repeatability result.

Controlled comparison with the two GCC 16.2.0 runs in
`results/gadi-gcc162-ompi5010-scotch/run-registry.md`. All runs use
Gadi `normalsr` Xeon Platinum 8470Q (Sapphire Rapids), four nodes,
104 physical cores and MPI ranks per node (416 total), the fixed
approximately 65M-cell `occDrivAerStaticMesh` case, `simpleFoam`,
Scotch decomposition, and 150 SIMPLE steps. The mesh, solver source,
`fvSchemes`, and `fvSolution.fixedIter` are unchanged; seven source-case
SHA-256 gates are enforced in the PBS script.

| Run | PBS job | Compiler for OpenFOAM | MPI / UCX / UCC | Average wall-clock per step | Final Cd | PBS walltime | SU | Status |
| --- | --- | --- | --- | ---: | ---: | --- | ---: | --- |
| ICX first | `181399707.gadi-pbs` | ICX 2025.3.2 `Opt` | Private Open MPI 5.0.10 / 1.18.1 / 1.4.4 | **1.976664844 s** | **0.2918761744** | 00:16:30 | **228.80 calculated** | Valid completed run |
| ICX verified repeat | `182564679.gadi-pbs` | ICX 2025.3.2 `Opt` | Private Open MPI 5.0.10; historical UCX/UCC runtime selection not fully recorded | **1.975253477 s** | **0.2918761744** | 00:16:28 | **228.34 posted** | PBS Exit 0; pass marker, four stages, Time 150 and End verified |
| ICX same-build repeat | `181402435.gadi-pbs` | Same | Same | No result | No result | 00:02:04 | About 28.66 calculated | Cancelled at user request; PBS exit 271 |
| GCC control 1 | `181368883.gadi-pbs` | GCC 16.2.0 `Opt` | Same | 1.991194389 s | 0.2918759493 | 00:16:19 | 226.26 posted | Valid completed run |
| GCC control 2 | `181371071.gadi-pbs` | GCC 16.2.0 `Opt` | Same | 1.988625920 s | 0.2918759493 | 00:16:36 | 230.19 posted | Valid completed repeat |

The ICX OpenFOAM binary is from build `181392981.gadi-pbs` with source
identity V2, real Scotch 6.1.0 and private MPI linkage. The MPI library
was built with GCC 16.2.0; ICX wrapper compatibility and a separate
five-rank tutorial run passed before this scored case. The first ICX run
used hosts `0514`, `0517`, `0532`, and `0534`, each with 104 mapped ranks.
`decomposePar`, `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`,
and `simpleFoam` each ended normally; the solver reached `Time = 150`,
printed `Finalising parallel run`, and the script pass marker. PBS
`Exit_status=0`. The final `coefficient.dat` row at time 150 has Cd in
column two. Evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/baseline-4n-scotch/181399707.gadi-pbs/evidence/`.

The reported first-run SU is calculated from the NCI queue charging
formula: 416 allocated cores × 990 walltime seconds × 2 SU/core-hour
÷ 3600 = 228.80 SU. `nci_account` after completion displayed used
1.12 KSU and reserved 0, rounded to two decimal places in KSU, so it
does not expose a more precise per-job posted charge. Peak PBS memory
was 310,467,840 KB and JOBFS 47,005,605 KB.

The GCC mean is 1.989910155 s/step. The first ICX run is 0.013245311
s/step (0.666%) faster than that mean, while Cd differs by about
0.000000225. The timing margin is small enough that this single run
does not establish a winner; the same-build ICX repeat was submitted
without changing script, scientific input, or archived binary.

The user then explicitly asked to stop the repeat and specified that
future repeat jobs require prior permission. It had already started
when checked; `qdel 181402435.gadi-pbs` succeeded. PBS history shows
state F, `Exit_status=271` and 00:02:04 walltime, so this is **not** a
completed scientific repeat. A queued job cancelled before starting
would have no runtime charge; this job may incur a charge for the time
it ran. At 416 cores and 2 SU/core-hour, 124 seconds corresponds to
about 28.66 SU. The first account check still showed the 832 SU
reservation; a later check showed it released and aggregate usage rise
from 1.12 to 1.15 KSU. NCI rounds that display to 0.01 KSU, so the
exact per-job posted amount is not visible from this account report.
No further repeat will be submitted without the user's permission.

The approved later repeat `182564679.gadi-pbs` used the same build and
scientific controls. Its two-run mean with `181399707.gadi-pbs` is
**1.975959161 s/step**; the run-to-run spread is 0.001411367 s/step
(about 0.071% of the first run). The repeated Cd is identical at the
reported precision. The raw PBS stdout and 26 job-keyed evidence files
were SHA-256-verified and archived under
`planning/evidence/gadi-pbs-script-snapshot/logs/182564679.gadi-pbs/` in
the current local repository. This repeat confirms timing stability but
does not establish which communication library or collective was actually
selected at runtime by the historical stack.
