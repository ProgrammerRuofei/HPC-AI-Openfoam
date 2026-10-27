# Gadi SPR GCC 16.2 / Open MPI 5.0.10 candidate

Status: **GCC 16.2 built and relocation-validated; Open MPI 5.0.10 build
submitted as `181344373.gadi-pbs` (result pending).** See
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

1. Complete and verify Open MPI build `181344373.gadi-pbs`: `Exit_status=0`,
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
