# ASPIRE2A hierarchical `(32 16 1)` stock Opt comparison

Status: **prepared locally; not submitted**.

## Purpose

Run one unprofiled 4-node, 512-rank, 150-step `occDrivAerStaticMesh`
solve with hierarchical `(32 16 1)`. This fills the build-matched
performance gap between the existing PgoUse hierarchical `(32 16 1)` run
(`24608558.pbs101`, 3.007944 s/step, Cd 0.290022) and the stock Opt,
unbound weighted Scotch Basic run (`20072244.pbs101`, 2.905 s/step,
Cd 0.2886). A single run remains subject to run-to-run variation.

## Script and runtime

- PBS script: `run_hier32161_opt_4n_v1.pbs`.
- Submit from the approved remote `control-repo` checkout after review and
  synchronization. PBS output is written to this experiment's `outputs/`.
- Existing OpenFOAM v2512 AOCC 5.0 stock Opt build with Open MPI 5.0.10;
  no build or software installation.
- Four ASPIRE2A standard compute nodes, 128 MPI ranks per node, 150 steps.
- Launcher uses the same explicit `ppr:128:node` mapping as the teammate's
  unbound weighted Scotch run, with no `--bind-to` setting.
- The existing scratch case template is read, and the new case is placed in
  a unique, absent PBS-ID directory under `~/scratch/openfoam-v2512/cases/`.
  The script refuses to reuse a directory and copies only scientific inputs,
  excluding old logs, postProcessing, and processor directories.
- The full official preparation chain is retained: `decomposePar -constant`,
  `restore0Dir -processor`, `renumberMesh -constant -overwrite -parallel`,
  `potentialFoam -initialiseUBCs -parallel`,
  `applyBoundaryLayer -ybl 0.0450244 -parallel`, then `simpleFoam -parallel`.
- The script records module versions, binary hash and linkage, effective
  input hashes, allocation, rank affinity, solver log, and a new 150-row
  `coefficient.dat`. It checks the `Time = 150` and `End` markers.

## Validation and result handling

`bash -n` must pass locally and remotely before submission. After completion,
check PBS final state/exit status, every preparation log, the solver metric,
fresh Cd(150), and input/binary provenance. Record the result in `results/`
without replacing the original PgoUse run or the weighted Scotch submission.

## Approval boundary

The current project `AGENTS.md` requires the relevant local diff to be shown
and approved before remote-affecting changes. No commit, push, pull, remote
write, build, or PBS submission is part of local preparation.
