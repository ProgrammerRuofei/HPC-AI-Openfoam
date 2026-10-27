# Project Workflow Instructions

This repository is the local control repository for OpenFOAM optimisation work
on ASPIRE2A. It uses the reusable workflow pack in `workflow/`.

## Required startup reading

Before taking workflow action, Codex must:

1. Read every numbered file in `workflow/` in numerical order.
2. Read this file and `APPLICATION.md`.
3. Read the latest progress report under `progress/`, if one exists.
4. Check the local Git state according to `workflow/01-Git-Sync-Policy.md`.

## Active project configuration

- Application: OpenFOAM
- Target release: openfoam.com v2512
- Active cluster: ASPIRE2A
- Workflow pack path: `workflow/`
- Application overview: `APPLICATION.md`
- ASPIRE2A connection, scheduler, launcher, and remote-root configuration:
  documented in `workflow/00-General-SSH-Rules.md`; fields retain an explicit
  `CONFIRMED`, `DISCOVERED AND VERIFIED`, or `TBD` status.

Remote actions are disabled by default. The exception is **cluster-adapter
setup**: when the user explicitly authorizes it in the current prompt, Codex
may use the documented existing SSH alias for lightweight, read-only remote
discovery even while the adapter is incomplete. This discovery may establish
only evidence-backed adapter fields; it must not guess missing values.

Adapter setup does not authorize remote writes, file transfers, job
submission/cancellation, builds, OpenFOAM runs, installations, or changes to
compiler/MPI/module settings. Those actions each still require explicit scope
in the current prompt. Before any non-discovery remote action, the relevant
adapter fields must be confirmed or discovered and verified.

## Cluster-adapter setup workflow

When the user explicitly authorizes cluster setup, Codex may:

- use the existing documented SSH alias and non-interactive form;
- run lightweight read-only discovery such as `hostname`, `whoami`, `pwd`,
  `command -v`, `module list`, `module avail`, `module show`, `ls`, `find`,
  `stat`, `grep`, `cat`, and read-only scheduler/account inspection;
- inspect the scheduler, launcher, module availability, remote project root,
  and approved paths; and
- update local cluster-specific documentation only with facts labelled
  `CONFIRMED` or `DISCOVERED AND VERIFIED`; retain all other fields as `TBD`.

Cluster-adapter discovery must never read, store, or expose passwords, private
key contents, tokens, or authentication configuration; alter `~/.ssh/config`
or `authorized_keys`; install software; modify remote files; submit/cancel
jobs; compile; or run OpenFOAM unless the user explicitly authorizes that
specific operation in the current prompt.

After every cluster-configuration or remote-automation task, report: actions
performed; local files changed and reasons; exact remote/scheduler commands;
facts with value, evidence, and status; remaining `TBD`; remote state changes;
and the recommended next step.

## Local permissions

### Explicit personal-account authentication exception (2026-10-23)

The user explicitly authorized local installation of `sshpass`, creation of
an empty local password file for the user to fill, personal SSH configuration,
and this workflow update. This is a narrow exception to the default
persistent-connection-only authentication policy, not remote-operation approval.

- Alias: `aspire2a-personal`; user: `rgao004` (lowercase, user-confirmed).
- Host configured: `aspire2antu.nscc.sg`; a separately authorized read-only
  password-file login test succeeded on 2026-10-23 as `rgao004` on
  `asp2a-login-ntu02`. This does not establish project/allocation permissions.
- Password file: `/Users/sofia/.config/cluster-secrets/aspire2a-personal.password`.
  Keep its parent directory mode `700` and file mode `600`, owned by the user.
  Create only if absent; never truncate or overwrite an existing file.
- Only the local `sshpass -f` process may consume this file directly for an
  otherwise authorized SSH operation. Codex must never inspect its contents,
  print, parse, copy, hash, log, commit, upload, or pass its value through
  command-line arguments, environment variables, clipboard, or chat.
- Metadata-only checks are allowed. Do not use verbose authentication traces,
  shell tracing, or automated password/MFA retries. Never bypass MFA or host-key
  verification. Keep `StrictHostKeyChecking=yes` for automatic authentication.
- Do not use this file for the competition account, Gadi, Git transports,
  SCP/rsync, or other accounts without additional explicit scope.
- Keep the existing competition adapter and its authorization rules unchanged.
  Personal remote roots, allocation, scheduler and permissions remain `TBD`;
  do not inherit competition-account paths or access rights.
- This setup authorizes no remote login/test, file transfer, job, build,
  installation on the cluster, or commit/push. Further operations require their
  own applicable authorization and verified adapter fields.

See `workflow/00-General-SSH-Rules.md` for the exact approved command form and
remaining personal-account prerequisites. Other authentication methods retain
the existing restrictions.

### Competition-account password-file authentication (2026-10-25)

The user authorized local setup for `gadi-comp` and `aspire2a-comp` without
requiring a persistent SSH master. This grants authentication setup only, not
permission for a remote command, transfer, build, or PBS action.

- Use separate local files under `/Users/sofia/.config/cluster-secrets/`:
  `gadi-comp.password` and `aspire2a-comp.password`. The user fills and rotates
  them locally. The parent must be user-owned mode `700`; each file must be a
  regular, non-symlink, user-owned file of mode `600`.
- Codex must never read, print, parse, hash, copy, commit, upload, or expose
  either password. Only local `sshpass -f` may consume the matching file for a
  separately authorized operation, after metadata-only checks.
- Disable SSH control-socket reuse for this mode. Require a trusted existing
  host key, one password prompt, and bounded timeouts. No verbose auth trace,
  shell tracing, automatic retry, MFA bypass, or fallback between accounts.
- Do not use these files for SCP, rsync, Git transports, or another account
  without separately approved and documented scope. The user approved one
  narrow exception on 2026-10-25: `aspire2a-comp.password` may be consumed
  by `sshpass -f` for Git push of reviewed `main` commits to this project's
  `/home/project/59000020/openfoam-isc26/control.git` only. Follow the exact
  command and safeguards in `workflow/00-General-SSH-Rules.md`. This does not
  authorize other Git operations, repositories, accounts, SCP, or rsync.
- The verified direct-login path requires a PTY-capable execution context.
  A default sandbox denial of `/dev/tty` is not evidence of a wrong password
  or a cluster outage. For each separately authorized remote read, verify
  credential-file metadata and the existing host key, use the exact bounded
  form in `workflow/00-General-SSH-Rules.md`, and never retry authentication
  automatically. An expired PBS `Unknown Job Id` is not a job outcome;
  inspect retained job-keyed outputs and scratch evidence within approved
  paths before classifying it.

### Current ASPIRE2A OpenFOAM evidence boundary (2026-10-25)

- PGO and rank-binding tests already exist. Their retained comparisons are
  exploratory and mostly use Bonus KaHIP; do not list them as missing Basic
  work or attribute their effects to Scotch without a matched Scotch test.
- The Basic question still open is whether plain Scotch or weighted Scotch
  has a reproducible advantage. The completed three-block A/B/C study has
  large timing variation, and its uniform-weight B arm has Cd below the
  reference band. Read the current evidence and correctness checks before
  proposing more jobs; do not promote a single minimum to a stable winner.
- Analysis and experiment proposals do not authorize a new PBS submission,
  compiler/build change, binding change, or weight sweep. Apply the existing
  diff and approval rules to any such action.

See `workflow/00-General-SSH-Rules.md` for the exact direct-login form.

Allowed without further approval:

- local read-only inspection;
- local project-file and directory creation or editing within this repository;
- local, non-destructive documentation and workflow-scaffold validation.

Do not commit, push, configure SSH, access ASPIRE2A, or run remote commands
unless the user explicitly approves that action.

## Actions requiring explicit approval

Obtain the user's explicit approval before:

- any source-code change;
- any remote file modification;
- job submission or job cancellation;
- package or software installation;
- any compiler, MPI, module, build-setting, launcher, or resource change;
- any optimisation experiment or optimisation decision;
- any destructive action, deletion, overwrite, reset, or cleanup.

Before every future remote-affecting change, show the user the relevant local
diff and wait for approval. A remote-affecting change includes preparation or
editing of files intended for remote transfer, build, execution, or scheduler
use.

## Application boundaries

The scientific workload is fixed. Do not change the mesh, `simpleFoam` source,
`fvSchemes`, or `fvSolution`. Current optimisation scope is limited to
compiler/build settings, MPI, rank placement/binding, and decomposition, and
each remains subject to competition rules and explicit approval.

Keep application facts in `APPLICATION.md`, optimisation planning in
`planning/`, structured outcomes in `results/`, and session handoffs in
`progress/`.

## Conflict and stop rule

If authority is missing, a cluster placeholder is incomplete, the required
diff has not been shown, or a workflow rule conflicts with a request, stop the
affected action and report the issue. Preserve evidence and do not broaden
permission by inference.
