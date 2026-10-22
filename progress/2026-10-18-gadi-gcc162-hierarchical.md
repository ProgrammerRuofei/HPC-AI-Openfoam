# Gadi GCC 16.2 hierarchical controlled comparison

Status: reviewed and ready for one PBS submission; result pending.

## Authorization and rule check

The user approved a GCC 16.2 hierarchical comparison after seeing the local
Scotch-to-hierarchical script diff and specifically asked for a competition-rule
check before submission. The current 2026 OpenFOAM HPC Task Rules, including
the 2026-09-25 addendum F0/F1, allow `hierarchical` and `scotch` in Basic and
permit edits to `nCores`, `decompositionMethod`, and `nHierarchical` in a fresh
case copy. The 4-node point requires 150 SIMPLE steps. The 1/2/4-node scaling
points require 40/80/150 steps respectively; metrics from those unlike points
must not be treated as same-workload timing comparisons. Rule source:
https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md

The older site-module series uses `(4 13 2)` at 104 ranks, `(8 13 2)` at
208, and `(16 13 2)` at 416. This experiment uses only the 4-node/416-rank
shape, so 16 * 13 * 2 = 416. The Gadi source `caseDefinition` was checked
read-only on 2026-10-18: `nCores 192`, `decompositionMethod hierarchical`,
`nHierarchical (16 6 2)`. The source `decomposeParDict` includes that definition
and retains `delta 0.001` and `order xyz`. The PBS script copies the case and
edits only the three permitted decomposition entries in its job-local copy.
It keeps the same seven source SHA256 checks, original mesh, `simpleFoam`,
`fvSchemes`, `fvSolution.fixedIter`, `controlDict.noWrite` and function objects.
The full Allrun command sequence, including `potentialFoam` and
`applyBoundaryLayer -ybl 0.0450244`, is retained.

## Controlled configuration

- Build: OpenFOAM.com v2512, GCC/G++ 16.2.0, `linux64GccDPInt32Opt`, same
  SHA256-pinned OpenFOAM and toolchain archives as the two successful Scotch
  runs. Double precision; no solver source changes.
- MPI/transport: private Open MPI 5.0.10 built with GCC 16.2; Gadi UCX 1.18.1,
  UCC 1.4.4, PBS TM and UCX PML.
- Hardware: Gadi `normalsr`, four Intel Xeon Platinum 8470Q Sapphire Rapids
  nodes, 104 physical cores and MPI ranks per node, 416 ranks total.
- Placement: `mpirun --prefix ... --map-by ppr:104:node --mca pml ucx -np 416`;
  no explicit `--bind-to`, matching the Scotch script. Rank-to-host mapping
  is verified by the job.
- Decomposition: hierarchical `(16 13 2)`, `delta 0.001`, `order xyz`.
- Workload: pinned ~65M `occDrivAerStaticMesh`, full official preparation
  chain, 150 solver steps. No 1N/2N job is submitted for this comparison.
- PBS request: pm78, 416 CPUs, 760GB memory, 100GB JOBFS, 01:00:00. At
  2 SU/core-hour, the maximum reservation is 832 SU. Based on the Scotch
  runs, actual billing may be ~230-260 SU, but it depends on elapsed time.
  Before submission, `nci_account -P pm78` reported 4.85 KSU available and
  zero reserved. Scratch was 197.81K of 202K inodes used, so the existing
  node-local JOBFS processor layout is retained.
- Baseline comparator: GCC 16.2/Scotch jobs `181368883` and `181371071`:
  1.991194389 and 1.988625920 seconds/step, Cd 0.291875949. The older
  site-module hierarchical job `178149002` is a separate absolute reference
  and cannot isolate decomposition because the compiler and MPI differ.

## Script and validation

`builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_v1.pbs`
is the reviewed script, derived from the successful Scotch script. It has a
unique PBS stdout and job-keyed `baseline-4n-hierarchical/<jobid>/evidence/`
path. `bash -n` and a static comparison of resource directives, runtime
archives/hashes, source checks and MPI launcher passed locally. Before qsub,
confirm the remote fast-forwarded commit, exact script SHA256, source inputs,
account balance, and absence of the unique stdout/output path.

A successful result requires PBS `Exit_status=0`, the hierarchical pass marker,
four SPR hosts each with 104 ranks, all five chain `End` markers, `Time = 150`,
normal MPI finalisation, coded average seconds/step, Cd sanity and actual SU.
Record the full configuration and result in `results/` and the build README.
No same-build repeat is authorized by this approval.

## Submitted job

On 2026-10-18, local commit `883cee76f8fef2b5a8460ac11e74b9819d443984`
was pushed to GitHub and Gadi. The Gadi checkout fast-forwarded from
`6d8787a` to the same commit; the reviewed script SHA256 on both sides was
`e18164e4f3043e45cbe6972f7619e605a7838ce0c612e48961ab92d9621390f7`.
The existing unrelated remote untracked paths under `experiments/` were
preserved. The single submission command was:

```sh
ssh -o BatchMode=yes gadi-comp 'set -e; cd /scratch/pm78/kj7183/openfoam_cpu/control-repo; test "$(git rev-parse HEAD)" = 883cee76f8fef2b5a8460ac11e74b9819d443984; test ! -e /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_hierarchical_v1.pbs.out; /opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_v1.pbs'
```

PBS returned `181519873.gadi-pbs`. The immediate `qstat -f` showed Q in
`normalsr-exec`, `select=4:ncpus=104:mpiprocs=104`, `ncpus=416`, and one-hour
walltime. The unique stdout path is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_hierarchical_v1.pbs.out`.
Job-keyed evidence will be in
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-hierarchical/181519873.gadi-pbs/evidence/`.
Result and actual charge are pending. Do not submit a repeat without new user
approval.

## Later read-only result recovery (2026-10-22)

The result had completed but had not been reconciled into this report.
`qstat -xf` no longer retains this job ID. The preserved independent PBS
stdout contains the NCI accounting receipt: **Exit Status 0**, **188.36 SU**,
13:35 walltime, 416 CPUs, 306.04 GB used memory and 22.07 GB used JOBFS.
The script recorded `script_exit_rc=0` and
`GCC162_OMPI5010_OF2512_HIERARCHICAL_4N_PASS`. All four preparation logs
and the solver log contain normal `End`; `simpleFoam` reached `Time = 150`
and `Finalising parallel run`. Rank-host-map has four distinct SPR hosts,
104 ranks each. The decomposition record shows `hierarchical (16 13 2)`.
The coded metric is **2.058549642268457 s/step** and final
**Cd = 0.28230614272579119**. The pinned case and stack provenance files
remain in the job-keyed evidence directory above.

The two same-stack Scotch runs averaged **1.989910155 s/step** and Cd
0.2918759493. Scotch was **3.33% faster** on the coded solver-step metric
than this one hierarchical run. Both Cd values lie in the predeclared
0.27–0.30 band, though they differ by about 0.00957. This is a controlled
decomposition comparison at the same compiler/MPI/rank count and iteration
count; it has no hierarchical repeat. No new PBS job was submitted to
recover the old result.
