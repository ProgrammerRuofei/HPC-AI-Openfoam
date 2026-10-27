# ASPIRE2A Scotch A/B/C preflight submitted

Date: 2026-10-22 (Asia/Singapore). Current step: preflight, before three full A/B/C blocks.

## Scope and files

The user approved the reviewed local diff and authorized committing, syncing, submitting the B/C preflight, then submitting the three full blocks only after preflight validation. Commit `b01d8e441088926e4e61f1b284f99e832cf2989a` added only `experiments/aspire2a-scotch-abc/` (README, common runner, preflight and three block PBS wrappers, output placeholder). Local unrelated modifications and untracked files were preserved.

The common runner uses the pinned AOCC 5.0 / Open MPI 5.0.10 stock Opt binary, fixed 65M-cell template, 4 nodes, 512 ranks, 150 steps for full runs, no profiler, no explicit binding. A is plain Scotch; B is `domains (4 8 16)` with `domainWeights (1 1 1)`; C is the same domains with `(1 1 0.01)`. Preflight decomposes B and C only and checks 512 processor directories. The runner refuses to reuse a PBS-ID output directory. The full job order is A-B-C, B-C-A, C-A-B.

Local `bash -n` passed on all new scripts; the staged diff whitespace check passed. Runner SHA-256 `6038937fe0acddd3ec86abe47f6a8f5387906c74f4f49bafd55a77f48b8cc3b4` matched the remote checkout.

## Remote actions and status

The existing SSH control socket was running. The approved Git transport received `b01d8e4`; the remote control checkout fast-forwarded to that commit. Existing untracked PBS output files were preserved. The preflight PBS job was submitted as **`25906729.pbs101`**. First and second `qstat -f` checks showed state `Q` in `q5`, comment `Insufficient amount of resource: node_pool`; there is no preflight result yet. No full A/B/C block has been submitted.

PBS stdout/stderr paths: `/home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-scotch-abc/outputs/scotch_abc_preflight_v1.o` and `.e`. Expected unique scratch root: `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-abc-preflight-b0-v1-25906729/`.

Exact remote/scheduler commands executed:

```sh
ssh -O check aspire2a-comp
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git status -sb && git log -1 --format="%H %s" && test ! -e experiments/aspire2a-scotch-abc && echo NEW_TARGET_ABSENT && test ! -e /home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-scotch-abc/outputs/scotch_abc_preflight_v1.o && echo PBS_OUTPUT_ABSENT'
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only && git rev-parse HEAD && sha256sum experiments/aspire2a-scotch-abc/run_scotch_abc_v1.sh && bash -n experiments/aspire2a-scotch-abc/run_scotch_abc_v1.sh && bash -n experiments/aspire2a-scotch-abc/run_scotch_abc_preflight_v1.pbs && test -d experiments/aspire2a-scotch-abc/outputs && test ! -e experiments/aspire2a-scotch-abc/outputs/scotch_abc_preflight_v1.o && test ! -e experiments/aspire2a-scotch-abc/outputs/scotch_abc_preflight_v1.e && echo PREFLIGHT_READY && git status --short | head -30'
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub experiments/aspire2a-scotch-abc/run_scotch_abc_preflight_v1.pbs'
ssh -o BatchMode=yes aspire2a-comp 'qstat -f 25906729.pbs101 | grep -E "Job Id:|job_state =|queue =|Resource_List.select =|Resource_List.walltime =|comment =|Exit_status ="'
ssh -o BatchMode=yes aspire2a-comp 'qstat -f 25906729.pbs101 | grep -E "Job Id:|job_state =|comment =|Exit_status ="'
```

## 2026-10-22 update: preflight passed; full blocks submitted

Historical `qstat -x -f 25906729.pbs101` reported state `F`, `Exit_status = 0`, and walltime `00:16:35`. The PBS stderr file was empty. Scratch `evidence/exit-status.txt` contained `script_exit_rc=0`; both `B_uniform` and `C_weighted` decomposition logs ended normally, each fresh case contained exactly 512 `processor*` directories, and both `summary.txt` files reported `partitions=512`. Effective dictionaries confirmed `domains (4 8 16)` with `domainWeights (1 1 1)` for B and `(1 1 0.01)` for C. Preflight root: `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-abc-preflight-b0-v1-25906729/`.

After checking the same intended Git commit, `bash -n` of all three PBS wrappers, and absence of existing full-block output/scratch targets, the approved full blocks were submitted:

| Block | Order | PBS ID | First observed state |
| --- | --- | --- | --- |
| 1 | A-B-C | `25909583.pbs101` | Q, `q5`, insufficient `node_pool` |
| 2 | B-C-A | `25909584.pbs101` | Q, `q5`, insufficient `node_pool` |
| 3 | C-A-B | `25909585.pbs101` | Q, `q5`, insufficient `node_pool` |

Exact additional remote/scheduler commands:

```sh
ssh -o BatchMode=yes aspire2a-comp 'qstat -x -f 25906729.pbs101 | grep -E "Job Id:|job_state =|Exit_status =|resources_used.walltime =|comment ="; root=/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-abc-preflight-b0-v1-25906729; cat "$root/evidence/exit-status.txt"; tail -35 "$root/evidence/run.log"; for arm in B_uniform C_weighted; do echo "ARM=$arm"; cat "$root/$arm/evidence/summary.txt"; tail -12 "$root/$arm/evidence/logs/10_decomposePar.log"; find "$root/$arm/case" -maxdepth 1 -type d -name "processor*" | wc -l; grep -E "domains|domainWeights" "$root/$arm/evidence/decomposeParDict.effective"; done'
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && test "$(git rev-parse HEAD)" = b01d8e441088926e4e61f1b284f99e832cf2989a && for n in 1 2 3; do f=experiments/aspire2a-scotch-abc/run_scotch_abc_block${n}_v1.pbs; bash -n "$f" || exit 1; test ! -e experiments/aspire2a-scotch-abc/outputs/scotch_abc_block${n}_v1.o || exit 1; test ! -e experiments/aspire2a-scotch-abc/outputs/scotch_abc_block${n}_v1.e || exit 1; done; test -z "$(find /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases -maxdepth 1 -type d -name "scotch-abc-full-b*-v1-*" -print -quit)" && echo FULL_BLOCK_TARGETS_READY'
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && for n in 1 2 3; do printf "block%s=" "$n"; qsub "experiments/aspire2a-scotch-abc/run_scotch_abc_block${n}_v1.pbs" || exit 1; done'
ssh -o BatchMode=yes aspire2a-comp 'for id in 25909583.pbs101 25909584.pbs101 25909585.pbs101; do qstat -f "$id" | grep -E "Job Id:|job_state =|queue =|comment =|Exit_status ="; done'
```

No jobs were cancelled, modified, or retried. Existing remote untracked files were preserved. The full-block status is external resource waiting; there are no new A/B/C solver results yet.

## Resume action

Check `qstat -f` for the three full-block IDs at a bounded interval. After they complete, validate each 150-step log, fresh 150-row coefficient file and Cd, average wall-clock time, and provenance before comparing paired differences. Do not retry or alter settings automatically if a block fails.

Adapter values used: SSH alias `aspire2a-comp`, remote root `/home/project/59000020/openfoam-isc26`, control checkout beneath it, PBS `qsub`/`qstat`, launcher `mpirun`; these are documented as CONFIRMED or DISCOVERED AND VERIFIED in `workflow/00-General-SSH-Rules.md`. Transfer forms, off-campus path, and polling limit remain TBD; no direct file transfer was used.
