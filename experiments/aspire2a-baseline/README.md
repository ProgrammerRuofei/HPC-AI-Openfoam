# ASPIRE2A OpenFOAM v2512 baseline workflow repair

## Purpose

`run_baseline_fixed.pbs` is a **candidate workflow repair**, not an optimisation experiment. It was created locally from the copied cluster evidence and has not been submitted, uploaded, or run.

## Selected source evidence

The selected source is `pbs_of2512_4n512_baseline01.pbs`.

It is the closest copied representation of the intended current baseline: OpenFOAM v2512, four PBS nodes, 128 MPI ranks per node (512 total), one OpenMP thread per rank, the existing case directory, existing 512-way decomposition, existing `mpirun` syntax, and the existing CPU binding. It also uses run-tagged per-stage logs, so it is preferable to `pbs_run_65M_512.pbs`, which copies benchmark dictionaries before running and uses less traceable fixed stage-log names.

The remaining copied PBS files are setup or smoke-test evidence, not a reconstruction source for the four-node baseline run.

## Preserved failure evidence

The observed previous failure was:

```text
restore0Dir: command not found
exit code 127
```

`restore0Dir` is an OpenFOAM shell function, rather than a standalone executable. The copied baseline loaded `openfoam/2512` but did not source `$WM_PROJECT_DIR/bin/tools/RunFunctions`, which defines that function. The failure occurred before `simpleFoam` launched, so it is a deterministic workflow-environment failure, not a performance result.

## Candidate changes

The candidate makes only these workflow repairs:

1. After preserving the original `module load openfoam/2512`, it verifies that `WM_PROJECT_DIR` is set.
2. It derives and verifies `$WM_PROJECT_DIR/bin/tools/RunFunctions`, then sources it before the `restore0Dir` call.
3. It verifies that `restore0Dir` resolves as a shell function and that `simpleFoam` resolves to an executable.
4. It verifies the expected case directory before changing into it or launching application stages.
5. It emits explicit pre-run validation messages and exits with code 2 on a missing prerequisite.
6. It gives the candidate a distinct PBS job/output name and a distinct run tag, preserving traceable logging without overwriting the copied baseline's named log files.

## Explicitly unchanged

The candidate intentionally does **not** change:

- the `openfoam/2512` module choice or OpenFOAM version;
- compiler or MPI implementation;
- four-node allocation, 128 ranks/node, 512 total ranks, or one thread/rank;
- walltime, queue, project, memory request, and all other PBS resource settings;
- `mpirun` launcher syntax, `--ppn`, or `--cpu-bind depth -d 1` placement/binding;
- `nHierarchical`/other decomposition settings or existing processor directories;
- mesh, case path, `fvSchemes`, `fvSolution`, `controlDict`, `simpleFoam`, and scientific workload;
- the `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`, and `simpleFoam` command lines.

## Successful baseline-validation evidence

An eventual run is a successful workflow validation only when the PBS output and stage logs show all of the following:

1. `WM_PROJECT_DIR`, the `RunFunctions` path, `restore0Dir=function`, the executable `simpleFoam` path, and the expected case directory are printed followed by `Pre-run validation: PASS`.
2. The processor-directory check confirms 512 existing `processor*` directories.
3. `restore0Dir -processor` completes without the previous `command not found`/127 failure.
4. Each stage log exists; `simpleFoam` launched and contains normal execution/timing markers rather than a `FOAM FATAL`, floating-point failure, or NaN marker.
5. The run meets the later-agreed scientific correctness/convergence checks. PBS exit status alone is insufficient.

## Remaining assumptions requiring a real ASPIRE2A test

- The module still sets `WM_PROJECT_DIR` and its RunFunctions location remains `$WM_PROJECT_DIR/bin/tools/RunFunctions`.
- The existing absolute case and PBS output paths exist and are writable.
- The case is already decomposed into exactly 512 processor directories.
- The copied PBS resource syntax, `mpirun` syntax, and CPU binding are still accepted by ASPIRE2A.
- The expected case dictionaries and mesh are present and scientifically valid.
- The eventual authoritative correctness/convergence criteria and official workload rules remain to be confirmed.

No remote verification, upload, submission, or optimisation decision is authorised by this candidate.

## Attempt `4n512_baseline_fixed_v1` — failed pre-run validation

- **PBS job ID:** `15811292.pbs101`
- **PBS output:** `/home/project/59000020/openfoam-isc26/results/of2512_4n512_baseline_fixed.out`
- **Observed error:** `/app/apps/openfoam/2512/OpenFOAM-v2512/bin/tools/RunFunctions: line 29: FOAM_LD_LIBRARY_PATH: unbound variable`
- **Result:** no preprocessing or `simpleFoam` stage log was created; PBS historical status was `F` with exit status `1` after approximately three seconds.
- **Cause:** the candidate enabled Bash `set -u` before sourcing `RunFunctions`. That helper references `FOAM_LD_LIBRARY_PATH`, which is not defined by the module environment at source time.
- **Track 1 repair:** `run_baseline_fixed_v2.pbs` sources and validates `RunFunctions` before enabling `set -u`; all OpenFOAM, PBS resource, MPI, binding, decomposition, case, and solver settings remain unchanged. It has new job/output/log identifiers and will not overwrite this failed evidence.

## Attempt `4n512_baseline_fixed_v2` — stopped during renumberMesh

- **PBS job ID:** `15811806.pbs101`
- **PBS output:** `/home/project/59000020/openfoam-isc26/results/of2512_4n512_baseline_fixed_v2.out`
- **renumberMesh log:** `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-isc26/cases/occDrivAerStaticMesh-v2512/logFiles/20_renumberMesh.4n512_baseline_fixed_v2.log`
- **Observed validation:** `WM_PROJECT_DIR`, `RunFunctions`, `restore0Dir=function`, executable `simpleFoam`, case directory, and 512 processor directories all passed. `restore0Dir -processor` completed.
- **Observed run state:** `renumberMesh` ran on 512 ranks across four nodes and printed `End`, but its log ended with `rank 100 died from signal 7`. PBS historical status was `F`, exit status `143`, after 68 seconds wall time.
- **Not reached:** `potentialFoam`, `applyBoundaryLayer`, and `simpleFoam` logs were absent. No solver timing or scientific result exists.
- **Classification:** Track 2 manual inspection. The signal/PBS termination cause is not established from current evidence; do not patch, retry, or alter MPI/resources/binding/decomposition without a separately authorized diagnosis.
- **Read-only diagnosis result:** the complete stage log has no `FOAM FATAL`,
  NaN, or explicit MPI error; the signal follows `End` and `Finalising parallel
  run`. No retained PALS or job-specific diagnostic file was accessible after
  completion. The cause remains unresolved.

## Attempt `4n512_baseline_fixed_v2_retry1` — reproducible renumberMesh finalisation failure

- **PBS job ID:** `15812450.pbs101`
- **PBS output:** `/home/project/59000020/openfoam-isc26/results/of2512_4n512_baseline_fixed_v2_retry1.out`
- **renumberMesh log:** `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-isc26/cases/occDrivAerStaticMesh-v2512/logFiles/20_renumberMesh.4n512_baseline_fixed_v2_retry1.log`
- **Configuration control:** the exact v2→retry1 diff changes only PBS job/output identifiers and `RUN_TAG`; local and remote `bash -n` passed and SHA-256 matched after upload.
- **Observed validation:** the same environment preflight and `restore0Dir -processor` workflow passed; 512 processor directories, four nodes, and 512 MPI slots were recorded.
- **Observed failure:** `renumberMesh` reached `End` and `Finalising parallel run`, then reported `x1001c6s4b0n1...: rank 185 died from signal 7`. PBS historical status was `F` with exit status `135`, after 58 seconds wall time.
- **Comparison with v2:** v2 reported rank 100 on `x1001c2s1b1n0...`, exit status `143`, and 68 seconds wall time. Both failures occur at the same stage/finalisation location, but on different rank/node allocations.
- **Classification:** **REPRODUCIBLE FAILURE** at the `renumberMesh` parallel-finalisation stage; **NON-DETERMINISTIC / PLATFORM-RUNTIME SUSPECT** for the varying rank/node manifestation. `potentialFoam`, `applyBoundaryLayer`, and `simpleFoam` were not started. Stop without retry or configuration change.
- **Repeat-control limitation:** `renumberMesh -overwrite` modified the
  processor mesh in v2. Retry-1 therefore began with v2's already-renumbered
  mesh state, despite identical PBS/module/MPI/command configuration. The
  recurring failure is strong workflow evidence, but not a strict
  identical-initial-state reproducibility proof.
