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

## P0 validated — 182588070.gadi-pbs

PBS F / Exit0; script_exit_rc0 and unique PASS. SPR host0381,104CPU,23seconds walltime,actual1.33SU. Default104 ranks each allowed13 physicalcores in one NUMA domain; core104 distinct physicalcores, each within the same rank's default CPU mask. Independent local helper validation passes; can_run_binding=true. Optional fill/span104-rank placement launches pass too.

Both MPI runtime ranks report UCP /usr/lib64/libucp.so.0 version1.21.0 with Allreduce sum1. HCOLL selected in dual-rank collective receipt; UCC unavailable/disqualified. These observations do not establish actual104-rank solver collective selection or memory-page placement. Modules remain ucx1.18.1/ucc1.4.4; module names alone do not identify the loaded library.

Archived444 original files with remote/local SHA agreement plus captured qstat-xf.txt in planning/evidence/gadi-pbs-script-snapshot/logs/182588070.gadi-pbs/. First short SCP pull hit a90second local transfer timeout while making progress; existing partial files were preserved and checked. Independent folder pulls into fresh staging directories with bounded420second transfer deadlines completed; this was not an authentication or PBS failure, and no job was retried. No raw file overwritten. No OpenFOAM solve, Cd or seconds/step in this preflight.

Next authorized action: once archive/result commit is synchronized and remote script hashes and absent unique AB stdout checked, submit AB once with BIND_ORDER=ab,BIND_PREFLIGHT_JOB=182588070.gadi-pbs and explicit _ab stdout. BA remains gated on AB results. Script unchanged from reviewed commit2b71932.

## AB submitted — 182588604.gadi-pbs

P0 fully validated and raw archive committed as46b9f53626d0e0e590e91877f5c7566a3b8767a8, synchronized GitHub/Gadi. Remote ff-only, HEAD, pair/helper SHA and bash -n passed; independent AB stdout absent. Submitted once:
`qsub -v BIND_ORDER=ab,BIND_PREFLIGHT_JOB=182588070.gadi-pbs -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_binding_pair_1n_v1_ab.pbs.out experiments/gadi-icx20253-binding-numa/run_binding_pair_1n_v1.pbs`.

Returned182588604.gadi-pbs. OneSPR104CPU/190GB/100GBJOBFS/40minutes,138.67SU ceiling. ICX2025.3.2/OpenMPI5.0.10/Scotch,default then core,104ranks and40steps each. Job evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-pair-1n-v1/ab/182588604.gadi-pbs/evidence/`.
BA has NOT been submitted. Never resubmit AB; monitor this ID. Advance to one BA only after complete PBS/solver/Cd/geometry/placement validation and archival. User approval remains312SU maximum and no extra jobs or failure retry.

## AB validated — 182588604.gadi-pbs

PBS F / Exit0, script_exit_rc0 and pair/arm PASS markers. One normalsr Sapphire Rapids8470Q host gadi-cpu-spr-0201,104 allocated CPUs,190GB memory,100GBJOBFS,40minute request. ICX2025.3.2/private OpenMPI5.0.10/OpenFOAMv2512/Scotch; fixed65,334,765cell scientific input. Modules ucx1.18.1/ucc1.4.4 declared; no UCX preload or collective override. Actual solver UCP version/collective selection remains unmeasured; P0 two-rank results cannot establish it.

Default then core,104 ranks and40steps each. Default8.25222384897436s/step,core8.248214656871795s/step,core lower by0.0485832%. Both final Cd0.43806006706848277; entire retained Cd trajectories identical. Complete preparation/solver End,exactTime1..40,finite positive coded timing,matching input and partition vectors pass independent local checks. Placement and solver-wrapper receipts contain104 ranks on the same host;core104 unique physicalcores stay within corresponding default masks. Pre-exec masks do not prove memory-page placement or post-MPI-init affinity.

Walltime22:56,actual79.50SU for the whole pair (not per arm),posted PBS receipt. Peak memory receipt190GB,JOBFS38.94GB. All465 remote originals (464 evidence files plus stdout) SHA matched; captured qstat is separate. Source paths/fileSHA in job archive sources.tsv/SHA256SUMS,default/core subdirectories preserved. No source/input or run-script change; no retry. Tiny one-pair timing difference is not a demonstrated binding benefit;40steps is screening,not a150step score.

BA remains conditional and unsubmitted at this validation record. After synchronization,quota check,hash checks and absent BAstdout,submit the already approved BA once;record returned ID immediately. Total cost so far P0+AB=80.83SU.
