# Official Gadi Sapphire Rapids workflow

This directory contains the official 2026 APAC OpenFOAM workflow for Gadi
`normalsr` (Intel Xeon Platinum 8470Q Sapphire Rapids) using the site
OpenFOAM v2512 module.  It is intentionally separate from the earlier
Cascade Lake workflow-validation runs.

`official_baseline_4n.pbs` is the first controlled official baseline.  It
uses four 104-physical-core nodes, one MPI rank per physical core (416 ranks
total), and hierarchical decomposition `(16 13 2)`.  This is a simple
hardware-topology-aligned baseline, not an optimisation claim.  The script
uses the full official preparation chain and only changes the permitted
decomposition entries in the fresh case copy.

The primary result is `Average wall-clock time per time step` emitted by
`simpleFoam`; `ClockTime` and other timings are secondary evidence.  Run
records belong in `results/official-gadi-spr/run-registry.md`.
