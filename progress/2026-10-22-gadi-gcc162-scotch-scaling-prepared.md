# GCC 16.2 Scotch scaling preparation — 2026-10-22

The user selected the existing default-binding one-node GCC 16.2/Open MPI 5.0.10/OpenFOAM v2512/Scotch result as the one-node scaling baseline and authorized local preparation of a matching two-node script. No new PBS job, remote sync, commit, or push was authorized by this scope or performed here.

## Existing evidence

| Point | Job | Nodes/ranks | Steps | Average wall seconds/step | Cd | Actual SU | State |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| Selected 1N | `182017873.gadi-pbs` | 1/104 | 40 | 8.373520290307694 | 0.43806006706848422 | 40.50 | PBS F/exit 0, complete |
| 4N candidate | `181368883.gadi-pbs` | 4/416 | 150 | 1.991194389201344 | 0.29187594927465327 | 226.26 | PBS F/exit 0, complete |
| 4N repeat | `181371071.gadi-pbs` | 4/416 | 150 | 1.988625920 | 0.29187594927465327 | 230.19 | PBS F/exit 0, complete |
| Missing 2N | — | 2/208 | 80 | — | — | — | script prepared, no submission |

The 1N core-bound job `182019151.gadi-pbs` is an affinity comparison, not the selected scaling baseline. Its single-pair 0.32437% speed difference is not a confirmed gain. The older site-module hierarchical official reference remains separate.

All chosen GCC16 points use Gadi `normalsr` Sapphire Rapids (Xeon Platinum 8470Q), one MPI rank per physical core, the pinned GCC 16.2.0/Open MPI 5.0.10/OpenFOAM v2512 archives, `ppr:104:node` without explicit core binding, Scotch decomposition, fixed ~65M `occDrivAerStaticMesh`, unchanged `simpleFoam`, `fvSchemes`, and `fvSolution.fixedIter`. The launch explicitly selects UCX PML and loads `ucx/1.18.1` and `ucc/1.4.4` modules. The historical jobs did not record the effective loaded `libucp` version or UCC collective selection; do not infer those from the module list.

The 2026 competition rules prescribe 40/80/150 steps for 1/2/4 nodes and use average wall-clock time per step for scaling. They require the full Allrun preparation chain. Their Cd numbers are a sanity check, not a strict Basic pass/fail range.

## Prepared local script

`builds/build-scripts/gadi-gcc162-ompi5010/run_scaling_2n_scotch_v1.pbs` is derived from the already successful four-node script. It requests 208 CPUs on two `normalsr` nodes, 380 GB memory, 100 GB JOBFS, and 30 minutes. At the observed 2 SU per core-hour rate, the request ceiling is 208 SU; actual charges depend on elapsed walltime. The script creates a unique job-ID evidence directory and stdout path, verifies source/archive/binary hashes, stages runtime and 104 processor directories per node, checks the two rank-to-host groups, runs the full preparation chain, and records the 80-step timing and finite Cd. The old stage helpers are node-count agnostic despite their `stage_4n_*` names and are reused unchanged.

Local `bash -n`, source-to-2N diff review, static parameter assertions, and `git diff --check` passed. The script has not been run on Gadi. Its untracked status and the two modified result files remain in the isolated `codex/gadi-gcc162-build` worktree for review. The primary `main` checkout and its unrelated changes were untouched.

Next action: review the final local diff, obtain separate approval for commit/push/remote synchronization and one two-node PBS submission, then verify remote hash and submit once with a unique stdout. Do not resubmit if the qsub result is unknown. After completion, inspect PBS exit, full-chain End markers, `Time = 80`, average seconds/step, coefficient.dat Cd, node mapping, and actual SU before adding the 2N point to the scaling table.
