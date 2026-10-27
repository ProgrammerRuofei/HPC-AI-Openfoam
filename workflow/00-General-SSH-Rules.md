# General SSH and Cluster Execution Rules

This document defines the safe remote-execution policy for the workflow pack.
It contains universal rules followed by values that must be adapted for each
new cluster. Preserve the universal rules when adapting this file.

## Universal authentication rules

- Never request an actual SSH password or expose its value to Codex, tool
  output, logs, chat, repository files, command arguments, or environment.
- By default, do not use `sshpass`, Expect, password files, clipboard
  extraction, or automated password entry. The named personal-account and
  competition-account exceptions below were expressly authorized by the user
  and are recorded in the root `AGENTS.md`.
- Do not modify SSH authentication settings or install authentication tools
  without explicit scope. The named exceptions grant only local setup and
  direct `sshpass -f` use, not an MFA/policy bypass.
- Never store cluster credentials or GitHub credentials on the cluster.

## Persistent connection rules

- Use the cluster's documented persistent-connection check before remote work.
- If the connection is unavailable, stop and tell the user exactly how to
  restore it, except for the separately authorized password-file modes below.
- Do not initiate a normal interactive SSH login.
- Every Codex-controlled remote command must use the documented non-interactive
  SSH form, or a named `sshpass` driver below (SSH itself needs `BatchMode=no`
  to accept that driver's prompt).
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
| Control workflow Git checkout | `/home/project/59000020/openfoam-isc26/control-repo` | **DISCOVERED AND VERIFIED** | Created from the local-control Git transport repository on 2026-09-17; `git rev-parse HEAD` matched local `a8ecb34be879c510154a667ff627ed5869a10273`, and the checkout was clean. This is distinct from the outer project root and the application-source checkout. |
| Control workflow Git transport | `/home/project/59000020/openfoam-isc26/control.git` (bare) | **DISCOVERED AND VERIFIED** | Created under user authorization on 2026-09-17. Local `main` was pushed using the existing `aspire2a-comp` SSH alias; the working checkout cloned from this bare repository. No GitHub credential is stored on ASPIRE2A. |
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
| Personal ASPIRE2A account | Separate `aspire2a-personal` profile below | **CONFIRMED** | User authorized separate local setup on 2026-10-23; not a replacement for this competition adapter. |
| Gadi adapter | `TBD` | **TBD** | Separate cluster adapter; do not infer from ASPIRE2A. |

## Separate personal-account profile — expressly authorized 2026-10-23

This exception applies only to the named local personal profile. It does not
change the competition or Gadi adapters. Setup is not proof of successful
authentication or permission to use any remote project or allocation.

| Field | Value | Status / evidence |
| --- | --- | --- |
| Alias | `aspire2a-personal` | **CONFIRMED** — user requested separate personal configuration. |
| User | `rgao004` | **CONFIRMED** — user corrected the username to lowercase on 2026-10-23. |
| Configured host | `aspire2antu.nscc.sg` | **DISCOVERED AND VERIFIED** — user-authorized read-only password-file login succeeded on 2026-10-23; `hostname` returned `asp2a-login-ntu02` and `whoami` returned `rgao004`, exit `0`. |
| Local SSH stanza | `/Users/sofia/.ssh/config.d/aspire2a-personal.conf`, included by `/Users/sofia/.ssh/config` | **DISCOVERED AND VERIFIED** locally on 2026-10-23 using `ssh -G` (no connection); alias resolves to the lowercase personal user. Both files mode `600`. |
| Password-file path | `/Users/sofia/.config/cluster-secrets/aspire2a-personal.password` | **DISCOVERED AND VERIFIED** by metadata only on 2026-10-23: created empty, parent mode `700`, file mode `600`, owner `sofia`. Contents are never evidence. |
| Local driver | `/opt/homebrew/bin/sshpass`, Homebrew version `1.10` | **DISCOVERED AND VERIFIED** by successful user-authorized local installation; no cluster software installed. |
| Password value / population | User-managed only | Codex must not inspect or record content; create an empty file only if absent. |
| Host-key check | Existing local `known_hosts` entry accepted with `StrictHostKeyChecking=yes` | **DISCOVERED AND VERIFIED** in the 2026-10-23 test; no key added/changed. Independent site fingerprint verification remains `TBD`. |
| Password-file login | Succeeded once without additional MFA in the tested session | **DISCOVERED AND VERIFIED**, 2026-10-23; disabled multiplexing/public-key authentication for this test. This does not establish site-wide MFA policy or future availability. |
| Authentication / MFA policy beyond the observed session | `TBD` | Password-file authentication cannot satisfy an additional MFA requirement by itself. |
| Remote home, project root, allocation, scheduler, approved paths and transfer forms | `TBD` | Never inherit competition-account values or permissions. |

### Approved driver and prerequisites

The user authorized local Homebrew installation of `sshpass` and creating the
empty credential placeholder. Only the user enters or changes the password.
Do not read the file with `cat`, `sed`, an editor tool, parser, hash utility,
or any other inspection tool. Do not copy it, send it to the cluster, store it
in Git/cloud documents, or put its value in arguments, environment, or logs.
Only `sshpass` may consume the file directly; credential transport is handled
by SSH, not by the model. Metadata-only checks may establish owner, permissions
and nonempty file size without reading the contents.

For a separately authorized remote operation, first verify the effective
local alias/user/host, a populated user-owned regular password file (not a
symlink), mode `600` under a mode `700` directory, and a trusted existing host
key. An empty file, placeholder username, changed/unknown host key, rejected
password, MFA challenge, or uncertain policy means stop without retrying.
Use a bounded command timeout; do not use `sshpass -v`, `ssh -v`, `set -x`,
password arguments, or environment-based password passing.

Exact driver template (replace only the authorized remote command):

```sh
sshpass -f /Users/sofia/.config/cluster-secrets/aspire2a-personal.password \
  ssh -o BatchMode=no -o StrictHostKeyChecking=yes \
  -o NumberOfPasswordPrompts=1 -o ConnectTimeout=15 \
  aspire2a-personal '<separately-authorized-command>'
```

This template is not authorization to execute it. No automatic fallback from
`aspire2a-comp`, no password-file use for SCP/rsync/Git, and no scheduled or
unbounded authentication retries are authorized. Local setup changes do not
require a remote script review; files intended for remote execution still do.

The personal SSH stanza defaults to `BatchMode yes` so plain `ssh` fails
without an existing usable authentication method instead of hanging on a
prompt. Only the explicit driver overrides it with `BatchMode=no`. Local
`ssh -G` checks confirmed this override and that `aspire2a-comp` still resolves
to its original competition user; no remote connection was made.

## Competition-account direct password-file mode — authorized 2026-10-25

This is a local authentication mode for the existing `gadi-comp` and
`aspire2a-comp` aliases. It does not authorize remote operations, change their
users or hosts, or transfer credentials to either cluster. A site policy or
additional MFA challenge takes precedence: stop rather than bypass it.

| Alias | Expected user and host | Local password file |
| --- | --- | --- |
| `gadi-comp` | `kj7183` at `gadi.nci.org.au` | `/Users/sofia/.config/cluster-secrets/gadi-comp.password` |
| `aspire2a-comp` | `apacsc20` at `aspire2antu.nscc.sg` | `/Users/sofia/.config/cluster-secrets/aspire2a-comp.password` |

The two files were created empty on 2026-10-25. The user alone fills and
rotates them locally. Codex may check only file metadata: regular file,
non-symlink, current-user owner, nonzero size and mode `600`, inside a
current-user-owned mode `700` directory. Never inspect, print, parse, hash,
copy, commit, upload or log their contents. Only local `sshpass -f` may read
the matching file directly for a separately authorized command. The same
restrictions apply to the personal-account file above.

Direct command template (substitute exactly one listed alias and its matching
file, plus a separately authorized remote command):

```sh
/opt/homebrew/bin/sshpass -f /Users/sofia/.config/cluster-secrets/ALIAS.password \
  ssh -T -o BatchMode=no -o StrictHostKeyChecking=yes \
  -o UpdateHostKeys=no -o NumberOfPasswordPrompts=1 \
  -o ConnectTimeout=15 -o ConnectionAttempts=1 \
  -o PreferredAuthentications=password,keyboard-interactive \
  -o PubkeyAuthentication=no -o GSSAPIAuthentication=no \
  -o ControlMaster=no -o ControlPath=none \
  -o ControlPersist=no -o ClearAllForwardings=yes \
  ALIAS '<separately-authorized-command>'
```

Use a bounded whole-command timeout as well. Do not use verbose SSH/sshpass
output, shell tracing, automatic retries, or another account's file. A
missing host key, empty file, authentication failure or MFA challenge ends the
attempt. The existing persistent connection remains an optional manual access
method, but this direct mode does not depend on it. Apart from the narrowly
approved Git push below, this exception does not cover SCP, rsync, Git
transports, scheduled logins or remote writes.

### ASPIRE2A control-repository Git push exception — authorized 2026-10-25

The user expressly approved `aspire2a-comp.password` for pushing reviewed
local `main` commits only to
`aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git`.
This does not authorize a push to GitHub or Gadi, another branch or repository,
Git fetch/clone, SCP, rsync, or any other file transfer. The commit and push
still require their own task authorization and a reviewed file list/diff.

After the competition-file metadata and trusted-host-key checks above, use a
PTY-capable execution context, no shell tracing, and one attempt. The exact
Git SSH command is:

```sh
GIT_SSH_COMMAND='/opt/homebrew/bin/sshpass -f /Users/sofia/.config/cluster-secrets/aspire2a-comp.password ssh -T -o BatchMode=no -o StrictHostKeyChecking=yes -o UpdateHostKeys=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=15 -o ConnectionAttempts=1 -o PreferredAuthentications=password,keyboard-interactive -o PubkeyAuthentication=no -o GSSAPIAuthentication=no -o ControlMaster=no -o ControlPath=none -o ControlPersist=no -o ClearAllForwardings=yes' \
  git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
```

Bound the whole Git command to 120 seconds. Never inspect the password-file
contents or pass the password value through an argument or environment.
The subsequent remote `git pull --ff-only` is a separately authorized remote
command using the direct SSH form above; it does not need a Git credential.

Local validation on 2026-10-25 found that the default command sandbox denied
the pseudo-terminal access required by `sshpass`: a dummy-password mock failed
there with `/dev/tty` permission denied, but passed in a PTY-capable execution
context. Do not classify a sandboxed `sshpass` failure as a cluster password or
PBS failure. With user-approved PTY-capable execution, one bounded read-only
direct login per alias succeeded without a control master: Gadi returned
`gadi-login-02.gadi.nci.org.au` / `kj7183`; ASPIRE2A returned
`asp2a-login-ntu01` / `apacsc20`, both exit `0`. Future authorized direct
operations need a PTY-capable execution context and the same credential and
host-key safeguards; this is not additional remote-operation authorization.

When checking an older PBS job, `qstat -x -f` may return `Unknown Job Id`
after the scheduler's history expires. Treat that only as an unavailable
scheduler record. For a separately authorized read-only results inspection,
check retained job-keyed PBS output and scratch evidence within the approved
paths; require the solver's expected steps, metric and fresh correctness file
before reporting a result. This is a verification procedure, not permission
to access the cluster or submit a job.

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
6. no rule asks Codex to inspect or expose authentication secrets; the named
   exceptions permit only direct local `sshpass -f` consumption.

If a check fails, stop only the affected remote action, preserve the evidence,
and report the missing field or authorization. Adapter discovery may continue
when its own preconditions are met.
