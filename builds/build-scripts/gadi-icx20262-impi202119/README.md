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

The single authorized v1 submission is `182139214.gadi-pbs` (initial PBS
state `Q`). Its stdout is in the stack's `submit-logs/build_openfoam_v2512_v1.pbs.out`,
and its job-keyed `build.log` is in the separate
`gadi-icx20262-impi202119-of2512/evidence/` tree. Do not classify the build
from PBS exit status alone; check every acceptance marker and binary link.

## OpenFOAM build attempt v1 outcome and approved v2 correction

Job `182139214.gadi-pbs` ended with PBS Exit Status 1 after 00:43:14,
charging 69.17 SU. The independent PBS stdout is preserved. All six
`BENCHMARK_APP_PASS` checks and `SCOTCH_BUILD_PASS` appeared, and `ldd`
resolved `simpleFoam` to private Intel MPI 2021.19 under
`$PRIVATE_MPI_PREFIX/lib/release/libmpi.so.12`. The v1 helper mistakenly
required `$PRIVATE_MPI_PREFIX/lib/libmpi.so.12`; `set -e` stopped before
`simpleFoam.sha256`, the runtime archive, or `BUILD_VALIDATION_PASS`. Thus
v1 is not an accepted runtime build. No solver run or Cd result exists.

The user approved one v2 build retry. `build_openfoam_v2512_v2.sh` differs
from v1 only by matching the observed `lib/release` MPI link path; the
corrected literal gate passed a read-only test against v1's saved `ldd`.
`build_openfoam_v2512_v2.pbs` retains the 48-core resource request but
uses a separate job name and stdout path. The original job's files and
logs remain untouched. Acceptance still requires PBS Exit Status 0, all
source and build gates, binary checksum, archive checksum, and
`BUILD_VALIDATION_PASS`; there is no automatic scientific benchmark.

The approved v2 attempt is PBS job `182193515.gadi-pbs`, initially Q on
`normalsr-exec` with one node, 48 CPUs, 190 GB memory, 100 GB JOBFS and a
four-hour walltime request. Independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/build_openfoam_v2512_v2.pbs.out`.
It finished PBS Exit Status 0 on `gadi-cpu-spr-0420` in 00:47:25,
charging 75.87 SU. Six benchmark applications, real Scotch, source identity
V2, ICX/ICPX 2026.2.0, Intel MPI 2021.19.0, the private `simpleFoam`
MPI link, and `BUILD_VALIDATION_PASS` all passed. The binary SHA-256 is
`ab7d574d63a87d48bf3ceb5651203c86e1d2f64eb741295917d4d8cf5658218c`.
The 874,890,850-byte runtime archive is under the stack's `runtime-archive/`
directory with job ID `182193515.gadi-pbs`, SHA-256
`efff0aa0137905dbac05b7418d99d89b523a32df3a5d068af9dd6192d7ae0c97`;
`sha256sum -c` passed. This establishes a usable build artifact, not a
solver or performance result. See
`progress/2026-10-25-gadi-icx20262-impi202119-build-retry.md` for evidence.
