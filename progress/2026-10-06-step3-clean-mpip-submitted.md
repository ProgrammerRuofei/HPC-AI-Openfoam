# ASPIRE2A Step 3 clean mpiP profile — submitted

## Current status

Step 3 is submitted once as PBS job `25695102.pbs101`. At the end of the
bounded monitoring window it remained queued in `q5` with scheduler comment
`Not Running: Insufficient amount of resource: node_pool`. It has not started,
failed, completed, been cancelled or been resubmitted.

The submitted experiment is
`experiments/aspire2a-six-step/step3_clean_mpip_v1.pbs`, committed as
`f21db8001871e1116ee46c888cebb8d31409f2e8`. The local repository, remote bare
transport and remote control checkout reached that commit before submission.

## Experiment design

- Four nodes, 512 MPI ranks, 128 ranks per node, one OpenMP thread per rank.
- AOCC 5.0, Open MPI 5.0.10 and the verified Opt `simpleFoam` binary.
- KaHIP decomposition with one fresh partition shared by all arms.
- Core binding and placement: `--bind-to core --map-by ppr:128:node:PE=1`.
- Three 40-step arms in one allocation: unprofiled A0, mpiP-profiled P0,
  unprofiled A1.
- Steps 20-40 are the controlled timing window. The script computes A0/A1
  repeatability and P0 profiler overhead relative to the control-pair mean.
- Each arm recreates initial fields and must generate a fresh 40-row
  `coefficient.dat`.
- Coefficient output and extracted scientific trajectories must be
  byte-identical across A0, P0 and A1 for the script to pass.
- mpiP percentages are classified as measured MPI time, not total application
  runtime.

No mesh, `simpleFoam` source, `fvSchemes`, `fvSolution`, compiler, MPI,
decomposition strategy, rank count or binding strategy was changed from the
verified Step 2 baseline.

## Preflight evidence

Read-only ASPIRE2A inspection confirmed:

| Fact | Value | Evidence status |
| --- | --- | --- |
| mpiP library | `$HOME/scratch/tools/mpiP-install/lib/libmpiP.so`, 914,816 bytes | **DISCOVERED AND VERIFIED** by `stat` |
| mpiP SHA256 | `017bfc27b8ff4e767d46e77e9c2df698e90d085367feb5f25834d84d631841ba` | **DISCOVERED AND VERIFIED** by `sha256sum` |
| `simpleFoam` SHA256 | `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f` | **DISCOVERED AND VERIFIED** by `sha256sum` |
| mpiP MPI linkage | Open MPI 5.0.10 `libmpi.so.40` | **DISCOVERED AND VERIFIED** by `ldd` |
| mpiP wrappers | `MPI_Init`, `MPI_Finalize`, `MPI_Allreduce`, `MPI_Waitall`, `MPI_Isend`, `MPI_Send` | **DISCOVERED AND VERIFIED** by `nm -D` |
| Local/remote script SHA256 | `4a35045fae0e1dcf7bba25511ed041ffc623518e3663d765614bb614401a2ca3` | **DISCOVERED AND VERIFIED** after remote synchronization |

The login-node-only `ldd` initially resolved system libfabric and could not
resolve OpenFOAM-private libraries without the OpenFOAM environment. This is
not treated as runtime evidence. The submitted PBS script loads the exact job
environment and hard-gates both `simpleFoam` and mpiP against the retained
scratch libfabric before launching MPI.

Local `bash -n` passed. `shellcheck` was unavailable locally. The script's
timing parser was tested against the archived Step 2 logs and reproduced:

- A0: `2.827619047619 s/step`, 21 increments for steps 20-40;
- A1: `2.829047619048 s/step`, 21 increments for steps 20-40.

The same offline test confirmed byte-identical A0/A1 coefficient files and
scientific-trajectory extracts.

## Git synchronization

Only `experiments/aspire2a-six-step/step3_clean_mpip_v1.pbs` was staged in
commit `f21db80`. Pre-existing local modifications and untracked evidence were
left untouched.

The commit was pushed through the existing SSH alias to
`/home/project/59000020/openfoam-isc26/control.git`, then fast-forwarded into
`/home/project/59000020/openfoam-isc26/control-repo`. A status check after the
pull showed local and `origin/main` at `f21db80`, with only the previously
preserved PBS outputs untracked.

The first remote pull command exceeded the local 30-second wait while applying
the fast-forward. An immediate status check briefly observed the new file in
the index with the old `HEAD`; the pull then completed normally. A subsequent
check confirmed matching `HEAD`/`origin/main`, no staged diff, no Git lock and
the correct script hash before `qsub`.

## Exact remote and scheduler commands

The meaningful commands executed were:

```sh
ssh aspire2a-comp '<read-only stat, sha256sum, ldd, nm and git-status preflight>'
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push \
  aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && bash -n experiments/aspire2a-six-step/step3_clean_mpip_v1.pbs && sha256sum experiments/aspire2a-six-step/step3_clean_mpip_v1.pbs'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub experiments/aspire2a-six-step/step3_clean_mpip_v1.pbs'
ssh aspire2a-comp 'qstat -xf 25695102.pbs101'
```

The submission command was executed exactly once. Six additional low-frequency
status polls were performed over roughly three minutes; all returned the same
queued state and node-pool comment.

## Remote state changes

- Bare transport `main` advanced from `635e941` to `f21db80`.
- Remote control checkout fast-forwarded to `f21db80`.
- PBS job `25695102.pbs101` was created.
- No source/build/runtime library was modified.
- No OpenFOAM or MPI process had started by the last status check.
- No job was cancelled or resubmitted.

## Remaining TBD and exact resume action

Still unknown until the job runs:

- compute-node linkage gates and selected runtime libfabric;
- A0/P0/A1 completion and correctness;
- control-pair repeatability;
- mpiP overhead at 4 nodes / 512 ranks;
- complete mpiP report and measured MPI-time breakdown;
- PBS exit status and final resource usage.

Resume with a bounded `qstat -xf 25695102.pbs101`. If still queued, leave the
job unchanged. If running, do not interfere. If complete, inspect scheduler
state, stdout, stderr, scratch evidence, correctness gates and the complete
mpiP report before classifying the experiment. Do not retry automatically if
any gate fails.
