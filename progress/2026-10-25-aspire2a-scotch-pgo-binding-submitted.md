# ASPIRE2A Scotch PGO × binding study submitted (2026-10-25)

## Scope and authorization

The user approved the displayed script diff, a local Git commit, ASPIRE2A Git
sync, and two four-node PBS submissions. The user separately approved a narrow
`aspire2a-comp.password` Git-push exception for this project's `control.git`;
the local `AGENTS.md` and `workflow/00-General-SSH-Rules.md` were amended.
Those documentation files had pre-existing unstaged changes and were not
included in the reviewed script commit.

## Build audit and reviewed scripts

- Read-only ASPIRE2A login returned `asp2a-login-ntu01` / `apacsc20`.
- Stock Opt `simpleFoam` SHA-256:
  `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f`.
- Existing AOCC PgoUse `simpleFoam` SHA-256:
  `240319310acc34e50851ac7b43506b2d0d165e30705e865de013f3bdf373fc26`.
- Existing merged PGO profile SHA-256:
  `01c9673719b97bf027ba673bbfcedb645ae4cc76ffd10bdee21443ff924ff834`.
- Both `c++Opt` and `c++PgoUse` rules show `c++OPT := -O3`. The retained PgoUse
  build script adds `-fprofile-instr-use` with the existing merged profile;
  training used the same DrivAer workload with KaHIP on one node. Compute-node
  runtime linkage remains to be checked by the submitted job.
- Local commit `78e3701913ade28c967b9de670e160e09b17923b` contains only the
  new PGO/binding runner, two PBS wrappers, and output-directory scaffold.
  The runner is derived from the previous validated Scotch A/B/C chain. All
  four arms use weighted Scotch `domains (4 8 16)`, `domainWeights (1 1 0.01)`,
  AOCC 5.0 / Open MPI 5.0.10, 4 nodes × 128 ranks, and 150 steps. Only the
  solver build (`Opt`/`PgoUse`) and solver placement (default/core) vary.
  Blocks reverse arm order. Existing mesh and numerical dictionaries are
  hash-gated; per-arm logs, rank affinity, coefficient.dat, and Cd are retained.
- `bash -n` passed locally and again in the ASPIRE2A control checkout. Remote
  checkout fast-forwarded to the same commit. Existing unrelated untracked
  PBS output files there were preserved.

## PBS submissions and first status

| Block | PBS job | Initial state | Queue comment |
| --- | --- | --- | --- |
| 1, O_default → O_core → P_core → P_default | `25970245.pbs101` | Q / q5 | User has reached queue q5 running job limit |
| 2, P_default → P_core → O_core → O_default | `25970246.pbs101` | Q / q5 | User has reached queue q5 running job limit |

Both request `select=4:ncpus=128:mpiprocs=128:mem=400gb`, `place=scatter`,
and `walltime=06:00:00`. `qstat -u apacsc20` listed these two queued jobs and
no other jobs for this account at the time of inspection. The queue comment
does not prove a failure and needs no immediate intervention.

Unique scratch roots will be
`/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-pgo-binding-b{1,2}-v1-<PBS-ID>`.
PBS output paths are under
`/home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-scotch-pgo-binding/outputs/`.

## Commands and state changes

Read-only: `ssh -O check aspire2a-comp`; two documented direct-SSH build and
Git-state probes; `qstat -f` for the new IDs; `qstat -u apacsc20`.
The control socket was absent. The new approved `GIT_SSH_COMMAND` using
`sshpass -f` pushed local `main:main` only to
`aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git`.
The remote direct-SSH command then ran `git pull --ff-only`, `bash -n` over the
three scripts, and verified the output paths did not pre-exist.
Submission commands from the control checkout were:

```sh
qsub experiments/aspire2a-scotch-pgo-binding/run_scotch_pgo_binding_block1_v1.pbs
qsub experiments/aspire2a-scotch-pgo-binding/run_scotch_pgo_binding_block2_v1.pbs
```

No job was cancelled or retried; no old result was overwritten. The two PBS
jobs are the only new remote workload state changes.

## Next action

At a later bounded check, inspect each job's state. On completion, require
script exit status 0, exact 150 solver steps for all four arms, average
wall-clock time per step, fresh 150-row coefficient.dat and Cd, the saved
rank-affinity mapping, and binary/input provenance before analysis. Do not
promote a single minimum to a PGO or binding gain; compare both blocks and
report timing variation. A queue delay alone is not a reason to resubmit.
