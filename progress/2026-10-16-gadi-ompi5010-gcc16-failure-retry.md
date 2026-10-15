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
