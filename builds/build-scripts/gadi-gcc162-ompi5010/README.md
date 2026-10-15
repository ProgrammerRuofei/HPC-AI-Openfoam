# Gadi SPR GCC 16.2 / Open MPI 5.0.10 candidate

Status: **GCC 16.2 and Open MPI 5.0.10 passed two-node UCX transport; OpenFOAM v2512 links correctly, but Scotch requires a corrected build.** See
`progress/2026-10-16-gadi-gcc162-relocation-ompi-submitted.md` for job IDs,
evidence, and the exact scope of each stage.

This candidate targets `normalsr` (Sapphire Rapids, 104 physical cores/node).
The first build stage produced a private GCC 16.2.0 archive. Open MPI 5.0.10,
OpenFOAM v2512, MPI runtime relocation, and the 416-rank Scotch benchmark
remain separate reviewed stages; no existing binary is called the team's best
build.

## Stage 1: GCC 16.2.0

- Source input: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz`.
- Official source SHA-512: `c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1`.
- Bootstrap compiler: Gadi module `gcc/15.1.0`; build only C and C++ with
  `--disable-bootstrap --disable-multilib --disable-nls`.
- PBS: one `normalsr` node, 104 CPUs, 400 GB RAM, 150 GB jobfs, six-hour limit.
- Build and install inside `$PBS_JOBFS`; retain a single tar archive in scratch
  to avoid exhausting the project's inode quota.
- Build `181342083.gadi-pbs` finished with `Exit_status=0`, GCC/G++ 16.2.0,
  `GCC162_BUILD_ARCHIVE_PASS`, and a verified SHA-256 archive. It used 38.42 SU.
- Relocation job `181344224.gadi-pbs` finished with `Exit_status=0` in a new
  `$PBS_JOBFS`: C and C++17 compile/run passed, and `ldd` resolved
  `libstdc++.so.6` from the relocated GCC prefix. It used 0.02 SU. An initial
  hash transcription failure, `181344115.gadi-pbs`, is retained as evidence.

The two upstream source archives have been downloaded locally to
`/private/tmp/gadi-toolchain-sources/` and verified against publisher hashes:

| Archive | Publisher hash | Local verification |
| --- | --- | --- |
| `gcc-16.2.0.tar.xz` | SHA-512 `c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1` | PASS |
| `openmpi-5.0.10.tar.gz` | SHA-256 `5692cc80554a7117c99eaa725d35100edd8bbf73423a5e265ff867979192df7d` | PASS |

The current `pm78` scratch allocation has 195.21K of 202K inodes used. Do not
unpack GCC or Open MPI installations onto scratch. The retained archive is
immutable and a repeated attempt must use a new job-specific filename.

## Remaining gates

1. Run and verify the upstream-patched Open MPI build retry: `Exit_status=0`,
   UCX 1.18.1, UCC 1.4.4, PBS TM, two-rank MPI smoke, archive/hash and SU.
2. Validate the Open MPI archive after relocation in a separate PBS job.
3. Build OpenFOAM v2512 against that exact MPI and verify `ldd`/wrapper paths.
4. Before the full 4-node/416-rank/150-step Scotch run, compare its script
   against the current build instructions and successful Gadi runs. Validate
   Cd and repeatability before labelling the candidate the team's best build.

No previous hierarchical benchmark is scheduled for repetition. The team's
valid site-build result `178149002.gadi-pbs` (2.139565 s/step) is the initial
absolute reference, with the caveat that the first candidate changes several
factors at once.

## Open MPI 5.0.10 GCC 16 build failure and repair

Build `181344373.gadi-pbs` finished with `Exit_status=2` after 10:45 and
charged 11.47 SU. The first relevant compiler error was
`mca_part_persist_start: inlining failed ... max-inline-insns-single limit reached`
in `ompi/mca/part/persist/part_persist.h`. The original output remains in
`submit-logs/build_ompi5010.pbs.out` and
`evidence/181344373.gadi-pbs/build_ompi5010.log`. This exact GCC 16 /
Open MPI 5.0.10 failure is tracked upstream in
[open-mpi/ompi#13847](https://github.com/open-mpi/ompi/issues/13847).
The retry script applies the one-line upstream fix from
[commit aa024ac](https://github.com/open-mpi/ompi/commit/aa024ac73d624611cfe3af6f541b5d28dedf07bb)
to a checksum-verified source copy within the new job's `$PBS_JOBFS`; it
removes `__opal_attribute_always_inline__` only from `mca_part_persist_start`.
This changes Open MPI's build input, not OpenFOAM or its scientific workload.
The retry has a distinct PBS stdout path; evidence and archives are named by
new job ID.

Build `181344546.gadi-pbs` used 11.36 SU and passed the first fix, then
failed in unused OpenSHMEM initialization. The v3 script adds
`--disable-oshmem` per Open MPI documentation. See the progress record for
the first error, preserved logs, and job IDs.

Build `181345046.gadi-pbs` used 12.32 SU. The install and version/UCX/UCC
checks passed; the `prte_info --param ras tm` command was invalid. The v4
script uses the documented plain `prte_info` probe and retains an archive
before acceptance smoke tests. See the progress record.

Build `181346004.gadi-pbs` used 13.30 SU and retained a SHA-256-verified
Open MPI archive. The installed PRRTE reported `ras: pbs` and `plm: tm`;
the script's obsolete `ras: tm` expectation caused `Exit_status=1` before
the MPI smoke. The archive requires fresh-job and cross-node validation.

Relocation job `181346158.gadi-pbs` cost 0.04 SU. The archive and version
checks passed, but `plm: tm` was absent after relocation. The archived
plugin exists; the v2 diagnostic checks its dynamic dependencies and PRRTE
failed-component report before any cross-node job.

The diagnostic cost 0.04 SU. Its plugin `ldd` resolved all libraries, while
PRRTE/PMIx error output still referenced the old build-job prefix. The
next smoke sets `OPAL_PREFIX`, `PMIX_PREFIX`, and `PRTE_PREFIX` together.

Job `181346315.gadi-pbs` passed in 18 s / 0.04 SU, including GCC/MPI
versions, UCX/UCC, PBS RAS/TM, relocated `libmpi`, and both local ranks.
The two-node smoke next checks PBS launch and UCX transport between distinct
SPR hosts before building the OpenFOAM candidate.

Job `181346473.gadi-pbs` used 1.96 SU and stopped after staging the first
node because `pbsdsh` output bypassed the parent's `tee`. The v2 scripts
write and verify unique per-node marker files before MPI launch.

Job `181346532.gadi-pbs` used 2.31 SU and again stopped before MPI.
`pbsdsh -n 1` selects the second task slot on the first node, not the
second node, so the no-overwrite gate rejected duplicate staging. The
v3 PBS script uses slots 0 and 104 and verifies host mapping against
`PBS_NODEFILE` before launch. Original evidence is retained.

Job `181350909.gadi-pbs` passed (`Exit_status=0`, 36 s, 4.16 SU): both
SPR nodes staged pinned archives, PBS RAS/TM components were present,
`libmpi.so.40` resolved from the relocated runtime, and two UCX MPI ranks
ran on distinct hosts. `OMPI5010_RELOCATION_2N_PASS` marks this stack ready
for the OpenFOAM v2512 build. See the progress record and retained raw logs.

## Stage 2: OpenFOAM v2512 build candidate

`build_openfoam_v2512.pbs` uses a Gadi `normalsr` SPR node with 48 CPUs,
190 GB memory, 100 GB JOBFS, and a four-hour limit. This bounds the
worst-case queue charge at about 384 SU at 2 SU per core-hour; the prior
C1 OpenFOAM build completed in 1:26:52 and used 97.5 GB memory and 5.01 GB
JOBFS, but its timing is not a prediction for GCC 16. The exact GCC/MPI
archives are SHA-256 checked and unpacked only into this job's JOBFS.

The shared build helper retains its previous site-Open-MPI behavior when
private-prefix variables are unset. For this candidate it exports the
three relocation prefixes, uses the archived GCC wrappers, checks
`simpleFoam` against relocated `libmpi.so.40`, and packages a full
OpenFOAM/ThirdParty runtime (including `META-INFO` and source needed for
codeStream) with a verified SHA-256. It verifies authoritative and staged
`OPENFOAM_SOURCE_ID_V2` before build and does not change mesh or solver
source. The initial GCC candidate uses stock `WM_COMPILE_OPTION=Opt`
(`-O3`) and no additional vector-width flags. A fresh-job run check is
required before a four-node benchmark.

The first OpenFOAM build `181351226.gadi-pbs` exited 0 in 56:38 for
90.61 SU and produced a verified full runtime archive with the private
MPI-linked `simpleFoam`. ThirdParty's optional Scotch and ADIOS2 builds
reported errors despite `Allwmake` returning success. A fresh-job
`pitzDaily_fused` smoke with Scotch decomposition is required before this
archive can be considered a four-node candidate. The tutorial smoke is
not an official competition result and preserves the 65M case untouched.

The fresh-job smoke `181359431.gadi-pbs` (0.12 SU) confirmed that Scotch
decomposition reaches only the dummy stub. The original build's Scotch 6.1.0
compile fails under GCC 16's C23 default. `build_openfoam_v2512_scotch_v2.pbs`
uses `-std=gnu17` for the copied Scotch makefile in JOBFS, requires real
Scotch and scotchDecomp libraries, and writes a new job-ID-keyed archive.
The original archive and smoke evidence remain available. The corrected
archive still needs a fresh-job tutorial smoke before any four-node run.

Tutorial smoke `181358016.gadi-pbs` used 0.01 SU and stopped before
unpacking because its functionObject SHA-256 literal was truncated. It
is not a Scotch result. The v2 script pins the full verified hash and
uses new stdout/evidence paths; the original failure output is retained.

Tutorial smoke v2 `181358755.gadi-pbs` used 0.11 SU. It passed all
archive and binary hashes but ran `ldd` before sourcing the runtime's
`etc/bashrc`, so OpenFOAM libraries were unresolved. This is a probe
ordering error, not a Scotch result. v3 activates the runtime before
linkage inspection; original evidence is retained.
