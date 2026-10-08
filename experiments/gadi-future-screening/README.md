# Proposed Gadi screening scripts — local review only

Status: **PROPOSED / NOT SUBMITTED**

These scripts are local candidates for a later Gadi allocation. They have not
been copied to Gadi, submitted, or used to generate results.

## Why the decomposition screen comes first

The retained senior-team slide reports `2.4925 s/step` for a Gadi
hierarchical baseline and `2.0752 s/step` for Scotch (16.7% lower). Those are
second-hand values whose exact inputs, tuple, toolchain, placement and raw logs
are not retained here. Our official Gadi 4-node result is `2.139565 s/step`
with hierarchical `(16 13 2)`, so the senior-team percentage cannot be applied
to our baseline.

The proposed 2-node screen therefore tests the claim directly with the current
site module. It supports three arms:

1. `hierarchical` — contemporaneous control, `(8 13 2)`;
2. `scotch` — high-value Gadi hypothesis;
3. `kahip` — cross-cluster candidate and ASPIRE2A leader.

Each invocation changes only `decompositionMethod`. Nodes, ranks, case,
toolchain, solver settings, launcher, placement policy and 40-step screening
window remain fixed. `nHierarchical` stays `(8 13 2)` in all cases, although
it is ignored by Scotch and KaHIP.

The jobs should be run serially and close in time. A preferred order is
hierarchical → Scotch → KaHIP → hierarchical repeat. The repeat brackets node
and system variation. Do not claim a method win from a single close pair.

Proposed submission commands, for review only:

```bash
qsub -v SCREEN_METHOD=hierarchical experiments/gadi-future-screening/run_decomposition_2n_v1.pbs
qsub -v SCREEN_METHOD=scotch experiments/gadi-future-screening/run_decomposition_2n_v1.pbs
qsub -v SCREEN_METHOD=kahip experiments/gadi-future-screening/run_decomposition_2n_v1.pbs
qsub -v SCREEN_METHOD=hierarchical experiments/gadi-future-screening/run_decomposition_2n_v1.pbs
```

KaHIP availability on Gadi is **UNKNOWN**. The KaHIP arm deliberately treats
`decomposePar` as a hard availability gate. If the site OpenFOAM module lacks
the method or its libraries, the script retains the complete decomposition log
and stops before any MPI preparation step or solver run.

## Screen decision rule

- Primary metric: mean `ClockTime` increment over steps 20–40, extracted from
  the raw `simpleFoam` log after the run.
- Correctness gates: normal completion at step 40, finite residuals and Cd,
  matching input hashes, and a Cd trajectory within the agreed tolerance of
  the contemporaneous hierarchical control.
- At least 3% lower time in a repeatable comparison: advance to the official
  80-step 2-node and 150-step 4-node validation.
- Repeatable 1–3% lower time: promising, but repeat before validation.
- Below 1%: treat as unresolved unless repeated enough to establish noise.

The 40-step screen is not a competition result.

## Placement script status

`run_placement_1n_v1.pbs` is prepared but marked **HOLD**. Existing Gadi job
`178623596` already showed one rank per core, no SMT and no oversubscription
under the site default. Its expected information gain is therefore lower than
the decomposition screen. Run it only if later profiling shows NUMA or
rank-order sensitivity, or if the chosen decomposition changes the placement
hypothesis.

The placement script supports `default`, `core`, and `numa13`. It fixes the
current hierarchical `(4 13 2)` partition and changes only the MPI mapping and
binding arguments. Each arm records the actual rank/core/NUMA map before the
solver.

## Storage and execution controls

Both scripts create a job-id-specific case and never delete or overwrite an
existing result. Before any future submission, check scratch quota and inode
headroom, create the proposed result root and review the complete remote diff.
Cleanup is a separate destructive action and is not included here.

