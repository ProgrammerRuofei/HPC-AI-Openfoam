# S1 — ICC 2021.10 + Intel MPI 2021.10

Preparation-only definition for a future isolated OpenFOAM v2512 build. It is
a complete software-stack screen, not a compiler-only comparison. No build,
MPI run, smoke test, or benchmark is authorised by this definition.

## Deterministic remote paths

| Purpose | Path |
| --- | --- |
| Common immutable source snapshot (required, not created by this script) | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/OpenFOAM-v2512` |
| Candidate build root | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s1-icc2021-impi2021` |
| Candidate worktree | `<build-root>/OpenFOAM-v2512` |
| Candidate platform output | `<build-root>/OpenFOAM-v2512/platforms/linux64IccDPInt32Opt` |
| PBS output directory | `<build-root>/submit-logs` |
| Build evidence | `<build-root>/evidence/<stack-id>.<PBS_JOBID>` |

The common source snapshot must be a v2512 source-only tree with no existing
`platforms/` output. The PBS output directory must be created after a separate
submission review because PBS opens `-o` before the script starts.

## Stack and control

- Modules: `intel-compiler/2021.10.0`, `intel-mpi/2021.10.0`
- OpenFOAM settings: `WM_COMPILER=Icc`, `WM_MPLIB=INTELMPI`, expected
  `WM_OPTIONS=linux64IccDPInt32Opt`
- No PGO, LTO, SCOTCH tuning, binding, rank-placement, MPI-tuning, or numerical
  option is added. Source-default ThirdParty/SCOTCH configuration is recorded.

The future shell script records compiler/MPI wrappers, modules, source hashes,
OpenFOAM settings, and binary `file`/`ldd`/SHA-256 evidence. It refuses to use
an existing candidate worktree and refuses a binary outside its own worktree.
