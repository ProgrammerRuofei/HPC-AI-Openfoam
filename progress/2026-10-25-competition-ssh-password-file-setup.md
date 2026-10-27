# Competition SSH direct-login setup — 2026-10-25

## Scope and local changes

The user requested direct, non-master authentication for the competition
`gadi-comp` and `aspire2a-comp` aliases. The user approved the displayed
password-file policy change. No credential value is stored in this repository.

- Created empty, user-owned mode-`600` files
  `/Users/sofia/.config/cluster-secrets/gadi-comp.password` and
  `/Users/sofia/.config/cluster-secrets/aspire2a-comp.password` beneath the
  existing mode-`700` directory. Their contents were never inspected.
- Added a narrow direct `sshpass -f` exception to `AGENTS.md` and
  `workflow/00-General-SSH-Rules.md`, including one-attempt and host-key
  safeguards. No SSH configuration file was edited.
- `git diff --check` passed for those documentation files. Changes remain
  uncommitted among unrelated pre-existing local work.

## Evidence and boundaries

- `ssh -G` with direct-mode overrides confirmed `gadi-comp` maps to
  `kj7183@gadi.nci.org.au` and `aspire2a-comp` to
  `apacsc20@aspire2antu.nscc.sg`, with `BatchMode=no`,
  `ControlMaster=no`, `ControlPersist=no`, and strict host-key checking.
- `ssh-keygen -F` confirmed an existing local host-key record for each host;
  the key material was not printed. Independent fingerprint verification is
  still `TBD`.
- Before setup, one fresh, key-only, non-interactive `ssh ... 'hostname &&
  whoami'` attempt per alias failed authentication. Gadi advertised public-key
  and password methods; ASPIRE2A advertised password but not public-key.
  These were authentication checks, not PBS/job outcomes.
- The two new password files remain empty. Direct password login, current MFA
  behavior, and future connection reliability are `TBD` until the user fills
  the files locally and a separately authorized one-attempt login test passes.
- No remote file was changed; no transfer, build, scheduler command, or job
  submission/cancellation occurred. No commit, push, or SSH config edit was
  made for this setup.

## Next step

The user should rotate the credentials exposed in chat, then enter each new
password into its matching local file without sending it to Codex. After the
user reports both files filled, perform metadata-only checks and one bounded
direct-login test per alias. Preserve the independent remote-work approval
rules for any subsequent operation.

## Follow-up: user filled files; one direct test per alias failed

The user reported filling both local files. Metadata-only checks found both
regular, non-symlink files owned by `sofia`, each mode `600` and nonzero size,
under the mode-`700` parent. No password content was inspected or printed.
`ssh -G` confirmed both expected alias/user/host mappings and password and
keyboard-interactive authentication enabled. Existing host-key records were
already confirmed above.

One fresh, bounded, no-control-socket `sshpass -f ... ssh -T ... 'hostname &&
whoami'` attempt was made for each alias, with `BatchMode=no`, strict host-key
checking, one password prompt, no public-key/GSSAPI attempt, and no retry.
Both returned SSH exit `255` with a `Permission denied` classification; no
remote hostname or username was established. Gadi's attempt took about 3.5 s;
ASPIRE2A's took under 1 s. Neither outcome is a PBS or cluster-job failure.

The actual cause is `TBD`: possible credential mismatch, account policy, or
site authentication flow. Do not repeat either automatic login until the user
checks the matching account/password directly in a terminal or obtains site
guidance. No remote scheduler command or state change occurred.

## Follow-up: user manual direct SSH succeeds

The user ran `ssh -T -o ControlMaster=no -o ControlPath=none -o
NumberOfPasswordPrompts=1` with `hostname && whoami` for each competition
alias and supplied the password interactively. Gadi returned
`gadi-login-02.gadi.nci.org.au` and `kj7183`; ASPIRE2A returned
`asp2a-login-ntu02` and `apacsc20`. This is user-provided evidence that both
accounts support direct password SSH without a persistent master. It does not
validate the local password-file contents or `sshpass` driver. The remaining
fault is local credential-file mismatch or driver/prompt compatibility; do not
infer an account or cluster outage from the earlier automatic attempts.

## Follow-up: files re-entered; automatic mode still rejected

After the user reported re-entering both files, metadata again confirmed
user-owned non-symlink mode-`600` files with nonzero sizes under the mode-`700`
parent. One fresh `sshpass -f` direct login per alias again returned SSH exit
`255` and `Permission denied`; no remote `hostname`/`whoami` result. There was
no automatic retry. A local-only `/opt/homebrew/bin/sshpass -f <file>
/usr/bin/true` test returned `0` for each file, establishing that the driver
can open the paths; it does not establish that the stored values match the
interactive credentials or that the site prompt is handled correctly.

Both accounts remain confirmed reachable by the user's interactive, no-master
SSH tests. Automated direct access remains unverified. Further login attempts
should wait for a reviewed diagnostic approach or user-run test. No PBS action
or remote state change occurred.

## Follow-up: matching credentials, sshpass-specific failure

The user ran a local hidden-input comparison and reported `MATCH` for both
files against the passwords that succeeded in direct interactive SSH. This
rules out a simple file-value mismatch by user report; Codex did not read the
files. A deliberate Gadi diagnostic wrapping the successful SSH command in
`sshpass -f` still returned exit `255` / `Permission denied`. Another Gadi
diagnostic selected the observed password-prompt text explicitly with
`sshpass -P`; it also returned exit `255` / `Permission denied`. No further
automatic login attempts should be made without a new authentication plan.

The confirmed result is that direct interactive SSH needs no persistent
master for either cluster, while this `sshpass` mode is not working for either
competition account. The precise mechanism remains `TBD`; do not assume a
cluster or PBS failure and do not claim automatic access is configured.

## Resolution: PTY-capable execution validates both direct logins

A local-only mock with a dummy password isolated the cause: the default
command sandbox denied `/dev/tty` access, while the same mock succeeded in a
PTY-capable execution context. No real credential was used in that mock.
Earlier sandboxed `sshpass` failures were therefore not evidence of a wrong
password or cluster outage.

In the PTY-capable context, one bounded `sshpass -f` direct login per alias
executed the read-only command `hostname && whoami` with `ControlMaster=no`,
`ControlPath=none`, strict host-key checking, one password prompt and no
automatic retry. Gadi returned `gadi-login-02.gadi.nci.org.au` and `kj7183`;
ASPIRE2A returned `asp2a-login-ntu01` and `apacsc20`. Both exited `0`.
Neither credential was read or printed by Codex. No master connection was
started, no remote file changed and no PBS command ran.

Direct, non-master authentication is now verified for these two aliases in
the PTY-capable execution context. Future actions still need their own scope
and the metadata/host-key/timeout checks in `workflow/00-General-SSH-Rules.md`.
