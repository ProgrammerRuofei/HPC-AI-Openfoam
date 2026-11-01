# Collective-policy first step — review prepared

Read AGENTS, numbered workflow, APPLICATION, latest progress and main/isolated
Git state. Preserved every existing modification and untracked file.
User accepted order: MPI collective, rank placement, NUMA, then build flags.

Prepared only a local review patch and README at
`planning/reviews/gadi-icx20253-collective-policy-2026-11-01/`.
No executable installed. No remote commands, transfers, compilation, commit,
push or PBS operation. No monitor enabled.

Existing HCOLL evidence is two-rank P0 only, not full solver selection.
Proposed first job: existing ICX2025.3.2/OpenMPI5.0.10/OpenFOAM binary,
single node five ranks, default/no-HCOLL fresh Scotch tutorial cases,
20 steps each, same flags except collective exclusion. Includes existing-method
MPI runtime probe, solver collective verbose log and bindings. 5 CPU/16GB/
20GB JOBFS/10min, approximately 1.67 SU maximum. Timing is not a performance
result; tutorial has no DrivAer Cd. Full checks and limitations in review.

Local validation: proposed shell bash -n and Python AST pass. Embedded C
derived from successful P0, not locally compiled. Approval must follow shown
diff per AGENTS. Then implement reviewed script on isolated branch, verify
current remote prerequisites, sync exact hashes and submit once. No four-node
or automatic-repeat authorization requested by this first-step review.

User approved the concrete diff, one submission, isolated-branch synchronization and archival. Installed exact proposed SHA 5f964f4939ae5885d84d232813d254a1784c5fd1fff49ff4d6b4d490166c4ac4; bash -n and Python AST passed; original smoke unchanged. Remote prerequisites and job submission still pending.

## Submitted once — 182829851.gadi-pbs

Approved first compatibility job submitted 2026-11-01 Singapore session.
Script commit 485ab3369b62e7fe82873e1a7b3aed71ffc39c1a; SHA256
5f964f4939ae5885d84d232813d254a1784c5fd1fff49ff4d6b4d490166c4ac4.
GitHub/Gadi pushed, execution checkout ff-only/current HEAD and script SHA
verified; bash -n passed, unique stdout absent before submission.
Command: qsub experiments/gadi-icx20253-collective-policy/smoke_collective_policy_1n_v1.pbs
Returned 182829851.gadi-pbs. Never resubmit this attempt.

Resources: normalsr 5 CPU,16GB RAM,20GB JOBFS,10min (1.67SU ceiling).
Read-only quota before submission:6.53KSU available,0reserved;
scratch644.95GiB/1TiB,175033/202000inodes. No cleanup.
Stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/smoke_collective_policy_1n_v1.pbs.out
Evidence: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/collective-policy-smoke-v1/182829851.gadi-pbs/evidence

Next read-only check: PBS/stdout; require final and both arm PASS, private
MPI and probe UCP receipts, five ranks sum10, solver Time1..20/End, equal
input hashes and component-selection evidence. Tutorial has no DrivAer Cd
and verbose timing is not a performance result. Archive original bytes/SHA
by job ID, record actualSU and fallback components without claiming per-call
algorithm ownership. Do not submit four-node/extra retry. Monitor remains off.

Initial qstat -f: Q, nodect1, ncpus/mpiprocs5,mem17179869184,jobfs21474836480,walltime00:10:00. PBS timestamp ctime Mon Nov 2 02:06:16 2026 retained as server text; local record date uses client Asia/Singapore context. No result yet.
