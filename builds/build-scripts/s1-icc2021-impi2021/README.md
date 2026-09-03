# S1 — ICC 2021.10 + Intel MPI 2021.10

Preparation-only definition for a future isolated OpenFOAM v2512 build. It is
a complete software-stack screen, not a compiler-only comparison. No build,
MPI run, smoke test, or benchmark is authorised by this definition.

## Deterministic remote paths

| Purpose | Path |
| --- | --- |
| Authoritative read-only source | `/apps/OpenFOAM/2512` |
| Candidate build root | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s1-icc2021-impi2021` |
| Candidate worktree | `<build-root>/OpenFOAM-v2512` |
| Candidate platform output | `<build-root>/OpenFOAM-v2512/platforms/linux64IccDPInt32Opt` |
| PBS output directory | `<build-root>/submit-logs` |
| Build evidence | `<build-root>/evidence/<stack-id>.<PBS_JOBID>` |

Each future job stages this source into its own worktree with `rsync -a`,
excluding root `platforms/`, `ThirdParty-v2512/platforms/`, and
`ThirdParty-v2512/build/`.  These are pre-existing/generated build outputs;
all source, ThirdParty sources, permissions, symlinks, and timestamps remain
preserved. The PBS output directory must be created after a separate
submission review because PBS opens `-o` before the script starts.

## Stack and control

- Modules: `intel-compiler/2021.10.0`, `intel-mpi/2021.10.0`
- OpenFOAM settings: `WM_COMPILER=Icc`, `WM_MPLIB=INTELMPI`, expected
  `WM_OPTIONS=linux64IccDPInt32Opt`
- No PGO, LTO, SCOTCH tuning, binding, rank-placement, MPI-tuning, or numerical
  option is added. Source-default ThirdParty/SCOTCH configuration is recorded.

The future shell script records compiler/MPI wrappers, source fingerprints,
OpenFOAM settings, and binary `file`/`ldd`/SHA-256 evidence. It uses the
verified Gadi package sequence `ThirdParty-v2512/Allwmake`, `src/Allwmake`,
then `applications/Allwmake` because this package has no top-level Allwmake.
It refuses an existing candidate worktree, inherited platform output, and a
binary outside its own worktree.
