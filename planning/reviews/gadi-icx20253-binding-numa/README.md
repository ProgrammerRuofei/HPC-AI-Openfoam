# ICX binding/NUMA: review package — not deployed

2026-10-30. No PBS submission, remote script modification, commit or push has
been performed for this package. These are review patches, not installed scripts.

## Proposed files and full diffs

- [Complete proposed additions](proposed-scripts.patch)
- [Preflight compared with successful GCC placement probe](preflight-vs-gcc.diff)
- [Paired run compared with successful same-host rank-count script](pair-vs-rankcount.diff)
- [Detailed plan](../../gadi-icx20253-binding-numa-plan.md)

## Approval scope to request

One preflight and at most two sequential paired blocks: P0, then AB, then BA.
ICX 2025.3.2 / Open MPI 5.0.10 / Scotch, one SPR node, 104 ranks. P0 is
10 minutes / 34.67 SU; each pair is 40 minutes / 138.67 SU; total 312 SU maximum.
Each pair has two fresh 40-step cases. The second block waits for the first's
validation. No four-node run, extra repeat, automatic failed-job retry,
installation, scientific-input change or historical-evidence deletion.

Request includes materializing reviewed files on codex/gadi-gcc162-build,
committing only related files, pushing existing GitHub/Gadi branches,
remote ff-only/hash checks, these bounded submissions, read-only monitoring,
verified SCP retrieval and raw-log/result documentation. Main's unrelated
changes remain untouched. Approval must follow display of this diff.

## Submission protocol after approval

1. Verify adapter, control connection, quota, archive paths and local/remote
   reviewed hashes; preserve the explicit tracked/untracked baseline.
2. Use the established remote control checkout as PBS working directory.
   Ensure each independent stdout path does not exist before qsub.
3. Submit preflight once; record returned job ID immediately. Unknown qsub
   outcome requires queue/evidence inspection, never a blind resubmission.
4. Check PBS Exit 0, preflight PASS, runtime receipts and acceptance.json.
   Identical masks mean skip both solves; changed NUMA placement means stop.
5. Submit pair using `-v BIND_ORDER=ab,BIND_PREFLIGHT_JOB=<verified job ID>`
   and explicit `-o .../run_binding_pair_1n_v1_ab.pbs.out`.
   The PBS file's UNSET output placeholder must never be used for submission.
6. After AB correctness/geometry/Cd/placement checks, submit BA once with
   `BIND_ORDER=ba` and a distinct `..._ba.pbs.out`. No automatic dependency
   chain that bypasses validation. Gate on PBS receipt as well as script PASS.
7. Retrieve original bytes and per-file SHA-256, both default/core subfolders,
   PBS receipt/actual SU; update job index/results/progress. Compare paired
   ratios within each job, then check consistency across reversed-order blocks.

## Local validation

These checks do not execute MPI, OpenFOAM, a cluster job or a compiler.
No current compute-node topology or runtime success is claimed.

```
experiments/gadi-icx20253-binding-numa/preflight_binding_numa_1n_v1.pbs: bash -n and 1 embedded Python blocks pass
experiments/gadi-icx20253-binding-numa/run_binding_pair_1n_v1.pbs: bash -n and 4 embedded Python blocks pass
Affinity: archived 104-rank default/core pair passes; identical treatment skipped; missing rank/shared core/outside-mask cases rejected. Topology fixture derives from archived 2x52-core/8-NUMA host, not current host assumption.
Archived solver/decomposition/Cd validation: {
  "default_s_step": 8.373520290307694,
  "core_s_step": 8.346359078358972,
  "partition_identical": true,
  "max_abs_Cd_difference": 0.0,
  "comparable_cd": true,
  "core_improvement_percent": 0.32437028880386415
}
New-file review patch applies cleanly in an empty temporary directory.
```

## Proposed content SHA-256

* `experiments/gadi-icx20253-binding-numa/preflight_binding_numa_1n_v1.pbs`: `3be58d39a4d7a55f27569250e2c756f9045c4795037ab1edeea40d83e712c9a4`
* `experiments/gadi-icx20253-binding-numa/run_binding_pair_1n_v1.pbs`: `fa7a5218b1e691e058274a3b5309da5252caecde5d9684ce825d3ba28b707871`
* `experiments/gadi-icx20253-binding-numa/affinity_receipt.py`: `e678b840d7be8a43df7a884f259f5a542106b145378b36458373c6a8dc218022`

## Approval received 2026-10-30

User explicitly approved the first three-job batch, maximum 312 SU, including isolated-branch commit/synchronization, sequential gated submission and raw evidence retrieval. No further approval is needed for these unchanged reviewed jobs. Failures stop progression; additional jobs remain excluded.
