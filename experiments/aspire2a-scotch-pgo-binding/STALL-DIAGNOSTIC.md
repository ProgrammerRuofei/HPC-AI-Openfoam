# Weighted Scotch stall recurrence diagnostic

`run_scotch_stall_diagnostic_v1.pbs` uses the existing pinned case and runner
with `BLOCK=3`. It runs `O_default_r1` then `O_default_r2` on the **same**
four-node allocation. Both use AOCC stock Opt, Open MPI, 512 ranks, no explicit
core binding, weighted Scotch `domains (4 8 16)` and
`domainWeights (1 1 0.01)`, and 150 steps. Each starts from a fresh case copy
and executes the full preprocessing chain. No profiler is loaded.

## Predeclared inspection

- Record PBS ID, four node names, rank affinity, exact solver executable SHA,
  effective input SHA, and the two solver logs and fresh coefficient files.
- For each run, verify script exit status, 150 completed steps, the reported
  average wall-clock time per step, and Cd at step 150. Keep both scores.
- Extract all 150 per-step wall-clock values and the matching `ExecutionTime`
  increments. Report median, maximum, and number of steps above 10 seconds,
  including their step numbers. The 10-second threshold identifies unusually
  long steps for investigation; it is not a rule for deleting samples.
- Compare both runs within the allocation. If the long steps recur, the
  intermittent delay remains and this job does not rank PGO or binding. If
  neither run stalls, this is only one stable snapshot; it still does not
  establish a PGO or binding effect.
- Preserve the full logs and Cd trajectories. Do not cherry-pick a minimum
  or replace the official Basic submission score with a diagnostic run.

This job can test recurrence under a matched configuration. Its logs alone
cannot identify whether a delay arose in the network, storage, or cluster
service; any such attribution needs additional evidence.
