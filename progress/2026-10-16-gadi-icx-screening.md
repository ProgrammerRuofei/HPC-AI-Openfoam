# Gadi ICX screening after the GCC baseline

## Confirmed starting point

The GCC 16.2.0 + Open MPI 5.0.10 + UCX 1.18.1 + UCC 1.4.4 OpenFOAM
v2512 build completed two identical `normalsr` Sapphire Rapids four-node
Scotch runs: 416 ranks, 150 steps, 1.991194389 and 1.988625920 s/step,
with final Cd 0.291875949 in both. Details and evidence are in
`results/gadi-gcc162-ompi5010-scotch/run-registry.md`.

Read-only Gadi module inspection found no `intel-compiler-llvm/2026.1`.
The newest available module was `intel-compiler-llvm/2025.3.2`; loading it
reported ICX/ICPX 2025.3.2 (2025.3.2.20260112). The other team's ICX
2026.1 timing is therefore context, not a directly reproducible toolchain
version on this Gadi installation. NCI reported pm78 6.00 KSU grant,
732.53 SU used, zero reserved, and 5.27 KSU available before screening.

## Step 1: compiler / MPI compatibility probe

The first experiment checks whether ICX 2025.3.2 can compile and run a
C++ MPI program with the existing private Open MPI 5.0.10 archive. It
reuses the verified GCC runtime archive only to satisfy dependencies of
that MPI build. It loads Gadi's UCX 1.18.1 and UCC 1.4.4 modules. The
probe requests one `normalsr` SPR node, four CPUs, 16 GB memory, 8 GB
JOBFS, and 20 minutes maximum. It verifies archive hashes, versions,
wrapper compilers, private libmpi linkage, and two UCX MPI ranks.

Script: `builds/build-scripts/gadi-icx20253-ompi5010/smoke_icx_ompi_1n.pbs`.
It passed local and Gadi `bash -n`; commit `eda1ebf` was pushed to GitHub
and Gadi, and the remote checkout fast-forwarded to
`eda1ebfa218e4d2aa867d6d545caf9403720fc11`. Submission command:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = eda1ebfa218e4d2aa867d6d545caf9403720fc11; mkdir -p /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/smoke_icx_ompi_1n.pbs.out; qsub builds/build-scripts/gadi-icx20253-ompi5010/smoke_icx_ompi_1n.pbs'
```

PBS returned **`181382175.gadi-pbs`**. First status check showed `Q`.
The script preserves job-keyed evidence at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/evidence/181382175.gadi-pbs/`.
Next, validate `Exit_status=0`, `ICX20253_OMPI5010_ABI_SMOKE_PASS`,
private MPI linkage, two-rank output and actual SU. A failure should be
diagnosed from the first error before deciding whether a separate ICX MPI
build is needed. Do not rebuild UCX merely because its module is reused.

After this gate, build OpenFOAM v2512 with ICX, confirm real Scotch and
MPI linkage, run a small tutorial, and only then compare the unchanged
four-node 416-rank Scotch 150-step workload with the GCC baseline.

## Probe result and ICX OpenFOAM build preparation

Job `181382175.gadi-pbs` finished with PBS `Exit_status=0`, 20 seconds
walltime, and `ICX20253_OMPI5010_ABI_SMOKE_PASS`. The node was an Intel
Xeon Platinum 8470Q (SPR). The log confirms ICX/ICPX 2025.3.2,
Open MPI 5.0.10, `mpicc` using `icx`, `mpicxx` using `icpx`, linkage to
the job-local private `libmpi.so.40`, no missing dynamic libraries, and
both MPI ranks running with `--mca pml ucx`. The `nci_account` reading
immediately after completion still showed 2.67 SU reserved and 732.53 SU
used; the final posted charge remains to be checked.

The next build keeps the same authoritative OpenFOAM source and source-ID
verification, private MPI archive, UCX/UCC modules, `Opt` setting, and
real Scotch validation. It changes the compiler to the available ICX
2025.3.2, selects `WM_COMPILER=Icx`, and stores output under a distinct
ICX stack ID. The existing GCC build path remains supported by the common
helper. The build script and PBS request are in
`builds/build-scripts/gadi-icx20253-ompi5010/`.

The prepared build was committed as `5d35bfd` and pushed to GitHub.
The subsequent push to the Gadi remote failed because the existing SSH
control connection broke; a separate read-only `ssh -o BatchMode=yes
-o ConnectTimeout=8 gadi-comp 'hostname'` returned `Permission denied`.
This was an access failure, not a PBS or build result. No ICX OpenFOAM
build job was submitted, and the Gadi branch/checkout remains at the
preceding synced commit `e77080b`. Resume the pending Gadi branch push,
fast-forward, script hash/syntax check and one `qsub` only after the user
restores that existing SSH control connection.

## Connection restored and ICX build submitted

The user restored the existing `gadi-comp` connection. A read-only check
reached `gadi-login-09.gadi.nci.org.au`; the Gadi checkout was at
`e77080b` with the same unrelated pre-existing untracked files. NCI
posted the ICX/MPI probe at **0.04 SU** (`Used` 732.57 SU, `Reserved`
0, `Avail` 5.27 KSU). The local branch remained clean at `c49bea6`.

The branch was pushed to the Gadi remote and the checkout fast-forwarded
to `c49bea6f228d0c561ddbdc107f851b0ee64b80c6`. Remote `bash -n`
passed for the common helper, ICX wrapper, and ICX PBS script; their
SHA-256 values matched local values, respectively
`520eecff363768d65e336d572c0a51a7469240fe00bf1d8e23ad670f13a34a90`,
`68b81e2ff331b1e2bdfd4b30dfb9ce356c671d6b5ad5249703e1dc15995afcf1`,
and `5809c70be5689f79489ca108e710447a56cd5a1a41ab6b57277f310e27860ac3`.
The build was submitted once with:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = c49bea6f228d0c561ddbdc107f851b0ee64b80c6; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/build_openfoam_v2512.pbs.out; qsub builds/build-scripts/gadi-icx20253-ompi5010/build_openfoam_v2512.pbs'
```

PBS returned **`181387300.gadi-pbs`**. It requests one `normalsr` SPR
node, 48 CPUs, 190 GB RAM, 100 GB JOBFS, and four hours maximum. Stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/build_openfoam_v2512.pbs.out`.
Job-keyed build evidence is expected under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/evidence/gadi-icx20253-ompi5010-of2512.181387300.gadi-pbs/`.
Wait for PBS `Exit_status=0`, `SCOTCH_BUILD_PASS`, `BUILD_VALIDATION_PASS`,
SOURCE_ID_V2, ICX/OMPI versions, private `libmpi` linkage and matching
runtime-archive `.sha256`; then record actual SU and perform a fresh-job
5-rank tutorial smoke test. Keep all failure evidence and use a new path
on any corrected retry. Do not interpret SSH failure as PBS outcome.

## First ICX OpenFOAM build failure and corrected retry

Build `181387300.gadi-pbs` finished with PBS `Exit_status=2`, walltime
00:49:27, and a posted **79.12 SU** charge (pm78 `Used` rose from
732.57 to 811.69 SU; 5.19 KSU available). Source-ID V2, ICX 2025.3.2,
Open MPI 5.0.10, and staged source identity passed. The first fatal
compiler errors in `build.log` are CGAL 4.14.3's
`boost/graph/iterator.h` reporting `no member named 'base'` for
`Halfedge_around_*_iterator<Graph>` while `applications/Allwmake`
compiled the optional `surfaceBooleanFeatures` utility. The earlier
Scotch install messages marked `Error 1 (ignored)` were not the fatal
error; real `libscotch.so` was compiled, but the full build terminated
before final Scotch and runtime archive validation. The raw 13 MB
`build.log`, source manifests, PBS stdout and job ID remain untouched
under the original job-keyed evidence directory. No valid ICX runtime
archive or timing result is claimed from this attempt.

The correction keeps the authoritative OpenFOAM source, ThirdParty
source, compiler, MPI, modules and build flags unchanged. Instead of
building unrelated optional CGAL tools, the ICX wrapper selects a
`benchmark-required` application subset after building ThirdParty and
all source libraries. The six required executables are `blockMesh`,
`decomposePar`, `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`,
and `simpleFoam`; each is built and hard-gated. The old GCC full-build
path remains unchanged. The distinct retry script is
`builds/build-scripts/gadi-icx20253-ompi5010/build_openfoam_v2512_v2.pbs`
with unique PBS stdout. It must be validated, committed, synced and
submitted as a new job; it has not been submitted at the time of this
record.

The corrected files passed local `bash -n`/diff checks, were committed as
`5478309`, pushed to GitHub and Gadi, and the Gadi checkout fast-forwarded
to `5478309c797793bc779d87ce988e77997a34043e`. Remote `bash -n`
passed and SHA-256 values matched the local common helper, ICX wrapper,
and v2 PBS script: `3681d846ac7d3cd1dd125290708b529cad9cc9f49feb800d406fb33d9d9ea772`,
`7dbf63e7c16a0b52d2379429f4ef3d6350d1af14fd60b7506c9896cfaca2f01b`,
`933151427dfda19eb4cc24b94c014174206a93c8f1d9755df4b25a8039740bc6`.
The new submission was made once with:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = 5478309c797793bc779d87ce988e77997a34043e; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/build_openfoam_v2512_v2.pbs.out; qsub builds/build-scripts/gadi-icx20253-ompi5010/build_openfoam_v2512_v2.pbs'
```

PBS returned **`181392981.gadi-pbs`**. It has the same one-node,
48-CPU, 190-GB RAM, 100-GB JOBFS, four-hour maximum request, but a new
stdout at `.../gadi-icx20253-ompi5010/submit-logs/build_openfoam_v2512_v2.pbs.out`
and unique job-ID evidence. It is pending validation; do not call the
ICX build successful until all six apps, Scotch, source identity,
private MPI linkage, archive/hash, and PBS exit are checked.

## Corrected ICX build result and runtime smoke preparation

Job `181392981.gadi-pbs` finished with PBS `Exit_status=0`, walltime
00:52:05, **83.33 SU**. All six `BENCHMARK_APP_PASS` markers,
`SCOTCH_BUILD_PASS`, `BUILD_VALIDATION_PASS`, authoritative and staged
`OPENFOAM_SOURCE_ID_V2` equality, ICX 2025.3.2, Open MPI 5.0.10,
`WM_OPTIONS=linux64IcxDPInt32Opt`, and job-local private `libmpi.so.40`
linkage passed. The runtime archive is 836 MB at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/runtime-archive/gadi-icx20253-ompi5010-of2512.181392981.gadi-pbs.tar.gz`.
Its SHA-256 is `a832416d47a1a26cc2a02ef0c69eb09dbf142043d619ed22ece37d96b029dfcd`;
`sha256sum -c` passed. The `simpleFoam` binary SHA-256 is
`7cc4af8c576eba1e97ba16a767fca5843293c391b71a3904a596b3981d2913e4`.
NCI `Used` rose from 811.69 to 895.02 SU, confirming the posted
83.33 SU charge; `Avail` is 5.10 KSU before the next job.

The candidate is a validated **build**, not yet a validated runtime or
performance result. A separate five-core `pitzDaily_fused` Scotch/UCX
smoke script adapted from the successful GCC smoke is at
`builds/build-scripts/gadi-icx20253-ompi5010/smoke_openfoam_v2512_v1.pbs`.
It pins the archive and binary hashes, expects `WM_COMPILER=Icx`, uses
the same coded wall-clock functionObject and requires solver `End`.

The smoke script passed local and Gadi `bash -n`; SHA-256
`bd669b7afc8732ad5cb216ade9758f50844f4e2282817e4975403a0f9f189000`
matched in both checkouts. Commit `ae16765` was pushed to GitHub/Gadi
and the Gadi checkout fast-forwarded. One submission returned
**`181399119.gadi-pbs`** (initial state Q):

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; git merge --ff-only codex/gadi-gcc162-build; test "$(git rev-parse HEAD)" = ae1676529258e1830641f72fb1521d0f99bb48ce; bash -n builds/build-scripts/gadi-icx20253-ompi5010/smoke_openfoam_v2512_v1.pbs; sha256sum builds/build-scripts/gadi-icx20253-ompi5010/smoke_openfoam_v2512_v1.pbs; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/smoke_openfoam_v2512_v1.pbs.out; qsub builds/build-scripts/gadi-icx20253-ompi5010/smoke_openfoam_v2512_v1.pbs'
```

This requests one SPR `normalsr` node, five CPUs, 16 GB RAM, 12 GB
JOBFS and 20 minutes maximum. Output is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/smoke_openfoam_v2512_v1.pbs.out`, with job-ID
evidence under `.../gadi-icx20253-ompi5010-of2512/evidence/smoke.181399119.gadi-pbs/`.
Require PBS exit 0, `OF2512_ICX20253_OMPI5010_SMOKE_PASS`, verified
archive/binary hashes, Scotch decomposition, five-rank UCX `simpleFoam`,
coded timing, `End` and actual SU before any four-node run.

While the smoke queued, the four-node ICX script and per-node staging
helpers were prepared locally from the two successful GCC runs. The
reviewed diff changes only stack identity, ICX module/compiler/platform,
archive and binary hashes, evidence paths and pass marker. The seven
scientific-input SHA-256 gates, 416-rank layout, Scotch decomposition,
150-step control, solver sequence, Cd gate and JOBFS processor layout
remain identical. These scripts are **not authorization to skip the
fresh-job smoke gate**; submit the four-node run only if that smoke
passes and after Git/remote syntax and hash checks.

## Fresh-job runtime smoke result

Job `181399119.gadi-pbs` completed with PBS `Exit_status=0`, script
`pbs_exit_status=0`, walltime 00:00:55 and **0.15 SU**. The archived
OpenFOAM and `simpleFoam` hashes passed, `libmpi.so.40` resolved to
the private Open MPI 5.0.10 unpacked in fresh JOBFS, and real Scotch
decomposed `pitzDaily_fused` into five domains. Five UCX ranks completed
`simpleFoam`; the coded timer printed an average of
0.003550377736842106 s/step, followed by `End` and `Finalising parallel
run`. The log contains `OF2512_ICX20253_OMPI5010_SMOKE_PASS`.
This is a tutorial smoke only; its timing is not a scored 65M result.
Evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/evidence/smoke.181399119.gadi-pbs/`.
The prepared ICX four-node script may now undergo final Git/hash,
scientific-input and budget checks before a single submission.

## Controlled four-node ICX submission

The three ICX four-node scripts passed local and Gadi `bash -n` and SHA-256
comparison after Gadi fast-forwarded to commit
`a1ab68592e2a559e9189e9a7612d48b4c74b1ba8`. The account had
5.10 KSU available and zero reserved before submission; the job's
one-hour maximum would reserve at most 832 SU. Scratch had about 4.87K
inodes free, so the proven per-node JOBFS processor-symlink layout is
required. The seven fixed scientific-input hash gates and the GCC run's
416-rank/Scotch/150-step preparation sequence remain identical.

One `qsub` returned **`181399707.gadi-pbs`**. The initial `qstat -f`
showed state Q in `normalsr-exec`, four 104-core chunks, 416 MPI ranks,
760 GB total RAM, 100 GB JOBFS, and a one-hour walltime limit. Exact
submission command:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = a1ab68592e2a559e9189e9a7612d48b4c74b1ba8; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_scotch_v1.pbs.out; qsub builds/build-scripts/gadi-icx20253-ompi5010/run_baseline_4n_scotch_v1.pbs'
```

PBS stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_scotch_v1.pbs.out`;
job evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/baseline-4n-scotch/181399707.gadi-pbs/evidence/`.
Require PBS Exit_status=0, the four-node pass marker, four distinct SPR
hosts with 104 ranks each, all preparation and solver `End` markers,
`Time = 150`, coded seconds/step, Cd in 0.27--0.30, and actual SU.
Compare only then with the two controlled GCC runs at 1.991194389 and
1.988625920 s/step (both Cd 0.291875949). Scientific result pending.

## First ICX scored result and same-build repeat

Job `181399707.gadi-pbs` completed with PBS `Exit_status=0`, 00:16:30
walltime and `ICX20253_OMPI5010_OF2512_SCOTCH_4N_PASS`. The four
Xeon Platinum 8470Q hosts `0514/0517/0532/0534` each hosted exactly
104 ranks. The original seven scientific input hash checks, all three
runtime archive checks, private `libmpi.so.40`, Scotch decomposition,
the full preparation chain and all five `End` markers passed. The solver
reached `Time = 150` and `Finalising parallel run`, with no fatal error.
The coded mean is **1.976664843872483 s/step**; final Cd is
**0.29187617440389690**, within 0.27--0.30. The 416-core, 990-second
charge computes to **228.80 SU**. NCI's post-job total displayed
1.12 KSU used, zero reserved, and 4.88 KSU available, rounded at KSU
precision. Evidence and full configuration are recorded in
`results/gadi-icx20253-ompi5010-scotch/run-registry.md`.

The first ICX time is about 0.666% faster than the 1.989910155 s/step
GCC two-run mean. Because that margin could be timing noise, a
same-build repeat was submitted with the identical reviewed script and
unique stdout. Command:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = 590081f76bbbc68fdda7cf5b9c4a64b668120988; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_scotch_v1_repeat1.pbs.out; /opt/pbs/default/bin/qsub -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_scotch_v1_repeat1.pbs.out builds/build-scripts/gadi-icx20253-ompi5010/run_baseline_4n_scotch_v1.pbs'
```

PBS returned **`181402435.gadi-pbs`**, initially Q in
`normalsr-exec`, with four nodes, 416 cores/ranks, and one-hour maximum.
The repeat's job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/baseline-4n-scotch/181402435.gadi-pbs/evidence/`.
It has not yet produced a scientific result.

## User-requested repeat cancellation

The user clarified that future repeat jobs require prior permission
and requested cancellation to avoid further SU. Read-only `qstat -f`
found `181402435.gadi-pbs` had already entered R, with 00:01:18
runtime at the first check. The authorized cancellation command was:

```sh
ssh -o BatchMode=yes gadi-comp 'qdel 181402435.gadi-pbs'
```

It returned success. Subsequent `qstat -xf` shows final state F,
`Exit_status=271`, and 00:02:04 walltime. No scientific result is
claimed for this cancelled job. At 416 allocated cores and 2
SU/core-hour, its runtime corresponds to about **28.66 SU**; the exact
posted charge is pending. Immediately after cancellation,
`nci_account -P pm78` still displayed 832 SU reserved and 1.12 KSU
used, reflecting accounting lag and rounded KSU display. A read-only
follow-up will confirm reservation release and record the actual SU.
Do not submit any further repeat job without explicit user permission.
