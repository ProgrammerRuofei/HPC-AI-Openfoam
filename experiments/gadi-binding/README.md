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

## V1 result — 182017185.gadi-pbs

PBS ended with `Exit_status=0` and the evidence-complete marker
`GCC162_OMPI5010_BINDING_1N_PROBE_PASS`. The job ran on SPR host
`gadi-cpu-spr-0408` for 16 seconds and was charged **0.92 SU**. Both launches
reported all 104 world/local ranks. The default policy gave each rank access
to one 13-core NUMA domain: eight distinct CPU masks, each shared by 13 ranks.
Explicit `--bind-to core` gave 104 distinct one-core masks. Each policy placed
13 ranks in each of the eight NUMA domains; every world rank remained in the
same NUMA domain across policies. The allowed CPU set is the binding evidence;
these observations do not measure solver speed or rank migration frequency.

Evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/binding-probe-1n/182017185.gadi-pbs/evidence/`.
The independent PBS stdout is in the sibling `submit-logs/` directory as
`probe_gcc162_ompi5010_binding_1n_v1.pbs.out`. SHA-256 of `default.jsonl` is
`c22d12b9ae1a7f4a923f63ab534e41d7afbacf138f4642006a36dbcf2dd81fe0`;
of `core.jsonl` is
`feeb2c144929826f9a1dcb2eea754f1fc6e92c848b912170f84addcf1efbc32b`.
This difference warrants a controlled solver comparison, subject to a new
reviewed script diff and approval under the repository workflow. No 40-step
or four-node solve was submitted as part of this probe.
