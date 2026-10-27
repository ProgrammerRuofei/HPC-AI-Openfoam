# Gadi ICX 2026.2 / Open MPI 5.0.10 candidate

The first approved action is a small one-node compatibility preflight.
`smoke_icx_ompi_1n_v1.pbs` checks private ICX/ICPX 2026.2.0 against the
already validated GCC 16.2.0-built Open MPI 5.0.10 archive, loading Gadi
UCX 1.18.1 and UCC 1.4.4. It uses `normalsr` Sapphire Rapids, four CPUs,
16 GB RAM, 30 GB JOBFS and 20 minutes (about 2.67 SU request ceiling).
The Intel archive is SHA-256 checked and extracted in JOBFS, but only its
compiler environment is sourced; its Intel MPI is not selected. The
preflight compiles an MPI C++ program with ICX, checks its private Open MPI
link, and runs two ranks over UCX. Logs are job-keyed on pm78 scratch.

This preflight does not build OpenFOAM or produce a scored result. A later
OpenFOAM v2512 build would retain the verified source identity, `Opt`,
real Scotch and six benchmark application gates. A four-node performance
run requires separate approval.

The first approved preflight was submitted once as `182372451.gadi-pbs`,
initially PBS `Q`; see the dated progress report for script checksum,
resource request and evidence paths. No outcome is claimed yet.
