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
