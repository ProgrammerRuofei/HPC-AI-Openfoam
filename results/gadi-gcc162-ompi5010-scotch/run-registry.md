# Gadi GCC 16.2 / Open MPI 5.0.10 / OpenFOAM v2512 Scotch results

These are 65M-cell scored-case candidates on `normalsr` Sapphire Rapids.
The fixed mesh, solver source, `fvSchemes`, and `fvSolution.fixedIter` are
unchanged. The copied case uses 416 ranks and Scotch decomposition.

| Run | PBS job | Nodes / ranks | Steps | Avg wall-clock/step | Final Cd | PBS walltime | SU | Status |
| --- | --- | --- | ---: | ---: | ---: | --- | ---: | --- |
| First GCC16 Scotch baseline | `181368883.gadi-pbs` | 4 / 416 | 150 | **1.991194389 s** | **0.2918759493** | 00:16:19 | **226.26** | Valid completed run |
| Same-build Scotch repeat | `181371071.gadi-pbs` | 4 / 416 | 150 | **1.988625920 s** | **0.2918759493** | 00:16:36 | **230.19** | Valid completed repeat |
| Same-stack hierarchical `(16 13 2)` | `181519873.gadi-pbs` | 4 / 416 | 150 | **2.058549642 s** | **0.2823061427** | 00:13:35 | **188.36** | Valid controlled decomposition comparison |
| Same-stack hierarchical `(26 16 1)` | `182558696.gadi-pbs` | 4 / 416 | 150 | **2.053949465 s** | **0.2886683087** | 00:13:33 | **187.89** | Valid single-run shape comparison; Scotch remains baseline |
| Same-stack hierarchical `(26 8 2)` | `182561241.gadi-pbs` | 4 / 416 | 150 | **2.042666683 s** | **0.2877289079** | 00:13:27 | **186.51** | Fastest measured hierarchical shape, single run; Scotch remains baseline |

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

### Runtime communication-library evidence boundary

Both scored runs recorded `ucx/1.18.1` and `ucc/1.4.4` in `modules.txt`.
Their `simpleFoam.ldd` files resolve private `libmpi.so.40` from the job's
Open MPI 5.0.10 archive and `libucc.so.1` from
`/apps/ucc/1.4.4/lib/libucc.so.1`, but resolve `libucp.so.0` from
`/usr/lib64/libucp.so.0`. They did not record that loaded UCX library's own
version or SHA256, and did not log the selected MPI collective component.
Thus the **effective UCX version in these historical jobs is unknown**, and
the presence of UCC does not establish that UCC handled collectives. The
module versions above describe the loaded modules, not proved effective
runtime versions. A later two-rank diagnostic can establish the current
matching environment, not retroactively identify the historical library.

That diagnostic, `181520734.gadi-pbs`, completed successfully in a fresh
one-node job. With the same archives, modules, and OpenFOAM `bashrc` order,
both ranks loaded `/usr/lib64/libucp.so.0` reporting **UCX 1.21.0** and
SHA256 `c5f993ab980f2bc736fe34cfb933acd6fb4d767444f6d64c3326766908277abc`.
`coll_ucc_enable` was the default `0`, and verbose MPI selection disqualified
UCC. This establishes the **current matching environment**, not the exact
historical binary version or collective choice during the scored jobs.

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

The later same-stack hierarchical job `181519873.gadi-pbs` used the same
GCC 16.2/Open MPI 5.0.10/OpenFOAM v2512 archives, 4 SPR nodes × 104 ranks,
full preparation chain, fixed mesh/solver/schemes/solution and 150 steps.
Its single completed run measured **2.058549642 s/step**, so the two-run
Scotch mean is **3.33% faster**. The NCI receipt gives Exit Status 0 and
188.36 SU. Four preparation logs and the solver reached normal `End`,
`Time = 150` and MPI finalisation; its four hosts each carried 104 ranks.
Cd was 0.2823061427, within the accepted 0.27–0.30 band but about 0.00957
below the Scotch Cd. This isolates decomposition more directly than the
older site-stack comparison, while one hierarchical run cannot establish
repeatability. Original evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-hierarchical/181519873.gadi-pbs/evidence/`,
with independent PBS stdout at the matching `submit-logs/run_baseline_4n_hierarchical_v1.pbs.out`.

## Unscored diagnostic profile attempt

PBS job `181520909.gadi-pbs` used the same GCC 16.2.0, private Open MPI
5.0.10, `ucx/1.18.1` and `ucc/1.4.4` loaded modules, OpenFOAM v2512,
four SPR nodes, 416 ranks (104/node), Scotch decomposition, and unchanged
scientific inputs. It was intended to sample eight ranks over 150 steps,
but never started `simpleFoam`: HPCToolkit 2021's `REALTIME@f20` preflight
stalled after the full preparation chain. The user authorized cancellation.
PBS recorded `Exit_status=271`, 26:04 walltime and **361.46 SU**. There is
no diagnostic timing, Cd or profiler database from this attempt, and it
does not enter the scored comparison above. Detailed evidence and paths are
in `progress/2026-10-19-gadi-baseline-runtime-evidence-profile.md`.

The follow-up one-node diagnostic `181521525.gadi-pbs` used four CPUs and
0.13 SU. Its six bounded tests show that REALTIME sampling of `/bin/sleep 1`
times out with both frequency and numeric-period notation, while REALTIME
sampling of a CPU-active command and CPUTIME sampling of `sleep` complete.
This is a profiler-preflight diagnosis, not an OpenFOAM run or a new score.

The separate five-rank HPCToolkit tutorial smoke `181585812.gadi-pbs`
completed with `Exit_status=0` and 0.19 SU. `CPUTIME@50000` generated
nonzero `simpleFoam` samples on all five ranks, and the Scotch tutorial
solver reached step 20 and `End`. This is profiler compatibility evidence
only; it does not enter the four-node 65M score comparison.

The archived tutorial samples were postprocessed in job
`181623287.gadi-pbs`: one SPR node, two CPUs, 1:25 and **0.15 SU**,
`Exit_status=0`. `hpcstruct` and `hpcprof` produced a SHA-256-checked
database with named OpenFOAM/MPI procedures, but no OpenFOAM source-file
paths. It validates limited function-level profiling, not full-case CPU
hotspots, MPI waiting time, or source-line attribution. It adds no scored
result.

The separately approved raw four-node sampling job `181627666.gadi-pbs`
completed with `Exit_status=0` and
`GCC162_OMPI5010_OF2512_SCOTCH_4N_RAW_PROFILE_PASS`. It used the same pinned
GCC 16.2.0/Open MPI 5.0.10/OpenFOAM v2512 archives, requested
`ucx/1.18.1` and `ucc/1.4.4` modules, 4 SPR nodes × 104 ranks, Scotch, the
unchanged ~65M `occDrivAerStaticMesh` scientific controls, and 150 steps.
Eight ranks were sampled with HPCToolkit `CPUTIME@50000`; the other ranks
ran normally. All four preparation/solver logs ended, the rank map had 104
ranks per host, and four raw profile archives passed SHA-256 verification.
Diagnostic timing was **1.988370329 s/step** with final **Cd
0.2918759493**; PBS used **16:43 and 231.80 SU**. These numbers are not a
third scored baseline. Raw samples await separate analysis; CPUTIME alone
does not quantify MPI waiting or network transfer. Full paths and archive
hashes are in the 2026-10-19 progress report. There was no repeat job.

The separately approved postprocessing job `181629095.gadi-pbs` completed
with PBS `Exit_status=0`, pass marker, 1:26 walltime and **0.15 SU**. It
analyzed the eight main solver profiles from `181627666` without another
OpenFOAM run. The checksum-verified HPCToolkit database is in the job-keyed
evidence directory named in the 2026-10-19 progress report. Of 2,496.11
procedure-attributed exclusive CPU seconds, OpenFOAM executable/libraries
account for about 72.63%, MPI/UCX/HCOLL libraries about 16.76%, and libc
about 9.18%. Top procedures: Gauss-Seidel smoothing 16.01%, matrix residual
11.39%, matrix multiply 6.22%, and `memmove` 5.93%. HCOLL collective
progress is visible. These are sampled CPU shares on 8 of 416 ranks, not
walltime, MPI-wait, or network fractions. Source-line mapping and effective
UCX/UCC selection for the historical solver run remain unproven.


The unscored C-only PMPI compatibility smoke `181704658.gadi-pbs` passed
with PBS `Exit_status=0`. It used the pinned GCC 16.2/Open MPI 5.0.10/
UCX 1.18.1/UCC 1.4.4/OpenFOAM v2512 stack on one SPR node, a two-rank
probe, and a five-rank 20-step Scotch tutorial. The source and runtime
library hashes were verified. It intercepted 14 MPI call types and wrote
seven per-rank CSVs. About 64 seconds of one startup `MPI_Barrier` on
nonzero ranks corresponded to rank 0 compiling a coded function object.
That timing is not a 65M-cell solver bottleneck. PBS used 1:57 and five
CPUs (approximately 0.33 SU by the established rate). No four-node
PMPI diagnostic or scored repeat was run. Detailed evidence is in the
2026-10-19 progress report.


The unscored PMPI v2 compatibility test `181705417.gadi-pbs` passed on
one `normalsr` SPR node (five CPUs, 1:59, about 0.33 SU by allocation). It
used GCC 16.2.0, private Open MPI 5.0.10, site UCX 1.18.1/UCC 1.4.4,
OpenFOAM v2512, and a five-rank 20-step Scotch `pitzDaily_fused` tutorial
after a two-rank UCX probe. All seven rank reports contain full-run and
ten-second-window data whose counts and durations reconcile exactly. The
tutorial's roughly 64.767-second barrier on ranks 1–4 is startup waiting
for rank 0 to compile the coded function object. This validates diagnostic
collection, not the 65M-cell scientific solver's MPI or network fraction.
Profiler library SHA-256:
`dbe725d1ee8e07746ff18d0179ef4f02b24962cc0c3311a8aecb22bef1e88b79`.
Raw evidence and precise SU caveat are in the 2026-10-19 progress report.

## GCC16/Scotch scaling baseline selection (2026-10-22)

The default-binding one-node job `182017873.gadi-pbs` is the selected 1N/104-rank/40-step point for this stack: 8.373520290307694 s/step, Cd 0.43806006706848422, 40.50 SU. The four-node points are `181368883.gadi-pbs` and `181371071.gadi-pbs` at 416 ranks/150 steps. The matching two-node 208-rank/80-step Scotch job `182022356.gadi-pbs` passed at 4.137720655924051 s/step, Cd 0.33963559075612176, and 95.56 SU from the NCI job receipt. Use per-step times for scaling because prescribed step counts differ; see [scaling-1n2n4n.md](scaling-1n2n4n.md). This selection does not relabel the historical site-module official reference.

## One-node core-binding comparison (2026-10-22)

The SHA-pinned GCC 16.2/Open MPI 5.0.10/OpenFOAM v2512 stack was tested on
one SPR node at the official 104-rank, 40-step Scotch point. The default
binding job `182017873.gadi-pbs` passed at **8.373520290 s/step**, Cd
**0.4380600671**, **40.50 SU**. The otherwise identical core-bound job
`182019151.gadi-pbs` passed at **8.346359078 s/step**, identical Cd,
**39.98 SU**. Both used the same physical host and identical decomposition
statistics. The observed core-binding gain was **0.32437%** in one pair,
insufficient to justify a four-node run under the current SU constraint.
See [binding-1n-40step.md](binding-1n-40step.md) for full provenance.
