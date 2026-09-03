# S1 — ICC 2021.10 + Intel MPI 2021.10

Preparation-only definition for a future isolated OpenFOAM v2512 build. It is
a complete software-stack screen, not a compiler-only comparison. No build,
MPI run, smoke test, or benchmark is authorised by this definition.

## Deterministic remote paths

| Purpose | Path |
| --- | --- |
| Authoritative read-only source | `/apps/OpenFOAM/2512` |
| Job-local build root | `$PBS_JOBFS/openfoam-build/s1-icc2021-impi2021` |
| Candidate worktree | `<jobfs-root>/OpenFOAM-v2512` |
| Candidate platform output | `<jobfs-root>/OpenFOAM-v2512/platforms/linux64IccDPInt32Opt` |
| Persistent evidence root | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s1-icc2021-impi2021/evidence/<stack-id>.<PBS_JOBID>` |
| Persistent runtime archive | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s1-icc2021-impi2021/runtime-archive/` |
| PBS output directory | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s1-icc2021-impi2021/submit-logs` |

The PBS request includes `jobfs=100GB`. This is an initial safety allocation,
not a measured build peak; the job records JOBFS capacity, free space, inode
information where available, and staged/build workspace usage for later
calibration. Each job stages its source into its own JOBFS worktree with
`rsync -a`, excluding root `platforms/`, `ThirdParty-v2512/platforms/`, and
`ThirdParty-v2512/build/`. These are inherited/generated build outputs; all
source, ThirdParty source, permissions, symlinks, and timestamps remain
preserved. No expanded common source snapshot is retained on scratch.

## Stack and control

- Modules: `intel-compiler/2021.10.0`, `intel-mpi/2021.10.0`
- OpenFOAM settings: `WM_COMPILER=Icc`, `WM_MPLIB=INTELMPI`, expected
  `WM_OPTIONS=linux64IccDPInt32Opt`
- No PGO, LTO, SCOTCH tuning, binding, rank-placement, MPI-tuning, or numerical
  option is added. Source-default ThirdParty/SCOTCH configuration is recorded.

The future shell script records compiler/MPI wrappers, key source-file hashes,
and deterministic regular-file plus symlink manifests that exclude exactly the
three generated output trees. It requires both authoritative and staged values
to match the reviewed common identity: regular
`802414c5b14ebb9cb4e3bab1a570e3c06c77e2d3028792faff865bcd4a181cc0`,
symlink `7d4ad344a50520ca0f79c6e45e198eb4f294e73759291fd4062c3ea2ab14b538`,
and `OPENFOAM_SOURCE_ID_V2`
`5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`.
It uses the verified Gadi package sequence `ThirdParty-v2512/Allwmake`,
`src/Allwmake`, then `applications/Allwmake` because this package has no
top-level Allwmake. It refuses an existing JOBFS worktree, inherited platform
output, and a binary outside its own worktree.

Only logs, source/build provenance, checksums, and a compact candidate runtime
archive persist on scratch. The archive is a conservative runtime candidate
containing `etc`, the candidate OpenFOAM platform, and candidate ThirdParty
platforms. Its contents and `ldd simpleFoam` evidence are captured; a separate
authorised smoke test must determine the minimal runtime closure. PBS_JOBFS is
node-local, so a future multi-node benchmark must distribute and hash-verify
the archive independently on every allocated node before launching MPI.
