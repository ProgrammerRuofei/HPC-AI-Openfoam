# ASPIRE2A six-step optimisation — Step 2 repeatability report

Date: 2026-09-24  
Status: **STEP 2 COMPLETE**  
Job: `25523028.pbs101`  
Classification: 40-step repeatability screen; not an official scored result.

## 1. Outcome

The v5 job completed with PBS `Exit_status=0` and printed
`STEP2_CLEAN_REPEATABILITY_PASS`. Both identical AOCC/Open MPI/KaHIP arms
reached step 40, finalized normally and passed the finite-output checks.
Stdout contains `ARM_A0_OK` and `ARM_A1_OK`; stderr is empty.

PBS allocated four nodes, 512 CPUs and 1,600 GB requested memory. Runtime was
12:48. The retained PBS record reports `Stageout_status=1`, but both absolute
PBS output files and the complete run-root evidence are present and readable.
There is no observed evidence loss.

## 2. Controlled configuration

| Field | Evidence-backed value |
| --- | --- |
| OpenFOAM | v2512 |
| Compiler | AOCC 5.0, clang 17.0.6, `WM_COMPILER=Amd` |
| Build | `linux64AmdDPInt32Opt` |
| MPI | Open MPI 5.0.10, `WM_MPLIB=SYSTEMOPENMPI`, `FOAM_MPI=sys-openmpi` |
| Actual `libmpi` | `/app/apps/openmpi/5.0.10-gcc11/lib/libmpi.so.40` |
| `simpleFoam` SHA256 | `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f` |
| Nodes / ranks | 4 / 512, 128 ranks per node |
| Launcher | `mpirun`, `--bind-to core --map-by ppr:128:node:PE=1` |
| Decomposition | KaHIP `config=fast`, `imbalance=0.01` |
| Workload | 65,334,765 cells, fresh 40-step cases |

All required source-workload SHA256 gates passed. The job copied only the
scientific inputs into a fresh case, created one fresh partition and reused
that exact partition for A0 and A1. Neither arm inherited a `postProcessing`
directory, processor time directory or solver log.

## 3. Repeatability timing

| Metric | A0 | A1 | Pair difference |
| --- | ---: | ---: | ---: |
| OpenFOAM `Average wall-clock time per time step` | 2.855659040 | 2.861398735 | 0.2008% of pair mean |
| Mean `ExecutionTime` increment, steps 20-40 | 2.827619048 | 2.829047619 | **0.0505%** of pair mean |
| Mean `ClockTime` increment, steps 20-40 | 2.857142857 | 2.857142857 | **0.0000%** |

The pre-agreed Step 2 low-noise threshold was 1%. Both the steady-window
metric and the complete-run log metric pass comfortably. This allocation is
stable enough to proceed to a paired Step 3 screen.

The 40-step values are slightly below the retained 150-step bound result
`2.869256832 s/step`, but the windows and run lengths differ. The new job is
evidence of repeatability and harness correctness, not a replacement official
score.

## 4. Correctness and fresh Cd provenance

| Check | Result |
| --- | --- |
| coefficient rows | 40 in each arm, steps 1-40 |
| generated during current allocation | yes |
| A0/A1 coefficient SHA256 | both `2cca4fd36f8bc80c3e5799f6701ef3e097163d974730be47efa824f0e8caac0d` |
| coefficient files byte-identical | **yes** |
| Cd at step 40 | **0.43471632678608485** in both arms |
| Ux/Uy/Uz/p iteration records | identical at every step |
| all solver residual records | identical |
| all continuity records | identical |
| normal parallel finalisation | yes |

The fresh Cd(40) reproduces the original retained KaHIP Cd(40) value. Step 1's
stale-file problem is therefore repaired for this experiment.

## 5. Actual placement and NUMA evidence

The affinity manifest contains 512 unique global ranks on four hosts. Every
host has:

- exactly 128 ranks and local ranks 0-127;
- 128 unique physical `(socket, core)` placements;
- 128 unique CPU masks;
- ranks distributed across NUMA nodes 0-7.

Each `--bind-to core` mask contains two logical CPU IDs, for example rank 0
has mask `0,128`. These are the two SMT siblings of one physical core. Thus
the evidence establishes one rank per distinct physical core, with each rank
allowed on that core's two hardware threads. The original CSV gate treated
the comma inside a CPU mask as a field delimiter, but the retained parser
reconstructs masks from the fixed leading and trailing fields and validates
all 512 placements correctly.

The four actual host blocks are consecutive groups of 128 ranks, confirming
the mapping assumption used in the earlier cross-node partition analysis.

## 6. Partition identity and quality

| Metric | Value |
| --- | ---: |
| Cells | 65,334,765 |
| Mean cells/rank | 127,606.963 |
| Maximum cells/rank | 128,882 |
| Maximum / mean cells | 1.009992 |
| Distinct processor-interface faces | 2,786,035 |
| Maximum processor faces on one rank | 21,408 |

The double-counted per-rank processor-face sum divided by two exactly matches
the decomposition log's reported distinct total. These values reproduce the
retained KaHIP partition statistics used in Step 1.

## 7. Decision

Step 2 passes. No v6 repair or repeat is needed.

The next proposed experiment is Step 3A: a paired 40-step KaHIP imbalance
screen using this exact toolchain, placement, input set, measurement window
and control partition procedure. Before selecting a candidate imbalance value,
the installed KaHIP/OpenFOAM interface must be inspected to confirm supported
values and deterministic behavior. A complete local PBS diff is required
before remote synchronization or submission.

Step 3B remains a controlled Opt-build comparison of KaHIP against
hierarchical `(32 16 1)`, resolving the PgoUse/binding confound in the
teammate's `3.008 s/step` result.

## 8. Local evidence

Evidence directory:

`planning/evidence/aspire2a-step2-repeatability-25523028/`

It contains the PBS record, stdout/stderr, original evidence directory,
solver and decomposition logs, coefficient files, affinity manifest,
reproducible parser and JSON summaries. `analyze_step2.py` reconstructs the
reported metrics from the retained raw files.

## 9. Remote action record

Read-only commands were used after completion:

- `qstat -xf 25523028.pbs101`;
- `cat` and `find` under the named v5 run root and PBS output paths;
- `scp -p` of stdout/stderr and `scp -p -r` of the evidence directory.

No remote file was modified, no build or OpenFOAM command was run, and no job
was submitted, cancelled or retried during this analysis.
