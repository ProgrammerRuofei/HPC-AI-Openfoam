# Gadi ICX 2025.3.2 / Open MPI 5.0.10 candidate

This candidate tests whether Gadi's available ICX 2025.3.2 improves the
OpenFOAM v2512 65M DrivAer run relative to the validated GCC 16.2.0
baseline. The other team's ICX 2026.1 module is not currently available
on Gadi. This build is an ICX **candidate**, not a best build.

| Item | Setting |
| --- | --- |
| Queue / CPU | Gadi `normalsr`, Xeon Platinum 8470Q (SPR) |
| Compiler | `intel-compiler-llvm/2025.3.2`, `icx`/`icpx` |
| MPI | Private Open MPI 5.0.10 archive built with GCC 16.2.0; wrappers set to ICX |
| Transport / collectives | Gadi UCX 1.18.1 / UCC 1.4.4 modules |
| OpenFOAM | v2512 authoritative `/apps/OpenFOAM/2512`, `OPENFOAM_SOURCE_ID_V2` pinned in common helper |
| Build | `WM_COMPILER=Icx`, `WM_MPLIB=SYSTEMOPENMPI`, `WM_COMPILE_OPTION=Opt` |
| Scotch | ThirdParty Scotch 6.1.0; staged Makefile uses C17 and requires real `libscotch` and `libscotchDecomp` |

The private GCC archive is unpacked into each job's JOBFS to provide
the runtime libraries required by the prebuilt Open MPI. Its presence
does not make the OpenFOAM candidate a GCC build. Both archives are
SHA-256 checked before extraction. Source, compiler environment,
`simpleFoam` MPI linkage, Scotch libraries and final runtime archive
are verified by the common build helper.

The low-cost compatibility probe `181382175.gadi-pbs` passed with ICX
2025.3.2, private Open MPI 5.0.10, and two UCX ranks; actual charge
was 0.04 SU. The first ICX OpenFOAM build is
**`181387300.gadi-pbs`**, submitted with one SPR node, 48 CPUs,
190 GB RAM, 100 GB JOBFS and a four-hour limit. Its outcome and
actual SU are pending. Raw logs and job-keyed evidence remain on Gadi;
submission and result details are in
`progress/2026-10-16-gadi-icx-screening.md`.
