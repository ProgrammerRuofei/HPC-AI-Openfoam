# Gadi GCC/Scotch baseline runtime evidence and profiling

Status: historical evidence reviewed; one-node diagnostic approved and locally prepared.

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
Exit status, runtime versions, UCC selection, profiler compatibility and
actual SU are pending. Do not submit another diagnostic on an unknown result.
