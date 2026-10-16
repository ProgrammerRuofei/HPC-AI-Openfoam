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
