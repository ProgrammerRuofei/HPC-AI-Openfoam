# PMPI peer-counter v2 single-node diagnostic

| Field | Verified value |
| --- | --- |
| PBS job | `181922750.gadi-pbs`, state F, `Exit_status=0` |
| Allocation | Gadi `normalsr`, one Sapphire Rapids node (`gadi-cpu-spr-0481`), 5 CPUs, 16 GB requested memory, 20 GB JOBFS, 15-minute limit |
| Runtime | GCC 16.2.0; private Open MPI 5.0.10; UCX 1.18.1 and UCC 1.4.4 modules; OpenFOAM v2512 with real Scotch |
| Workload | Two-rank communicator probe; four separate five-rank, 20-step `pitzDaily_fused` Scotch tutorial runs; diagnostic only |
| Evidence | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/pmpi-peer-v2-smoke.181922750.gadi-pbs/` |
| Independent stdout | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_pmpi_peer_counter_1n_v2.pbs.out` |
| Usage | 5:05 walltime, 0.85 SU (NCI receipt) |

The two-rank probe checked direct, duplicated, and reversed-rank
communicators. All exact peer and requested-byte assertions passed. Each
peer-counter tutorial run generated five complete report sets. All 91,816
point-to-point calls per run mapped to world ranks, with zero `other_comm`,
unresolved peers, or datatype-size errors. The control runs used the existing
v2 timing interposer. All four solver logs ended normally and printed coded
wall-clock step timing.

Peer-counter/control mean launcher-time ratio: **0.997647**. Coded solver-step
ratio: **0.985577**. With only 20 steps, these results establish functional
coverage and reveal no measurable incremental overhead in this test. They do
not establish the overhead of a four-node profile or show a speedup. The
source/PBS hashes and preservation details are in
`progress/2026-10-22-gadi-pmpi-peer-counter.md`.
