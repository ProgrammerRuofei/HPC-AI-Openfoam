# Gadi Open MPI 5.0.10 GCC 16 build failure and repaired retry — 2026-10-16 SGT

## Failure preserved

PBS `181344373.gadi-pbs` completed `F`, `Exit_status=2`, walltime 00:10:45,
11.47 SU. GCC/G++ 16.2.0 and UCX/UCC modules were loaded; the source and
GCC archive checksums passed. The first material compiler error was
`mca_part_persist_start: inlining failed in call to always_inline: --param
max-inline-insns-single limit reached` in
`ompi/mca/part/persist/part_persist.h`. The original output is retained at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010.pbs.out`; the job evidence is under
`.../evidence/181344373.gadi-pbs/build_ompi5010.log`. No Open MPI archive
was produced by this failed job.

## Evidence-backed fix

Open MPI's own [issue 13847](https://github.com/open-mpi/ompi/issues/13847)
records the same failure for v5.0.10 with GCC 16. Its
[upstream commit aa024ac](https://github.com/open-mpi/ompi/commit/aa024ac73d624611cfe3af6f541b5d28dedf07bb)
changes the one declaration from `__opal_attribute_always_inline__ static inline int`
to `static inline int`. The v2 build script applies exactly that one-line
change to the checksum-verified Open MPI source after unpacking in the new
job's `$PBS_JOBFS`, and fails closed if the expected original text is absent.
The original release archive and prior job evidence remain untouched. The
local source tarball was inspected to confirm the exact declaration.

The reviewed retry files are `builds/build-scripts/gadi-gcc162-ompi5010/
build_ompi5010_v2.sh` and `build_ompi5010_v2.pbs`. Both passed `bash -n`.
The PBS stdout has a distinct `build_ompi5010_v2.pbs.out` path; new evidence
and runtime archive paths include the new PBS job ID. This repair is limited
to MPI; the OpenFOAM scientific inputs are unchanged.

## Retry submission and next check

Commit `71dd3c4e2b3c6e1928e1c4930a8232be59a78564` was pushed to GitHub
and Gadi. The Gadi control checkout was fast-forwarded to that commit. Both
remote scripts passed `bash -n`, and their SHA-256 matched the local files:
`9ab00c071ae13f8201c9b03256c587f51a273ab1b40673b1bedb7b5c7b49db21`
for the shell script and
`8ac16999b46a31c89b22034e48f38774d7a04661077ef878e67862a9bfa3682b`
for PBS. Pre-existing untracked remote experiment files were preserved.

The exact submission was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010_v2.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010_v2.pbs'
```

`qsub` returned `181344546.gadi-pbs` once. Its first `qstat -f` showed `Q`,
32 CPUs and a 2-hour limit. `nci_account -P pm78` showed 49.90 SU used, 0
reserved and 5.95 KSU available; scratch inode usage was 195.28K/202K.
Check terminal PBS status and SU, MPI components, two-rank smoke, archive
SHA-256, and a separate fresh-job relocation test.

## Second failure and targeted v3 repair

The first patched retry, `181344546.gadi-pbs`, completed `F`,
`Exit_status=2`, walltime 00:10:39, and 11.36 SU. It passed the prior
`part/persist` failure and reached OpenSHMEM, where GCC 16 rejected
`mca_memheap_base_map = {{{{0}}}}` in
`oshmem/mca/memheap/base/memheap_base_frame.c:38` with
`braces around scalar initializer`. Original logs remain at
`submit-logs/build_ompi5010_v2.pbs.out` and
`evidence/181344546.gadi-pbs/build_ompi5010.log`; no archive was produced.

OpenSHMEM is not required by this OpenFOAM MPI workload. The v3 retry adds
only Open MPI's documented `--disable-oshmem` configure option, retaining
the upstream `part/persist` fix, UCX, UCC, PBS TM, GCC 16.2, and all
checksum gates. [Open MPI's configure documentation](https://docs.open-mpi.org/en/v5.0.5/installing-open-mpi/configure-cli-options/oshmem.html)
describes this option. The v3 PBS stdout path is unique, and eventual evidence
and archive names include the new job ID. The v2 files and logs remain intact.

## v3 submission

Commit `67bc71e903bd8db7d3cb9de8441f15ba21566a73` was pushed to GitHub
and Gadi. The Gadi control checkout fast-forwarded to it; both v3 scripts
passed remote `bash -n`, and the script SHA-256 matched local values
`b798890cacb36e9d3497f2d89b4dbf1a1c334a7a9ac560db63b03ea6d82c630e`
and `8ac7af7957d95f0d7c06cd86c7aff5ab4937f5e15b75663161383d88d833dfc7`.
Existing untracked remote experiment files were preserved. The exact command:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010_v3.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010_v3.pbs'
```

`qsub` returned `181345046.gadi-pbs` once; first status was `Q`, 32 CPUs,
2-hour walltime. `nci_account -P pm78` showed 61.26 SU used, 0 reserved,
5.94 KSU available, scratch inodes 195.30K/202K.

## Third failure and v4 acceptance repair

Job `181345046.gadi-pbs` completed `F`, `Exit_status=255`, after 00:11:33
and charged 12.32 SU. The compilation and installation completed; output
confirmed `mpirun (Open MPI) 5.0.10`, the GCC 16.2 wrapper, and both
`MCA pml: ucx` and `MCA coll: ucc`. The failure was the validation command
`prte_info --param ras tm`: PRRTE rejected the second argument `tm`. The
original output remains at `submit-logs/build_ompi5010_v3.pbs.out` and
`evidence/181345046.gadi-pbs/build_ompi5010.log`. This was a validation
script error after compilation, not an MPI build failure; the v3 script
created no archive because its archiving step followed the failed check.

The [Open MPI PBS/Torque guide](https://docs.open-mpi.org/en/v5.0.1/launching-apps/tm.html)
specifies `prte_info | grep ras` and the expected `MCA ras: tm` component.
The v4 retry changes the probe to plain `prte_info`, with an explicit
`MCA ras: tm` grep gate. It also archives the installed tree under the
unique new job ID before smoke checks, so a subsequent acceptance-script
error cannot discard a completed compilation. `OMPI5010_BUILD_ARCHIVE_PASS`
remains conditional on all gates, including the two-rank MPI smoke. Both
v4 scripts passed local `bash -n`; the v3 scripts and logs remain intact.

## v4 submission

Commit `1b3d22be4e8184ce59ea0842ed9d280e73096c5c` was pushed to GitHub
and Gadi. The Gadi control checkout fast-forwarded, both v4 scripts passed
remote `bash -n`, and SHA-256 matched local values
`331b8d79fb3de397ce6e953018bb91223fffaca946988180f5936e66a4d1a67d`
for the shell script and
`c0c83a293eda72df1743668e98a9c38921c2d206f77891d039e7a99419045eec`
for PBS. The exact submission was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_ompi5010_v4.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_ompi5010_v4.pbs'
```

`qsub` returned `181346004.gadi-pbs` once; initial status was `Q`, 32 CPUs,
2-hour walltime. `nci_account -P pm78` showed 73.58 SU used, 0 reserved,
5.93 KSU available and scratch inodes 195.33K/202K.

## Retained v4 archive and relocation test

Job `181346004.gadi-pbs` completed `F`, `Exit_status=1`, walltime 00:12:28,
13.30 SU. It built and installed Open MPI 5.0.10; `mpicc` used GCC 16.2,
`MCA pml: ucx` and `MCA coll: ucc` appeared, and `prte_info` showed both
`MCA ras: pbs` and `MCA plm: tm`. The v4 acceptance gate expected the older
`ras: tm` name, so it stopped before the two-rank smoke. Original logs remain
in `submit-logs/build_ompi5010_v4.pbs.out` and
`evidence/181346004.gadi-pbs/build_ompi5010.log`.

The retained archive is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/runtime-archive/openmpi-5.0.10.181346004.gadi-pbs.tar.gz`.
Its SHA-256 is
`8ac121e4f64eb329dc33cd2cc8229dc9f655064a757cbcaa36af962b21619fc6`;
`sha256sum -c` passed. The archive is a *build artifact pending runtime
acceptance*, not a validated best build. There is no reason to repeat the
completed compilation solely for the mislabeled PBS RAS gate.

The new `smoke_ompi5010_relocation_1n.pbs` script validates the retained
archive in a fresh `$PBS_JOBFS`: pinned GCC/MPI hashes, relocated compiler
wrappers, MPI 5.0.10, UCX/UCC, actual PBS RAS and TM launcher components,
relocated `libmpi` linkage, and a two-rank UCX program. It passed local
`bash -n`. A later two-node smoke remains necessary to verify cross-node
launch before the OpenFOAM baseline.

## One-node relocation submission

Commit `1b757fcf8f6e7a63c938083ef1b13ae32e06be90` was pushed to GitHub
and Gadi and the Gadi checkout fast-forwarded. The script passed local and
remote `bash -n`; SHA-256 was
`bed0de549c854ec7843cf4d7e0ee206a300fdd4b592af57c8f9708e35c6ed328`
on both. The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_ompi5010_relocation_1n.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_ompi5010_relocation_1n.pbs'
```

`qsub` returned `181346158.gadi-pbs` once. First status was `Q`, 4 CPUs,
20-minute limit. `nci_account -P pm78` showed 86.88 SU used, 0 reserved,
5.91 KSU available and scratch inodes 195.36K/202K.

## First relocation result and focused plugin diagnostic

Fresh-job relocation `181346158.gadi-pbs` completed `F`, `Exit_status=1`,
walltime 00:00:18, and 0.04 SU. Both pinned archives unpacked in the new
`$PBS_JOBFS`; GCC 16.2, `mpirun` 5.0.10, UCX, UCC, and `ras: pbs` were
observed. The acceptance gate stopped because `plm: tm` was absent from the
relocated `prte_info` output. No MPI application was launched by this job.
Original logs are retained under `submit-logs/smoke_ompi5010_relocation_1n.pbs.out`
and `evidence/181346158.gadi-pbs/`.

The retained archive contains `lib/prte/prte_mca_plm_tm.so`. A read-only
inspection of its `.la` metadata found a PBS library dependency and original
build-prefix references; this does not by itself identify the runtime failure.
The revised one-node diagnostic adds `ldd` for the TM plugin and PRRTE's
failed-component report before the same acceptance gate. It uses a distinct
PBS stdout path, new job-ID evidence, and the same pinned archives. The new
script passed `bash -n`. The goal is to determine whether a missing library
or another plugin-loading issue prevents TM from appearing; this is required
before a two-node launch.

## TM diagnostic submission

Commit `3e7bdafb20b5a94f37c8c45e2207ebb3e387a6f4` was pushed to GitHub
and Gadi, the control checkout fast-forwarded, remote `bash -n` passed, and
script SHA-256 matched local
`720e31c9ae717591d1bb964eb780e9ecbb486227f441f615fb0426a04c069b12`.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_ompi5010_relocation_1n_v2.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_ompi5010_relocation_1n_v2.pbs'
```

`qsub` returned `181346266.gadi-pbs` once; first status `Q`.
`nci_account -P pm78` showed 86.92 SU used, 0 reserved, 5.91 KSU
available and scratch inodes 195.39K/202K.

## Prefix-root cause and v3 relocation fix

Diagnostic `181346266.gadi-pbs` completed `F`, `Exit_status=213`, in
00:00:18 and 0.04 SU. The TM plugin's `ldd` showed `libpbs.so.0` from
`/opt/pbs/default/lib`, relocated `libprrte` and `libpmix`, and no missing
libraries. The diagnostic `prte_info --show-failed` option itself stopped
with an unregistered-option error; crucially, its error handler attempted
to load help files from the *original* build-job prefix
`/jobfs/181346004.gadi-pbs/ompi5010-build/install/openmpi-5.0.10`.
This identifies an incomplete relocation environment. The original stdout
and `evidence/181346266.gadi-pbs/plm-tm.ldd` are retained.

[Open MPI's relocation guidance](https://www.open-mpi.org/video/general/easybuild_tech_talks_01_OpenMPI_part3_20200805.pdf)
explicitly requires `OPAL_PREFIX`, `PMIX_PREFIX`, and `PRTE_PREFIX` together.
The first smoke set only `OPAL_PREFIX`. The v3 smoke sets all three to the
new job-local installation, retaining the same archive hashes, compiler,
module and component gates, and two-rank UCX program. It passed local
`bash -n` and uses a new PBS stdout/evidence path.

## Three-prefix relocation submission

Commit `39f39923d60df51e78e0d71af9690b0a985c8cb3` was pushed to GitHub
and Gadi and the checkout fast-forwarded. Local and remote `bash -n` passed;
script SHA-256 matched
`adb2d2b506921d817d637f1288a5f00632ad30e8f3d7908657b9b7f8cb066497`.
The exact submission command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_ompi5010_relocation_1n_v3.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_ompi5010_relocation_1n_v3.pbs'
```

`qsub` returned `181346315.gadi-pbs` once; initial status `Q`.
`nci_account -P pm78` showed 86.96 SU used, 0 reserved, 5.91 KSU
available and scratch inodes 195.42K/202K.

## One-node relocation passed; two-node transport gate prepared

Job `181346315.gadi-pbs` completed `F`, `Exit_status=0`, walltime
00:00:18, and 0.04 SU. `OMPI5010_RELOCATION_1N_PASS` appeared. In the new
`$PBS_JOBFS`, GCC/G++ 16.2.0 and `mpirun` 5.0.10 were confirmed; UCX/UCC,
`ras: pbs`, and `plm: tm` were present. `ldd` resolved the test executable's
`libmpi.so.40` from the relocated MPI tree with no missing libraries. Both
UCX-launched ranks printed their expected markers. The original evidence is
under `evidence/181346315.gadi-pbs/` and the PBS receipt is
`submit-logs/smoke_ompi5010_relocation_1n_v3.pbs.out`. The retained MPI
archive's SHA-256 remains
`8ac121e4f64eb329dc33cd2cc8229dc9f655064a757cbcaa36af962b21619fc6`.

The next gate uses two SPR nodes and 208 allocated cores but only two MPI
ranks. `stage_ompi5010_node.sh` verifies and unpacks both pinned archives
into each node's own `$PBS_JOBFS` through PBS `pbsdsh`; the PBS script then
checks two distinct node names, GCC/MPI versions, PBS RAS/TM components,
relocated `libmpi` linkage, and two UCX ranks on different hosts. It uses
unique job-ID evidence, a unique stdout path, and a 15-minute limit. Both
scripts passed `bash -n`. This checks the launch/transport needed before a
416-rank OpenFOAM run without spending on a full solver job.

## Two-node transport submission

Commit `aad648a1661ed174f8f60794897af32ed3ff83f2` was pushed to GitHub
and Gadi; the Gadi control checkout fast-forwarded. Both scripts passed
local and remote `bash -n` and matched local/remote SHA-256:
`1677d0156820e1127037c9b8659a067e14b00167edf8c78cb12710c6b974ebee`
for node staging and
`ea022d029a1a9857e8864f7c1bcf231a8dbb5e00927ddfd82896aab9b7b03b44`
for PBS. The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_ompi5010_relocation_2n.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_ompi5010_relocation_2n.pbs'
```

`qsub` returned `181346473.gadi-pbs` once; first status `Q`, 208 CPUs,
15-minute limit. `nci_account -P pm78` showed 87.00 SU used, 0 reserved,
5.91 KSU available and scratch inodes 195.44K/202K.

## Two-node staging evidence fix

Job `181346473.gadi-pbs` completed `F`, `Exit_status=1`, walltime
00:00:17, and 1.96 SU. PBS allocated two distinct SPR hosts
`gadi-cpu-spr-0427` and `0428`. `pbsdsh -n 0` verified both archive hashes
and completed staging on the first node, printing
`STAGE_OMPI5010_NODE_PASS` to the PBS output. The script then checked an
empty `tee` file and stopped before staging node 1 or launching MPI. The
issue was that `pbsdsh` wrote child stdout directly to PBS output instead
of the parent's pipe. Original stdout and
`evidence/181346473.gadi-pbs/` are retained.

The v2 node helper writes its own job-ID-specific marker in the shared
evidence directory. The v2 PBS script waits for that marker after each
`pbsdsh -n` call and verifies two distinct host names before MPI launch.
Archive pins, compiler/MPI checks, UCX transport test, and science scope
remain the same. Both v2 scripts passed local `bash -n` and use a new PBS
stdout path.

## Two-node v2 submission

Commit `50e25bb5e1fd6515437301358ddf627bfbc004b4` was pushed to GitHub
and Gadi and the Gadi checkout fast-forwarded. Both v2 scripts passed
local/remote `bash -n` and matched SHA-256
`9aba6a2adf727cc8e6d87fa8d76faaedff5ed57f1ca37742b564011534feb8ec`
for the node helper and
`51b35ba9be950c975e930cb622166b3e5fb052e65f1568bb41fa97b68d59fcf1`
for PBS. The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_ompi5010_relocation_2n_v2.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_ompi5010_relocation_2n_v2.pbs'
```

`qsub` returned `181346532.gadi-pbs` once; first status `Q`, 208 CPUs,
15-minute limit. `nci_account -P pm78` showed 88.97 SU used, 0 reserved,
5.91 KSU available and scratch inodes 195.47K/202K.

## Two-node v2 failure and corrected task index

Job `181346532.gadi-pbs` completed `F`, `Exit_status=1`, walltime
00:00:20, and 2.31 SU. PBS allocated distinct SPR hosts
`gadi-cpu-spr-0641` and `0647`. The first stage marker records a
successful unpack on `0641`; no marker for the other host and no MPI
smoke exist. The original stdout and `evidence/181346532.gadi-pbs/`
remain untouched. `pbsdsh -n 1` addressed the second task slot on the
first 104-core node, where the unique `$PBS_JOBFS` tree already existed;
the helper's no-overwrite gate correctly exited 1. This is a task-index
error, not an MPI transport result.

The v3 script targets task indices 0 and 104, checks that `PBS_NODEFILE`
lines 1 and 105 name different hosts, and requires each direct marker to
match its expected host. The archive pins and all MPI/UCX gates remain
unchanged. `bash -n` passed; v3 uses a new stdout path and job-ID evidence.

## Two-node v3 submission

Commit `d78db9c` was pushed to GitHub and Gadi. The Gadi checkout
fast-forwarded; local and remote `bash -n` passed and the v3 script
SHA-256 matched on both hosts:
`baf43c532d2a352962c0d4921f4f27ee4bb406045d9047d5f25a38caa4a8737b`.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_ompi5010_relocation_2n_v3.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_ompi5010_relocation_2n_v3.pbs'
```

`qsub` returned `181350909.gadi-pbs` once; first status `Q`, 208 CPUs,
15-minute limit. `nci_account -P pm78` showed 91.28 SU used, 0 reserved,
5.91 KSU available and scratch inodes 195.50K/202K.

## Two-node Open MPI acceptance

Job `181350909.gadi-pbs` completed `F`, `Exit_status=0`, walltime
00:00:36, and 4.16 SU. It passed `OMPI5010_RELOCATION_2N_PASS`.
Each SPR host independently verified and unpacked the pinned GCC and Open MPI
archives into its own new `$PBS_JOBFS`: `gadi-cpu-spr-0505` and `0506`.
The two UCX MPI ranks printed `OMPI5010_CROSS_NODE` on these distinct
hosts. `ldd` resolved `libmpi.so.40` from the relocated Open MPI 5.0.10
tree, with no missing libraries; `prte_info` showed `ras: pbs` and
`plm: tm`. The raw files are under `evidence/181350909.gadi-pbs/` and
`submit-logs/smoke_ompi5010_relocation_2n_v3.pbs.out`. The benign UCX
warnings concern unused module environment variables; both ranks exited
normally. Stage 1 is accepted; next is an OpenFOAM v2512 build with this
verified GCC/MPI archive pair.

## OpenFOAM build preparation

Prepared `build_openfoam_v2512.pbs` and its wrapper for a single SPR node
on `normalsr`: 48 CPUs, 190 GB memory, 100 GB JOBFS, four-hour cap. The
existing common helper gained conditional private GCC/MPI prefix support;
its old site-MPI path is unchanged. The wrapper pins and verifies the
accepted GCC 16.2 and Open MPI 5.0.10 archive hashes, then builds
OpenFOAM v2512 with `WM_COMPILER=Gcc`, `WM_MPLIB=SYSTEMOPENMPI`, stock
`WM_COMPILE_OPTION=Opt`, UCX 1.18.1, and UCC 1.4.4. The helper verifies
`OPENFOAM_SOURCE_ID_V2`, real `simpleFoam` linkage, and a complete
SHA-256-verified runtime archive. No scientific workload input or solver
source is changed. Script review and local syntax checks precede Git sync
and submission; no OpenFOAM build job ID exists yet.

## OpenFOAM v2512 build submission

Commit `0427f02129e697365419c19633f713107da1e896` was pushed to GitHub
and Gadi. The remote control checkout fast-forwarded; all three scripts
passed local and remote `bash -n`, and local/remote SHA-256 matched:
`9fb4b73e39bbac9a070c4b6d8e6e7a0a31c2fff5d51484bf60cd3e87053ce312`
(common helper),
`ffed6f4d16e5bf3e12770a505a3df15ab21da106cf7916dc53986627009baf2b`
(PBS), and
`d6bc69824475b6f18b11d1a506c7b5d47d4acc2e45cd3ec1813afbf8410f3823`
(wrapper). Pre-existing untracked Gadi experiment files were left untouched.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_openfoam_v2512.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_openfoam_v2512.pbs'
```

`qsub` returned `181351226.gadi-pbs` once; initial status `Q`, 48 CPUs,
190 GB memory, 100 GB JOBFS, four-hour limit. `nci_account -P pm78`
showed 95.44 SU used, 0 reserved, 5.90 KSU available and scratch inodes
195.53K/202K. Await build completion, validate `Exit_status=0`,
`BUILD_VALIDATION_PASS`, source identity, GCC/MPI versions, `simpleFoam`
linkage, runtime archive/hash and SU; then run a fresh-job smoke before
four-node work.

## First OpenFOAM build result and runtime probe

Job `181351226.gadi-pbs` finished `F`, `Exit_status=0`, walltime
00:56:38, 90.61 SU, peak memory 161.86 GB, JOBFS 6.28 GB. It matched
both authoritative and staged `OPENFOAM_SOURCE_ID_V2`
`5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`,
built `linux64GccDPInt32Opt` with actual `-O3`, and produced a
`simpleFoam` binary with SHA-256
`81e33ca312323d87cef5852c07ba98bec24775fe4cb9a44681da64fcb4776154`.
`ldd` resolved its `libmpi.so.40` to the private Open MPI 5.0.10 tree.
The full runtime archive and `.sha256` are at
`toolchain-screening/gadi-gcc162-ompi5010-of2512/runtime-archive/`;
archive SHA-256 is
`3ee887a1ade68784a4b84343aba3aef8158e126aa8765257269ec1360e98906a`,
and `sha256sum -c` passed. `BUILD_VALIDATION_PASS` appeared.

The same build log reports ThirdParty Scotch C compilation errors (the
first is incompatible function-pointer prototypes in `module.h` with GCC
16) and ADIOS2's bundled yaml-cpp missing `uint16_t`/`uint32_t` types.
`ThirdParty-v2512/Allwmake` treats these components as optional and
returned success, so the PBS exit code alone does **not** certify Scotch.
Original raw log and PBS receipt are retained. A fresh-job 5-rank
`pitzDaily_fused` tutorial smoke will test the exact archived runtime,
`decomposePar` with Scotch, MPI launch, coded wall-clock functionObject,
and solver completion. This tutorial check has `official_result=false`
and does not alter the fixed 65M case. Its script pins archive, binary,
and functionObject hashes; it passed local `bash -n`. A Scotch failure
will trigger a targeted build repair before any four-node run.

## Fresh-job Scotch/tutorial smoke submission

Commit `aba8100eaebe3b73dc59c06238923df285b7edd7` was pushed to GitHub
and Gadi, the remote checkout fast-forwarded, `bash -n` passed on both
hosts, and script SHA-256 matched:
`e722b465b8936ff5008ee678c6b110128ec35a044ed64cb8a02cafd26fccd09f`.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_openfoam_v2512.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_openfoam_v2512.pbs'
```

`qsub` returned `181358016.gadi-pbs` once; initial status `Q`, 5 CPUs,
20-minute cap. Account usage was 186.05 SU, 0 reserved, 5.81 KSU
available; scratch inodes 195.57K/202K. Await Scotch decomposition,
private MPI runtime, coded functionObject, solver completion, PBS status,
and SU receipt before classifying this archive.

## Tutorial smoke hash transcription failure

Job `181358016.gadi-pbs` finished `F`, `Exit_status=1`, walltime 3 s,
0.01 SU. The GCC, MPI, and OpenFOAM archive hashes passed, then
`sha256sum -c` rejected the functionObject checksum line as malformed.
The first error was a shortened 58-character `FO_SHA` constant in the
local PBS script, not a software or Scotch error. It failed before JOBFS
staging, decomposition, or solver launch; the original PBS stdout remains
at `submit-logs/smoke_openfoam_v2512.pbs.out`. The v2 script restores the
confirmed full 64-hex SHA-256
`0a0e5d072527bc1e67e5bc505da30bec0abebc67262aa47ecaece4d13b2ece08`,
uses a new PBS stdout path, and passed `bash -n` and five-hash length checks.
All other runtime and tutorial gates are unchanged.

## Corrected tutorial smoke submission

Commit `68e0c28f936a745c9ee78a4c691ce4e4bfaae650` was pushed to GitHub
and Gadi; the remote checkout fast-forwarded. Local and remote `bash -n`
passed, and script SHA-256 matched:
`ce68a93b8c2d42c3ba8196b7b9f6d1f232c9578bdcd5a094d5867f859a8bc0d1`.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_openfoam_v2512_v2.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_openfoam_v2512_v2.pbs'
```

`qsub` returned `181358755.gadi-pbs` once; initial status `Q`, 5 CPUs,
20-minute cap. Account usage was 186.06 SU, 0 reserved, 5.81 KSU
available; scratch inodes 195.59K/202K.

## Tutorial smoke v2 environment-order failure

Job `181358755.gadi-pbs` finished `F`, `Exit_status=1`, walltime 38 s,
0.11 SU. All four input SHA-256 checks passed; the runtime and binary
unpacked, and the binary checksum passed. The script called `ldd` before
sourcing the archived OpenFOAM `etc/bashrc`, so its library search path
lacked `libfiniteVolume.so`, `libOpenFOAM.so`, `libPstream.so`, and peers.
The first failing gate was `! grep 'not found' simpleFoam.ldd`; no
`decomposePar` or solver ran. Original evidence remains under
`evidence/smoke.181358755.gadi-pbs/` and the v2 PBS stdout is retained.
The v3 script sources the exact archived runtime first, checks
`WM_PROJECT_DIR`, then evaluates `ldd`; it uses new stdout/evidence paths
and passed `bash -n`. No source, science input, or archive changes.

## Tutorial smoke v3 submission

Commit `635d9b80abdb259cf2d9bae27e66e8a554ffc992` was pushed to GitHub
and Gadi; the remote checkout fast-forwarded. Both `bash -n` checks
passed, and the v3 script SHA-256 matched:
`8423b7b826364cf36bc10ce3c324f45b2c077ce47c9a52549b9fa393b72f8f5a`.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_openfoam_v2512_v3.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_openfoam_v2512_v3.pbs'
```

`qsub` returned `181359431.gadi-pbs` once; initial status `Q`, 5 CPUs,
20-minute cap. Account usage was 186.16 SU, 0 reserved, 5.81 KSU
available; scratch inodes 195.61K/202K.

## Scotch failure in fresh-job v3 smoke and isolated rebuild

The v3 tutorial smoke `181359431.gadi-pbs` finished with PBS `Exit_status=1`,
43 seconds and **0.12 SU**. GCC/MPI/OpenFOAM archive hashes and the
`simpleFoam` private MPI link passed; `blockMesh` ran. The first actual
application error is in
`toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/smoke.181359431.gadi-pbs/decomposePar.log`:
`Attempted to use <scotch> without the scotchDecomp library loaded`, followed
by the dummy Scotch stub. No solver or four-node case ran. Its PBS stdout,
run log, decomposition log and exit status are retained.

The original build log at
`evidence/gadi-gcc162-ompi5010-of2512.181351226.gadi-pbs/build.log`
shows Scotch 6.1.0 failing in `module.h` while GCC 16.2 compiles `arch.c`:
an unprototyped function-pointer declaration is interpreted under GCC's
new C23 default and rejected as an incompatible pointer type. A new build
job will first verify the authoritative `OPENFOAM_SOURCE_ID_V2`, then change
only its copied `ThirdParty-v2512/etc/makeFiles/scotch/Makefile.inc.Linux.shlib`
in JOBFS by appending `CFLAGS += -std=gnu17`. The source under `/apps` and
scientific case are unchanged. The job now gates on real `libscotch.so` and
`libscotchDecomp.so` before archiving. The independent ADIOS2 failure is
outside the fixed solver/decomposition workload and remains documented.
The retry uses `build_openfoam_v2512_scotch_v2.pbs` with a unique PBS stdout
path and job-ID-keyed evidence and archive paths. A new fresh-job Scotch
smoke is required before the four-node baseline.

## Corrected Scotch build submission

The repair was reviewed with `git diff`, `git diff --check`, and `bash -n`.
Commit `a1df21ee79079da83e412ab23a68aa1bb887fa8f` was pushed to GitHub
and the Gadi remote; the Gadi checkout fast-forwarded. Local and remote
SHA-256 values matched for the PBS file
(`8d1a56bb47571d351f35f689f303dc13c4830751bb6c617ee3687df94565d23b`),
wrapper (`0067beca4877ff2ec9115f2eeb710aa25673c0ef822ea3023217c63758ba10be`),
and common builder (`dd41e1b2858de9c085f41717748302e6ccfa7e364a89533a7b5bf2d73c117588`).
Before submission `nci_account -P pm78` showed 186.28 SU used,
5.81 KSU available, 229 GiB scratch and 195.63K/202K scratch inodes.
The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_openfoam_v2512_scotch_v2.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/build_openfoam_v2512_scotch_v2.pbs'
```

`qsub` returned **`181360543.gadi-pbs` once**. This is a 48-CPU,
190-GB, 100-GB JOBFS, four-hour-cap normalsr build. Its distinct PBS stdout
is `toolchain-screening/gadi-gcc162-ompi5010/submit-logs/build_openfoam_v2512_scotch_v2.pbs.out`;
build evidence and runtime archive will have the new job ID. Acceptance
requires PBS `Exit_status=0`, `SCOTCH_BUILD_PASS`, `BUILD_VALIDATION_PASS`,
GCC/MPI/source identity and private MPI link checks, a verified archive, and
a later fresh-job Scotch tutorial smoke.

## Corrected Scotch build result and v4 smoke preparation

Job `181360543.gadi-pbs` completed with PBS `Exit_status=0`, walltime
00:55:57, **89.52 SU**, peak memory 142.1 GB and JOBFS 6.28 GB. Both
`SCOTCH_BUILD_PASS` and `BUILD_VALIDATION_PASS` appear in its build log.
The authoritative and staged `OPENFOAM_SOURCE_ID_V2` equal
`5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`;
GCC/G++ 16.2.0 and Open MPI 5.0.10 passed version gates; the
`simpleFoam` link resolves `libmpi.so.40` from this job's private MPI.
The real Scotch and scotchDecomp libraries passed explicit file gates.
The new full runtime archive is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/runtime-archive/gadi-gcc162-ompi5010-of2512.181360543.gadi-pbs.tar.gz`,
SHA-256 `64cd075a385938f0c9ac0c478066349e5bb198f5fa8cd80cc3ed61fb12286281`;
its `.sha256` file exists and `sha256sum -c` passed. `simpleFoam` SHA-256
is `b3b992619ea5b9805fe1c549d2dafafe6cba88411bd152f7b1eb50081fc867c5`.
ADIOS2's optional yaml-cpp compile error is still present; no ADIOS2
component is used in this smoke or the prescribed simpleFoam case.

`smoke_openfoam_v2512_v4.pbs` pins this new archive and binary. It reuses
the validated v3 environment order and retains GCC/MPI/functionObject
hashes, five-rank tutorial copy, Scotch decomposition, private MPI
launch, coded timing function and End checks. It has a distinct PBS stdout
and job-ID-keyed evidence; the fixed 65M case is untouched. Pass is required
before this build can be a four-node baseline candidate.

## Corrected build v4 tutorial smoke submission

Commit `509d30776e80e39848b21983096603e98dd2ba86` was pushed to GitHub
and Gadi; the remote control checkout fast-forwarded. Local and remote
SHA-256 of `smoke_openfoam_v2512_v4.pbs` matched
`289b641e35691ae378e40743ac56e14a09f84ee043f67512b9a51f1284fd3f47`.
Both local and Gadi `bash -n` checks passed. Before submission the project
showed 275.80 SU used and 5.72 KSU available. The exact scheduler command:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_openfoam_v2512_v4.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_openfoam_v2512_v4.pbs'
```

`qsub` returned **`181366491.gadi-pbs` once**, 5 CPUs and a 20-minute cap.
Acceptance requires PBS `Exit_status=0`,
`OF2512_GCC162_OMPI5010_SMOKE_PASS`, verified archive/binary hashes,
actual Scotch decomposition, five-rank private-MPI `simpleFoam` completion,
coded timing marker, and SU receipt. This tutorial job is not a scored
65M-case result.

## Corrected v4 smoke result and four-node storage design

The v4 tutorial smoke `181366491.gadi-pbs` completed with PBS
`Exit_status=0`, walltime 51 seconds, and **0.14 SU**. Its archive and binary
hashes passed. `decomposePar.log` shows `Decomposition method scotch [5]`,
`Finished decomposition`, and `End`; `simpleFoam.ldd` resolves the private
Open MPI 5.0.10 library. The five-rank solver log shows the coded average
wall-clock metric, `End`, and `Finalising parallel run`.
`OF2512_GCC162_OMPI5010_SMOKE_PASS` and `pbs_exit_status=0` are retained
under `evidence/smoke.181366491.gadi-pbs/`. This validates the repaired
Scotch build in a fresh job. It remains a tutorial, not the scored result.

The official Gadi SPR baseline `178149002.gadi-pbs` used four 104-core
Sapphire Rapids nodes, 416 ranks, the full preparation chain, 150 steps,
2.139565 s/step and Cd 0.28231 with hierarchical `(16 13 2)`.
The authoritative case hashes still match those in
`experiments/gadi-4n-decomp/run_baseline_16x13x2.pbs`; the fixed mesh,
`fvSchemes`, and `fvSolution.fixedIter` will be copied without alteration.
Only `nCores=416` and `decompositionMethod=scotch` are changed in the copied
`caseDefinition`. The code/solver source is pinned by the accepted build.

Scratch reports about 195.69K of 202K allocated inodes, while the prior
four-node uncollated case contains 8,818 files. The new four-node script
keeps processor directories in each SPR node's JOBFS and presents them
through 416 symlinks in a shared scratch case. It stages four tar archives
of decomposed initial processor data (one tar per 104-rank node), and keeps
the shared dictionaries, coded functionObject output, logs and Cd on
scratch. The script validates rank-to-host placement, four distinct SPR
nodes, pinned archives, source hashes, copied mesh bytes, full chain,
150 steps, coded timing and Cd. A small symlink-layout smoke will check
the novel file layout before this four-node job is submitted.

## JOBFS symlink-layout smoke submission

The v5 script passed local and remote `bash -n`; commit
`9438594bae295718b37da0d06b8a76fb684a358b` was pushed to GitHub and
Gadi, and the remote checkout fast-forwarded. Local/remote script SHA-256
matched `6e2f8b60f668b0d3933c144ae7be3a166d4a0e537523e01fc69639b23f9b5bb0`.
`nci_account -P pm78` showed 275.95 SU used, 5.72 KSU available and
195.69K/202K scratch inodes. The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_openfoam_v2512_v5.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/smoke_openfoam_v2512_v5.pbs'
```

`qsub` returned **`181368402.gadi-pbs` once**, 5 CPUs, 20-minute cap.
It is a tutorial-only validation of a shared scratch case resolving its
processor directories through symlinks to local JOBFS. The original
scientific 65M case is not changed or run. Four-node submission waits for
this layout test to pass or for its documented repair.

## JOBFS symlink-layout smoke result and four-node readiness

Job `181368402.gadi-pbs` finished with PBS `Exit_status=0` in 49 seconds,
about **0.13 SU** (5 CPUs on normalsr at 2 SU/core-hour). Its independent
evidence includes `pbs_exit_status=0` and
`OF2512_GCC162_JOBFS_SYMLINK_SMOKE_PASS`. Scotch decomposition ended
successfully, the five-rank private-MPI solver emitted the coded timing
metric and `End`, and `simpleFoam.ldd` resolved `libmpi.so.40` in the
job's private Open MPI. The job used a scratch case with five processor
symlinks into node-local JOBFS, validating the layout on one node only.

The planned four-node job pins the accepted GCC, MPI, and OpenFOAM archives,
verifies authoritative input hashes, changes only the copied case's rank
count and decomposition method, and gates four 104-rank node mappings before
the full chain. Each node receives its own processor data in JOBFS; only
shared dictionaries, 416 symlinks, stage tar files, logs, and Cd evidence
use scratch. This avoids the approximately 8,818 scratch files of the older
uncollated baseline when only about 6.3K project inodes are available.
The cross-node form still requires the actual four-node job to validate it.

## Four-node Scotch baseline submission

The three four-node scripts passed local and Gadi `bash -n`; the relevant
local diff was reviewed and `git diff --check` passed. Commit `a96c8ae`
was pushed to GitHub and Gadi, and the Gadi checkout fast-forwarded.
Local and remote SHA-256 values match for the PBS script
(`fdb212365043d8a2315d7e17b1b72a615dfea97d432d39b2cbbca2a40226f8ac`),
runtime helper (`4214cdc59bf18176701b3c1e40570c179afaf04a584acc3381b00623ad8c131f`),
and processor helper (`2caa257b7ede430a638b97eed8a2b88e91f4b019cd9a828e0bcb05b1f9a2fa2e`).
Before submission pm78 had 276.08 SU used, 5.72 KSU available, and
195.71K/202K scratch inodes. The exact scheduler command was:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_scotch_v1.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_scotch_v1.pbs'
```

`qsub` returned **`181368883.gadi-pbs` once**. Initial PBS state was Q on
`normalsr-exec`, with four nodes, 104 CPUs/node, 416 MPI ranks, 760 GB total
memory, 100 GB JOBFS and a one-hour cap (832 SU at the full walltime).
The distinct PBS stdout is
`toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_scotch_v1.pbs.out`;
job-ID-keyed evidence will be under
`toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-scotch/181368883.gadi-pbs/evidence/`.
Acceptance requires PBS `Exit_status=0`, the script pass marker, 150 steps,
Cd in band, a coded step time, correct 416-rank host map and full preparation
logs. The result has not yet been measured.

## First four-node Scotch baseline result

Job `181368883.gadi-pbs` finished with PBS `Exit_status=0`, walltime
00:16:19, `GCC162_OMPI5010_OF2512_SCOTCH_4N_PASS`, and script exit 0.
The four SPR nodes were `gadi-cpu-spr-0080/0081/0083/0084`, each with
104 MPI ranks. Scotch decomposition completed in 213.94 seconds. All
four preparation logs ended normally; `simpleFoam` reached `Time = 150`,
emitted `End` and `Finalising parallel run`. The coded average wall-clock
time was **1.991194389201344 s/step**; final Cd was
**0.29187594927465327**, inside the 0.27–0.30 gate. PBS peak memory was
315,117,540 KB and JOBFS 50,641,586 KB. The initial SU estimate from
allocated cores and measured walltime is **226.26 SU**; `nci_account`
still held the full 832 SU reservation immediately after PBS completed,
so the posted charge needs a later check.

The older site-module hierarchical four-node baseline measured
2.139565188 s/step, Cd 0.2823068404. The new combined GCC/MPI/Scotch
stack is about 6.93% faster per step, with Cd 0.00957 higher but still
within the declared acceptance band. The difference cannot be attributed
to one build or decomposition setting from this comparison alone. A repeat
with the same new stack is warranted to check stability. Detailed results
are in `results/gadi-gcc162-ompi5010-scotch/run-registry.md`.

## Same-build four-node repeat submission

Commit `6b0822d` records the first result in GitHub and Gadi. The Gadi
checkout fast-forwarded, and the unchanged four-node PBS script retained
SHA-256 `fdb212365043d8a2315d7e17b1b72a615dfea97d432d39b2cbbca2a40226f8ac`.
Its syntax passed again. NCI had not yet posted the first job's charge and
still showed the 832 SU reservation; 4.89 KSU remained available.
The same script was submitted once with a distinct PBS stdout:

```sh
ssh -o BatchMode=yes gadi-comp 'test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_scotch_v1_repeat1.pbs.out && cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_scotch_v1_repeat1.pbs.out builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_scotch_v1.pbs'
```

`qsub` returned **`181371071.gadi-pbs`**. Initial PBS state was Q;
the request is four nodes, 416 CPUs and one-hour maximum. This is a
repeatability run with the same build and Scotch setting, not a new
optimisation decision. Its evidence directory is job-ID-keyed under
`baseline-4n-scotch/181371071.gadi-pbs/evidence/`.

NCI subsequently posted the first job's **226.26 SU** charge: pm78 usage
rose from 276.08 to 502.34 SU, matching the walltime-based estimate.
The earlier 832 SU reservation was released; 5.50 KSU remained available
while the repeat queued.
