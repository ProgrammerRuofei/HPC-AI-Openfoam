# ASPIRE2A Scotch A/B/C: PBS and node-event follow-up

Date: 2026-10-25 (Asia/Singapore). Purpose: investigate the intermittent
wall-clock stalls established in the [zero-SU audit](2026-10-25-aspire2a-scotch-abc-zero-su-audit.md)
before deciding whether an A/C repeat is warranted.

## Evidence available now

- Jobs: block 1 `25909583.pbs101`, block 2 `25909584.pbs101`, block 3
  `25909585.pbs101`.
- Each block used four nodes with 128 ranks per node. The retained rank map
  from the previous authorized read shows the following short hostnames:

| Block | Recorded nodes | Long wall-clock jumps (A/B/C) |
| --- | --- | --- |
| 1 | `x1002c4s1b0n1`, `x1002c4s5b1n1`, `x1002c5s6b1n1`, `x1002c6s3b0n0` | 0 / 1 / 2 |
| 2 | `x1001c0s1b0n1`, `x1002c0s6b1n0`, `x1002c2s2b1n1`, `x1002c2s7b1n1` | 2 / 0 / 1 |
| 3 | `x1001c0s2b1n1`, `x1002c5s4b0n1`, `x1003c6s1b0n0`, `x1003c6s6b1n1` | **16 / 9 / 8** |

- The saved PBS stdout/stderr was inspected in the prior audit. All three
  stderr files were empty; all stdout files recorded `SCOTCH_ABC_PASS` and the
  same libfabric hash, with no explicit timeout/fabric error. This is a lack
  of a diagnostic message, not evidence that the system had no incident.
- The local checkout has summary/provenance notes but **does not have copies
  of the three job-keyed PBS stdout/stderr or per-step A/B/C solver logs**.
  No local node health, fabric telemetry, accounting event log, or historical
  co-scheduled-job list was found in the repository.
- The 2026-10-25 read-only `qstat -x -f 25909585.pbs101` check in the
  [completion note](2026-10-25-aspire2a-scotch-abc-evidence.md) returned
  `Unknown Job Id`, consistent with expired scheduler history. It is not a
  failure status.

## Current access boundary

The user authorized continued read-only investigation. Before connecting,
local metadata-only checks reconfirmed the dedicated competition password
file is regular, non-symlink, owned by the user, mode `600`, and nonempty under
an owned mode-`700` parent. `ssh -G` resolved `aspire2a-comp` to
`apacsc20@aspire2antu.nscc.sg`; `ssh-keygen -F` found an existing host-key
entry. The single documented direct-SSH attempt to run the following
read-only command failed during authentication:

```sh
bash -s <<'SH'
command -v tracejob || true
for id in 25909583.pbs101 25909584.pbs101 25909585.pbs101; do
 echo "JOB $id"
 qstat -x -f "$id" 2>&1 | grep -E 'Job Id:|Unknown Job|job_state =|Exit_status =|resources_used.walltime =|resources_used.cput =|stime =|obittime =|exec_host =|exec_vnode =|comment ='
done
SH
```

SSH returned `Permission denied (gssapi-keyex,gssapi-with-mic,password)`.
The remote shell and PBS commands above **did not execute**. Following the
project's no-retry rule, no further login, alternative account, control-socket
fallback, transfer or remote action was attempted. Password contents were
never inspected or displayed. No scheduler command succeeded in this
follow-up; no remote state changed.

### Resumed after user-confirmed direct login

The user then ran the same direct-authentication form in their own terminal
and confirmed it returned `apacsc20`. Under that new confirmation, metadata,
alias and host-key checks were repeated locally; the same one-prompt,
no-control-socket form succeeded for read-only commands. This does not explain
why the earlier single authentication attempt failed.

Exact remote commands subsequently issued through that form:

```sh
command -v tracejob || true
for id in 25909583.pbs101 25909584.pbs101 25909585.pbs101; do
 echo "JOB $id"
 qstat -x -f "$id" 2>&1 | grep -E 'Job Id:|Unknown Job|job_state =|Exit_status =|resources_used.walltime =|resources_used.cput =|stime =|obittime =|exec_host =|exec_vnode =|comment ='
done

for id in 25909583 25909584 25909585; do
 echo "JOB $id"
 tracejob -n 7 "$id" 2>&1 | tail -55
done

date '+remote_now=%Y-%m-%d %H:%M:%S %Z %z'
# stat -c '%n | birth=%w | modified=%y' for each block's nodes.txt,
# run.log, PBS stdout and each arm's solver log and coefficient.dat.
# grep -n -E 'A_plain|B_uniform|C_weighted|SCOTCH_ABC_PASS|START|END|RUN'
# for each retained run.log.
```

`tracejob` resolves to `/opt/pbs/bin/tracejob`. All three `qstat -x -f`
queries returned `Unknown Job Id`. All three `tracejob -n 7` queries returned
`Couldn't find Job Id ... in logs of past 7 days`. The jobs were only about
three days old; this means the accessible trace logs do not contain them, not
that there were no historical node incidents.

File timestamps on the remote +0800 clock bound the **retained job evidence**:

| Block / job | `nodes.txt` creation | `run.log` modified / PBS stdout modified | Last solver-log modification in each arm, in run order |
| --- | --- | --- | --- |
| 1 / `25909583` | 2026-10-22 10:33:38 | 11:25:27 / 11:25:27 | A 10:50:51; B 11:07:47; C 11:25:26 |
| 2 / `25909584` | 2026-10-22 10:34:29 | 11:26:13 / 11:26:13 | B 10:52:08; C 11:09:00; A 11:26:12 |
| 3 / `25909585` | 2026-10-23 07:17:46 | 08:56:17 / 08:56:17 | C 08:01:31; A 08:31:04; B 08:56:15 |

These are file timestamps, not independently authenticated PBS start/end
times. For a site-support request, the useful block-3 window is approximately
**2026-10-23 07:17–08:56 +0800**, with the four recorded nodes above.
Neither PBS historical counters nor fabric/node event logs were accessible
through the tested account tools. No job or remote file was changed.

## What can and cannot be concluded

The saved solver logs establish large intermittent wall-clock gaps, especially
in block 3, but their cause is still **unknown**. Neither cabinet placement
nor a fabric issue is proven. Local records cannot establish historical node
health, co-scheduled activity, or PBS resource counters for those exact time
windows. A later `pbsnodes` snapshot would describe current state and should
not be treated as evidence about 2026-10-22/23.

The direct login works again, but the tested `qstat -x` and `tracejob -n 7`
history is unavailable. The next useful evidence would be NSCC's historical
node/fabric/maintenance or scheduler event records for the block-3 window;
the user would need to contact support, since no message to others has been
authorized. Supply the job IDs, time window and node names above. Only
after evaluating that evidence should the team choose a fresh paired A/C
design. Do not reuse the nine noisy points as proof of a weight benefit and do
not submit a new job from this note.

Draft for the team to send to NSCC support if desired (not sent):

> We observed intermittent 10–75 second elapsed-time stalls in OpenFOAM
> `simpleFoam` during PBS job `25909585.pbs101` on ASPIRE2A, despite typical
> steps taking about 3 seconds. The retained allocation spans approximately
> 23 October 2026, 07:17–08:56 SGT (+0800) on nodes
> `x1001c0s2b1n1`, `x1002c5s4b0n1`, `x1003c6s1b0n0`, and
> `x1003c6s6b1n1`. Comparison jobs `25909583.pbs101` and
> `25909584.pbs101` ran on 22 October, 10:33–11:26 SGT, with fewer stalls.
> Our account's `qstat -x` and `tracejob -n 7` no longer return these job IDs.
> Could you check historical PBS, node-health, fabric, or maintenance events
> during these allocations and advise whether any event coincides with the
> stalls? We can provide the per-step solver logs and node maps if needed.

Local change: this progress note only, recording the attempted read, resumed
read-only queries and the historical-accounting limitation. Cluster adapter
values remain as previously documented; historical site-event availability
and the stall cause remain unknown.
