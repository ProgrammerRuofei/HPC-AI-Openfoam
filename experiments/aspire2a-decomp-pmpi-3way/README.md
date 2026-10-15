# Three-way stock Opt PMPI diagnosis

This diagnostic compares hierarchical `(32 16 1)`, plain Scotch, and
weighted Scotch in one four-node PBS allocation. Each configuration starts
from the same pinned 65M DrivAer template, uses 512 ranks and 150 steps,
and profiles `simpleFoam` only. Preparation is unprofiled. The fixed build
is AOCC 5.0 + Open MPI 5.0.10, stock `Opt`; the launcher maps 128 ranks per
node without an explicit binding flag.

The weighted Scotch settings match the existing Basic result:
`domains (4 8 16)` and `domainWeights (1 1 0.01)`. The PMPI library is the
same SHA-256-pinned wrapper used in the teammate's completed weighted Scotch
profile. The script records the actual input and binary hashes, rank mapping,
per-run solver logs, freshly generated `coefficient.dat`, and PMPI report.

This is a mechanism comparison, **not** a replacement for the unprofiled
contest score. The matching unprofiled hierarchical `(32 16 1)` run is job
`25826705.pbs101` and was queued when this script was prepared. The prior
weighted Scotch Basic result is job `20072244.pbs101`; its prior PMPI result
is job `25769467.pbs101`.

The script refuses an existing PBS-ID output directory and performs no
deletion or modification of prior cases. A failed configuration stops the
three-way job, leaving completed evidence in its unique scratch directory.

Status: prepared locally; **not submitted**. Review the complete PBS script
diff before authorizing Git sync and one `qsub`.
