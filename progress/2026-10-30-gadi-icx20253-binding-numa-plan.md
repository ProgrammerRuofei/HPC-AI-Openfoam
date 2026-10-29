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

## P0 submitted — 182588070.gadi-pbs

Approved script commit 2b71932034f54ad9c6007aecb81c37f49a7200f2. The user approved all three gated jobs, maximum 312 SU, after full diff review. Submitted only P0 once using `/opt/pbs/default/bin/qsub experiments/gadi-icx20253-binding-numa/preflight_binding_numa_1n_v1.pbs` from `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo`.

The initial generic `git pull --ff-only` attempted the checkout's GitHub origin and failed authentication before qsub; no job was submitted in that command. No credentials/configuration were changed. The verified local Gadi transport was used explicitly: `git pull --ff-only /scratch/pm78/kj7183/openfoam_cpu/control-repo codex/gadi-gcc162-build`. HEAD and all three file hashes matched; remote bash -n passed; independent stdout was absent. The single qsub returned 182588070.gadi-pbs.

stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_binding_numa_1n_v1.pbs.out`.
Evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-numa-preflight-v1/182588070.gadi-pbs/evidence/`.

P0 requests 104 cores/16 GB/20 GB JOBFS/10 minutes (34.67 SU max). AB and BA remain unsubmitted and must pass the documented gates. Pre-submission pm78 had 8.76 KSU available, scratch 527.80 GiB and 161.33K inodes. No historical evidence or unrelated files altered.

## Active bounded follow-up

Thread heartbeat `gadi-icx-binding` is ACTIVE at five-minute intervals to monitor P0 182588070 and advance only the approved gated AB/BA batch. It stays quiet on unchanged Q/R and pauses on failure, redundant treatment, or completion. Latest observed P0 state: Q; AB/BA not submitted. No additional SU scope beyond 312 maximum.
