# Gadi Phase 0 baseline repeat — successful independent reproduction

## Project status

- **GADI CLUSTER ADAPTER: READY FOR DOCUMENTED PHASE 0 REPEATABILITY RUNS**
- **PHASE 0 INITIAL REPEAT: PASS** — PBS job `178063948.gadi-pbs`, 2026-09-03.

## Fresh work area used by Phase 0

```
/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902
```

The historical source remains read-only for this workflow:

```
/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh
```

Before the approved submission, only the empty `submit-logs` directory was
created. PBS opens its `-o` file before the script begins; the fresh case and
evidence directory were then created by the job on allocated compute nodes.

```
/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/submit-logs
```

The candidate PBS job refuses to run if the fresh `case` directory already
exists. It preserved the historical source case as read-only.

## Fresh-copy protocol

The candidate copies exactly `0.orig`, `constant`, `system`, and `Allrun.gadi`
from the source case. The historical `Allrun.gadi` resets `0` from `0.orig`,
uses `controlDict.noWrite`, preserves `fvSolution.fixedIter`, then performs a
fresh `decomposePar` into its own work area before the unchanged solver launch.
It deliberately does **not** copy source `0`, numerical time directories,
`logFiles`, `postProcessing`, `dynamicCode`, or `processor*` directories.
`constant/polyMesh` is retained as part of `constant`, so the source mesh is
preserved.

Before submission, confirm that `0` is the historical baseline's intended
initial condition and that the historical `drivaer_4n.pbs` has no additional
required case files outside these three directories.  Do not submit until
the provenance fields and the comparison against that script are filled in.

## Invariants requested for Phase 0

- Gadi / NCI, project `pm78`
- OpenFOAM.com `v2512`
- 4 nodes, 48 MPI ranks per node, 192 ranks total
- `hierarchical`, `n (16 6 2)`
- SIMPLE target: 150 iterations (must be verified in copied `controlDict`)
- unchanged launcher: `mpirun -np "$PBS_NCPUS" simpleFoam -parallel`
- no explicit CPU binding or MPI performance options

## Phase 0 provenance

- GCC and G++: `8.5.0 20210514 (Red Hat 8.5.0-28)`
- `WM_COMPILER=Gcc`
- `WM_OPTIONS=linux64GccDPInt32Opt`
- `WM_MPLIB=SYSTEMOPENMPI`
- MPI: `Open MPI 4.1.7`
- OpenFOAM build: module `OpenFOAM/2512`, `WM_PROJECT_VERSION=v2512`,
  `WM_PROJECT_DIR=/apps/OpenFOAM/2512`
- **Compute-node CPU:** Intel(R) Xeon(R) Platinum **8274** CPU @ 3.20GHz;
  2 sockets × 24 physical cores = 48 physical cores/node; SMT = 2. This
  compute-node observation supersedes the earlier login-node 8268 observation.

The historical PBS script SHA-256 is
`c92003460300d5aa5f0ca6ccf7f68052c47454650bf87fcb40a6ef5b22172756`.
The candidate is deliberately built from that script's PBS request and
`Allrun.gadi` protocol; its local snapshot is
[historical_drivaer_4n.pbs](historical_drivaer_4n.pbs).

## Validation completed before `qsub`

1. Read the source `drivaer_4n.pbs` and exact source dictionary locations.
2. Record `gcc --version`, `g++ --version`, `WM_COMPILER`, `WM_OPTIONS`,
   `WM_MPLIB`, `mpirun --version`, the OpenFOAM build/version, and the CPU
   topology under the loaded OpenFOAM/2512 environment.
3. Confirm source metadata/checksums are unchanged before versus after the
   candidate preparation (the candidate itself does no remote write).
4. Confirm the copied `decomposeParDict` has `method hierarchical` and
   `numberOfSubdomains 192` with `n (16 6 2)`; confirm the workload has a
   150-iteration target.
5. Run `bash -n` on the final script and review `diff -u` against the
   historical script.

The executed candidate is [phase0_baseline_repeat_4n.pbs](phase0_baseline_repeat_4n.pbs),
from Git commit `21c4c48` in the Gadi control clone
`/scratch/pm78/kj7183/openfoam_cpu/control-repo`.

## Phase 0 consolidation

### 1. Objective

Validate that an independent fresh-case workflow can reproduce the documented
four-node Gadi baseline configuration. Phase 0 is a reproducibility validation,
not an optimisation experiment.

### 2. Controlled configuration

- OpenFOAM.com v2512; GCC 8.5.0; Open MPI 4.1.7.
- Four nodes, 48 MPI ranks/node, 192 ranks total, and one OpenMP thread/rank.
- 150 SIMPLE iterations; hierarchical decomposition `n (16 6 2)`.
- Historical `Allrun.gadi` pipeline and `mpirun -np "$PBS_NCPUS" simpleFoam -parallel`.
- No newly introduced binding, MPI tuning, decomposition, solver, or numerical change.

### 3. Hardware and software provenance

The job ran on `gadi-cpu-clx-1096`, `gadi-cpu-clx-1105`,
`gadi-cpu-clx-1106`, and `gadi-cpu-clx-1115`. Each reported Xeon Platinum
8274 @ 3.20 GHz, two sockets, 24 physical cores/socket, and SMT = 2. The
loaded module environment was `openmpi/4.1.7` and `OpenFOAM/2512`.

### 4. Fresh-case isolation

The job copied only `0.orig`, `constant`, `system`, and `Allrun.gadi` from the
immutable historical source. It excluded prior `0`, time directories,
`logFiles`, `postProcessing`, `dynamicCode`, and all `processor*` directories.
It recorded checksums for the copied launcher and dictionaries.

### 5. Validation checks

The preflight confirmed four allocated nodes, 192 ranks, OpenFOAM v2512,
GCC/Open MPI versions, `nCores 192`, `nHierarchical (16 6 2)`, `endTime 150`,
fixed-iteration `fvSolution`, the mesh, and the executable launcher. The
solver reached `Time = 150`, followed by `End` and `Finalising parallel run`;
PBS reported `Exit_status = 0`.

### 6. Result

| Metric | Phase 0 measurement |
| --- | ---: |
| Solver ClockTime | 802 s |
| Solver ExecutionTime | 781.85 s |
| Mean measured timestep wall time | 5.1367 s/step |
| Measured timesteps | 149 |
| PBS walltime | 17m54s |
| Peak memory | 230.13 GB |

### 7. Historical comparison

The documented historical four-node reference is ClockTime 787 s,
ExecutionTime 776.52 s, and mean measured timestep time 5.174129850805368
s/step. Phase 0 ClockTime is 15 s (about 1.9%) higher, while its mean measured
timestep time is slightly lower.

### 8. Interpretation

Phase 0 is a **PASS**: the isolated workflow reproduced the required
configuration and completed the fixed workload. The single 802 s result is a
measurement, not evidence of a regression or an optimisation conclusion.

### 9. Limitations

One repeat cannot estimate run-to-run variance or establish a controlled
baseline median. The official scientific acceptance criteria remain to be
recorded separately; this validation confirms the fixed-step workflow and its
normal completion markers.

### 10. Next step — repeatability

Prepare two further independent fresh-case repeats before any profiling or
optimisation comparison. Retain every individual measurement and use their
controlled-run median, not the fastest run, as the future comparison baseline.

## Evidence

- PBS output: `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/submit-logs/drivaer_p0r_4n.pbs.out`
- Solver log: `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/case/logFiles/50_simpleFoam.178063948.gadi-pbs.log`
- Provenance and copied checksums: `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/evidence/phase0-baseline-repeat-20260902-4n-192r.178063948.gadi-pbs/`

## Phase 0 closeout — four controlled repeats

**Closeout date:** 2026-09-03.  This section records extracted facts and
interpretation; it does not alter any raw remote artifact.  The four repeats
are correctness-valid controlled observations.  R2 is retained in the raw
dataset despite its anomalous performance.

### Exact shared configuration

Every run recorded `OpenFOAM v2512` at `/apps/OpenFOAM/2512`, GCC/G++ `8.5.0
20210514`, Open MPI `4.1.7`, `WM_OPTIONS=linux64GccDPInt32Opt`, and
`WM_MPLIB=SYSTEMOPENMPI`.  Each requested four nodes / 192 `ncpus` / 192
`mpiprocs` (48 ranks per node), used `mpirun -np 192 simpleFoam -parallel`,
one OpenMP thread per rank, `hierarchical (16 6 2)`, `endTime 150`, and the
fixed-iteration `fvSolution`.  No script specifies an explicit Open MPI
binding or mapping option; the detailed runtime binding map was not captured.

Each provenance log records the same copied-protocol SHA-256 values:
`Allrun.gadi` `2a02ec…a662ec3`, `caseDefinition` `1da447…e6a6c6`,
`controlDict.noWrite` `ce4ec0…278ef06`, `fvSchemes` `064bb5…7889b3`, and
both fixed-iteration `fvSolution` files `5e1db8…cab1ba`.  Thus the source
workload protocol and protected numerical dictionaries agree across R1–R4.

The local PBS diffs independently show that R2–R4 differ from R1 only in PBS
job name, PBS output path, `REPEAT_ROOT`, and `RUN_TAG`.  Physical allocation
is deliberately not controlled: every repeat received a different four-node
set.

### Raw repeat inventory and validity

| Repeat | PBS job | Allocated nodes | PBS / exit | Classification | Artifact note |
| --- | --- | --- | --- | --- | --- |
| R1 | `178063948.gadi-pbs` | 1096, 1105, 1106, 1115 | F / 0 | VALID CONTROLLED REPEAT | Expected solver, provenance, and PBS output artifacts present. |
| R2 | `178073349.gadi-pbs` | 1694, 1695, 1696, 1706 | F / 0 | VALID CONTROLLED REPEAT | Correctness-valid sustained performance anomaly; retained. |
| R3 | `178073350.gadi-pbs` | 0995, 1000, 1003, 1004 | F / 0 | VALID CONTROLLED REPEAT | Expected solver, provenance, and PBS output artifacts present. |
| R4 | `178107780.gadi-pbs` | 1274, 1280, 1281, 1282 | F / 0 | VALID WITH DOCUMENTED ARTIFACT ANOMALY | Configured `submit-logs` PBS stdout is absent. Provenance `run.log`, solver log, and PBS historical record are present; no repair was performed. |

All four solver logs reached `Time = 150`, then `End` and `Finalising parallel
run`.  The fresh-copy protocol created a separate case for each repeat; no
historical source case was modified.

| Repeat | ClockTime (s) | ExecutionTime (s) | Clock−Execution (s) | Measured steps | Mean timestep (s) | Timestep stddev (s) | PBS walltime | PBS memory (kb) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| R1 | 802 | 781.85 | 20.15 | 149 | 5.136668 | 0.027106 | 17m54s | 241,305,336 |
| R2 | 1045 | 1025.47 | 19.53 | 149 | 6.842763 | 0.310174 | 21m52s | 241,862,424 |
| R3 | 793 | 773.28 | 19.72 | 149 | 5.152651 | 0.023207 | 17m48s | 236,809,152 |
| R4 | 790 | 770.84 | 19.16 | 149 | 5.129230 | 0.023586 | 17m40s | 239,705,140 |

Raw remote evidence roots are the corresponding
`/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-*` directories;
every solver log is `case/logFiles/50_simpleFoam.<PBS_JOBID>.log` and every
provenance root contains `run.log` plus `copied-protocol.sha256`.

### Repeatability statistics

Sample standard deviation is used below; percentage is relative to the
four-run median.  These summaries retain R2 and therefore describe the full
observed controlled sample, not a normal-noise estimate.

| Metric | R1 | R2 | R3 | R4 | Min / max / range | Mean | Median | Sample SD | CV | R1/R2/R3/R4 vs median |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | --- |
| Solver ClockTime (s) | 802 | 1045 | 793 | 790 | 790 / 1045 / 255 | 857.50 | 797.50 | 125.10 | 14.59% | +0.56% / +31.03% / −0.56% / −0.94% |
| Solver ExecutionTime (s) | 781.85 | 1025.47 | 773.28 | 770.84 | 770.84 / 1025.47 / 254.63 | 837.86 | 777.565 | 125.16 | 14.94% | +0.55% / +31.88% / −0.55% / −0.86% |
| Mean timestep (s) | 5.136668 | 6.842763 | 5.152651 | 5.129230 | 5.129230 / 6.842763 / 1.713533 | 5.565328 | 5.144659 | 0.851679 | 15.30% | −0.16% / +33.01% / +0.16% / −0.30% |

### Interpretation and baseline status

R1, R3, and R4 form a close observed group (ClockTime 790–802 s); R2 is
approximately 31% above the all-run ClockTime median and has a much larger
within-run timestep standard deviation.  R2's timestep sequence rises from
an initial 5.21 s to approximately 7.0 s/step for the later run, rather than
showing a small number of isolated large spikes.  Its `ClockTime −
ExecutionTime` overhead (19.53 s) is comparable to the other three
(19.16–20.15 s), so the measurable difference is in per-timestep solver
performance, not startup/finalisation overhead.  Its longer PBS walltime is
consistent with that solver-time difference.

Different physical node sets correlate with the four observations only in the
weak sense that each run had a different allocation.  No captured per-rank
timing, node-level frequency, network/MPI counters, binding map, or filesystem
throughput establishes a cause.  CPU-frequency variation, OS noise,
MPI/network contention, rank straggling, NUMA placement, and filesystem noise
remain hypotheses, not findings.

**Baseline configuration:** frozen reference configuration is the verified
GCC 8.5.0 / Open MPI 4.1.7 / OpenFOAM v2512 four-node configuration above.

**Representative baseline performance:** report the median of all valid
controlled repeats, currently Solver ClockTime **797.5 s**.  R1 (802 s) is
the valid concrete run closest to that median, but it is not selected as a
replacement for the median.  R2 remains reported.  Four runs cannot establish
a stationary normal-noise distribution or attribute the anomaly to hardware.

### Next approved planning boundary

No toolchain build, PBS submission, profiling, or optimisation has begun.
The next proposed phase is compiler/toolchain screening, with the frozen
configuration as control and only one primary variable changed per experiment.
