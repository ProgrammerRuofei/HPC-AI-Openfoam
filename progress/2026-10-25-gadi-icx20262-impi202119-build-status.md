# Gadi ICX 2026.2 + Intel MPI 2021.19 build status

Read-only inspection on 2026-10-25 of PBS job `182139214.gadi-pbs`.

- `qstat -f`, `qstat -xf`, `qstat -x -u kj7183`, and `tracejob -n 7` no longer
  expose this job. This does not establish its result.
- The independent PBS stdout at
  `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/build_openfoam_v2512_v1.pbs.out`
  reports `Exit Status: 1`, walltime `00:43:14`, `69.17` SU, 48 requested CPUs,
  190 GB requested memory (158.18 GB used), and 100 GB requested JOBFS
  (7.3 GB used). Its resource summary is timestamped 2026-10-24 01:52:15.
- Job-keyed `build.log` contains `BENCHMARK_APP_PASS` for `blockMesh`,
  `decomposePar`, `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`, and
  `simpleFoam`, plus `SCOTCH_BUILD_PASS`.
- The last validation output is `ldd` for `simpleFoam`. It resolves
  `libmpi.so.12` under the private Intel MPI 2021.19
  `lib/release/libmpi.so.12`. The script's next command requires
  `$PRIVATE_MPI_PREFIX/lib/libmpi.so.12`; that literal path does not match the
  observed `lib/release` path. With the script's failure handling, this is
  the first identifiable validation failure, after compilation and linking.
- `simpleFoam.sha256` is absent, the runtime-archive directory is empty, and
  `BUILD_VALIDATION_PASS` is absent. Therefore the candidate is **not** a
  completed/accepted OpenFOAM build, despite the compiled applications.

No files or jobs were changed on Gadi. A future retry needs a reviewed fix to
the MPI link-path validation, a new job and output path, and all remaining
archive/hash checks; this inspection itself does not authorize submission.
