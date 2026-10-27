# Cray PALS one-node availability probe: submitted

**Date:** 2026-09-17. **Current step:** Authorized one-node compute-node availability probe. **Job:** `22693051.pbs101`, queued in `qdev` at the latest check. This follows [`2026-09-17-cray-pals-probe-preparation.md`](2026-09-17-cray-pals-probe-preparation.md).

## Actions and evidence

- Applied the user's reviewed two-line PBS output-path correction. Local [`scripts/probe_cray_pals_1n_v1.pbs`](../scripts/probe_cray_pals_1n_v1.pbs) passed `bash -n` and `git diff --cached --check`.
- Committed **only** that script and `scripts/outputs/.gitkeep` as `a8ecb34be879c510154a667ff627ed5869a10273` (`Add one-node Cray PALS availability probe`). Pre-existing unrelated modifications and untracked evidence remain untouched. Local `main` is one commit ahead of GitHub `origin/main`; there was **no GitHub push**.
- Created `/home/project/59000020/openfoam-isc26/control.git` as a bare Git transport repository, pushed local `main` to it through the existing SSH alias, and cloned `/home/project/59000020/openfoam-isc26/control-repo` from that bare repository. `git pull --ff-only` reported `Already up to date`; remote `git status --porcelain` was empty. Local and remote commit IDs matched. Both copies of the probe have SHA256 `45c426468287f95fb7cc32d1573322fc8f677ced0a258a1c839f6f79fdba358e`.
- Submitted the reviewed script from the remote working checkout. PBS returned `22693051.pbs101`. No OpenFOAM run or build was launched by Codex; the probe itself calls `ldd` and `mpiexec -n 2 --ppn 2 /bin/hostname` if scheduled. It does not call `MPI_Init`.
- PBS routed `#PBS -q normal` to execution queue `qdev`. The job is `Q`; comment: `Not Running: would exceed overall limit on resource ncpus in queue qdev`. `qdev` permits up to 128 CPU per job and has a 256 CPU aggregate limit. The probe requests 128, so the comment indicates current aggregate capacity pressure, not a per-job limit violation. No resource change, cancellation, or retry has been made.

## Facts and status

| Fact | Value | Status / evidence |
| --- | --- | --- |
| Control Git checkout | `/home/project/59000020/openfoam-isc26/control-repo` | **DISCOVERED AND VERIFIED**, remote `git rev-parse HEAD`, clean status and script hash. |
| Credential-free Git transport | `/home/project/59000020/openfoam-isc26/control.git` | **DISCOVERED AND VERIFIED**, successful SSH push and clone. No GitHub credential on cluster. |
| Submitted probe | `22693051.pbs101`, `qdev`, `Q` | **DISCOVERED AND VERIFIED** by `qsub` and `qstat -f`. |
| Compute-node PALS and Cray MPICH library availability | **TBD** | Probe has not started. |
| MPI initialization and OpenFOAM Pstream compatibility | **TBD** | Outside this hostname probe's scope. |

## Exact remote and scheduler commands

`ssh -O check aspire2a-comp` confirmed the persistent control connection before remote work. Exact unique commands with effects:

```sh
ssh aspire2a-comp 'ls -ld /home/project/59000020/openfoam-isc26/control.git /home/project/59000020/openfoam-isc26/control-repo 2>&1'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26 && git init --bare --initial-branch=main control.git'
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26 && git clone control.git control-repo'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git rev-parse HEAD && git status --porcelain && test -f scripts/outputs/.gitkeep && test -d scripts/outputs && bash -n scripts/probe_cray_pals_1n_v1.pbs && sha256sum scripts/probe_cray_pals_1n_v1.pbs && command -v qsub'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only && git status --porcelain && git rev-parse HEAD'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub scripts/probe_cray_pals_1n_v1.pbs'
ssh aspire2a-comp 'qstat -f 22693051.pbs101'
ssh aspire2a-comp 'qstat -Qf qdev normal 2>&1 | grep -E "^(Queue:|[[:space:]]+(queue_type|resources_max\.|resources_min\.|max_run|enabled|started|route_destinations|default_chunk|resources_default|acl_|comment))"'
ssh aspire2a-comp 'qstat -Q qdev'
ssh aspire2a-comp 'qstat -a qdev 2>&1 | head -35'
```

One read-only `qstat -a -q qdev` query returned a usage error; it had no effect. Additional bounded `qstat -f` reads confirmed the same queued state. No cancellation or other job submission occurred.

## Exact next action

Check `qstat -f 22693051.pbs101` at a bounded interval. After completion, inspect its PBS `Exit_status` and the two raw files in `control-repo/scripts/outputs/`; classify PALS/library availability from those files. Do not treat a successful `hostname` launch as proof of MPI initialization. Preserve this attempt and request approval before any script/resource modification or retry.

## Later read-only status check

On the user's follow-up request, `ssh -O check aspire2a-comp` confirmed the existing connection. `ssh aspire2a-comp 'qstat -xf 22693051.pbs101 2>&1 | grep -E "^(Job Id:|[[:space:]]*(job_state|queue|comment|exec_host|stime|obittime|Exit_status|resources_used\.walltime|Output_Path|Error_Path))"'` still showed `Q` in `qdev`, with the same aggregate-CPU-limit comment and no `Exit_status`. `ssh aspire2a-comp 'qstat -Q qdev'` reported 3 queued, 6 running, and 9 held jobs. A bounded `ls -l` of the probe's `.o` and `.e` paths under `control-repo/scripts/outputs/` found neither file. No scheduler or remote state was changed by this check.

On the next user status request, `ssh -O check aspire2a-comp` failed with `Control socket connect(...): No such file or directory` (exit 255). Per `workflow/00-General-SSH-Rules.md`, no further remote command was attempted. The job's status after the preceding queued check is **UNKNOWN** until the persistent SSH connection is restored. No local connection start or remote state change was made.

## Completed-job check after connection restoration

The user restored the persistent SSH connection and requested another status check. `ssh -O check aspire2a-comp` returned `Master running`. `qstat -xf 22693051.pbs101` reported `F`, `Exit_status = 2`, two seconds wall time, and node `x1002c0s5b1n0`; the job began at 14:43:44 and ended at 14:43:50 cluster local time. The raw stdout under `control-repo/scripts/outputs/probe_cray_pals_1n_v1.o` has `libfabric.so.1 => not found` in `ldd` of the selected Cray MPICH `libmpi.so`; stderr says `Unresolved Cray MPICH dependency`. The preflight exited before `mpiexec` ran, so PALS startup and MPI initialization remain **TBD**.

Read-only `module -t avail libfabric`, `module show cray-pals/1.1.6`, `module show cray-mpich/8.1.15`, and `module show libfabric/1.22.0` showed that the Cray libfabric module is available and prepends `/opt/cray/libfabric/1.22.0/lib64` to `LD_LIBRARY_PATH`. The v1 probe loaded PALS but not that module. This is recorded as a separate `USER_ACTION_REQUIRED` Track 2 case in [`MANUAL_INSPECTION_ERROR.md`](../MANUAL_INSPECTION_ERROR.md). No script, module setting, resource request, or remote file was changed; no retry was submitted.

**Exact next action:** If the user authorizes a retry, show and review a local v2 diff that adds `module load libfabric/1.22.0` and unique v2 PBS output names, then commit/synchronize that diff before submitting. A successful v2 `hostname` launch would still require a separate MPI-initialization/OpenFOAM compatibility check before the performance screen.

**Remote reads for this check:**

```sh
ssh -O check aspire2a-comp
ssh aspire2a-comp 'qstat -xf 22693051.pbs101 2>&1 | grep -E "^(Job Id:|[[:space:]]*(job_state|queue|comment|exec_host|stime|obittime|Exit_status|resources_used\.walltime|resources_used\.cput|Output_Path|Error_Path))"'
ssh aspire2a-comp 'cat /home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v1.o'
ssh aspire2a-comp 'cat /home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v1.e'
ssh aspire2a-comp 'qstat -xf 22693051.pbs101 2>&1 | grep -E "^[[:space:]]*(job_state|Exit_status|resources_used\.|Resource_List\.|exec_host|stime|obittime|comment)"'
ssh aspire2a-comp 'module -t avail libfabric 2>&1 | head -30; module show cray-pals/1.1.6 2>&1 | head -60; module show cray-mpich/8.1.15 2>&1 | head -70'
ssh aspire2a-comp 'module show libfabric/1.22.0 2>&1 | head -65'
```

## Local v2 draft awaiting diff review

The user approved preparing one minimal v2 retry but explicitly requested the complete local diff before any synchronization or submission. A new local `scripts/probe_cray_pals_1n_v2.pbs` was drafted without editing v1. It retains the exact PBS resource lines, loads `libfabric/1.22.0`, uses unique v2 job/output names, records the requested environment/version/dependency evidence, and guards `mpiexec hostname` behind complete `ldd` and `libfabric.so.1` path checks. `bash -n` passed and the v1/v2 resource directives matched. The v2 file is untracked; no commit, push, remote write, or retry was performed in this step. Await the user's review of the displayed v1-to-v2 diff before further action.
