# ICX 2026.2 + Open MPI 5.0.10: Gadi tutorial smoke

| Field | Observed result |
| --- | --- |
| PBS job | `182469604.gadi-pbs`, `Exit_status=0`, `OF2512_ICX20262_OMPI5010_SMOKE_PASS` |
| Allocation | `pm78`, `normalsr`, one Sapphire Rapids node (`gadi-cpu-spr-0611`), 5 CPUs, 16 GB RAM, 30 GB JOBFS, 20-minute request |
| Toolchain | ICX 2026.2, private Open MPI 5.0.10, OpenFOAM v2512, real Scotch |
| Workload | `pitzDaily_fused` tutorial, Scotch decomposition, 5 MPI ranks, 20 steps; fixed 65M competition case was not run |
| Solver | `simpleFoam` SHA-256 `d0125c49d047afd5e42164438d0a10af0c2a7310fa9b99fcabc41614275bb181`; `Time = 20`, `End`, `Finalising parallel run` |
| Tutorial coded timing | 0.003752561789473684 s/step; not comparable with the competition baseline; no comparable Cd |
| Cost | 00:01:14 walltime, 0.21 SU; peak memory 14.72 GB, JOBFS 9.18 GB |

The checked OpenFOAM runtime archive has SHA-256
`73f62f4b06df806a7409a9a45d3de02d3cfb59b227fbe99fa2254305ccd5d2f5`.
`decomposePar.log` records `Decomposition method scotch [5]` and `End`.

The separate two-rank MPI-initialized probe loaded `/usr/lib64/libucp.so.0`
on both ranks. That library reported UCX **1.21.0** and SHA-256
`c5f993ab980f2bc736fe34cfb933acd6fb4d767444f6d64c3326766908277abc`.
Although `ucx/1.18.1` and `ucc/1.4.4` modules were loaded and `ldd`
found `/apps/ucc/1.4.4/lib/libucc.so.1`, the probe's collective selection
log disqualified UCC and selected `hcoll` for its two-rank communicator.
The five-rank solver's exact collective selection was not recorded. This
run therefore verifies a working solver, not an effective UCX 1.18.1/UCC
runtime or a competition performance ranking.

Evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/smoke.182469604.gadi-pbs/`.
Submission, validation and provenance are in
`progress/2026-10-28-gadi-icx20262-ompi5010-smoke.md`.

## UCX 1.18.1 path-gated follow-up

The separately approved `182508155.gadi-pbs` job used the same five-rank
tutorial request with a new script and output path. It finished with PBS
`Exit_status=1`, walltime 1:00 and **0.17 SU**. After archive and compiler
checks, `ldd` still resolved `libucp.so.0` from `/usr/lib64` even though
`/apps/ucx/1.18.1/lib` had been placed ahead of the prior
`LD_LIBRARY_PATH` (after the private MPI directory). The
path gate stopped the job before MPI initialization, decomposition or solver;
there is no new Cd or timing result. Original evidence is retained under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/smoke-ucx118.182508155.gadi-pbs/` and the independent
stdout at `gadi-icx20262-ompi5010/submit-logs/smoke_openfoam_v2512_ucx118_v1.pbs.out`.
