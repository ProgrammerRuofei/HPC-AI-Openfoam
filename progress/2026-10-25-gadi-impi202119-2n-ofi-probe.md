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

Script review, synchronization, PBS submission, job ID, first error,
actual SU and outcome are pending.
