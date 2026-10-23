# Private Intel 2026.2 / MPI 2021.19 toolchain on Gadi

This directory stages the official Intel oneAPI RPM dependency closure into
pm78 scratch as verified package archives. The small PBS job extracts them only
inside its own `PBS_JOBFS`, checks the actual compiler/MPI versions and runtime
linkage, launches two MPI ranks through PBS, and creates a SHA-256-checked
toolchain archive for a later OpenFOAM build. It does not modify `/apps` or
system RPM state.

`fetch_official_rpms.py` pins the Intel Yum repository primary metadata SHA-256
and requires each RPM to match its recorded size and SHA-256. Its two root
packages are `intel-oneapi-compiler-dpcpp-cpp-2026.2` and
`intel-oneapi-mpi-devel-2021.19`. The read-only plan resolved 27 RPMs, 1.12 GB.
The transfer target is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/rpm-cache`.

The first PBS attempt is `smoke_private_toolchain_1n.pbs` in `normalsr` with
four CPUs, 16 GB memory, 30 GB JOBFS, and a 20-minute limit. Its job-keyed
evidence lives under the sibling `evidence/<PBS_JOBID>` directory. Success
requires the marker `ICX20262_IMPI202119_PRIVATE_1N_PASS`, compiler 2026.2,
Intel MPI 2021.19, `libmpi` from the private prefix, both MPI ranks, and an
archive SHA-256 check. This is a compatibility test, not a benchmark score.

Job `182138851.gadi-pbs` passed with PBS `Exit_status=0` and walltime
`00:03:57` (four CPUs, **0.53 SU** in the PBS resource receipt).
It reported ICX 2026.2.0 and Intel MPI 2021.19.0, linked `libmpi.so.12`
from the private JOBFS installation, and completed both ranks on one SPR node.
The verified runtime archive is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/runtime-archive/gadi-icx20262-impi202119.182138851.gadi-pbs.tar.gz`,
SHA-256 `013ea4758e05b3656b5474845577fcd0631b28d783e115b5e42d644d321a2fbc`.

OpenFOAM v2512 build settings, compiler flags, Scotch, and application binary
linkage must be validated in a separate job before any scientific run.

## OpenFOAM build attempt v1

`build_openfoam_v2512_v1.pbs` requests one `normalsr` SPR node with 48 CPUs,
190 GB memory, 100 GB JOBFS and a four-hour walltime limit (384 SU maximum).
Its job-specific build helper verifies and extracts the preflight toolchain
archive into fresh JOBFS, then uses `WM_COMPILER=Icx`, `WM_MPLIB=INTELMPI`,
`WM_COMPILE_OPTION=Opt` and the private `I_MPI_ROOT`. This Intel MPI path uses
Intel's fabric stack; it does not claim the Open MPI UCX/UCC configuration.

The build gates the unchanged `OPENFOAM_SOURCE_ID_V2`, compiles genuine Scotch
and the six benchmark applications, verifies `simpleFoam` links to the private
Intel MPI `libmpi.so.12`, and checks a new OpenFOAM runtime archive SHA-256.
Optional applications outside the benchmark are excluded because the prior
ICX 2025.3.2 all-applications attempt failed in unrelated CGAL 4.14.3 code.
This is a build-only job; it has no solver run or performance score.
