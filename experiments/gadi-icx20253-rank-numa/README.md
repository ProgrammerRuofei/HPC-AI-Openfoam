# ICX 2025.3.2 / Open MPI 5.0.10 rank-NUMA preflight

One approved single-node 104-rank MPI-only preflight, 10 minutes / 34.67 SU maximum. No OpenFOAM solve or build. Six launches test baseline, equivalent rankfile control and four candidate placement blocks on one node.

See [review](../../planning/reviews/gadi-icx-rank-numa-preflight-2026-11-02/README.md) and [offline analysis](../../planning/analysis/gadi-icx-rank-numa-order-2026-11-02/README.md). Exact script hashes are in the review manifest.

Require PBS Exit 0, unique PASS, 624 valid rank receipts, pre/post MPI affinity agreement, 104 unique cores, sum 5356, ring communication and expected 3/6/10/2 candidate changes. This establishes placement compatibility only, not speedup or memory page location. No automatic retry or four-node submission.

Status: submitted once as **182926714.gadi-pbs**, initial PBS state **Q**, 2026-11-02 18:12:25 Gadi time. Script commit `dc7f25906ad1043de106c02ccef23279f4da1457`; all four remote file SHA256 values verified against the approved manifest. At that initial check no result was available; final outcome is recorded below.

## Result v1

182926714: F/Exit137,28sec,1.62SU on SPR0201; exceeded16GB during first104-rank baseline probe.0 rank receipts,no candidate launches/no PASS. [Raw evidence](../../planning/evidence/gadi-pbs-script-snapshot/logs/182926714.gadi-pbs/README.md). Track2 memory resource change proposed; not applied. No automatic retry.

## v2 memory-only retry

User approved once on2026-11-02:104CPU/64GB/20GBJOBFS/10min,max34.67SU. Exact reviewed script74a325010a6f0800860928faf9e7f5b1166131acb190f95a53e83c254e73c655; source/helper/map unchanged. New unique v2 paths; submission pending.

Submitted v2 once: **182929980.gadi-pbs**, initialQ at2026-11-02 18:42:57 Gadi time. Result/actualSU pending. [Handoff](../../progress/2026-11-02-gadi-rank-numa-preflight-v2.md).

## v2 acceptance

182929980 F/Exit0/PASS,48sec,2.77SU. Full655originalfiles+qstatSHAarchive,independent624rankreceipt validation PASS. Memory20.89GB confirms16GBv1wasinsufficient;noMRregistrationfailurein v2. Four-node proposal now prepared locally; no performance claim or extra submission.

## Approved four-node pair

One PBS control->candidate pair,4SPR/416ranks,150steps each,ICX2025.3.2/OpenMPI5.0.10/Scotch,core-bound botharms. Only21rank placements differ withinoriginalsocket/node.416CPU/760GB/400GBJOBFS/1h,max832SU,estimated465–500SU. [Approved review](../../planning/reviews/gadi-icx-rank-numa-4n-2026-11-02/README.md). Scripts installed with exact approved hashes; submission pending. Preserve all prior evidence; no automatic retry.

Four-node pair submitted once as **182932939.gadi-pbs**, initialQ. [Submission and monitoring handoff](../../progress/2026-11-02-gadi-rank-numa-4n-pair.md). No result yet;max832SU.

## 182932939.gadi-pbs — failed topology receipt, 2026-11-02

F / Exit1, 00:02:32, **35.13 actual SU**; SPR0201–0204, 4×104 requested ranks, 416 total. ICX2025.3.2 / private OpenMPI5.0.10 / OpenFOAMv2512 / Scotch. Planned control then candidate, each150steps; neither reached solver. No seconds/step or Cd.

Four runtime staging receipts and source-dictionary/archive/binary SHA checks passed. `control/evidence/lscpu-0.txt` is empty while PBS stdout contains lscpu output. The first identified failing gate is the required model grep following the pbsdsh stdout redirection (arm script lines106–107); no ERR trace is available. Failure is in topology evidence collection, before baseline rank mapping, MPI probe, decomposition or candidate. Runtime UCP version / collective selection are unknown; module names and ldd do not establish them.

24 original files plus qstat captured, SHA verified, no originals excluded or overwritten. [Raw local logs](../../planning/evidence/gadi-pbs-script-snapshot/logs/182932939.gadi-pbs/README.md). Preserve failure; no automatic retry. Proposed repair is node-side receipt writing with nonempty/model checks and explicit error-stage logging, followed by local tests and a complete new-version diff for approval. No run-script change applied.
