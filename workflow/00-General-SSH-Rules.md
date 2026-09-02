# General SSH and Cluster Execution Rules

This document defines the safe remote-execution policy for the workflow pack.
It contains universal rules followed by values that must be adapted for each
new cluster. Preserve the universal rules when adapting this file.

## Universal authentication rules

- Never request, read, store, transmit, echo, or log any SSH password.
- Never use `sshpass`, Expect, password files, clipboard extraction,
  environment variables, or command-line password arguments for authentication.
- Never attempt to modify SSH authentication settings.
- Never automate password entry.
- Never install tools merely to bypass interactive authentication.
- Never store cluster credentials or GitHub credentials on the cluster.

## Persistent connection rules

- Use the cluster's documented persistent-connection check before remote work.
- If the connection is unavailable, stop and tell the user exactly how to
  restore it.
- Do not initiate a normal interactive SSH login.
- Every Codex-controlled remote command must use the documented non-interactive
  SSH form.
- Every Codex-controlled file transfer must use the documented non-interactive
  SCP or rsync form.

Starting or closing a persistent SSH control connection changes local
connection state and requires explicit user authorization. Checking an already
configured connection is read-only, but may be used only when the user has
authorized cluster-adapter discovery or the relevant remote workflow.

## Remote scope and execution rules

- Keep remote work inside the approved project root unless the user explicitly
  approves another path.
- Do not use `sudo`.
- Do not install Codex, package managers, background services, daemons, proxies,
  or remote agents on the cluster.
- Do not install new software or packages without user approval.
- Do not modify shared software. Prefer available modules and site-supported
  tools.
- During workflow execution, create or edit only approved project files and
  designated output directories. Do not delete folders without user approval.
- Run computation through the cluster scheduler via batch jobs.
- Do not perform computational workloads on login nodes.
- Do not poll the scheduler excessively; use bounded monitoring.

## Cluster-adapter status model

Every adapter field has one of these statuses:

- **CONFIRMED** — supplied or explicitly approved by the user, with its source
  recorded in this adapter.
- **DISCOVERED AND VERIFIED** — observed through an authorized, read-only
  remote command, with the command/output evidence recorded in the task report.
- **TBD** — unknown, incomplete, or not yet verified. Codex must not guess it.

## Cluster-adapter setup and discovery

An incomplete adapter is not a blanket SSH prohibition. When the user
explicitly authorizes **cluster-adapter setup** in the current prompt, Codex
may use the existing SSH alias and documented SSH form for lightweight,
read-only discovery. Allowed examples are `hostname`, `whoami`, `pwd`,
`command -v qsub`, `command -v qstat`, `command -v mpirun`, `module list`,
`module avail`, `module show`, `ls`, `find`, `stat`, `grep`, `cat`, and
read-only scheduler/account inspection.

Discovery exists only to establish adapter facts: alias/host reachability,
remote user/home, scheduler commands, module/launcher availability, remote
project root, approved paths, and login/compute restrictions. It must be
bounded, non-computational, and reported with exact commands and evidence.

Even during adapter setup, Codex must not read passwords, private-key contents,
tokens, or authentication configuration; modify SSH configuration or
`authorized_keys`; install software; modify remote files; submit/cancel jobs;
delete, move, or overwrite data; compile; or run OpenFOAM unless the user
explicitly authorizes that exact operation in the current prompt.

## Active cluster adapter — ASPIRE2A

| Field | Value | Status | Evidence / boundary |
| --- | --- | --- | --- |
| Cluster | `ASPIRE2A` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Profile | `competition account` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| SSH alias | `aspire2a-comp` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| SSH host | `aspire2antu.nscc.sg` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Required read-only SSH form | `ssh aspire2a-comp '<read-only-command>'` | **CONFIRMED** | User-provided authorized form; use only under current-prompt authorization. |
| Persistent connection start | `ssh -MNf aspire2a-comp` | **CONFIRMED** | User-provided command; requires explicit authorization because it changes local connection state. |
| Persistent connection check | `ssh -O check aspire2a-comp` | **CONFIRMED** | User-provided read-only command. |
| Persistent connection close | `ssh -O exit aspire2a-comp` | **CONFIRMED** | User-provided command; requires explicit authorization. |
| If connection unavailable | `TBD` | **TBD** | Do not guess a recovery action. |
| Required SCP form | `TBD` | **TBD** | A transfer form must be explicitly documented/authorized before use. |
| Required rsync form | `TBD` | **TBD** | A transfer form must be explicitly documented/authorized before use. |
| Remote user | `apacsc20` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Remote home | `/home/users/industry/ai-hpc/apacsc20` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Remote project root | `/home/project/59000020/openfoam-isc26` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Approved remote paths | The remote project root and its existing descendants only. | **CONFIRMED** | User-provided remote root; other paths require explicit approval. |
| Scheduler | `PBS` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Submission command | `qsub` | **CONFIRMED** | User-provided project configuration; each submission still requires current-prompt authorization. |
| Status command | `qstat` | **CONFIRMED** | User-provided project configuration. |
| Monitoring command and polling limit | `qstat <job-id>`; bounded cadence/limit `TBD` | **TBD** | Command is known; polling policy has not yet been specified. |
| MPI/application launcher | `mpirun` | **CONFIRMED** | User-provided observed launcher, 2026-08-30. |
| Current OpenFOAM module | `openfoam/2512` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Module policy beyond current module | `TBD` | **TBD** | Discover only under explicit cluster-setup authorization. |
| Login-node restrictions | Read-only discovery only; no computational workloads. | **CONFIRMED** | This workflow policy. |
| Compute-node restrictions | Builds/runs only through authorized PBS jobs; no shared-software changes. | **CONFIRMED** | This workflow policy. |
| Current access path | `MacBook on NTU campus network -> direct SSH -> ASPIRE2A` | **CONFIRMED** | User-provided project configuration, 2026-08-30. |
| Off-campus / VPN / jump-host path | `TBD` | **TBD** | Do not infer network access requirements. |
| Personal ASPIRE2A account | `TBD` | **TBD** | Not needed for the competition-account adapter. |
| Gadi adapter | `TBD` | **TBD** | Separate cluster adapter; do not infer from ASPIRE2A. |

## Cluster adaptation checks

### Before authorized read-only adapter discovery

Verify that:

1. the user explicitly authorized cluster-adapter setup in the current prompt;
2. the existing SSH alias and read-only SSH form are marked `CONFIRMED` or
   `DISCOVERED AND VERIFIED`;
3. every planned command is read-only, bounded, and free of credentials; and
4. unknown fields will remain `TBD` rather than being inferred.

### Before remote write, transfer, build, job submission, cancellation, or run

Verify that:

1. the user explicitly authorized that exact action in the current prompt;
2. required alias, remote root/path, scheduler/transfer form, launcher, and
   module fields are `CONFIRMED` or `DISCOVERED AND VERIFIED`;
3. SSH and any transfer commands are non-interactive and scoped to approved
   paths;
4. scheduler commands use batch execution and bounded monitoring;
5. launcher, modules, and resource syntax have been verified for the intended
   action; and
6. no rule asks Codex to handle or expose authentication secrets.

If a check fails, stop only the affected remote action, preserve the evidence,
and report the missing field or authorization. Adapter discovery may continue
when its own preconditions are met.
