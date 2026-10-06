# Step 3 mpiP — v1 outcome and v2 submission

Recorded 2026-10-06, Asia/Singapore. Current step: Step 3 profiling.

## Completed work

SSH was restored after the stale Master was replaced by the user.
Read-only inspection found that v1 job `25695102.pbs101` had completed A0
and P0 but stopped before A1. Shell `script_exit_rc=1` is retained; PBS
accounting is unavailable from `qstat -xf` and `tracejob -n 2`.

The confirmed Track 1 defect was a literal report-heading grep:
`Aggregate Time (top twenty)` does not match mpiP's real heading
`Aggregate Time (top twenty, descending, milliseconds)`.
The solver and profiler both completed, so preserve their valid partial
evidence while classifying the three-arm experiment as incomplete.

Raw PBS outputs, all run evidence and the 37,451,364-byte mpiP report were
retrieved to `experiments/aspire2a-six-step/outputs/step3-v1-25695102/`.
The report's local and remote SHA256 match:
`b905f1fced29af87ff73e8675c620a036023df8cfa62ad6195e5ccec384f57cc`.
Remote originals were left intact. Detailed quantitative results and sources:
[`v1 result`](../results/aspire2a-step3-mpip-v1-25695102.md).

V2 corrects report validation and changes only the attempt/job/output/root
names plus validation code. Resources, workload, binary, MPI, compiler,
decomposition, preparation and binding remain those of v1.
`bash -n` passes. The new validator accepts the complete v1 and historical
KaHIP reports and rejects missing-rank coverage. No software was installed.

## Current attempt

- Script: `experiments/aspire2a-six-step/step3_clean_mpip_v2.pbs`.
- Commit: `03ff2e0ac7aa2ab707bb682e002ee317214e1e5f`.
- Script SHA256: `13af7d2b153ce0a66510346ae0ea009ab139b6c4c99226b63b7ef61f21c196e8`.
- PBS job: `25702468.pbs101`, submitted exactly once.
- First status: `Q` in `q5`, `Insufficient amount of resource: node_pool`.
- Requested: 4 nodes, 128 ranks/node, 400 GB/node, 1 hour walltime.
- PBS outputs: remote `scripts/outputs/step3_clean_mpip_v2.o` and `.e`.
- Scratch evidence root after start:
  `$HOME/scratch/openfoam-v2512/cases/step3-clean-mpip-v2-25702468/`.

The user previously authorized routine submissions without repeated approval
pauses. Only the new v2 script, experiment README and v1 result record were
included in the repair commit. Existing unrelated changes remain untouched.

## Remote actions and state changes

Evidence was retrieved via non-interactive `scp -p -o BatchMode=yes` (files)
and `scp -pr -o BatchMode=yes` (the named run's evidence directory).
The reviewed local commit was pushed to the existing ASPIRE2A bare
`control.git`, then fast-forward pulled into `control-repo`. Local/remote
script hashes matched; `bash -n` and new output-name collision gates passed.
`qsub experiments/aspire2a-six-step/step3_clean_mpip_v2.pbs` was invoked once,
followed by `qstat -xf 25702468.pbs101`.

No source/runtime library was modified and no prior result was overwritten.
The only new scheduler state is queued job `25702468.pbs101`.

## Exact next action and unresolved evidence

Inspect `qstat -xf 25702468.pbs101` at a bounded cadence. On completion,
retrieve and inspect scheduler status, PBS output, per-arm completion,
fresh Cd/trajectory comparisons, control repeatability, profiler overhead,
affinity, hashes and full mpiP report. A0/A1 repeatability and clean three-arm
closure are pending. Any new uncertain runtime/scientific failure needs
evidence-based diagnosis before a further attempt.
