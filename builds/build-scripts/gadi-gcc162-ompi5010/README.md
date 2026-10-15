# Gadi SPR GCC 16.2 / Open MPI 5.0.10 candidate

Status: **LOCAL REVIEW ONLY — NOT SUBMITTED**.

This candidate targets `normalsr` (Sapphire Rapids, 104 physical cores/node).
The first build stage produces a private GCC 16.2.0 archive. Open MPI 5.0.10,
OpenFOAM v2512, runtime relocation, and the 416-rank Scotch benchmark require
separate reviewed stages; no existing binary is called the team's best build.

## Stage 1: GCC 16.2.0

- Source input: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz`.
- Official source SHA-512: `c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1`.
- Bootstrap compiler: Gadi module `gcc/15.1.0`; build only C and C++ with
  `--disable-bootstrap --disable-multilib --disable-nls`.
- PBS: one `normalsr` node, 104 CPUs, 400 GB RAM, 150 GB jobfs, six-hour limit.
- Build and install inside `$PBS_JOBFS`; retain a single tar archive in scratch
  to avoid exhausting the project's inode quota.
- Before using this GCC in another PBS job, extract the archive into the new
  `$PBS_JOBFS` and verify that relocation works with C/C++ compile and link
  probes. An archive by itself is **not** a validated compiler installation.

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

1. Review the exact local diff and approve Git synchronization, source
   transfer, remote directory creation, and this single GCC build submission.
2. Check its archive, version, compiler paths, and relocation in a separate
   reviewed smoke before using it to build Open MPI.
3. Prepare and review Open MPI 5.0.10 with site UCX 1.18.1 and UCC 1.4.4.
4. Build OpenFOAM v2512 against that exact MPI and verify `ldd`/wrapper paths.
5. Run the full 4-node/416-rank/150-step Scotch case on SPR; validate Cd and
   repeatability before labelling the candidate the team's best build.

No previous hierarchical benchmark is scheduled for repetition. The team's
valid site-build result `178149002.gadi-pbs` (2.139565 s/step) is the initial
absolute reference, with the caveat that the first candidate changes several
factors at once.
