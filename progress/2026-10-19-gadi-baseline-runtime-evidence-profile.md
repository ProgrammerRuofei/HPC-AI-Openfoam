# Gadi GCC/Scotch baseline runtime evidence and profiling

Status: historical evidence reviewed; one-node UCX/UCC diagnostic completed;
four-node profile cancelled after timer-preflight stall; bounded one-node
HPCToolkit timer diagnosis completed, operational stall isolated, and
five-rank OpenFOAM CPUTIME smoke completed.

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

## Four-node profile submission

The approved profile script, node archive helper, and documentation were
committed as `10d7e8e17ae0e882b3713cf2ae4dfc0d986d1694`, pushed to the
isolated branch on GitHub and Gadi, and fast-forwarded into the Gadi control
checkout. The script and helper SHA256 values matched locally and remotely:

- `profile_baseline_4n_scotch_v1.pbs`:
  `4533207541c82989f73015f854231d5faf527b46ce6d6e8ca6539763264749c5`
- `stage_4n_hpctoolkit_node.sh`:
  `375bf4e471ee9316b4f63794d2e2a527235ca72f9359888e2f89754f5eb86cd6`

Local and remote `bash -n`, static scientific-control comparison, unique
stdout and account prechecks passed. `nci_account -P pm78` showed 4.66 KSU
available and zero reserved SU before submission. The single qsub command:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = 10d7e8e17ae0e882b3713cf2ae4dfc0d986d1694; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_scotch_v1.pbs.out; /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/profile_baseline_4n_scotch_v1.pbs'
```

PBS returned `181520909.gadi-pbs`; initial `qstat -f` showed `Q` in
`normalsr-exec`, 4 nodes/416 CPUs, 760 GB memory, 100 GB JOBFS, and a
40-minute limit. Unique stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_scotch_v1.pbs.out`.
The job-keyed evidence path is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-scotch/181520909.gadi-pbs/evidence/`.
## Four-node profile outcome and cancellation

The job started on four Xeon Platinum 8470Q SPR nodes (`0565`–`0568`),
each with 104 ranks. PBS ultimately reported `F`, `Exit_status=271`
(`SIGTERM`), walltime `00:26:04`, and **361.46 SU** in its independent
stdout resource summary. `nci_account` subsequently cleared the reservation
and displayed 1.70 KSU used (rounded from the pre-job 1.34 KSU). The user
approved `qdel 181520909.gadi-pbs` after the HPCToolkit preflight stopped
making progress; the cancellation was to avoid spending the full 554.67 SU
walltime ceiling. The only cancellation command was:

```sh
ssh -o BatchMode=yes gadi-comp 'qdel 181520909.gadi-pbs'
```

The pinned source and archive SHA256 checks passed. `simpleFoam.ldd` resolved
the private MPI library. Scotch decomposition, `renumberMesh`,
`potentialFoam`, and `applyBoundaryLayer` each logged `End`, and
`rank-host-map.txt` records 104 ranks on each of the four allocated nodes.
The first unresolved operation was
`hpcrun -e REALTIME@f20 -o "$LOCAL_ROOT/realtime-preflight" /bin/sleep 1`.
Its `realtime-preflight.log` remained empty from 03:58:27 AEDT until
cancellation at 04:13:45 AEDT; `profile-events.txt` and `simpleFoam.log`
were never created. This localizes the stall to the REALTIME preflight;
the exact internal cause of the HPCToolkit hang remains unproven. The
script's `exit-status.txt` says `script_exit_rc=0` because the EXIT trap ran
after SIGTERM; PBS `Exit_status=271` and the absence of solver/profile
outputs are decisive. No 150-step solver time, Cd or profile database was
produced, and this is **not** a scored run.

Original logs remain at the job-keyed evidence path above, with the PBS
resource summary in the unique stdout. A future attempt would need a
separately reviewed script, a bounded profiler preflight, and explicit
approval for another 416-rank job. Do not treat the successful two-rank
CPUTIME-only test as validation of this REALTIME preflight.

## Bounded timer diagnosis preparation

The user approved a separate, non-scored one-node diagnostic after seeing
the proposed script difference. It requests four CPUs, 16 GB memory, 12 GB
JOBFS, and six minutes (at most 0.8 SU at 2 SU/core-hour), retaining the
same pinned GCC/MPI/OpenFOAM archives and module environment. Six individual
HPCToolkit invocations compare `@f20` with the documented numeric 50,000
microsecond period for CPUTIME and REALTIME on `/bin/sleep 1`, and compare
both REALTIME spellings on a bounded CPU-active `seq` command. Each invocation
has an eight-second TERM plus two-second KILL limit and independent result
log. This distinguishes event syntax from a sleep/signal interaction without
another 416-rank run. Raw measurements will be packaged into one archive.
The installed `hpcrun --help` explicitly limits `@f` notation to Linux perf
events; whether this explains the old stall remains to be tested.

## One-node timer diagnosis submission and result

The reviewed script was committed as `7c46a6299275706290c37c15acc7794bb2cbce49`,
pushed to GitHub and Gadi, and fast-forwarded into the Gadi control checkout.
Local and remote `bash -n` passed; the script SHA256 matched at both sites:
`f039ace97c7181c77f4b8b409698e612353e3cc85ccf05a9ad09d1283635fe31`.
The unrelated remote untracked `experiments/` files were preserved. The
single submission command was:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = 7c46a6299275706290c37c15acc7794bb2cbce49; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/diagnose_hpctoolkit_timers_1n_v1.pbs.out; /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/diagnose_hpctoolkit_timers_1n_v1.pbs'
```

PBS returned `181521525.gadi-pbs`, then `F`, `Exit_status=0`, walltime
`00:01:00`, and **0.13 SU** in the independent stdout resource summary. It
ran on `gadi-cpu-spr-0562` with four allocated CPUs. All pinned archive and
binary hashes, module checks and private MPI linkage passed. The job's
evidence directory is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/hpctoolkit-timer-diag.181521525.gadi-pbs/`;
its unique stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/diagnose_hpctoolkit_timers_1n_v1.pbs.out`.
`matrix.tsv` SHA256 is
`08b1bdc75c67a57ae83ac3e4a0c08d75e684ae74ec4b2b5bf307cfc122439c8a`;
the measurements tar SHA256 is
`7107c8a449cd8efbae714a308954858c15b98e79e057b36843cb873ef580683d`.

| Program | HPCToolkit event | Exit code | Elapsed |
| --- | --- | ---: | ---: |
| `sleep 1` | `CPUTIME@f20` | 0 | 2 s |
| `sleep 1` | `CPUTIME@50000` | 0 | 1 s |
| `sleep 1` | `REALTIME@f20` | 124 (timeout) | 8 s |
| `sleep 1` | `REALTIME@50000` | 124 (timeout) | 8 s |
| CPU-active `seq` | `REALTIME@f20` | 0 | 1 s |
| CPU-active `seq` | `REALTIME@50000` | 0 | 1 s |

This controlled matrix reproduced the old preflight stall with `sleep`
regardless of timer spelling, while REALTIME on an active process finished.
Thus the operational cause was choosing `/bin/sleep` as the REALTIME
profiler preflight target; `@f20` alone is not a sufficient cause. The
installed help and official HPCToolkit manual recommend numeric microsecond
periods for timer events, so future code should also use `@50000`. A precise
internal explanation, such as repeated interruption of `sleep`'s syscall,
remains an inference rather than directly observed process evidence. No
OpenFOAM profile or scored run resulted, and no four-node retry is authorized
or submitted. The next safe gate is a bounded 5-rank OpenFOAM sampling smoke
with numeric CPUTIME only, followed by a separately approved four-node plan.

## Approved five-rank OpenFOAM CPUTIME smoke preparation

The user approved one follow-up diagnostic after reviewing the local diff.
`smoke_hpctoolkit_openfoam_1n_v1.pbs` copies the previously successful
`pitzDaily_fused` Scotch tutorial smoke with the same GCC 16.2.0, Open MPI
5.0.10, OpenFOAM v2512 archives, pinned SHA256 values, five ranks, and
20-step tutorial control. It replaces the unprofiled solver command with
HPCToolkit 2021.05.15 `CPUTIME@50000` on each of five ranks, under a
120-second TERM plus five-second KILL timeout. The job requests one
`normalsr` node, five CPUs, 16 GB memory, 12 GB JOBFS, and ten minutes
(maximum 1.67 SU at 2 SU/core-hour). It writes unique PBS stdout and
job-keyed logs, validates solver `End` and the coded timer, checks nonempty
per-rank `.hpcrun` files, and archives raw samples. It is diagnostic only;
no 65M scientific input or scored baseline is modified or rerun.

Local `bash -n` and static comparison of source/archive hashes, tutorial
controls, Scotch preparation and solver checks passed. The reviewed script
SHA256 is `24353aed593493903dad32736d2c5b845def9c07aac7f33a4e6bf32736a50f59`.
The approved submission and result are recorded below.

## Five-rank OpenFOAM CPUTIME smoke result

The reviewed script was committed as `a9779c5a09f91edc51724e3ac434cb385f1c73a7`,
pushed to GitHub and Gadi, and fast-forwarded into the Gadi checkout.
Remote `bash -n` passed and its SHA256 matched the local value
`24353aed593493903dad32736d2c5b845def9c07aac7f33a4e6bf32736a50f59`.
The unrelated untracked Gadi `experiments/` paths were preserved. The one
submission command was:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = a9779c5a09f91edc51724e3ac434cb385f1c73a7; test "$(sha256sum builds/build-scripts/gadi-gcc162-ompi5010/smoke_hpctoolkit_openfoam_1n_v1.pbs | cut -d " " -f 1)" = 24353aed593493903dad32736d2c5b845def9c07aac7f33a4e6bf32736a50f59; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_hpctoolkit_openfoam_1n_v1.pbs.out; /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_hpctoolkit_openfoam_1n_v1.pbs'
```

PBS returned `181585812.gadi-pbs`. It ran on one Sapphire Rapids node
`gadi-cpu-spr-0036` with five CPUs/ranks and ended `F`, `Exit_status=0`,
`00:01:10` walltime and **0.19 SU** (independent PBS stdout). The pinned
GCC 16.2.0, Open MPI 5.0.10 and OpenFOAM v2512 archive/binary hashes and
private `libmpi.so.40` link passed. The module labels were `ucx/1.18.1` and
`ucc/1.4.4`; this job did not measure the effective loaded UCX version or
collective selection. The `pitzDaily_fused` tutorial used Scotch, five
ranks and 20 time steps. `blockMesh` and `decomposePar` passed; the solver
logged `Time = 20`, coded average wall-clock time per step, `End`, and
`Finalising parallel run`. The diagnostic marker was
`GCC162_HPCTOOLKIT_OPENFOAM_1N_SMOKE_PASS`. This is not a scored run.

Five rank-specific `simpleFoam` HPCToolkit logs each report nonzero
`CPUTIME@50000` samples: rank 0 recorded 3 and ranks 1–4 recorded 227
each, with zero reported sample anomalies. Rank 0's coded function object
compiled during the run; its profile also contains compiler subprocesses.
These tiny, uneven tutorial profiles establish startup/termination and
raw-data capture, not representative hotspot fractions for the fixed 65M
case or validated source attribution. The measurement archive passed
`sha256sum -c` with SHA256
`c9fef4adf1b3a19126688c6602277d593981875f5efab4c31dbf7d131020ead0`;
`log.simpleFoam` SHA256 is
`3c1839efe80d26421b7e09d1f31b5327af2c74861b4899aa1cca1c9cdb4085eb`.
Raw evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/hpctoolkit-openfoam-smoke.181585812.gadi-pbs/`;
unique stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_hpctoolkit_openfoam_1n_v1.pbs.out`.

No new four-node job was submitted. Any next 416-rank profile needs a
separately reviewed diff and authorization under `AGENTS.md`, with
`REALTIME`-on-`sleep` removed and a cost ceiling.

## Archived five-rank profile inspection and approved postprocessing

After the user restored the existing `gadi-comp` control connection,
read-only inspection reconfirmed the measurement archive SHA-256
`c9fef4adf1b3a19126688c6602277d593981875f5efab4c31dbf7d131020ead0`.
Rank 1–4 `simpleFoam` logs each report 227 `CPUTIME@50000` samples and no
sample errors; rank 0's primary `simpleFoam` process has only three samples
and a later rank-0 process has zero. The logs contain a DSO mapping warning
for `(null)` on the nonzero-sample processes. The `.hpcrun` load map embeds
the former `/jobfs/181585812.gadi-pbs/gcc162-hpctoolkit-openfoam-181585812.gadi-pbs`
prefix, which no longer exists. The installed `hpcprof --help` documents
`-R old=new` replacement for load-map and source paths. This inspection
confirms raw capture, not function or source attribution.

The user separately approved one small PBS postprocessing job after seeing
its proposed diff: one `normalsr` node, two CPUs, 16 GB RAM, 20 GB JOBFS,
ten-minute limit, at most 0.67 SU at two SU/core-hour. The script
`postprocess_hpctoolkit_smoke_1n_v1.pbs` reads the existing archive, checks
all pinned hashes, reconstructs the runtime in JOBFS, runs bounded
`hpcstruct` and `hpcprof -M stats -R old=new` on ranks 1–4, and saves a
single database archive. It does not run OpenFOAM or modify the 65M case.
PBS and database results must be assessed before any separately authorized
four-node profile; the prior four-node approval is exhausted.

The reviewed script passed local and remote `bash -n`; its SHA-256 is
`6c3752246b75d8ce9bd2447a3929d030c7cba209b73b55a3cd0e1420029ff640`.
Commit `c598cd269417ae8d5cf95d60c8a62d8044dfd9bc` was pushed to the
isolated `codex/gadi-gcc162-build` branch on GitHub and Gadi. The Gadi
control checkout remains on its original `main`; the reviewed script was
materialized from the verified branch under the unique path
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/postprocess_hpctoolkit_smoke_1n_v1.submitted.pbs`.
The unrelated untracked Gadi `experiments/` files were preserved. The
single submission command was:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; p=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/postprocess_hpctoolkit_smoke_1n_v1.submitted.pbs; test "$(sha256sum "$p" | cut -d " " -f1)" = 6c3752246b75d8ce9bd2447a3929d030c7cba209b73b55a3cd0e1420029ff640; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/postprocess_hpctoolkit_smoke_1n_v1.pbs.out; /opt/pbs/default/bin/qsub "$p"'
```

PBS returned `181623287.gadi-pbs`; initial `qstat -f` showed `Q` in
`normalsr-exec`, one node, two CPUs, 16 GB RAM, 20 GB JOBFS and a
ten-minute walltime. Unique stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/postprocess_hpctoolkit_smoke_1n_v1.pbs.out`;
job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/hpctoolkit-postprocess.181623287.gadi-pbs/`.

## Five-rank profile database result

PBS job `181623287.gadi-pbs` finished `F`, `Exit_status=0`, on SPR node
`gadi-cpu-spr-0315`, with 2 CPUs, 1:25 walltime and **0.15 SU** in the
independent PBS stdout. Peak memory was 9.41 GB and JOBFS 6.28 GB.
All four archive hashes and the `simpleFoam` binary hash matched. The
script emitted `HPCTOOLKIT_SMOKE_POSTPROCESS_1N_PASS`; `hpcstruct` and
`hpcprof -M stats` completed, and the database tar passed SHA-256 check:
`89ea21f309e94bde6636d6731966c882311fba314446c7e7cbfc299f0178bfe5`.
The DB is in the job-keyed evidence path above and contains
`experiment.xml` plus `experiment.dtd`.

Read-only parsing of `experiment.xml` found 21 load modules and 95 named
procedures, including 33 `Foam::` procedures and MPI wait/barrier paths.
This proves function-level correlation is available despite the raw
measurement DSO warning. It found **zero OpenFOAM source-file paths**;
20 of 26 file entries are explicitly `unknown file`. `hpcprof.log` also
contains 27 nonfatal BFD/DWARF warnings. The existing optimized binary
therefore supports a limited function/library-level profile, not verified
OpenFOAM source-line attribution. This short `pitzDaily_fused` sample is
not representative of the fixed 65M case and does not measure MPI waiting
time: its event is CPU-time sampling only.

No new four-node profile was submitted. A proposed v2 would remove the
known-bad REALTIME-on-sleep preflight, use `CPUTIME@50000` on eight ranks,
save raw measurements before separate postprocessing, and request at most
35 minutes for 416 CPUs (maximum **485.33 SU** at two SU/core-hour).
The user must review the full v2 diff and separately approve its one
four-node submission; this small-job approval does not cover it.
