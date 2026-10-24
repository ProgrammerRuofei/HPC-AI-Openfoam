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
Post-run acceptance remains pending. No four-node solver run or performance
claim is authorized by this retry.
