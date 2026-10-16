# Gadi ICX 2025.3.2 / Open MPI 5.0.10 / OpenFOAM v2512 Scotch comparison

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
| ICX same-build repeat | `181402435.gadi-pbs` | Same | Same | Pending | Pending | Pending | Pending | Submitted; initial Q |
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
