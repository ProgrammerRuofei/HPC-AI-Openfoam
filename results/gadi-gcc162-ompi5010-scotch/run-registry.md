# Gadi GCC 16.2 / Open MPI 5.0.10 / OpenFOAM v2512 Scotch results

These are 65M-cell scored-case candidates on `normalsr` Sapphire Rapids.
The fixed mesh, solver source, `fvSchemes`, and `fvSolution.fixedIter` are
unchanged. The copied case uses 416 ranks and Scotch decomposition.

| Run | PBS job | Nodes / ranks | Steps | Avg wall-clock/step | Final Cd | PBS walltime | SU | Status |
| --- | --- | --- | ---: | ---: | ---: | --- | ---: | --- |
| First GCC16 Scotch baseline | `181368883.gadi-pbs` | 4 / 416 | 150 | **1.991194389 s** | **0.2918759493** | 00:16:19 | **226.26** | Valid completed run; repeat pending |
| Same-build Scotch repeat | `181371071.gadi-pbs` | 4 / 416 | pending | pending | pending | pending | pending | Submitted; initial Q |

The first run had PBS `Exit_status=0`, script
`GCC162_OMPI5010_OF2512_SCOTCH_4N_PASS`, four distinct SPR nodes with
104 ranks each, and normal `End` markers for Scotch `decomposePar`,
`renumberMesh`, `potentialFoam`, `applyBoundaryLayer`, and `simpleFoam`.
The solver reached `Time = 150`, emitted its coded timing metric, and
finalised MPI. The final `coefficient.dat` row has Cd in column two. Peak
memory was 315,117,540 KB and JOBFS 50,641,586 KB according to PBS.
Evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-scotch/181368883.gadi-pbs/evidence/`.
NCI later posted the 226.26 SU charge: pm78 usage rose from 276.08 to
502.34 SU, matching 416 allocated cores × 979 seconds × 2 SU/core-hour ÷
3600 to two decimals.

The earlier site-module, hierarchical 4-node baseline
`178149002.gadi-pbs` measured 2.139565188 s/step and Cd 0.2823068404.
The first GCC16/Scotch run is about 6.93% faster per step. Its Cd is
0.00957 higher, within the predeclared 0.27–0.30 band. Because the
compiler/MPI and decomposition both changed, this comparison does not
attribute the speed gain to a single change. A same-build Scotch repeat
will check stability before this is named a best build.
