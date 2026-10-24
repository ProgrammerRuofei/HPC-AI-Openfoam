# Intel MPI 2021.19 two-node OFI preflight

The user approved one two-node, two-rank diagnostic after reviewing the
proposed script diff. This is a new small preflight, not permission to
repeat the failed 416-rank official case. The earlier job
`182194314.gadi-pbs` completed Scotch 416-way decomposition but failed
at `MPI_Init` in `MPIDI_OFI_mpi_init_hook`; PBS charged 157.62 SU.

`probe_impi202119_2n_v1.pbs` requests pm78 `normalsr`, two SPR nodes,
208 CPUs allocated to guarantee 104 PBS slots on each node, 16 GB memory,
20 GB JOBFS per node and ten minutes (about 69.3 SU request ceiling at
the observed SPR rate). It stages the already verified private ICX
2026.2 / Intel MPI 2021.19 archive into each node's JOBFS and does not
load the OpenFOAM case. A PBS TM / Hydra `hostname` check precedes a
two-rank `MPI_Init` / `Sendrecv` / `Allreduce` / `Finalize` program. It
saves library and OFI provider information and bounded Intel MPI debug
logs. If the default provider fails and `fi_info` lists `tcp`, it tries
that provider separately as a diagnostic only. A successful diagnostic
script is not a scored scientific run and does not establish that the
default MPI configuration is suitable for the baseline.

The script passed local `bash -n` and staged-diff checks. Commit
`a683040323cc79a90f066bf24e6114232c8c1948` was pushed to GitHub,
transferred by SHA-256-verified Git bundle, and fast-forwarded on Gadi's
isolated branch. The staged PBS file SHA-256 is
`357f4bff9ab5784bac89d842c78b92c12c4e5929c3ea464ae59c502d10b84faf`.
Exactly one `qsub` returned `182194827.gadi-pbs`; initial `qstat -f`
showed Q on `normalsr-exec`, 208 CPUs, 16 GB memory, 20 GB JOBFS and
ten minutes. Independent PBS stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/probe_impi202119_2n_v1.pbs.out`.
Job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/evidence/impi-ofi-2n.182194827.gadi-pbs/`.
The job finished on `gadi-cpu-spr-0685` and `0686` with PBS
`Exit_status=1`, walltime 00:00:51 and **5.89 SU**. Both private Intel
archives staged successfully. The first failed assertion was the
Hydra placement test: `hydra-hosts.txt` has two lines, both naming
`gadi-cpu-spr-0685.gadi.nci.org.au`, despite the two distinct PBS nodes.
The script exited before compiling or running the MPI peer program; no
`MPI_Init` or OFI test occurred. `fi_info` was not on the runtime PATH,
but the archived Intel stack contains a private
`libfabric/2.6/lib/libfabric.so.1.32.13`. This diagnostic result does
not identify the cause of the original four-node OFI error.

The placement check needs a separately approved revision using the
two allocated PBS hosts explicitly and disabling Intel MPI's scheduler
process-placement inheritance for this two-rank probe. Preserve this
job's stdout and job-keyed evidence; do not auto-resubmit.
