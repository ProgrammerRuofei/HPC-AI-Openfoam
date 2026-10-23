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

OpenFOAM v2512 build settings, compiler flags, Scotch, and application binary
linkage must be validated in a separate job before any scientific run.
