# ICX 2025.3.2 / Open MPI 5.0.10 rank-NUMA preflight

One approved single-node 104-rank MPI-only preflight, 10 minutes / 34.67 SU maximum. No OpenFOAM solve or build. Six launches test baseline, equivalent rankfile control and four candidate placement blocks on one node.

See [review](../../planning/reviews/gadi-icx-rank-numa-preflight-2026-11-02/README.md) and [offline analysis](../../planning/analysis/gadi-icx-rank-numa-order-2026-11-02/README.md). Exact script hashes are in the review manifest.

Require PBS Exit 0, unique PASS, 624 valid rank receipts, pre/post MPI affinity agreement, 104 unique cores, sum 5356, ring communication and expected 3/6/10/2 candidate changes. This establishes placement compatibility only, not speedup or memory page location. No automatic retry or four-node submission.

Status: submitted once as **182926714.gadi-pbs**, initial PBS state **Q**, 2026-11-02 18:12:25 Gadi time. Script commit `dc7f25906ad1043de106c02ccef23279f4da1457`; all four remote file SHA256 values verified against the approved manifest. No result or actual SU yet.
