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
