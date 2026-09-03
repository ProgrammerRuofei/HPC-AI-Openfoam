# S2 — ICX 2023.2 + Intel MPI 2021.10

Preparation-only definition for a future isolated OpenFOAM v2512 build. It
uses the same immutable source snapshot and non-stack controls as S1/S3.

| Purpose | Path |
| --- | --- |
| Authoritative read-only source | `/apps/OpenFOAM/2512` |
| Job-local build root | `$PBS_JOBFS/openfoam-build/s2-icx2023-impi2021` |
| Candidate platform output | `<jobfs-root>/OpenFOAM-v2512/platforms/linux64IcxDPInt32Opt` |
| Persistent PBS output / evidence / runtime archive | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s2-icx2023-impi2021/{submit-logs,evidence,runtime-archive}` |

Modules are `intel-compiler-llvm/2023.2.0` and `intel-mpi/2021.10.0`.
The initial `jobfs=100GB` request is a safety allocation to be calibrated from
recorded JOBFS usage. The job stages its own source/worktree from
`/apps/OpenFOAM/2512` into JOBFS with the same `rsync -a` exclusions as S1/S3:
root `platforms/`, ThirdParty `platforms/`, and ThirdParty `build/`. It
requires the reviewed common regular digest
`802414c5b14ebb9cb4e3bab1a570e3c06c77e2d3028792faff865bcd4a181cc0`,
symlink digest `7d4ad344a50520ca0f79c6e45e198eb4f294e73759291fd4062c3ea2ab14b538`,
and `OPENFOAM_SOURCE_ID_V2`
`5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`
to match both authoritative and staged source. Only logs, provenance, checksums
and a candidate runtime archive persist on scratch. The expected OpenFOAM
settings are `WM_COMPILER=Icx`, `WM_MPLIB=INTELMPI`, and
`WM_OPTIONS=linux64IcxDPInt32Opt`. No PGO, LTO, SCOTCH tuning, MPI tuning,
binding, decomposition, or numerical change is introduced.
