# Rank/NUMA placement compatibility preflight

| Job | Stack | Allocation | Status | Result | SU |
|---|---|---|---|---|---|
|182926714.gadi-pbs|ICX2025.3.2 / private Open MPI5.0.10, module UCX1.18.1 UCC1.4.4|normalsr, 1SPR node,104ranks,16GB,20GBJOBFS,10min|F / Exit137|Memory allocation exceeded; no acceptance/PASS; no solver timing or Cd|1.62 actual;34.67 max|

Module names are not runtime-library/collective proof. The six launches record actual UCP and pre/post MPI_Init affinity; no memory page residency or performance claim. See [experiment](../../experiments/gadi-icx20253-rank-numa/README.md) and [handoff](../../progress/2026-11-02-gadi-rank-numa-offline.md). No automatic retry or four-node job authorized.

[Complete produced raw evidence](../../planning/evidence/gadi-pbs-script-snapshot/logs/182926714.gadi-pbs/README.md):28sec on SPR0201; actual runtime UCP/collective unknown, as no probe JSON completed.

## v2 submitted

182929980.gadi-pbs: initialQ; sameICX2025.3.2/privateOpenMPI5.0.10,1SPR/104ranks,64GB RAM/20GBJOBFS/10min.34.67SU max,actualpending. MPI-only; no solversteps/Cd/timing. No success assumed.
