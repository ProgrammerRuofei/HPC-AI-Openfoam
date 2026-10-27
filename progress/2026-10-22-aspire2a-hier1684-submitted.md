# ASPIRE2A hierarchical `(16 8 4)` stock Opt run submitted

Date: 2026-10-22 (Asia/Singapore). PBS job: `25906053.pbs101`.

## Purpose and controlled change

Repeat the historical hierarchical `(16 8 4)` case using the same pinned
OpenFOAM v2512 source template, AOCC 5.0 / Open MPI 5.0.10 stock `Opt`
binary, four nodes, 512 ranks, 150 steps, `ppr:128:node` launcher, and no
explicit binding as the completed hierarchical `(32 16 1)` control job
`25826705.pbs101`. The only computational setting changed in the cloned
script is `nHierarchical`. The new script also has distinct PBS names,
output paths, scratch directory prefix, and provenance labels.

The historical `(16 8 4)` result was 3.190876 s/step with Cd(150)
0.273561; its build/binding provenance was insufficient for a strict
three-XYZ ranking. The new job must save a fresh 150-row coefficient file
and its final Cd. The script refuses to reuse an existing PBS-ID directory.

## Local and remote actions

- Created `experiments/aspire2a-hier1684-opt-4n/run_hier1684_opt_4n_v1.pbs`
  and `experiments/aspire2a-hier1684-opt-4n/outputs/.gitkeep` only.
- `bash -n` and `git diff --cached --check` passed. The new script SHA-256
  was `e9b90b22f5ba6083b28e429ee816afdd99eb4e8a1296160718dba5544a2b1350`.
- Committed only the two new files as
  `909c95afc0a92bb8c13dbf0ab9323c49f28e541e`, then pushed to the
  approved ASPIRE2A bare Git transport. Other local modifications and
  untracked files were preserved.
- The ASPIRE2A control checkout fast-forwarded to the same commit. The
  script hash and `bash -n` matched locally. The PBS output files and
  `hier1684-opt-4n-v1-*` scratch paths were absent before submission.
- One `qsub` returned `25906053.pbs101`. First `qstat -f` showed `Q` in
  `q5`, with `Insufficient amount of resource: node_pool`; this is a queued
  resource wait, not a reported job failure.
- Existing untracked PBS stdout/stderr files in the remote control checkout
  were preserved.

## Exact cluster/Git commands

```sh
ssh -O check aspire2a-comp
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git status -sb && git log -1 --format="%H %s" && test ! -e experiments/aspire2a-hier1684-opt-4n && echo NEW_TARGET_ABSENT && test ! -e /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/hier1684-opt-4n-v1-* && echo SCRATCH_TARGET_ABSENT'
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git ls-remote aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git refs/heads/main
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only && git rev-parse HEAD && sha256sum experiments/aspire2a-hier1684-opt-4n/run_hier1684_opt_4n_v1.pbs && bash -n experiments/aspire2a-hier1684-opt-4n/run_hier1684_opt_4n_v1.pbs && test -d experiments/aspire2a-hier1684-opt-4n/outputs && test ! -e experiments/aspire2a-hier1684-opt-4n/outputs/hier1684_opt_4n_v1.o && test ! -e experiments/aspire2a-hier1684-opt-4n/outputs/hier1684_opt_4n_v1.e && test -z "$(find /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases -maxdepth 1 -type d -name "hier1684-opt-4n-v1-*" -print -quit)" && echo PREFLIGHT_READY && git status --short | tail -25'
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub experiments/aspire2a-hier1684-opt-4n/run_hier1684_opt_4n_v1.pbs'
ssh -o BatchMode=yes aspire2a-comp 'qstat -f 25906053.pbs101 | grep -E "Job Id:|job_state =|queue =|Resource_List.select =|Resource_List.walltime =|comment =|Exit_status ="'
```

## Remaining checks

On completion, verify PBS final status, preparation logs, exact 150 solver
steps, average wall-clock time per step, new 150-row `coefficient.dat`,
Cd(150), input and binary hashes, and script exit status. Then compare the
new `(16 8 4)` result with the `(32 16 1)` stock Opt result and the
historical `(8 8 8)` point, noting that the latter lacks a retained
at-run binary hash. Do not treat the historical Cd reference as a hard
0.28–0.29 acceptance cutoff; review the complete trajectory if the new
Cd again differs materially.

No job was cancelled, retried, or modified after submission. Existing
automatic monitoring remains paused.
