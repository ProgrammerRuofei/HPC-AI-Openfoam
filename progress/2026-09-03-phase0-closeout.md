# Phase 0 closeout — Gadi four-node controlled repeats

## Current step

Phase 0 reproducibility/repeatability is closed in documentation only.  No
compiler screening, profiling, or optimisation experiment has started.

## Completed evidence review

- R1 `178063948.gadi-pbs`: ClockTime 802 s.
- R2 `178073349.gadi-pbs`: ClockTime 1045 s; correctness-valid sustained
  performance anomaly retained in the raw dataset.
- R3 `178073350.gadi-pbs`: ClockTime 793 s.
- R4 `178107780.gadi-pbs`: ClockTime 790 s; valid with the documented absence
  of the expected PBS stdout at its configured `submit-logs` path.

Every run used the frozen v2512/GCC 8.5.0/Open MPI 4.1.7, 4-node/192-rank,
hierarchical `(16 6 2)`, endTime-150 configuration, reached Time 150, and
ended normally.  R4 provenance `run.log`, solver log, and PBS history exist;
no post-hoc repair was made.

## Documentation updated locally

- `phase0/README.md`: R1–R4 inventory, validity, metrics, statistics, and
  baseline status.
- `results/metrics.csv` and `results/RESULTS.md`: structured extracted results.
- `results/README.md`: schema status.
- `planning/PLANS.md`: non-executable toolchain-screening and profiling plan.

## Baseline and next action

The frozen configuration's representative ClockTime is the median of all
valid controlled repeats: 797.5 s.  R2 is not discarded.  The next action is
to obtain explicit approval for read-only Gadi module/toolchain discovery,
then prepare candidate stack definitions locally for review.  Do not submit a
job, build OpenFOAM, or profile until separately authorised.
