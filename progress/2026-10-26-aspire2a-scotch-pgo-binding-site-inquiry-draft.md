# ASPIRE2A Scotch timing stalls: site inquiry draft (2026-10-26)

## Read-only checks completed

- Reviewed the [per-step audit](2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md): both jobs and all eight 150-step arms completed normally; very long elapsed-time steps dominate the mean, while median recorded step times are 2.897–2.910 s.
- Queried retained PBS history on 2026-10-26 with `qstat -x -f` for jobs `25970245.pbs101` and `25970246.pbs101`. Both returned `Unknown Job Id`; this means the PBS history is unavailable, not that either job failed. `tracejob -n 7` returned no matching event lines for those IDs. The job-keyed scratch logs, PBS stdout and empty stderr remain available.
- Checked the public [NSCC ASPIRE2A bulletin](https://help.nscc.sg/aspire2a/bulletin/) and [service page](https://help.nscc.sg/aspire2a/service/). No notice matching the 2026-10-25 run window was found on those pages. Public notices cannot rule out an unannounced node or fabric event.
- Did not submit, cancel or modify any job, nor contact support. The only new local file is this draft.

## Ready-to-send English message

**Subject:** ASPIRE2A intermittent 10–550 s solver-step stalls in jobs 25970245 and 25970246 (25 Oct 2026)

Dear NSCC Support,

Could you please check whether ASPIRE2A recorded any node, fabric, system or co-scheduled workload events affecting the following two four-node PBS jobs on **25 October 2026, approximately 06:49–10:01 SGT**?

- Project/account: `59000020` / `apacsc20`.
- Job `25970245.pbs101`: nodes `x1001c5s6b1n0`, `x1001c5s6b1n1`, `x1001c5s7b0n0`, `x1001c5s7b1n1`.
- Job `25970246.pbs101`: nodes `x1002c1s3b1n0`, `x1002c1s3b1n1`, `x1002c1s4b0n0`, `x1002c1s4b0n1`.

The jobs ran OpenFOAM `simpleFoam` on the same fixed 65M-cell case with 512 MPI ranks (128 per node). Both completed with PBS and script exit status 0. Across eight sequential 150-step runs, the median time per solver step was about 2.9 s, but occasional steps took tens or hundreds of seconds and raised the full-run averages to 4.1–10.3 s/step. The clearest example is **job 25970245, stock Opt/default binding, step 64: 550.840 s wall-clock**, while OpenFOAM's `ExecutionTime` counter advanced by about 2.9 s. In **job 25970246, PgoUse/default binding**, step 84 took about 115 s and steps 82–84 had successive large `ClockTime` jumps. All runs completed 150 steps and produced the same final drag coefficient, Cd(150) = 0.288551. The retained PBS stderr files are empty and stdout contains no explicit fabric timeout or OOM error.

Could you check historical monitoring, PBS/MOM and fabric records for these job windows and nodes, and advise whether there was a known event or a recommended diagnostic for intermittent MPI/elapsed-time stalls? We can provide the saved solver logs, PBS outputs and rank-affinity records if useful. We are trying to determine whether performance comparisons on these allocations are reliable before running more tests.

Thank you.

## Evidence locations for a follow-up

Scratch roots:

- `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-pgo-binding-b1-v1-25970245/`
- `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-pgo-binding-b2-v1-25970246/`

PBS stdout/stderr:

`/home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-scotch-pgo-binding/outputs/scotch_pgo_binding_block{1,2}_v1.{o,e}`

No attached logs have been transmitted. A support message and any attachment transfer require separate explicit authorization.
