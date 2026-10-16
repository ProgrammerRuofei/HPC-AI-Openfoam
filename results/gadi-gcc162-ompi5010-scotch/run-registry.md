# Gadi GCC 16.2 / Open MPI 5.0.10 / OpenFOAM v2512 Scotch results

These are 65M-cell scored-case candidates on `normalsr` Sapphire Rapids.
The fixed mesh, solver source, `fvSchemes`, and `fvSolution.fixedIter` are
unchanged. The copied case uses 416 ranks and Scotch decomposition.

| Run | PBS job | Nodes / ranks | Steps | Avg wall-clock/step | Final Cd | PBS walltime | SU | Status |
| --- | --- | --- | ---: | ---: | ---: | --- | ---: | --- |
| First GCC16 Scotch baseline | `181368883.gadi-pbs` | 4 / 416 | 150 | **1.991194389 s** | **0.2918759493** | 00:16:19 | **226.26** | Valid completed run |
| Same-build Scotch repeat | `181371071.gadi-pbs` | 4 / 416 | 150 | **1.988625920 s** | **0.2918759493** | 00:16:36 | **230.19** | Valid completed repeat |

## Configuration behind the comparison

| Setting | Older official baseline `178149002` | New run `181368883` and repeat `181371071` |
| --- | --- | --- |
| Cluster and queue | Gadi `normalsr`, four Sapphire Rapids Xeon Platinum 8470Q nodes | Same queue and CPU model; four nodes |
| Cores and MPI ranks | 104 physical cores/node, 416 ranks total | Same, with an explicit 104 ranks/node map check |
| PBS resource limits | 760 GB memory, 1 h 15 min walltime | 760 GB memory, 100 GB JOBFS, 1 h walltime |
| Application | Gadi `OpenFOAM/2512` site module | Private OpenFOAM v2512, pinned source identity `5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db` |
| Compiler | Site binary built with GCC 8.5.0 | Private GCC 16.2.0, stock OpenFOAM `Opt` (`-O3`), no extra vector-width flags |
| MPI and transport | Site Open MPI 4.1.7; transport and rank placement not explicitly pinned in the old script | Private Open MPI 5.0.10, UCX 1.18.1 and UCC 1.4.4 modules, PBS TM; `mpirun --prefix privateMPI --map-by ppr:104:node --mca pml ucx -np 416` |
| Decomposition | Hierarchical `(16 13 2)` | Scotch 6.1.0 |
| Scientific case | Fixed 65M mesh, `simpleFoam`, `fvSchemes`, `fvSolution.fixedIter`; 150 steps | Same fixed scientific inputs and 150 steps; copied case changes only rank count and decomposition method |
| Preparation | Serial `decomposePar`, then 416-rank `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`, `simpleFoam` | Same full chain; each processor directory is in node-local JOBFS and visible through a scratch symlink |

Here “older official baseline” means the previously validated reference
under the site's default software stack. “New baseline” is the first
completed run of the GCC16/MPI5/Scotch candidate. The repeat uses the
**same** script, archived binaries, input hashes and decomposition; it
changes only PBS job ID, output directory and allocated node identities.

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

The repeat also had PBS `Exit_status=0`, script pass marker, four SPR
nodes (`0073/0074/0080/0081`) with 104 ranks each, every chain `End`,
`Time = 150`, normal MPI finalisation and final Cd in the 0.27–0.30 band.
Its evidence is under the matching `baseline-4n-scotch/181371071.gadi-pbs/evidence/`
directory. NCI usage rose from 502.34 to 732.53 SU, a **230.19 SU** charge.

The earlier site-module, hierarchical four-node baseline
`178149002.gadi-pbs` measured 2.139565188 s/step and Cd 0.2823068404.
The two GCC16/Scotch runs average **1.989910155 s/step**, about **7.00%**
faster than that reference. Their step times differ by 0.002568469 s
(about 0.13% of the mean), and their final Cd values are identical to
the displayed precision. The new Cd is 0.00957 higher than the old
reference but inside the predeclared 0.27–0.30 band. Because compiler,
MPI and decomposition all changed, this comparison does not isolate the
cause of the gain. This is a validated current candidate, not a claim
that every possible build/decomposition has been tested.
