# Weighted Scotch PGO × binding study

Status: **both four-arm blocks completed; no stable PGO or binding gain
established because of intermittent elapsed-time stalls**. Last experiment
evidence checked on 2026-10-26, not a live scheduler query.

This is an index for the existing executed design, not approval for another
run or a change of build, launcher, resources or scientific inputs.

- Configuration: fixed 65M-cell OpenFOAM v2512 case, AOCC 5.0/Open MPI
  5.0.10, weighted Scotch `domains (4 8 16)`, weights `(1 1 0.01)`,
  4 nodes / 512 ranks / 150 steps.
- Arms: existing stock Opt and PgoUse builds crossed with default/core binding.
  The two blocks used opposite run orders.
- PBS jobs: `25970245.pbs101`, `25970246.pbs101`.
- All eight arms completed and retained fresh Cd evidence; the official
  full-run means were affected by sporadic long steps. Median step time is
  diagnostic and must not replace the official mean.

## Evidence and handoff

- [Submission/design record](../../progress/2026-10-25-aspire2a-scotch-pgo-binding-submitted.md).
- [Completed-run timing, correctness, affinity and stall audit](../../progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md).
- [Site inquiry draft — not sent](../../progress/2026-10-26-aspire2a-scotch-pgo-binding-site-inquiry-draft.md).

Use those records for exact arm timings and original evidence paths. The
physical cause of stalls is unresolved. This README was added during local
repository organization; no existing experiment script was changed or run.
