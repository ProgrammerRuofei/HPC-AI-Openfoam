# Gadi GCC/Scotch baseline runtime evidence and profiling

Status: historical evidence reviewed; one-node diagnostic completed; four-node
profile pending separate script review and approval.

## Historical jobs and evidence boundary

The two successful Gadi `normalsr` GCC 16.2/Open MPI 5.0.10/Scotch baseline
jobs were `181368883.gadi-pbs` and `181371071.gadi-pbs`: four Sapphire Rapids
nodes, 104 cores and ranks per node, 416 ranks, 150 steps of the pinned ~65M
`occDrivAerStaticMesh` case. Their coded average times were 1.991194389 and
1.988625920 s/step; final Cd was 0.2918759493 in both.

Read-only inspection on 2026-10-19 used:

```sh
ssh -o BatchMode=yes gadi-comp 'd=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-scotch/181368883.gadi-pbs/evidence; grep -Eina "ucx|ucc|libucp|libmpi|LD_LIBRARY_PATH|module" "$d/modules.txt" "$d/simpleFoam.ldd" "$d/run.log" "$d/provenance.txt" | head -90'
ssh -o BatchMode=yes gadi-comp 'd=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-scotch/181371071.gadi-pbs/evidence; grep -E "ucx/|ucc/" "$d/modules.txt"; grep -E "libmpi.so.40|libucc.so.1|libucp.so.0" "$d/simpleFoam.ldd"'
```

Both jobs' module lists contain `ucx/1.18.1` and `ucc/1.4.4`. Their
`simpleFoam.ldd` resolves `libmpi.so.40` into the private MPI archive,
`libucc.so.1` into `/apps/ucc/1.4.4/lib`, and `libucp.so.0` into
`/usr/lib64`. No old job artifact records the loaded `libucp` version,
hash, or chosen MPI collective component. Therefore historical effective
UCX version and UCC collective selection remain unknown. The current login
node's library version must not be substituted for the historical compute
node's version.

## Approved diagnostic and profiler tool check

The user approved one **diagnostic, non-scored** PBS job with 4 CPUs, 16 GB
memory, 12 GB JOBFS, 10-minute limit (maximum 1.33 SU at 2 SU/core-hour).
The new script `builds/build-scripts/gadi-gcc162-ompi5010/diagnose_ucx_ucc_hpctoolkit_1n_v1.pbs`
uses the same pinned GCC/MPI/OpenFOAM archives and module/basrc environment as
the old baseline, then uses two MPI ranks to report the actually loaded
`libucp` path, `ucp_get_version_string()` result, SHA256, host, and CPU
affinity after `MPI_Init`. It records `coll_base_verbose` selection without
forcing UCC and tests low-frequency HPCToolkit `CPUTIME` sampling on those
two ranks. It does not modify the scientific case or run the 416-rank solver.

Read-only module inspection found the site `mpiP/3.4.1` installation has
static `libmpiP.a` only for MPICH and Open MPI 2/3, with no preloadable
Open MPI 5 library. `hpctoolkit/2021.05.15` supplies `hpcrun`; the small
job must establish actual compatibility before a four-node profile is
considered. `nci_account -P pm78` reported 4.66 KSU available and zero
reserved SU; scratch inode usage was 198.42K of 202K, so diagnostic data
should stay in JOBFS and be archived into few scratch files.

The later four-node profile will be a separately reviewed, explicitly
diagnostic run of the unchanged GCC/Scotch scientific workload. It will
sample representative ranks only if HPCToolkit passes the small test, and
its local script diff, resource ceiling, and expected outputs will be shown
before submission. It is not an additional scored repeat.

## Small diagnostic submission

The approved script and evidence note were committed as
`5d046613eac86a27eda5957cdb3c78ab6be2abcc` and pushed to the isolated
`codex/gadi-gcc162-build` branch on GitHub and Gadi. The Gadi checkout was
fast-forwarded to that commit. GitHub SSH authentication from Gadi itself
failed, so the local checkout pushed directly to the `gadi` Git remote;
there was no PBS or cluster SSH failure. The unrelated untracked Gadi
`experiments/` paths remain untouched. Script SHA256 on both checkouts:
`28e1ae2d75c4b376d0cd0938e7481c6b9802021c02ac740729b70f45d27047f9`.
Local and remote `bash -n` and unique stdout/archive prechecks passed.

The single submission command was:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = 5d046613eac86a27eda5957cdb3c78ab6be2abcc; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/diagnose_ucx_ucc_hpctoolkit_1n_v1.pbs.out; /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/diagnose_ucx_ucc_hpctoolkit_1n_v1.pbs'
```

PBS returned `181520734.gadi-pbs`. The immediate `qstat -f` showed `Q`,
`normalsr-exec`, one node, four CPUs and 10-minute walltime. Its unique
stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/diagnose_ucx_ucc_hpctoolkit_1n_v1.pbs.out`;
job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/ucx-ucc-diag.181520734.gadi-pbs/`.
PBS reached `F` with `Exit_status=0`, script
`UCX_UCC_HPCTOOLKIT_1N_DIAG_PASS`, and 44 seconds walltime. Both MPI ranks
ran on `gadi-cpu-spr-0524` and had one allowed CPU each (observed CPU 26 and
27). After `MPI_Init`, each reported `/usr/lib64/libucp.so.0` and
`ucp_get_version_string() = 1.21.0`; that file's SHA256 was
`c5f993ab980f2bc736fe34cfb933acd6fb4d767444f6d64c3326766908277abc`.
The UCC library at `/apps/ucc/1.4.4/lib/libucc.so.1` hashed to
`04701fddce814d1d1a9bf8a3b4e997a0b7826f0a4220ce24d9dfb3427aa67abb`.
Private MPI and OpenFOAM archive/binary SHA256 checks passed.

`coll-ucc-info.txt` reports `coll_ucc_enable = 0` from the default, and
`mpi-runtime.txt` shows UCC disqualified with priority -1. Other collective
components, including `hcoll` and `tuned`, were enabled; this diagnostic
does not establish which routine served each OpenFOAM collective. Thus UCC
was installed and linked but **not selected in this matching two-rank
environment**. The old baseline jobs lack this verbose runtime evidence,
so their collective selection remains historically unproven.

The HPCToolkit 2021 `hpcrun` two-rank trial returned success and generated
rank-specific `.hpcrun` files (the first rank log recorded 12 samples),
archived as `hpctoolkit-smoke.tar.gz`. Its log also contains a non-fatal
`hpcfnbounds` DSO mapping warning. This supports a carefully bounded solver
sampling run but does not yet prove successful source attribution for the
full OpenFOAM binary. The PBS-derived usage is
`4 CPUs × 44 s × 2 SU/core-hour / 3600 = 0.0978 SU`, about 0.10 SU;
`nci_account` has cleared the 1.33 SU reservation but reports used SU only
to 0.01 KSU, too coarse to independently confirm this tiny debit.

## Approved four-node diagnostic profile design

The user approved **one** four-node profile after reviewing the proposed
changes. `profile_baseline_4n_scotch_v1.pbs` copies the validated Scotch
baseline script. All archive and source hashes, case copy, mesh comparison,
`fvSchemes`, `fvSolution.fixedIter`, 416-rank placement, preparation commands,
Scotch decomposition and 150 solver steps remain the same. A new
`profile-4n-scotch/<jobid>/` path and unique stdout isolate the diagnostic.
The walltime request is 40 minutes, bounding 416 CPUs at 2 SU/core-hour to
554.67 SU; prior unprofiled runs used about 226-230 SU. The profile cost and
solver timing are not competition scores.

Only solver ranks 0, 52, 104, 156, 208, 260, 312 and 364 are sampled by
HPCToolkit 2021 at 20 Hz `CPUTIME`; all 416 ranks still participate in the
unchanged solver. A one-second `REALTIME` event preflight in JOBFS adds the
wall-clock sampling metric only if supported. Each node packages its two
rank directories into one scratch archive via `stage_4n_hpctoolkit_node.sh`.
The head node merges eight measurement directories in JOBFS, optionally
runs `hpcstruct`, runs `hpcprof -M stats`, and writes one compressed database
archive. Raw archives remain available if symbolization fails. The script
still requires full-chain `End`, `Time = 150`, rank mapping, Cd 0.27-0.30 and
a diagnostic pass marker. No scored repeat is authorized by this approval.
