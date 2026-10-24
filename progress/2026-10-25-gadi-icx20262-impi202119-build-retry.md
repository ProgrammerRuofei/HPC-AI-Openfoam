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

Submission and post-run acceptance remain pending. No four-node solver run
or performance claim is authorized by this retry.
