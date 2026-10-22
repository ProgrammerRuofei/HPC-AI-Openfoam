# GCC 16.2 / Open MPI 5.0.10 CPU affinity audit

`probe_gcc162_ompi5010_binding_1n_v1.pbs` compares the current baseline
launcher mapping (`ppr:104:node`, UCX PML) with the same launch plus explicit
`--bind-to core`. It runs 104 ranks on one `normalsr` Sapphire Rapids node,
without an OpenFOAM solve. Both launches record each rank's OS CPU affinity,
physical core, socket and NUMA set, and Open MPI binding report. A PASS means
the evidence is complete; it does **not** mean either policy performs better.

The PBS request is 104 CPUs, 16 GB memory, 20 GB JOBFS and 5 minutes. At the
established 2 SU per core-hour rate, the request ceiling is 17.33 SU. The
script verifies SHA-256 pinned private GCC and MPI archives, uses the same
`ucx/1.18.1` and `ucc/1.4.4` module environment as the baseline, and writes
to a new job-keyed scratch directory. The fixed stdout name is unique to v1.
No solver input, case directory, or earlier evidence is modified.

After completion, inspect `default.jsonl`, `core.jsonl`, binding reports and
`summary.txt`. If default placement already covers 104 distinct cores with
one physical core per rank, stop this experiment direction before spending
SU on a 40-step solver comparison.
