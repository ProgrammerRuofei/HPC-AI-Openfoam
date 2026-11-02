# ICX 2025.3.2 / Open MPI 5.0.10 rank-NUMA preflight

One approved single-node 104-rank MPI-only preflight, 10 minutes / 34.67 SU maximum. No OpenFOAM solve or build. Six launches test baseline, equivalent rankfile control and four candidate placement blocks on one node.

See [review](../../planning/reviews/gadi-icx-rank-numa-preflight-2026-11-02/README.md) and [offline analysis](../../planning/analysis/gadi-icx-rank-numa-order-2026-11-02/README.md). Exact script hashes are in the review manifest.

Require PBS Exit 0, unique PASS, 624 valid rank receipts, pre/post MPI affinity agreement, 104 unique cores, sum 5356, ring communication and expected 3/6/10/2 candidate changes. This establishes placement compatibility only, not speedup or memory page location. No automatic retry or four-node submission.

Status: implemented and locally validated; no PBS job submitted yet.
