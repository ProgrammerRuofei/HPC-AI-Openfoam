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

## Approved synchronization and one submission

After reviewing the prepared script, the user separately approved a commit, GitHub/Gadi push, remote hash check, and exactly one two-node PBS submission. The four related files were committed as `f00872ffaa88394177d8048b6d480331f8a7e4e9` on `codex/gadi-gcc162-build`. `git ls-remote` verified that both GitHub and Gadi branch refs point to that commit. The Gadi main checkout remained on `main` with its pre-existing unrelated untracked files preserved.

The branch blob was materialized as the previously unused immutable script `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_scaling_2n_scotch_v1.submitted.pbs`; remote `sha256sum -c` and `bash -n` passed. SHA-256: `89a789fa1fcf58ac4566f16b29becbc851d14e3719c90d1ba2b731588f670b04`. Remote working copies of the two unchanged node-stage helpers matched the branch blob hashes. Before submission, `nci_account -P pm78` reported 5.73 KSU available, zero reserved, and scratch inodes 200.91K/202K. A retained successful four-node case used 555 scratch inodes; the two-node script creates 208 processor symlinks and two stage tar files, so its expected inode increment is below the then-current ~1.09K normal headroom, though this should be checked during execution.

Exact submission command, run once from the Gadi control checkout:

```sh
/opt/pbs/default/bin/qsub /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_scaling_2n_scotch_v1.submitted.pbs
```

It returned **`182022356.gadi-pbs`**. Initial `/opt/pbs/default/bin/qstat -f 182022356.gadi-pbs` reported Q on `normalsr-exec`, 2 nodes ×104 CPUs/MPIPROCS, 380 GB memory, 100 GB JOBFS, and 30 minutes. There is no PBS result, Cd, timing, or actual SU yet. Independent stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_scaling_2n_scotch_v1.pbs.out`. Job-keyed evidence will be under `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/scaling-2n-scotch/182022356.gadi-pbs/evidence/`.

Monitor at a bounded cadence. If SSH fails, classify transport as unavailable, not the PBS job as failed. On terminal state, preserve logs and verify PBS exit, script PASS, both SPR hosts with 104 ranks each, five `End` markers, `Time = 80`, coded average wall seconds/step, finite Cd near the rules' ~0.34 sanity reference, input hashes and actual SU. No repeat or automatic retry is authorized.
