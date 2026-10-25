# Intel MPI 2021.19 two-node OFI preflight v3

The user approved one v3 diagnostic after reviewing the path-check diff.
The v2 job `182218986.gadi-pbs` ended PBS Exit Status 1 after 00:00:55,
charging 6.36 SU. Both node stages passed, and Hydra placed processes on
`gadi-cpu-spr-0104` and `gadi-cpu-spr-0718`. The saved `mpi-peer.ldd`
resolved the private Intel MPI library at `$MPI/lib/libmpi.so.12`; the
script's literal `$MPI/lib/release/libmpi.so.12` grep failed before MPI_Init.
No OFI result is yet available. Original evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/evidence/impi-ofi-2n-v2.182218986.gadi-pbs/`
and independent stdout
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/probe_impi202119_2n_v2.pbs.out`.

The v3 change verifies the observed loaded `libmpi.so.12` is inside the
private MPI `lib/` prefix and compares its SHA-256 against the expected
private release library. All resource and launch settings are unchanged,
with unique stdout/evidence paths. This is one two-node, two-rank
diagnostic, not a scientific or scored OpenFOAM run. Awaiting local and
remote validation and PBS submission.
