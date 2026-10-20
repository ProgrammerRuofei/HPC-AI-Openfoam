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

## Approved four-node raw sampling submission

The user reviewed the v2 script change and approved **one** four-node raw
sampling job. They separately approved pushing its scripts to the established
`git@github.com:ProgrammerRuofei/HPC-AI-Openfoam.git` repository after an
automatic approval check rejected the earlier GitHub push. No repeat or
postprocessing job is authorized by these approvals.

The v2 script retains the pinned GCC 16.2.0, Open MPI 5.0.10, OpenFOAM v2512,
UCX/UCC module requests, four SPR nodes with 104 ranks each, Scotch
decomposition, fixed case hashes, preparation chain, and 150 solver steps.
It removes the previously hung `REALTIME` preflight, samples ranks
0,52,104,156,208,260,312,364 with `CPUTIME@50000`, caps the solver launch at
900 seconds, checks solver completion and Cd, and archives only nonempty raw
`.hpcrun` measurements with SHA-256. It does not run `hpcstruct` or `hpcprof`
inside the four-node job. The request is 416 CPUs, 760 GB memory, 100 GB
JOBFS per node, and 30 minutes in `normalsr`, at most **416 SU** at the stated
2 SU/core-hour rate. This is diagnostic, not a competition result.

The two scripts passed local `bash -n` and diff review and were committed as
`52f94a558f4b3a58078553fb87b255232079ac70` on the isolated branch,
then pushed to GitHub and Gadi. The Gadi control checkout remained on `main`;
the scripts were materialized from the verified branch to unique files under
`.../gadi-gcc162-ompi5010/submit-logs/`. Remote `bash -n`, exact SHA-256,
and unchanged existing runtime/processor helpers passed. Script SHA-256:
`3ddffb8d8b3fce2b170746a810ad0e07224450d854614583ba28e7fce5522df2`;
profile staging helper SHA-256:
`6edbea64952b03ac191838df735be213e185be2a64047f1f26257eaca4c472fe`.
The unrelated untracked Gadi `experiments/` files were preserved. Before
submission `nci_account -P pm78` showed 4.30 KSU available, zero reserved SU,
and scratch 199.10K of 202K inodes used.

After checking the unique stdout path was absent, a single `qsub` of
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_scotch_v2.submitted.pbs`
returned **`181627666.gadi-pbs`**. Initial `qstat -f` showed `Q` in
`normalsr-exec` with 416 CPUs and the 30-minute limit. Its unique PBS stdout
is `.../submit-logs/profile_baseline_4n_scotch_v2.pbs.out`, and job-keyed
evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-scotch-v2/181627666.gadi-pbs/evidence/`.
The job finished with PBS `job_state=F`, `Exit_status=0`, and
`GCC162_OMPI5010_OF2512_SCOTCH_4N_RAW_PROFILE_PASS`. PBS reports
**00:16:43 walltime and 231.80 SU**, with 300.59 GB peak memory and
21.99 GB JOBFS. The four SPR hosts were `0132`, `0137`, `0138`, and `0139`,
with exactly 104 of the 416 ranks per host. Scotch `decomposePar`,
`renumberMesh`, `potentialFoam`, `applyBoundaryLayer`, and `simpleFoam` each
ended normally; solver `Time = 150`, coded average **1.988370328637583
s/step**, and final **Cd = 0.29187594927465327**. The profiler run is
unscored; its timing must not replace either uninstrumented GCC baseline.
The sampled eight ranks and binding policy beyond the explicit
`--map-by ppr:104:node` were not separately traced.

Four raw profile archives passed `sha256sum -c`:

| Node-rank range | SHA-256 | Size |
| --- | --- | --- |
| 0–103 | `34353a3502cdf3607f50c47ef786a9b6b000de00a3e3b9cc07ddca0eed751eb3` | 139 KB |
| 104–207 | `2252eed42379060e912d1e78d0a3533a98a9479db5f663980fc4fc7d9e5a2bb4` | 93 KB |
| 208–311 | `814e57b9aa338d7daef34e47d433279b12e4152a430a194a142da4bdb55e4783` | 98 KB |
| 312–415 | `5efc63b76990d5783dfb73ca1c5b24a2533c690227c9ff499704dcacf89474e4` | 98 KB |

Each archive contains both selected rank directories and nonempty
`.hpcrun` files. The first node's archive also contains numerous rank-0
child-process profiles from coded-function execution; raw file counts
therefore do not directly measure solver samples. No full-case `hpcprof`
analysis or source-line attribution is claimed. Any parsing work requires a
separate approved job or read-only inspection of these preserved archives.
There was no repeat submission.

## Approved four-node profile postprocessing and CPU hotspots

The user separately approved one low-cost postprocessing job, including
publishing its script and result record to the existing isolated GitHub/Gadi
branch. No further 416-rank run or repeat was approved. The reviewed
`postprocess_hpctoolkit_4n_v1.pbs` script (SHA-256
`dd62c75cfa2f8352b8d52bffba1bdc2ce8d32a2d99ee9e962b65a4e30cdb9ab2`)
passed local `bash -n`, embedded Python compilation, synthetic XML parsing,
and diff review. Commit `782e78ae1aed17ab6aa3f5295bc537508372fa08`
was pushed to both isolated branches. Gadi `main` and unrelated untracked
files were left intact. The branch commit, remote script hash, `bash -n`, and
unique stdout path were checked before one `qsub` of
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/postprocess_hpctoolkit_4n_v1.submitted.pbs`.
The returned job ID was **`181629095.gadi-pbs`**.

The analysis requested `pm78`, `normalsr`, one SPR node, two CPUs, 16 GB
memory, 20 GB JOBFS, and 10 minutes. PBS reports **Exit_status=0**, 1:26
walltime, 10.05 GB peak memory, 6.32 GB JOBFS, and **0.15 SU**. Its
`HPCTOOLKIT_4N_POSTPROCESS_PASS` marker, selected profiles, logs, tables,
database archive, and checksum are preserved in
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/hpctoolkit-4n-postprocess.181629095.gadi-pbs/`.
The `hpcprof-db.tar.gz` SHA-256 is
`e904bb217c341b326c3d4ea1b2639748fd21851506dc54304bc1f2dd714ade60`
and `sha256sum -c` passed. The eight selected main `simpleFoam` profiles
have 5,049–5,246 samples each; rank 0's many coded-function child profiles
were excluded. The database preserves function and module names. Its only
source file is generated `foamConfig.Cver.cc`; BFD/DWARF warnings were
nonfatal, so solver source-line attribution is **not** established.

Across these eight sampled ranks, the parser attributes 2,496.11 seconds of
exclusive `CPUTIME` to procedures. Shares below use that denominator,
**not** 416-rank walltime. OpenFOAM executable/libraries account for about
72.63%; MPI/UCX/HCOLL libraries about 16.76%, including HCOLL modules
about 8.00%; and libc about 9.18%. The top procedures are
`GaussSeidelSmoother::smooth` 16.01%, `lduMatrix::residual` 11.39%,
`lduMatrix::Amul` 6.22%, and libc `memmove` 5.93%. HCOLL collective-progress
functions and MPI/UCX progress functions also appear. This points first to
linear-system work and associated memory traffic as CPU-active hotspots;
it also justifies examining collective/progress behavior before changing
communication settings. The eight per-profile CPU totals are 301.87 seconds
for the first metric and 313.19–313.61 seconds for the other seven. This
does not establish whole-job rank balance: only 8 of 416 ranks were sampled,
and rank 0 has different coded-function activity.
Read-only inspection of the preserved database shows Gauss-Seidel smoothing
as the largest named procedure in each of the eight metric groups. The
MPI/UCX/HCOLL module share ranges from roughly 14.0% to 18.4% by group,
while HCOLL alone ranges from about 4.5% to 11.1%. This spread merits a
rank-aware communication/wait check; the database's metric-group order was
not independently validated as a rank map, so no particular rank is blamed.

`CPUTIME` cannot separate useful communication work from spin waiting,
blocked MPI wait, or network transfer. Loaded UCX/UCC module names and
library paths do not prove the effective UCX version in the old solver job;
it remains **unknown**. HCOLL appears in the sampled stack, while no UCC
library appears in the attributed module table. These are observations,
not evidence that UCC was selected or that forcing UCC would improve the
case. The next decision should use this profile to prioritize controlled
solver/build experiments, and a separate MPI-wait/collective measurement
would be needed to quantify communication delay. No further PBS job was
submitted under this postprocessing approval.


## mpiP 3.6 compatibility smoke, first attempt

The approved one-node five-CPU, 15-minute mpiP smoke `181635700.gadi-pbs`
ended with PBS `Exit_status=2` after 0:52 and **0.14 SU**. Pinned
source/GCC/Open MPI archive checks and tool versions passed. The first fatal
error occurred during mpiP wrapper generation: Gadi `/bin/python` is a
blocking shim (`#!/usr/local/bin/python`), so mpiP was not built and no MPI
probe or OpenFOAM solver ran. Original `make.log`, `run.log`, PBS stdout and
`exit-status.txt` remain at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/mpip36-smoke.181635700.gadi-pbs/`.
The separately approved v2 script selects verified `/bin/python3` (3.6.8)
for configure and make, retains the scientific and MPI settings, and uses
a new stdout and job-keyed evidence path. The original attempt is not
interpreted as a mpiP/Open MPI compatibility result.


## mpiP 3.6 smoke v2 submission

The user approved one corrected one-node retry. Script
`build_smoke_mpip36_1n_v2.pbs` changes only the unique stdout path and
selects `/bin/python3` for mpiP configure/make. `bash -n` and `git diff
--check` passed; script SHA-256 is
`57aa96b444950fcb75ae596f4800f2ec91c8c5e1b9714767889bf1d29f844af6`.
Commit `2a1a982e1258c05c74af235f024ea680d75b6243` was pushed to the
isolated GitHub and Gadi branches. The Gadi branch and submitted-copy hash
matched, and the source archive SHA-256 remained
`b8433569b4f8cf4a5f42b23d6108df76eb80e3632a0389331bb7368679196de9`.
Gadi control checkout `main` and unrelated untracked files were preserved.
The one `qsub` returned **`181691060.gadi-pbs`**; initial PBS state was Q.
Resources: pm78 normalsr, one SPR node, five CPUs, 16 GB memory, 20 GB
JOBFS, 15-minute limit (2.5 SU request ceiling). Submitted copy and unique
stdout are under the existing `gadi-gcc162-ompi5010/submit-logs/` directory;
job-keyed evidence will be under
`gadi-gcc162-ompi5010-of2512/evidence/mpip36-smoke.181691060.gadi-pbs/`.
Completion, actual SU, and mpiP compatibility are pending PBS evidence.


## mpiP 3.6 smoke v2 result

PBS job **`181691060.gadi-pbs`** finished on SPR node
`gadi-cpu-spr-0720` with `Exit_status=2`, 0:53 walltime, five CPUs,
9,525,784 KB peak memory and 6,748,046,686 bytes peak JOBFS. At the
previously verified normalsr rate of two SU per core-hour, the walltime
implies about **0.15 SU**; `nci_account -P pm78` only exposes aggregate
rounded project usage (1.94 KSU used, 0 reserved, 4.06 KSU available),
so it does not independently establish a more precise per-job debit.

Original `configure.log`, `make.log`, `run.log`, `exit-status.txt`, module
list, and PBS stdout remain at the job-keyed evidence path. The v2
`/bin/python3` setting passed wrapper generation. The **first fatal
compile error** is in generated `mpiP-wrappers.c`: mpiP 3.6 declares
`MPI_Pready_list(int, const int *, MPI_Request)`, while the pinned Open
MPI 5.0.10 `mpi.h` declares `MPI_Pready_list(int, int *, MPI_Request)`.
GCC reports `conflicting types for 'MPI_Pready_list'` at generated line
9325, then make exits 2. No `libmpiP.so`, 2-rank MPI probe, or 5-rank
OpenFOAM solve was produced. This is a mpiP/Open MPI API signature
compatibility issue, not evidence of solver MPI communication behavior.
The approval covered one v2 retry, now exhausted; no further job was
submitted. A new patch and job would require separate diff review and
approval under `AGENTS.md`.


## Approved mpiP 3.6 smoke v3 plan

Read-only inspection of the pinned mpiP 3.6.0 source archive found the
conflicting `MPI_Pready_list` declaration in
`mpi.partitioned.protos.txt`. The archive's `configure.ac` explicitly
provides `--disable-mpi-partitioned`; its `mpi.protos.txt.in` then omits
that wrapper group. This keeps the ordinary MPI point-to-point and
collective wrappers needed for the bottleneck check while avoiding the
Open MPI 5.0.10 partitioned-call signature conflict.

After the user reviewed the exact two-line v3 change and approved one
more low-cost job, `build_smoke_mpip36_1n_v3.pbs` was created with a new
stdout path and that configure option. The previously pinned source,
compiler/MPI/OpenFOAM archives, two-rank probe, five-rank tutorial, and
resource request are otherwise unchanged. Local `bash -n` and diff checks
passed. Script SHA-256:
`2c2d3462230ed6083776c2aef6c4c4a184450adc95bfd3f7ce17cbcc5cd525b6`.
The v3 result is pending; no inference about MPI wait is made yet.


## mpiP 3.6 smoke v3 submission

The reviewed and approved v3 script was committed as
`3df4ebbec95fb13e72a84a21b0eefcc09b3da58e`, pushed to the isolated
GitHub and Gadi branches, and compared against the remote branch head.
The immutable submitted copy matched script SHA-256
`2c2d3462230ed6083776c2aef6c4c4a184450adc95bfd3f7ce17cbcc5cd525b6`;
`bash -n` passed, and the unique stdout path did not exist before submission.
Exactly one `qsub` of
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_smoke_mpip36_1n_v3.submitted.pbs`
returned **`181694279.gadi-pbs`**, initially Q. It requests pm78
`normalsr`, one SPR node, five CPUs, 16 GB memory, 20 GB JOBFS and a
15-minute walltime (2.5 SU request ceiling). New job-keyed evidence is
expected under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/mpip36-smoke.181694279.gadi-pbs/`.
Completion and actual SU remain pending PBS evidence.


## mpiP 3.6 smoke v3 result

The one approved job **`181694279.gadi-pbs`** ran on SPR node
`gadi-cpu-spr-0720` and finished with PBS `Exit_status=2` after 0:56,
five CPUs, 7,678,264 KB peak memory and 5,781,451,767 bytes peak JOBFS.
At the verified normalsr rate of two SU per core-hour, this implies about
**0.16 SU**; PBS does not report a job-specific SU field and the project
account command is rounded. Raw `configure.log`, `make.log`, `run.log`,
`exit-status.txt`, module list, and PBS stdout remain in the unique v3
job evidence path.

The v3 flag worked: configure reports `MPI-Partitioned support: no`,
`mpiP-wrappers.c` compiled, and the previous `MPI_Pready_list` conflict
did not recur. The **first fatal error** is now `fortran_vars.f` compiling
through `mpifort`: `mpif.h:56: Error: Can't open included file
'mpif-config.h'`. The pinned Open MPI 5.0.10 archive contains `mpif.h`
and `mpifort` but no `mpif-config.h`; the recorded Open MPI build script
used `--disable-mpi-fortran`. mpiP's normal C shared-library target still
compiles `fortran_vars.o`, and `mpiPi.c` calls `fortran_vars` at init, so
merely skipping the Fortran object is not a verified fix. No libmpiP,
MPI probe, or OpenFOAM solver run was produced. No further job was
submitted under the one-job v3 approval. MPI wait/collective timing
remains unmeasured.


## C-only PMPI timing, low-cost validation plan

The user authorized a C-only PMPI timing alternative and autonomous
low-cost smoke repair/retry, with no permission for a four-node run.
`pmpi_timing.c` interposes 14 selected C MPI point-to-point, wait/test,
and collective calls and writes one CSV per rank at `MPI_Finalize`. It
records call count, cumulative monotonic-clock duration, and maximum
duration. It does not intercept every MPI routine and cannot equate call
duration with network transfer time. It uses the pinned C MPI interface
and has no Fortran dependency. The profiler was syntax-checked locally
with a minimal MPI declaration stub; exact-header compilation still
requires a PBS compute-node check.

`smoke_pmpi_timing_1n_v1.pbs` requests pm78 normalsr, one SPR node, five
CPUs, 16 GB memory, 20 GB JOBFS, and at most 15 minutes (2.5 SU request
ceiling). It hash-checks the existing GCC16.2/Open MPI5.0.10/OpenFOAM
v2512 archives and the profiler source; builds the shared library with
the private mpicc; checks private libmpi linkage; then runs a two-rank
Allreduce/Barrier probe and the existing five-rank, 20-step Scotch
`pitzDaily_fused` tutorial. It checks per-rank CSV reports and solver
`End`. This is non-scored, and no 416-rank profiler job is authorized.


## C-only PMPI timing smoke submission

Commit `5f47b7df9fd3901dd1e75184ef2a9fb9f84fbd0c` was pushed to the
isolated GitHub and Gadi branches. The Gadi branch head matched the local
commit, and materialized source/script SHA-256 values were respectively
`311577465685d7086a2bca1653ba2f583a4f3ca3332c882e85efdad4903a00e5`
and `28020d504666fb55d3abad26245455862a21d7d5f3f5bb420e46f56a1e749492`.
The submitted script passed `bash -n`; unique submitted files and stdout
were checked before creation. One `qsub` of
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_pmpi_timing_1n_v1.submitted.pbs`
returned **`181704658.gadi-pbs`**, initially queued. Resources are one
SPR node, 5 CPUs, 16 GB, 20 GB JOBFS, 15 minutes on pm78 normalsr. The
Gadi control checkout stayed on `main` and its unrelated untracked files
were preserved. Job-keyed evidence is expected under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/pmpi-timing-smoke.181704658.gadi-pbs/`.
Result and actual SU are pending PBS evidence.


## C-only PMPI timing smoke result and interpretation

PBS job **`181704658.gadi-pbs`** finished on `gadi-cpu-spr-0503` with
`Exit_status=0`, 1:57 allocated walltime, five CPUs, 11,325,852 KB
peak memory and 6,752,251,181 bytes peak JOBFS. At the previously
verified normalsr rate of two SU per core-hour, this implies about
**0.33 SU**; the project account reported only rounded aggregate usage
and temporarily still showed the 2.50 SU reservation, so an exact
job-specific debit was not observable. The job emitted
`GCC162_OMPI5010_PMPI_TIMING_1N_SMOKE_PASS`. The profiler shared library
linked to the relocated private `libmpi.so.40`, and its archived SHA-256
`58916f17351013881dc32af672f97ff5def696a4d624ff6d4297836e8a792301`
passed `sha256sum -c`.

The two-rank UCX probe passed `MPI_PROBE_PASS` and produced two valid rank
CSVs, each with one timed `MPI_Allreduce` and one `MPI_Barrier`. The
five-rank Scotch `pitzDaily_fused` tutorial reached `Time = 20`,
`Finalising parallel run`, coded wall-clock output and `End`. Five rank
CSVs each contained all 14 selected call categories and a positive
post-init elapsed time; the validator counted 193,840 intercepted calls.
The raw CSVs, full solver/preparation/build logs, independent PBS stdout,
modules, linker traces, binary and checksum are preserved under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/pmpi-timing-smoke.181704658.gadi-pbs/`.

The tutorial is not scientific bottleneck evidence. Its rank 0 spent
roughly 64 seconds building the coded wall-clock function object. Ranks
1–4 each recorded about 64.185 seconds in a *single* `MPI_Barrier` while
waiting for rank 0; rank 0's corresponding barrier took about 0.014 ms.
The solver's 20 time steps then finished quickly. This demonstrates that
PMPI call timing detects rank-asymmetric waiting but also shows why
start-up must be separated from the 150-step scientific solve. It cannot
by itself attribute this barrier duration to network transfer. No
four-node job was submitted under the low-cost smoke authorization.


## Windowed C-only PMPI smoke submitted

The user authorized autonomous low-cost tests and repair/retry of the C-only
PMPI approach. `pmpi_timing_v2.c` adds per-rank 10-second counters alongside
the existing full-run counters, with calls assigned by start time since
`MPI_Init`. This separates tutorial startup synchronization from later
solver windows; call duration still includes waiting and cannot establish
network-transfer time. `smoke_pmpi_timing_1n_v2.pbs` retains the one SPR node,
five CPUs, 16 GB, 20 GB JOBFS, 15-minute (at most 2.5 SU) tutorial test.
Local stub-header C syntax, shell syntax, embedded Python syntax, and
`git diff --check` passed.

Commit `2e958344fbd406c23c443c71b4e6f0797335f792` was pushed to the
GitHub and Gadi isolated branches. Gadi materialized the immutable source
and PBS script from that exact branch ref in the designated `submit-logs`
directory; their SHA-256 values were respectively
`b3e8f31868cce92284048b896d6339fc0b01d0b8b900eef3e28409207790ccd0`
and `1ee5a57853146eddd7cc9b5491754c868f81840faf7b889a32389789d579cc94`.
Remote `bash -n` passed. One qsub returned **`181705417.gadi-pbs`**. It finished on `gadi-cpu-spr-0036` with `job_state=F`, `Exit_status=0`,
1:59 PBS walltime, 5 CPUs, 11,164,708 KB peak memory and 6,752,251,911
bytes peak JOBFS. At 2 SU/core-hour the observed allocation implies about
**0.33 SU**; NCI reported only rounded project-level usage and a 2.50 SU
reservation, so a precise job-specific debit remains unobserved. Its job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/pmpi-timing-v2-smoke.181705417.gadi-pbs/`; its independent
stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_pmpi_timing_1n_v2.pbs.out`.

Validation passed: `GCC162_OMPI5010_PMPI_TIMING_V2_1N_SMOKE_PASS`,
`PMPI_BUCKET_REPORT_PASS` for both the two-rank UCX probe (4 calls) and the
five-rank Scotch tutorial (193,840 calls), exact per-rank bucket count and
duration reconciliation, private MPI linkage, profiler library SHA-256
`dbe725d1ee8e07746ff18d0179ef4f02b24962cc0c3311a8aecb22bef1e88b79`,
and solver `Time = 20` / `End`. The tutorial reports have five summaries
and five bucket files. Ranks 1–4 each spent about 64.767 seconds in a
single `MPI_Barrier` that began in the 0-second bucket; rank 0's barrier
began after 60 seconds and was negligible. This ties the large wait to
start-up synchronization while rank 0 compiled the coded function object.
The later solver window exists, but the 20-step tutorial cannot establish
the 65M-cell scientific solver's MPI fraction. No four-node PMPI job was
submitted or authorized. The next high-SU diagnostic needs a separately
reviewed concrete diff and approval.
