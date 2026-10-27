# ASPIRE2A stock Opt decomposition comparison — jobs submitted

Current step: Step 4, queued on PBS. Monitoring automation checks roughly
every 30 minutes and reports material changes. No retry is authorized.

## Jobs

| PBS ID | Purpose | Status at last check | Evidence path |
| --- | --- | --- | --- |
| `25826705.pbs101` | 4-node, 512-rank, 150-step unprofiled hierarchical `(32 16 1)` stock Opt | `Q`, `q5`; insufficient `node_pool` resources | `experiments/aspire2a-hier32161-opt-4n/outputs/hier32161_opt_4n_v1.{o,e}`; scratch `cases/hier32161-opt-4n-v1-25826705/` |
| `25826770.pbs101` | 4-node, 512-rank, 150-step PMPI profiles of hierarchical `(32 16 1)`, plain Scotch, weighted Scotch in one allocation | `Q`, `q5`; insufficient `node_pool` resources | `experiments/aspire2a-decomp-pmpi-3way/outputs/decomp_pmpi_3way_v1.{o,e}`; scratch `cases/decomp-pmpi-3way-v1-25826770/` |

Both scratch paths are under
`/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/`.
The 3-way profile is diagnostic only; its measured times are not official
unprofiled scores. The scientific inputs and binary are SHA-gated. The
PMPI wrapper SHA-256 is
`c3f10fe11ea15640f788a34f0192748e4fd755a4bdf7e897f770468c6f8b8443`.

## Synchronization and validation

- User reviewed the local three-way script diff and explicitly approved its
  Git commit/sync and one `qsub`.
- Local commit `c15ec18e3a971f5318674436bfa039ef63fcff84` contains only
  the three new experiment files. Other pre-existing local changes were
  preserved.
- The existing bare ASPIRE2A Git transport accepted `main:main`; the remote
  control checkout advanced by `git pull --ff-only` to this commit.
- Remote script SHA-256 was
  `d9ae08e86e20679acce6ee8b79896dc4390bc154e34ab7f702f3279362ca1a52`,
  matching the approved local script. `bash -n` passed locally and remotely.
  The target PBS stdout/stderr and scratch directories were absent before
  submission.
- Remote control checkout's pre-existing untracked PBS output files under
  `scripts/outputs/` were preserved.

## Exact remote/scheduler commands

```sh
ssh -O check aspire2a-comp
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only && git rev-parse HEAD && sha256sum experiments/aspire2a-decomp-pmpi-3way/run_decomp_pmpi_3way_v1.pbs && bash -n experiments/aspire2a-decomp-pmpi-3way/run_decomp_pmpi_3way_v1.pbs && test ! -e experiments/aspire2a-decomp-pmpi-3way/outputs/decomp_pmpi_3way_v1.o && test ! -e experiments/aspire2a-decomp-pmpi-3way/outputs/decomp_pmpi_3way_v1.e && find /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases -maxdepth 1 -type d -name "decomp-pmpi-3way-v1-*" -print'
ssh -o BatchMode=yes aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub experiments/aspire2a-decomp-pmpi-3way/run_decomp_pmpi_3way_v1.pbs'
ssh -o BatchMode=yes aspire2a-comp 'for job in 25826705.pbs101 25826770.pbs101; do qstat -f "$job" | grep -E "Job Id:|job_state =|queue =|stime =|resources_used.walltime =|Exit_status =|comment ="; done'
```

## Next check

For each PBS job: inspect state, exit status, stdout/stderr, unique scratch
evidence, solver completion and exact 150 steps, average wall-clock time per
step, fresh 150-row `coefficient.dat`, and final Cd. For the PMPI job also
verify all three reports, rank coverage and library hash before making a
mechanism comparison. Do not resubmit or patch automatically if either job
fails.
