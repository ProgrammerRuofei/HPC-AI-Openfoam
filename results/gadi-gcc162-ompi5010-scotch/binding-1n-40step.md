# One-node GCC 16.2/Open MPI 5.0.10 core-binding comparison

This is the official 1-node scaling point (104 ranks, 40 SIMPLE steps), run
as a controlled binding experiment on Gadi `normalsr`. Both jobs used the
same SPR host `gadi-cpu-spr-0638`, pinned GCC 16.2.0/Open MPI 5.0.10/
OpenFOAM.com v2512 archives, loaded UCX 1.18.1/UCC 1.4.4 modules, UCX PML,
Scotch decomposition, the unchanged ~65M `occDrivAerStaticMesh` source mesh,
`simpleFoam`, `fvSchemes`, `fvSolution`, and the complete preparation chain.
The only launcher change was `--bind-to core`; both used
`--map-by ppr:104:node -np 104`. The prescribed 1-node step count was 40.

| Policy | Job | PBS status | Average solver wall s/step | Final Cd | PBS wall | Actual SU | Affinity |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| Default | `182017873.gadi-pbs` | F, exit 0 | 8.373520290307694 | 0.43806006706848422 | 11:41 | 40.50 | Eight 13-core NUMA masks, 13 ranks per mask |
| Core | `182019151.gadi-pbs` | F, exit 0 | 8.346359078358972 | 0.43806006706848422 | 11:32 | 39.98 | 104 distinct one-core masks |

**Selected 1-node scaling baseline:** `182017873.gadi-pbs` (default binding). It uses the same pinned GCC 16.2.0/Open MPI 5.0.10/OpenFOAM v2512/Scotch stack and `ppr:104:node` launcher policy as the completed four-node Scotch baseline. The explicit core-binding run remains a separate affinity experiment; its single-pair 0.32437% difference is inconclusive. The planned two-node point must use 208 ranks, 80 steps and the default binding policy. No two-node result has been measured yet. This designation does not replace the older site-module official reference.

Both jobs have the relevant PASS marker and all five stage `End` markers;
the solver reached `Time = 40` and finalized MPI. The input SHA-256 records
match byte-for-byte, as do 1,358 extracted `decomposePar` statistic lines.
The two `coefficient.dat` files have identical SHA-256
`49226f84a1d9b5c8041d37587b840bd4c45f0c7a96e2324363de0b6866197be8`.
The Cd values are from 40-step runs and should not be compared against the
150-step four-node acceptance band.

Core binding was **0.027161212 s/step (0.32437%)** faster in this one
pair. The total charged for the two solves was **80.48 SU**; including the
earlier 0.92-SU affinity probe, this direction used **81.40 SU**. One pair
does not quantify run-to-run noise, so it cannot establish a meaningful
speedup. The small effect does not justify a 416-rank/150-step confirmation
under the present SU constraints. No extra repeat or four-node job was run.

Job-keyed evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/binding-1n-40step/default/182017873.gadi-pbs/evidence/`
and
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/binding-1n-40step/core/182019151.gadi-pbs/evidence/`.
Independent PBS stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_binding_1n_40step_v1_default.pbs.out`
and
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_binding_1n_40step_v1_core.pbs.out`.
