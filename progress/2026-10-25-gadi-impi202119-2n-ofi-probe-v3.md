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
diagnostic, not a scientific or scored OpenFOAM run. Local `bash -n` and diff checks passed. The reviewed script commit
`fcd24ecaa61c2b0ac97aa55af82d9ecc74f823b4` was pushed to GitHub,
transferred by SHA-256-verified bundle, and fast-forwarded on Gadi's isolated
branch. Staged PBS SHA-256:
`8911fbe39024071a01fa2b1af6c3bf902930745795b7d23ebdf889c274f4ef2c`.
Exactly one `qsub` returned `182236904.gadi-pbs`, initially Q on
`normalsr-exec` with 208 CPUs, 16 GB memory, 20 GB JOBFS and ten minutes.
Independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/probe_impi202119_2n_v3.pbs.out`;
job-keyed evidence is under the sibling
`evidence/impi-ofi-2n-v3.182236904.gadi-pbs/`. The job finished PBS Exit Status 0 in 00:00:57 and charged **6.59 SU**.
This only means the diagnostic script reached its completion marker.
The actual MPI peer probe returned `default_rc=143`; `tcp_rc=SKIPPED`
because `fi_info` was unavailable. Both private archives staged and Hydra
placed one process on each of `gadi-cpu-spr-0718` and
`gadi-cpu-spr-0720`. The private `libmpi.so.12` linkage gate passed.
The first MPI error in `default-ofi.log` was:
`failed to load libfabric.so.1: libfabric.so.1: cannot open shared object file`.
The recorded `LD_LIBRARY_PATH` lacked the archive's
`opt/intel/oneapi/libfabric/2.6/lib`, although
`fabric-library-paths.txt` found `libfabric.so.1.32.13` there.
`MPI_Init` failed before Sendrecv or Allreduce; no cross-node Intel MPI/OFI
validation or OpenFOAM result exists. The original logs remain preserved.
A future, separately authorized small preflight should add the private
libfabric directory to the runtime library search path and verify
`libfabric.so.1` resolves on both nodes before launching the peer probe.
No repeat is authorized under this v3 approval.
