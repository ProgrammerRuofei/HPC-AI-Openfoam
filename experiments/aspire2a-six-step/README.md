# ASPIRE2A six-step experiments

The Step 2 clean repeatability control completed as job `25523028.pbs101`.
Its report and archived evidence are linked from
`progress/2026-09-23-aspire2a-six-step-optimization.md`.

## Step 3 clean mpiP profiling

Use the verified AOCC 5.0 / Open MPI 5.0.10 / Opt binary, a fresh 65,334,765-cell
KaHIP partition, four nodes and 512 core-bound MPI ranks. Run 40-step A0
control, P0 mpiP (`LD_PRELOAD`, `MPIP=-k 3`), then A1 control in one allocation.
Preserve input/binary/library hashes, rank affinity, fresh correctness files,
scientific trajectories and the complete mpiP report. Compare steps 20-40
ExecutionTime increments; retain the solver's wall-clock statistic separately.

### v1 — job 25695102.pbs101: harness failure after successful P0

Script commit: `f21db8001871e1116ee46c888cebb8d31409f2e8`.
Original PBS outputs: `scripts/outputs/step3_clean_mpip_v1.o` and `.e` in the
remote control checkout. Local archive:
`outputs/step3-v1-25695102/`. Original scratch artifacts remain intact.

A0 and P0 both completed 40 steps and finalized normally. Both fresh
coefficient files contain 40 rows, have Cd(40) `0.43471632678608485`, and share
SHA256 `2cca4fd36f8bc80c3e5799f6701ef3e097163d974730be47efa824f0e8caac0d`.
Their extracted solver/residual/continuity trajectories also share SHA256
`798044a16e28ab702dbc4817556749dc02832064f7f682b1304433378e743b9c`.

The P0 report `simpleFoam.512.1870938.1.mpiP` is 37,451,364 bytes, records all
512 ranks and has an `End of Report` footer. The shell harness exited with
`script_exit_rc=1` because its literal grep required
`Aggregate Time (top twenty)`; mpiP 3.5 actually prints
`Aggregate Time (top twenty, descending, milliseconds)`. This is a confirmed
Track 1 report-validation defect. A1 never ran. The overall A0/P0/A1
experiment is incomplete, although its completed arms and report are retained.
`qstat -xf` and `tracejob -n 2` no longer expose this job's scheduler history;
the final PBS exit status and resource accounting remain unavailable.

| Metric | A0 | P0 |
| --- | ---: | ---: |
| Steps 20-40 mean ExecutionTime increment, s/step | 2.849047619048 | 3.122857142857 |
| Solver average wall-clock time per step, s/step | 2.876553809102564 | 3.153061245358975 |

The single-control profiler-overhead estimate is
`100 * (3.122857142857 / 2.849047619048 - 1)`, approximately `9.61%`.
This is diagnostic evidence, not the planned bracketing-control result or an
optimization speedup. Full repeatability requires A1.

### v2 — routine harness repair

Preserve v1. Use new v2 job/output/run-root names, the same resources and
scientific/runtime configuration. Replace the brittle report-heading grep
with validation against mpiP 3.5 sections, the report footer and complete
rank assignments/rank timing rows. Test the validator against the retained
report and incomplete reports before synchronizing and submitting once.

User authorization: the user approved this profiling workflow and stated
on 2026-10-06 that subsequent routine submissions should proceed without
repeated approval pauses. This covers the deterministic harness repair;
changes to scientific inputs or optimization strategy remain separate.

## Evidence retrieval

Retain raw outputs under this experiment's `outputs/` using the existing
`aspire2a-comp` alias, non-interactive `scp -p -o BatchMode=yes` for files and
`scp -pr -o BatchMode=yes` for the run's evidence directory. Record the remote
and local hashes. Retrieve only the named run's logs/evidence/report, not its
mesh or processor case tree.
