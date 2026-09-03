# S2 — ICX 2023.2 + Intel MPI 2021.10

Preparation-only definition for a future isolated OpenFOAM v2512 build. It
uses the same immutable source snapshot and non-stack controls as S1/S3.

| Purpose | Path |
| --- | --- |
| Common immutable source snapshot | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/OpenFOAM-v2512` |
| Candidate build root | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s2-icx2023-impi2021` |
| Candidate platform output | `<build-root>/OpenFOAM-v2512/platforms/linux64IcxDPInt32Opt` |
| PBS output / evidence | `<build-root>/submit-logs`, `<build-root>/evidence/<stack-id>.<PBS_JOBID>` |

Modules are `intel-compiler-llvm/2023.2.0` and `intel-mpi/2021.10.0`.
The expected OpenFOAM settings are `WM_COMPILER=Icx`, `WM_MPLIB=INTELMPI`, and
`WM_OPTIONS=linux64IcxDPInt32Opt`. No PGO, LTO, SCOTCH tuning, MPI tuning,
binding, decomposition, or numerical change is introduced.
