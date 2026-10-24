# ICX 2026.2 / Intel MPI 2021.19 OpenFOAM build retry

## v1 evidence

PBS job `182139214.gadi-pbs` ended Exit Status 1, walltime 00:43:14,
69.17 SU (48 CPUs; 190 GB requested, 158.18 GB used; 100 GB JOBFS
requested, 7.3 GB used). Six benchmark applications and real Scotch built.
The first identifiable fatal gate was a stale `lib/libmpi.so.12` path
check; `ldd` actually resolved private Intel MPI 2021.19 at
`lib/release/libmpi.so.12`. The saved stdout and job-keyed evidence on Gadi
are preserved. No OpenFOAM archive, binary checksum, or validation pass
marker was produced.

## v2 scope and validation

The user approved exactly one v2 build retry after reviewing the proposed
one-line link-gate correction. The helper and PBS script are new v2 files;
v1 stays unchanged. Resource request stays pm78/normalsr, one SPR node,
48 CPUs, 190 GB memory, 100 GB JOBFS, four-hour walltime. Only the
observed Intel MPI `lib/release` path is accepted; existing Open MPI
exclusion, missing-library check, source identity, Scotch, six applications,
checksums and archive gates remain. A read-only grep against v1's saved
`simpleFoam.ldd` showed the corrected path gate exits 0.

The v2 scripts were committed as `4239b3f57951b8571c1fae4a658fc5d2abf115e9`,
pushed to the isolated GitHub branch, transferred in a SHA-256-verified Git
bundle, and fast-forwarded on Gadi without changing its `main` checkout.
The staged helper and PBS hashes are respectively
`52b96e57bb67ce7772e317e126916566a93e95162d7102abe6671ebb58e6d40f`
and `20b2442e1415feae9bda10407753ce0051dc129505628387ed66299ef4333e90`.
One `qsub` returned `182193515.gadi-pbs`. Initial `qstat -f` showed state Q,
`normalsr-exec`, one node, 48 CPUs, 190 GB memory, 100 GB JOBFS, four-hour
walltime. Independent stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/build_openfoam_v2512_v2.pbs.out`.
Job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119-of2512/evidence/gadi-icx20262-impi202119-of2512.182193515.gadi-pbs/`.
## v2 outcome

PBS `qstat -xf 182193515.gadi-pbs` reported state F and `Exit_status=0`.
The independent stdout reports walltime `00:47:25`, CPU time `03:39:01`,
48 requested CPUs, 117.37 GB maximum memory used, 7.3 GB JOBFS used,
and **75.87 SU**. The job ran on `gadi-cpu-spr-0420`.

The job-keyed evidence contains all six `BENCHMARK_APP_PASS` markers,
`SCOTCH_BUILD_PASS`, and `BUILD_VALIDATION_PASS`. The source identity V2
equals `5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`
for both authoritative and staged trees. Saved versions are ICX/ICPX
2026.2.0 and Intel MPI 2021.19.0. Saved `simpleFoam.ldd` resolves
`libmpi.so.12` to the private Intel MPI 2021.19 `lib/release` directory,
with no missing dependency. `simpleFoam` SHA-256 is
`ab7d574d63a87d48bf3ceb5651203c86e1d2f64eb741295917d4d8cf5658218c`.

The runtime archive is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119-of2512/runtime-archive/gadi-icx20262-impi202119-of2512.182193515.gadi-pbs.tar.gz`
(874,890,850 bytes), SHA-256
`efff0aa0137905dbac05b7418d99d89b523a32df3a5d068af9dd6192d7ae0c97`;
the saved checksum file passed a fresh `sha256sum -c`. Thus this is an
accepted **build artifact**. No solver smoke test, four-node run, Cd, or
performance result was produced or authorized by this retry.
