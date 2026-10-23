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
The proposed next step fetches those RPM archives to a user scratch cache,
validates each against Intel repository metadata, and privately extracts them
inside a fresh PBS_JOBFS. A 4-core two-rank smoke test checks compiler version,
actual Intel MPI linkage, PBS startup, and an archived SHA-256 before any
OpenFOAM build. No shared installation is planned.
