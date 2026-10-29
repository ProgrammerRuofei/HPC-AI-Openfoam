# ICX 2025 binding, rank order and NUMA planning handoff

2026-10-30, Asia/Singapore. User requested a detailed plan and approximately
two hours of execution. Startup workflow/AGENTS/APPLICATION/progress and
main/isolated-worktree Git state were read. Existing unrelated changes retained.

## Completed

- Wrote planning/gadi-icx20253-binding-numa-plan.md, separating core binding,
  rank numbering/CPU placement and memory-page policy, with staged resources,
  failure handling, storage and correctness gates.
- Prepared three proposed-file diffs under planning/reviews/gadi-icx20253-binding-numa/.
  No remote-use script has been installed; they remain a review patch.
- Verified PBS shell syntax, embedded Python, helper parser/negative cases,
  archived real default/core geometry and Cd comparison, and patch applicability.
  Detailed validation is in the review README. No scientific executable ran.
- Read-only SSH control check succeeded (`ssh -O check gadi-comp`, Master running).
  Bounded BatchMode remote command: `hostname; /opt/nci/bin/nci_account -P pm78`.
  Returned gadi-login-06; pm78 used 5.24 KSU, available 8.76 KSU, reserved 0;
  scratch 527.80 GiB/1 TiB, inode 161.33K/202K. Snapshot only, not reservation.
  No credentials read and no remote state changes made.

## Pending approval after concrete diff

P0 one-node 104-core/10-minute preflight, then at most two same-host paired
40-step blocks AB and BA, each 104-core/40-minute, total ceiling 312 SU.
Each block has default/core arms with fresh input copies in private JOBFS.
B1/B2 are skipped if treatment is identical or confounded by NUMA placement;
BA waits for AB validation. No additional repetition or four-node run approved
by this package yet. GitHub/Gadi synchronization and raw-log pulls must be
included in the batch authorization and use verified adapter command forms.

## Continue

Show the full review patch and request one scoped batch approval under AGENTS.md.
If approved, materialize reviewed files only on the existing isolated branch,
verify hashes and synchronize; submit P0 exactly once. Preserve main and other
untracked work. Follow P0 -> AB -> BA validation gates. Queue time may exceed
user's approximate two-hour window. Rank-order/NUMA-policy/four-node followups
remain separately budgeted proposals, not automatically authorized submissions.

## Approval received 2026-10-30

User explicitly approved the first three-job batch, maximum 312 SU, including isolated-branch commit/synchronization, sequential gated submission and raw evidence retrieval. No further approval is needed for these unchanged reviewed jobs. Failures stop progression; additional jobs remain excluded.
