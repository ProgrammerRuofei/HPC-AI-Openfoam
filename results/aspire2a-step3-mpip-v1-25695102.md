# ASPIRE2A Step 3 mpiP v1 — partial result

Recorded 2026-10-06 (Asia/Singapore). Job `25695102.pbs101`, script revision
`f21db8001871e1116ee46c888cebb8d31409f2e8`.

## Outcome and validity

The unprofiled A0 and mpiP-profiled P0 each completed 40 steps and finalized
normally. The overall A0/P0/A1 experiment is **incomplete**: a report-heading
validation defect caused the harness to exit before A1. The retained
`exit-status.txt` records shell exit code 1. The PBS history has expired from
`qstat -xf`; `tracejob -n 2` also found no record. Final PBS accounting is
unavailable and must not be invented.

Environment: AOCC 5.0, Open MPI 5.0.10, OpenFOAM v2512 Opt, KaHIP,
4 nodes / 512 MPI ranks, core binding, `ppr:128:node:PE=1` placement.
The mesh and partition evidence gives 65,334,765 cells, 2,786,035 distinct
processor-interface faces and 213,435 cross-node faces using the report's
actual rank-to-host assignments. Source:
`outputs/step3-v1-25695102/evidence/logs/10_decomposePar.log` and mpiP task
assignments (paths below).

## Timing evidence

| Metric | A0 control | P0 mpiP profile |
| --- | ---: | ---: |
| Steps 20-40 mean ExecutionTime increment (s/step) | 2.849047619048 | 3.122857142857 |
| Solver average wall-clock time per step (s/step) | 2.876553809102564 | 3.153061245358975 |

Each first-row value is the mean of 21 consecutive increments:
`sum(ExecutionTime[i] - ExecutionTime[i-1], i=20..40) / 21`.
Sources: `evidence/execution-time-A0.csv`, `execution-time-P0.csv`,
`steady-window-A0.txt`, `steady-window-P0.txt`, and the corresponding
`logs/50_simpleFoam_*.log`. Wall-clock values come from each log's
`Average wall-clock time per time step` line.

The single-control overhead estimate is
`100 * (3.122857142857 / 2.849047619048 - 1) = 9.610563%`.
Because A1 is absent, control-pair repeatability and the planned
bracketing-control overhead cannot be calculated. These values are
profiling diagnostics, not a speedup or final competition performance.

## Fresh correctness evidence

Both coefficient files have 40 data rows covering steps 1-40 and Cd(40)
`0.43471632678608485`. Their SHA256 is identical:
`2cca4fd36f8bc80c3e5799f6701ef3e097163d974730be47efa824f0e8caac0d`.
Sources: `evidence/coefficient-A0.dat`, `coefficient-P0.dat`, and their
`.sha256` / `.stat` provenance.

The extracted timestep, solver iteration/residual and continuity records
also match byte-for-byte, with SHA256
`798044a16e28ab702dbc4817556749dc02832064f7f682b1304433378e743b9c`.
Sources: `evidence/scientific-trajectory-A0.txt` and
`scientific-trajectory-P0.txt`. Runtime/binary/input hash gates and affinity
collection passed before either solver arm.

## MPI profile

The complete mpiP 3.5 report has 512 task assignments, 512 rank timing rows
and an `End of Report` footer. It is 37,451,364 bytes, SHA256
`b905f1fced29af87ff73e8675c620a036023df8cfa62ad6195e5ccec384f57cc`.
Report header: P0 began 2026-10-06 00:57:02 and stopped 00:59:19; report
serialization continued after the measured application interval.

| Call / category | Share of reconstructed measured MPI time |
| --- | ---: |
| Allreduce | 50.994579% |
| Waitall | 29.095454% |
| Collectives combined | 56.212881% |
| Wait/Test combined | 32.728659% |
| Point-to-point combined | 10.060116% |
| Other | 0.998344% |

Calculation: sum `Count * Mean_ms` over every per-rank row in
`Callsite Time statistics (all, milliseconds)`, group by call/category,
then divide by the sum over all calls. Reconstructed total is
18,315.530783 rank-seconds; the sum of rounded per-rank MPI timing rows is
18,315.7 rank-seconds (ratio 0.999990761). The existing parser
`planning/evidence/aspire2a-mpip-4n512-2026-09-23/analyze_mpip_reports.py`
was reused through its `parse_report`, `category` and `parse_decompose`
functions without modifying earlier evidence.

These percentages describe measured MPI time in the instrumented P0 run.
They do not directly describe total application runtime or a wall-clock
saving available from removing a call. Rank-seconds are summed across ranks,
not elapsed job seconds. A1 is still required for the clean profiling closure.

## Failure and repair

The original script required the literal heading
`Aggregate Time (top twenty)`. The real report contains
`Aggregate Time (top twenty, descending, milliseconds)`, so that grep failed.
The report and successful solver arms remain useful evidence. The v2 repair
matches the actual section prefix and validates complete ranks and footer.

## Evidence index and provenance

Local raw archive:
[`step3-v1-25695102`](../experiments/aspire2a-six-step/outputs/step3-v1-25695102/).
It contains original PBS `.o/.e`, the run's complete `evidence/` directory
and `simpleFoam.512.1870938.1.mpiP`. Remote originals remain intact.
The local report SHA256 matches the remote original.

Cluster operations for this attempt were performed by Codex through the
user-authorized workflow. Human approval of the experiment is recorded in
this chat; do not imply these commands were manually typed by the user.
