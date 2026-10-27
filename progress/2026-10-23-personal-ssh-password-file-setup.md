# Personal ASPIRE2A authentication setup

Date: 2026-10-23 (Asia/Singapore). Scope: local authentication setup only.

## Authorization and boundaries

The user requested installing `sshpass`, creating an empty password file for
the user to populate, setting up a separate personal SSH profile, and updating
the workflow to permit direct password-file authentication without reading or
outputting the password. The user confirmed username `rgao004` in lowercase.
No remote login/test, transfer, job operation, build, commit or push was
requested or performed.

## Actions and local evidence

- Read the numbered workflow pack, root instructions, application overview,
  latest dated progress report, Git state and existing relevant SSH stanza.
- Installation was initially rejected by auto-review because the old workflow
  prohibited `sshpass`. Updated root/workflow instructions within the user's
  explicit scope, then resubmitted the same installation for review. The
  subsequent reviewed installation succeeded; no indirect workaround was used.
- Installed Homebrew `sshpass` version `1.10` at `/opt/homebrew/bin/sshpass`.
- Created `/Users/sofia/.config/cluster-secrets/` with mode `700` and an empty
  `aspire2a-personal.password` with mode `600`, owned by `sofia`. Metadata
  recorded size zero immediately after creation. Never inspected contents;
  do not later read, hash, copy, log or commit this file.
- Created `/Users/sofia/.ssh/config.d/aspire2a-personal.conf` mode `600` and
  added only an Include at the top of the existing mode-`600` SSH config.
  Personal alias uses `rgao004`, host `aspire2antu.nscc.sg`, strict host-key
  verification and default `BatchMode yes`; the approved driver overrides only
  BatchMode to permit password prompting through `sshpass`.
- Kept the existing competition SSH stanza unchanged. Local `ssh -G` checks
  confirmed personal/competition users and distinct expanded ControlPaths.
- Changed `AGENTS.md`, `workflow/00-General-SSH-Rules.md` and
  `workflow/06-Workflow-Automation-and-Authorization.md` to define only this
  narrow exception. Existing unrelated workflow edits and other dirty files
  were preserved. No remote-execution script was changed.

## Local commands and validation

Installation (the first reviewed attempt was rejected, the second succeeded):

```sh
HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 /opt/homebrew/bin/brew install sshpass
```

Created only previously absent personal files with `apply_patch` under umask
`077`; prepared named directories using `install -d -m 700`, and enforced
file mode `600` with `chmod`. Existence/symlink checks preceded creation to
avoid overwriting credentials. `stat -f` checked metadata, not contents.

Local-only configuration checks (filtered output kept only non-secret fields):

```sh
ssh -G aspire2a-personal
ssh -G -o BatchMode=no aspire2a-personal
ssh -G aspire2a-comp
git diff --check -- AGENTS.md workflow/00-General-SSH-Rules.md workflow/06-Workflow-Automation-and-Authorization.md
```

`ssh -G` does not connect. No remote/scheduler commands were run; remote state
changes: none. Git was initially dirty and ahead of `origin/main` by 17
commits; no pull, staging, commit or push was performed for this setup.

## Remaining TBD and exact next action

The user fills the password file locally (one line, no quotes or `password=`).
Codex must not open the editor for it or inspect the resulting contents.
Personal-account reachability, authentication/MFA policy, trusted host-key
verification, remote home/project/allocation, scheduler and approved paths
remain unverified/TBD. Do not inherit competition account paths or permissions.

Future operations must have separate applicable authorization and use the
approved `sshpass -f` driver with metadata gates, trusted host-key checking,
one password prompt, a bounded command timeout and no automatic retries.
An empty file, rejected password or MFA challenge stops the affected action.

## Follow-up: authorized read-only automatic-login test succeeded

The user reported filling the file and explicitly authorized testing
`aspire2a-personal` with read-only commands, without reading/outputting the
password. Metadata checks confirmed a nonempty regular file, not a symlink,
owned by the current user, mode `600`, parent mode `700`. No password contents
or hash were inspected. Local effective-config checks confirmed user
`rgao004`, expected host, and strict host-key checking; `ssh-keygen -F` found
an existing host record, with key output suppressed.

One fresh login was attempted. Disabled ControlMaster/ControlPath reuse and
public-key authentication so a cached connection or SSH agent key could not
masquerade as a password-file success. The exact SSH command was:

```sh
/opt/homebrew/bin/sshpass -f /Users/sofia/.config/cluster-secrets/aspire2a-personal.password ssh -T -o BatchMode=no -o StrictHostKeyChecking=yes -o UpdateHostKeys=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=15 -o ConnectionAttempts=1 -o PreferredAuthentications=password,keyboard-interactive -o PubkeyAuthentication=no -o ControlMaster=no -o ControlPath=none -o ControlPersist=no -o ClearAllForwardings=yes aspire2a-personal 'hostname && whoami'
```

A local Python subprocess supervisor supplied a 45-second whole-command
timeout and process-group termination on timeout; it did not open the
credential file. The test completed normally without triggering the timeout
and without any retry. Output:

```text
asp2a-login-ntu02
rgao004
LOGIN_TEST_EXIT_STATUS=0
```

Verified: password-file authentication worked for this personal account in
this attempt, with the server key matching an existing local known-host
record. No additional MFA was required in this observed attempt; do not infer
a permanent MFA exemption or site policy. No host key was added/changed and
no persistent control connection was created. Remote application/files/job
state changes: none (normal SSH server authentication/session accounting may
occur). No remote commands beyond `hostname` and `whoami` were executed.

Updated only the local instruction/adapter verification state and this
handoff. No credential/SSH-config changes, file transfers, scheduler commands,
staging, commit or push. Project/allocation access, remote roots, scheduler
and transfer forms remain `TBD`; independent site fingerprint verification
was not performed. Resume only a separately authorized remote operation.
