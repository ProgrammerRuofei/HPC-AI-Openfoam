# ASPIRE2A optimisation plan after teammate results

Date: 2026-09-24  
Scope: OpenFOAM v2512 `occDrivAerStaticMesh`, 65,334,765 cells, ASPIRE2A.  
Primary objective: improve the 4-node / 512-rank result without changing the
scientific workload. Secondary objective: produce evidence that explains the
performance result and can be defended in the competition presentation.

## 1. Current evidence and decisions

The controlled working baseline is AOCC 5.0, Open MPI 5.0.10, KaHIP
`config=fast`, `imbalance=0.01`, four nodes, 128 ranks per node, 512 ranks,
explicit core binding. The retained 150-step result is
`2.869256832046979 s/step` (job `20092999`). The teammate PgoUse result is
`2.868 s/step` (job `21252868`), only about 0.03% faster, so PGO has no
demonstrated material benefit. The Opt build remains the controlled analysis
baseline; PgoUse may be retained as a nominal final candidate only after a
matched repeat shows a real advantage.

Teammate results close or lower the priority of these branches:

- AOCC and GCC PGO: no repeatable gain; close.
- GCC `znver3`: no gain; close.
- METIS: `2.934 s/step` at 4N/512, about 2.30% slower than the PgoUse quote;
  close unless later profiling gives a specific reason to revisit it.
- A separate vendor Open MPI 5.0.10 + UCX build: skip because the site
  Open MPI 5.0.10 already provides `pml:ucx`.
- Binding by itself: previously changed KaHIP by only about 0.23%; retain a
  fixed explicit binding policy as a control rather than a leading tuning
  axis.

Results that remain informative but need controlled validation:

- hierarchical `(32 16 1)` reached `3.008 s/step`, substantially better than
  `(8 8 8)` at `3.355476 s/step`, but it used the PgoUse tree and is not yet a
  one-variable comparison with the Opt bound KaHIP baseline.
- Scotch remains close to KaHIP and is especially relevant to the future Gadi
  path. On ASPIRE2A it is a diagnostic comparison, not the leading candidate.
- mpiP reports show KaHIP < Scotch < hierarchical in aggregate MPI time.
  `MPI_Allreduce` is about half of measured MPI time, while `MPI_Waitall`
  rises from 28.25% for KaHIP to 34.41% for hierarchical. This justifies one
  controlled collective-algorithm screen and continued partition analysis.

## 2. Experiment rules shared by Steps 2-6

Every controlled pair must keep fixed:

- OpenFOAM v2512 source and exact `simpleFoam` binary unless the experiment is
  explicitly a compiler comparison;
- mesh, initial fields, `fvSchemes`, `fvSolution`, force coefficients and
  `controlDict`, verified with SHA256;
- 4 nodes, 128 ranks per node, 512 ranks, PBS placement and walltime class;
- `mpirun --bind-to core --map-by ppr:128:node:PE=1`;
- fresh case creation with no inherited processor, time, log or
  `postProcessing` directories;
- KaHIP partition identity when the independent variable is MPI/compiler;
- timing window and extraction method;
- rank-to-host/core/NUMA manifest, binary hash, `ldd`, module list and MCA
  selection evidence.

Screening metric: mean per-step `ExecutionTime` increment over steps 20-40,
with `ClockTime` increment retained as a cross-check. Correctness requires
normal completion, finite residuals, a newly created 40-row coefficient file,
and a Cd trajectory compatible with its contemporary control. An exact Cd
tolerance must be agreed before any candidate is called competition-valid.

Decision thresholds:

- at least 3% repeatable improvement: promote to 150-step validation;
- 1-3% improvement: repeat in a contemporary paired allocation before
  promotion;
- less than 1%: treat as noise unless three matched repeats establish it;
- any changed solver iteration counts, abnormal residuals, missing evidence,
  or material Cd divergence: correctness review before performance use.

## 3. Six-step execution plan

### Step 1 — Existing evidence reconstruction

Status: **complete**.

Completed outputs:

- raw KaHIP, Scotch and hierarchical mpiP reports archived locally;
- corrected profile Cd provenance: inherited 150-step files cannot validate
  the 40-step profile runs;
- time-weighted MPI call aggregation and per-rank distributions;
- verified rank-to-host mapping for the old mpiP jobs;
- decomposition topology joined to actual host assignment.

Result: KaHIP is the correct baseline. Allreduce is the highest-value MPI
screening target, while Waitall growth is the strongest decomposition-related
signal.

### Step 2 — Clean baseline repeatability and placement capture

Completed job: `25523028.pbs101`, script
`step2_clean_repeatability_v5.pbs`. It finished with `Exit_status=0`.

Experiment:

- two identical AOCC/Open MPI/KaHIP bound 40-step arms in one four-node
  allocation;
- fresh decomposition and fresh coefficient output for each arm;
- complete rank/core/socket/NUMA manifest;
- binary, MPI, libfabric, input and partition hashes.

Success criteria:

1. both arms reach `Time = 40` and finish normally;
2. each coefficient file is newly created during the allocation, contains
   exactly steps 1-40 and is not an inherited 150-row file;
3. solver iteration schedules and residual behavior agree;
4. steps-20-40 times differ by no more than 1% for a clean low-noise baseline;
5. all 512 ranks have a unique, valid core placement on four hosts.

Measured outcome:

- steps-20-40 ExecutionTime means: 2.827619048 and 2.829047619 s/step;
- pair difference: **0.0505%**;
- fresh Cd(40): 0.43471632678608485 in both arms, byte-identical files;
- solver residual, iteration and continuity records: identical;
- actual mapping: four hosts, 128 ranks and 128 unique physical cores per
  host, across NUMA nodes 0-7.

Interpretation:

- pair difference <=1%: proceed to Step 3;
- 1-3%: keep the faster/slower ordering provisional and require every later
  candidate to run beside a contemporary control;
- >3% or correctness mismatch: diagnose allocation, input, decomposition and
  solver evidence before tuning.

Step 2 passes and Step 3 may proceed after its local script diff is reviewed.

Failure handling:

- preflight failure: collect the named checkpoint, stdout/stderr, exit status
  and run-root evidence; change only the failing harness condition;
- decomposition/launcher failure: preserve all evidence and verify no
  scientific input was changed;
- solver/correctness failure: stop; do not reinterpret it as performance;
- prepare a unique v6 script and complete local diff. Project policy requires
  that exact diff to be shown before remote synchronization and submission.

### Step 3 — Clean AOCC/Open MPI/KaHIP profiling confirmation

The earlier mpiP work already profiled KaHIP, Scotch and hierarchical at four
nodes / 512 ranks and established the Allreduce/Waitall signal. Its solver
logs and mpiP reports remain valid, but its retained coefficient files were
inherited 150-step files. Step 3 repairs that final provenance gap on the
winning baseline before new tuning starts.

Run one fresh four-node allocation in this order:

1. unprofiled control A0;
2. mpiP `LD_PRELOAD` profile P0;
3. unprofiled control A1.

All three arms reuse one freshly generated KaHIP partition and the exact Step
2 binary, inputs, binding and rank placement. Each arm starts from restored
initial fields with no inherited `postProcessing`. Record the mpiP library
path, SHA256 and `ldd`, plus the `LD_PRELOAD` and `MPIP` settings actually
propagated to all ranks.

Required outputs:

- fresh 40-row coefficient file for every arm;
- steps-20-40 ExecutionTime and ClockTime increments;
- profiler overhead relative to the mean of the surrounding controls;
- complete mpiP call, call-site and per-rank report;
- time-weighted collective, wait/test, point-to-point and other MPI shares;
- Allreduce and Waitall absolute time and rank-tail distributions;
- the same affinity, input, binary and partition evidence as Step 2.

Success requires both unprofiled controls to remain within 1%, all three Cd
and solver trajectories to agree, mpiP to finalize normally, and a complete
report for 512 ranks. Profiled wall time is diagnostic only and never replaces
the unprofiled performance metric.

### Step 4 — Profiling-directed optimisation screen

This is a narrow screen, not a factorial sweep. Select the first branch from
the clean Step 3 profile: partition/Waitall if imbalance dominates, or a
verified collective setting if Allreduce remains the clearest addressable
cost.

#### 4A. KaHIP imbalance parameter

Hypothesis: a slightly larger cell imbalance budget may reduce interface
surface and Waitall enough to offset local work imbalance.

Run a paired 40-step comparison against the Step 2 KaHIP control. Change only
one KaHIP imbalance value. Select the candidate after confirming the exact
values accepted by the installed KaHIP/OpenFOAM interface; do not guess an
unsupported setting. Preserve `config=fast`, partition seed behavior,
toolchain, binding and inputs.

Metrics: steps-20-40 s/step; total and cross-node processor-interface faces;
maximum cells/mean; maximum interface faces/rank; Cd and residual checks.

Promotion: >=3% faster and correct, or a repeatable 1-3% gain accompanied by
a credible reduction in communication surface without a harmful work tail.

#### 4B. Controlled hierarchical `(32 16 1)` attribution

Hypothesis: the teammate's improved hierarchical layout reduces the severe
cross-node surface of `(8 8 8)`, but remains slower than KaHIP.

Use the exact Opt AOCC/Open MPI binary and binding from the KaHIP control.
Change only decomposition method/settings to hierarchical `(32 16 1)`.
Compare its decomposePar topology, timing, solver convergence and newly
generated Cd trajectory. This resolves the PgoUse/binding confound in job
`24608558`.

This run is primarily explanatory. Promote it only if it actually beats
KaHIP under the controlled pair and passes correctness checks.

#### 4C. Bound Scotch control, optional

Run only if Step 2 demonstrates low noise and the existing bound Scotch
evidence cannot be matched to the same effective inputs/binary/placement.
Its main value is a middle point between KaHIP and hierarchical for the
decomposition-to-MPI story and a bridge to future Gadi work.

#### 4D. Open MPI Allreduce screen

First use the Step 2/3 `ompi_info --param coll all --level 9` output to
identify the active collective component and exact supported Allreduce
controls. Never invent MCA parameter names or algorithm IDs.

Paired screen:

- control: default Open MPI selection;
- candidate: one verified Allreduce algorithm/selection setting;
- same KaHIP processor partition, binary, inputs, binding and 40-step window;
- paired in the same allocation where practical.

Hypothesis: because Allreduce is about 51% of KaHIP's measured mpiP time, a
better algorithm at 512 ranks may reduce per-iteration collective cost.

Metrics: steps-20-40 s/step, solver iteration identity, Cd trajectory,
selected MCA component/algorithm, and mpiP only if the profiling method has
already been shown not to invalidate the timing comparison. The unprofiled
wall time remains the decision metric.

Test at most two high-value supported candidates. Advance only a >=3%
repeatable win or a 1-3% win confirmed by a second paired run. If the default
is already best, close manual collective tuning.

Do not change PML, BTL, collective algorithm and binding together. Site Open
MPI already has UCX support; transport replacement is not the first screen.

Stop Step 4 after the selected high-information comparisons. Do not rerun
weighted Scotch, METIS, all old hierarchical layouts, PGO or `znver3`.

### Step 5 — Controlled compiler attribution

Purpose: determine whether the small retained AOCC/GCC difference is real
after decomposition, placement and MPI behavior are fixed.

Preferred controlled pair:

- AOCC 5.0 + Open MPI 5.0.10;
- GCC 15.2 + Open MPI 5.0.10;
- identical KaHIP processor partition copied from a verified control;
- identical MPI version, launcher, MCA policy, binding, resources and inputs;
- record exact flags, hashes and actual linked `libmpi`.

This is compiler attribution only if MPI and all MPI-dependent OpenFOAM
libraries are demonstrably equivalent. Otherwise label it a software-stack
comparison.

Existing results differ by only about 0.16%, so the expected outcome is no
material compiler winner. One clean paired screen is sufficient unless it
finds >=1%; do not launch a large compiler matrix.

### Step 6 — Final validation and scaling

Select candidates only from Steps 4-5 that passed correctness and promotion
gates.

Final 4-node scored validation:

- fresh 150-step run;
- contemporary baseline and candidate where allocation permits;
- exact binary/input/partition/placement evidence;
- full residual, continuity and Cd trajectory comparison;
- official average wall-clock s/step and steps-20-40/100-150 stability;
- at least two successful measurements for a sub-3% claim.

Final scaling table:

- 1 node / 128 ranks;
- 2 nodes / 256 ranks;
- 4 nodes / 512 ranks;
- same winning software stack and decomposition policy;
- report time/step, speedup `T1/TN`, parallel efficiency
  `speedup/N`, and correctness status.

Do not mix the older Gadi 416-rank result into this ASPIRE2A scaling curve.

## 4. Gadi preparation after additional allocation becomes available

Gadi should have a separate controlled baseline because its node architecture,
rank count and MPI stack differ from ASPIRE2A. Prepare two decomposition
paths rather than assuming the ASPIRE2A KaHIP ranking transfers:

1. Scotch baseline, because prior Gadi evidence suggests Scotch may be
   competitive or faster there.
2. KaHIP comparison using the same workload and a matched rank count.

First Gadi sequence:

- validate the existing 1-node baseline and input hashes;
- run matched 1-node KaHIP/Scotch screens;
- promote the winner to 2 nodes;
- run 4 nodes only after the 2-node result passes correctness and shows useful
  scaling;
- screen placement separately from decomposition;
- calculate speedup and efficiency from matched 1/2/4-node configurations.

No Gadi job should use ASPIRE2A performance as its numerical control. Cross
system results belong in a platform comparison, not the decomposition table.

## 5. Work that can continue unattended

While Step 2 is queued or running, local/read-only work may continue:

- monitor PBS state without resubmitting or cancelling;
- on completion, archive stdout/stderr and the complete evidence directory;
- parse A0/A1 timing, Cd, residual, hash and affinity evidence;
- update the Step 2 report and the six-step tracker locally;
- prepare Step 3 experiment specifications and local candidate diffs;
- keep all teammate PGO/METIS results as context rather than rerunning them.

If Step 2 fails, the unattended task may diagnose the exact checkpoint and
prepare a minimal local v6 patch. The project workflow still requires the
complete v6 diff to be shown before it can be synchronized or submitted.

## 6. Slide deliverables

The final evidence package should support four compact claims:

1. Baseline selection: AOCC/Open MPI/KaHIP is the fastest retained controlled
   ASPIRE2A configuration; PGO and METIS add no material gain.
2. Decomposition mechanism: KaHIP minimizes communication surface and MPI
   wait relative to hierarchical; identical solver iteration counts rule out
   extra iterations as the main timing explanation.
3. Profiling-guided tuning: Allreduce and Waitall dominate measured MPI time,
   motivating one controlled collective screen and a narrow KaHIP parameter
   screen.
4. Final performance: show only repeated, correctness-validated 150-step
   results with exact toolchain, rank placement and input provenance.

Before a result enters final slides, require: original solver log, PBS record,
decomposePar log, fresh coefficient file, input and binary hashes, actual
`libmpi`, rank/core/NUMA mapping, normal completion, and a clearly stated
measurement window.
