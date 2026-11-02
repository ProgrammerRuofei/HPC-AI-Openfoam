# Rank/NUMA placement compatibility preflight

| Job | Stack | Allocation | Status | Result | SU |
|---|---|---|---|---|---|
|182926714.gadi-pbs|ICX2025.3.2 / private Open MPI5.0.10, module UCX1.18.1 UCC1.4.4|normalsr, 1SPR node,104ranks,16GB,20GBJOBFS,10min|F / Exit137|Memory allocation exceeded; no acceptance/PASS; no solver timing or Cd|1.62 actual;34.67 max|

Module names are not runtime-library/collective proof. The six launches record actual UCP and pre/post MPI_Init affinity; no memory page residency or performance claim. See [experiment](../../experiments/gadi-icx20253-rank-numa/README.md) and [handoff](../../progress/2026-11-02-gadi-rank-numa-offline.md). No automatic retry or four-node job authorized.

[Complete produced raw evidence](../../planning/evidence/gadi-pbs-script-snapshot/logs/182926714.gadi-pbs/README.md):28sec on SPR0201; actual runtime UCP/collective unknown, as no probe JSON completed.

## v2 submitted

182929980.gadi-pbs: initialQ; sameICX2025.3.2/privateOpenMPI5.0.10,1SPR/104ranks,64GB RAM/20GBJOBFS/10min.34.67SU max,actualpending. MPI-only; no solversteps/Cd/timing. No success assumed.

## v2 completed and independently verified

182929980: F/Exit0/PASS,48s,2.77SU,SPR0686,104ranks;64GBrequested/20.89GBused.655originals+qstatSHAverified;624rankJSON validated. Same MPIInitmask and5356/ring,104cores/13perNUMA;candidatechanges3/6/10/2. ActualprobeUCP1.21.0 from/usr/lib64;collectiveunknown. No OpenFOAMtime/Cd. [Raw logs](../../planning/evidence/gadi-pbs-script-snapshot/logs/182929980.gadi-pbs/README.md).

## Four-node pair pending

182932939.gadi-pbs,initialQ:4SPR×104ranks,ICX2025.3.2/privateOpenMPI5.0.10/OpenFOAMv2512/Scotch/fixed65M. Bothcorebound,control->candidate21rankchanges,150stepsperarm. ModulesUCX1.18.1/UCC1.4.4;actualruntimepending.1hour/832SUmax,actualSU/time/Cd pending. No claim of speedup.

## 182932939.gadi-pbs — failed topology receipt, 2026-11-02

F / Exit1, 00:02:32, **35.13 actual SU**; SPR0201–0204, 4×104 requested ranks, 416 total. ICX2025.3.2 / private OpenMPI5.0.10 / OpenFOAMv2512 / Scotch. Planned control then candidate, each150steps; neither reached solver. No seconds/step or Cd.

Four runtime staging receipts and source-dictionary/archive/binary SHA checks passed. `control/evidence/lscpu-0.txt` is empty while PBS stdout contains lscpu output. The first identified failing gate is the required model grep following the pbsdsh stdout redirection (arm script lines106–107); no ERR trace is available. Failure is in topology evidence collection, before baseline rank mapping, MPI probe, decomposition or candidate. Runtime UCP version / collective selection are unknown; module names and ldd do not establish them.

24 original files plus qstat captured, SHA verified, no originals excluded or overwritten. [Raw local logs](../../planning/evidence/gadi-pbs-script-snapshot/logs/182932939.gadi-pbs/README.md). Preserve failure; no automatic retry. Proposed repair is node-side receipt writing with nonempty/model checks and explicit error-stage logging, followed by local tests and a complete new-version diff for approval. No run-script change applied.
