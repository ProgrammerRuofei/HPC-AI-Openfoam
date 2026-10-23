# Gadi newer ICX + Intel MPI build

The preceding inode cleanup job `182137556.gadi-pbs` completed with
`Exit_status=0`, consumed 0.26 SU, and reduced live pm78 scratch use to about
153.4K of 202K inodes. No further cleanup is needed before this build.

An ABI and PBS launch probe using site modules `intel-compiler-llvm/2025.3.2`
and `intel-mpi/2021.17.2` completed as `182138214.gadi-pbs` with
`Exit_status=0`, `ICX20253_IMPI202117_1N_SMOKE_PASS`, 6 seconds, and 0.01 SU.
Two ranks ran on `gadi-cpu-spr-0232`; `ldd` resolved `libmpi.so.12` under
`/apps/intel-tools/intel-mpi/2021.17.2`, and Intel MPI reported its `mlx`
libfabric provider. Its evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-impi202117/evidence/182138214.gadi-pbs`.

The user clarified that the intended build uses newer Intel versions; the
site-module OpenFOAM build proposed after the probe was **not submitted**.
Only the inexpensive ABI probe ran. No four-node benchmark was submitted.

Intel's 2026 toolkit release table maps 2026.1 to compiler 2026.1 and MPI
2021.18, and 2026.2 (released on October 23) to compiler 2026.2 and MPI
2021.19. The Gadi login node runs Rocky Linux 8.10, and the public Intel
oneAPI Yum repository metadata directly lists both versioned RPM groups. A
read-only dependency plan resolved 27 Intel RPMs totalling 1,119,733,448 bytes.
The next stage fetches those RPM archives to a user scratch cache,
validates each against Intel repository metadata, and privately extracts them
inside a fresh PBS_JOBFS. A 4-core two-rank smoke test checks compiler version,
actual Intel MPI linkage, PBS startup, and an archived SHA-256 before any
OpenFOAM build. No shared installation is planned.

The user approved exactly this private-toolchain download and one 4-core
preflight job. Commit `6c86b8d` reached GitHub and Gadi's isolated branch;
the two executable script SHA-256 values matched locally and on Gadi
(`1591bfcadfee9bfcfa6bb2d356bcaab28b7576ef81fdd59404381c0e8eadc3f2`
for the downloader and
`1e0992f307071498b918f2fcec561fa5ba30bb75f7d28759c3b44ac57ff90875`
for PBS). All 27 RPMs downloaded to `rpm-cache` with repository-recorded
size and SHA-256; the cache occupies about 1.1 GB. No system package was
installed.

PBS job `182138851.gadi-pbs` was submitted once from the verified
`submit-logs/smoke_private_toolchain_1n.6c86b8d.pbs` copy. Initial `qstat -f`
showed state `Q`, queue `normalsr-exec`, 4 CPUs and a 20-minute limit. Its
independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/smoke_private_toolchain_1n.pbs.out`;
job-keyed evidence will be under the same stack's
`evidence/182138851.gadi-pbs/` directory. No OpenFOAM compilation or
four-node run was submitted.

The private-toolchain preflight **passed**. PBS reported `Exit_status=0` and
walltime `00:03:57` on SPR node `gadi-cpu-spr-0476` with four allocated CPUs.
The probe printed `ICX20262_IMPI202119_PRIVATE_1N_PASS`; `icx --version`
reported 2026.2.0, Intel MPI reported 2021.19.0, and `ldd` resolved
`libmpi.so.12` from the extracted private MPI tree under this job's JOBFS.
Both MPI ranks ran on that node. The runtime archive's verified SHA-256 is
`013ea4758e05b3656b5474845577fcd0631b28d783e115b5e42d644d321a2fbc`.
The independent PBS resource receipt reports **0.53 SU** (four CPUs at two
SU per core-hour, 3:57 walltime), 6.52 GB memory and 3.82 GB JOBFS used.
`nci_account -P pm78` subsequently showed zero reserved and rounded
2.36 KSU used.
This establishes private compiler and MPI usability only. OpenFOAM v2512
has not yet been built or run with this combination.

The user separately approved exactly one OpenFOAM v2512 build with this
private toolchain after the proposed script changes were shown. The build-only
scripts were locally validated with `bash -n` and `git diff --check`, committed
as `9ccd15d`, and pushed to GitHub and Gadi's isolated branch. Gadi's branch
resolved to `9ccd15d19d29d6391f68c1ddbb5f19ba0076b640`; the submitted
helper/PBS copies had matching local and remote SHA-256 values
`d3bd04234b3c2b888123df22fa62f64a615d8b835e25c730a9492738e085714f`
and `a7d9e9de8a6b43ac50019da6ec52b029988c8d1b0f244dd56f9d9ea5afd46e78`.
The remote `main` checkout and its unrelated untracked files were untouched.

`qsub` returned **`182139214.gadi-pbs`** exactly once. Initial `qstat -f`
showed `Q` in `normalsr-exec`, one node, 48 CPUs, 190 GB memory, 100 GB
JOBFS, four-hour walltime and a 384-SU request ceiling. Unique stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/build_openfoam_v2512_v1.pbs.out`.
The job-keyed build log will be at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119-of2512/evidence/gadi-icx20262-impi202119-of2512.182139214.gadi-pbs/build.log`.
Acceptance requires PBS Exit_status 0, unchanged SOURCE_ID_V2, ICX 2026.2,
Intel MPI 2021.19, real Scotch, six benchmark executables, `simpleFoam`
linked to private `libmpi.so.12`, and a verified OpenFOAM runtime archive.
There is no OpenFOAM run, Cd or performance result yet.
