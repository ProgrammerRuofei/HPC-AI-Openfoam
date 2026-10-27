# ASPIRE2A next-experiment plan

Date: 2026-09-23  
Status: **planning only; no remote change or PBS submission authorized**

## 1. Starting point

Current ASPIRE2A performance baseline:

- OpenFOAM v2512, AOCC 5.0, Open MPI 5.0.10;
- 4 nodes, 128 ranks/node, 512 MPI ranks;
- KaHIP `fast`, imbalance `0.01`;
- explicit core binding for the scored baseline;
- 150 SIMPLE steps: `2.869257 s/step` bound and `2.875901 s/step`
  without explicit binding.

Current clean decomposition signal from matched unbound runs:

| Method | 150-step time | Relative to KaHIP |
| --- | ---: | ---: |
| KaHIP | 2.875901 s/step | 1.000x |
| weighted Scotch | 2.905191 s/step | 1.010x |
| Scotch | 2.912440 s/step | 1.013x |
| hierarchical `(8 8 8)` | 3.355476 s/step | 1.167x |

Current mpiP aggregate measurements:

| Method | Aggregate MPI fraction |
| --- | ---: |
| KaHIP | 26.64% |
| Scotch | 29.80% |
| hierarchical `(8 8 8)` | 37.08% |

These values strongly motivate communication work, but they do not yet name
the dominant MPI operation or prove causation. The profile runs also contain a
Cd provenance inconsistency: their reported Cd at step 40 matches values seen
at step 150 in earlier runs. That must be resolved before the profiling runs
become slide evidence.

## 2. Experimental rules for every new run

Every controlled pair must hold fixed:

- mesh and all scientific inputs;
- `simpleFoam` source and binary, except in an explicitly labelled toolchain
  experiment;
- `fvSchemes`, `fvSolution`, initial fields and wall treatment;
- 4 nodes, 128 ranks/node and 512 ranks;
- launcher, placement and binding, except in a placement experiment;
- decomposition and processor numbering, except in a decomposition experiment;
- start state and measurement window;
- output and timing extraction procedure.

Each run must retain:

- input and mesh hashes;
- binary hash and `ldd` output, including resolved `libmpi`;
- modules, compiler, MPI and OpenFOAM environment;
- PBS allocation and exit status;
- actual rank → host → socket → NUMA → core manifest;
- `decomposePar` log and a partition fingerprint;
- raw `simpleFoam` log and every `coefficient.dat`;
- exact launcher arguments and effective Open MPI MCA parameters.

Screening uses a fresh case to step 40 and compares mean `ClockTime`
increments over steps 20–40. The function-object average is retained but is
not the sole metric. Final 4-node validation uses all 150 required steps.

## 3. Phase 0 — repair and finish the existing evidence, zero solver SU

### P0.1 Cd provenance audit

For each retained mpiP profile, establish:

1. whether the copied source case already contained `postProcessing` or later
   time directories;
2. `startFrom`, `startTime`, `endTime`, `latestTime` and write settings;
3. number and time range of rows in every retained `coefficient.dat`;
4. whether the paired control and profiled arms created fresh files;
5. why KaHIP profile Cd(40) is approximately the earlier Cd(150).

Acceptance: a documented file-level provenance chain. If provenance cannot be
reconstructed, retain timing as diagnostic evidence and rerun the clean
profile before using Cd or correctness claims.

### P0.2 Raw mpiP aggregation

Archive the three raw reports locally and calculate:

- time and call count by MPI function;
- collective, point-to-point, wait/test and communicator/setup totals;
- `MPI_Allreduce` and other global-reduction shares;
- message-size and call-site summaries where mpiP provides them;
- per-rank MPI time: min, median, p90, p95, p99 and max;
- slowest ranks and stability of the same outliers across methods.

### P0.3 Partition and rank correlation

For every rank, join:

- cells;
- processor-interface faces;
- neighbor count;
- node, socket, NUMA domain and core;
- mpiP MPI time and total application time.

Report scatterplots and rank correlations. Treat correlations as diagnostic
signals rather than proof of cause.

### P0 decision

- Allreduce dominant → test collective algorithms first.
- Wait/point-to-point dominant and correlated with interface surface → tune
  decomposition before MPI internals.
- A few rank outliers correlated with cells or interfaces → prioritize balance
  and partition-tail reduction.
- Outliers correlate with node/NUMA placement → promote placement testing.

## 4. Phase 1 — establish a clean repeatability envelope

Use AOCC/Open MPI/KaHIP with explicit core binding and the current baseline
partition.

| ID | Run | Purpose |
| --- | --- | --- |
| R0 | 40-step control A | Fresh baseline and complete evidence capture |
| R1 | 40-step control A repeat in the same allocation | Short-term run-to-run noise |
| R2 | 40-step control A on a second allocation | Node/allocation variation |

Record both full-run time and steps-20–40 time. Calculate coefficient of
variation and the maximum pairwise spread. The empirical repeat envelope, not
an assumed percentage, becomes the threshold for subsequent screens.

Correctness reference is the control-repeat envelope for:

- Cd at every timestep and at step 40;
- pressure and velocity initial/final residuals;
- continuity errors;
- fixed solver iteration counts.

## 5. Phase 2 — decomposition optimization around KaHIP

The existing result establishes the algorithm family winner but does not prove
that KaHIP `fast, imbalance 0.01` is optimal.

### P2.1 Decompose-only quality sweep

Generate fresh decompositions and measure quality before spending solver SU:

| ID | KaHIP configuration | Changed variable |
| --- | --- | --- |
| D0 | `fast`, imbalance `0.01` | Control |
| D1 | `eco`, imbalance `0.01` | KaHIP configuration only |
| D2 | `strong`, imbalance `0.01` | KaHIP configuration only |
| D3 | best of D0–D2, imbalance `0.005` | Imbalance tolerance only |
| D4 | best of D0–D2, imbalance `0.02` | Imbalance tolerance only |

For each partition calculate maximum cell imbalance, total unique interface
faces, maximum per-rank interface faces, neighbor-count tail and measured
cross-node interface surface using the actual rank-to-node map.

Do not discard a candidate on total cut alone. Advance the two candidates with
the best combined communication surface and tail balance.

### P2.2 Solver screen

Run an A/B/A sequence for each advanced candidate:

- A: current KaHIP fast/0.01 control;
- B: candidate partition;
- A: repeated control.

Use 40 steps and the steps-20–40 metric. A partition advances when it beats the
interpolated A controls by at least the repeatability threshold, passes the Cd
and residual gates, and does not create a worse per-rank tail.

Retain Scotch as a control point. Hierarchical needs only one clean repeat for
the profiling/correctness storyline; the existing 16.68% loss makes a broad
hierarchical tuple solver sweep low value.

## 6. Phase 3 — targeted Open MPI screening

Do not choose MCA values until P0.2 establishes the dominant call and
`ompi_info --all` confirms that the candidate component and parameter exist in
the deployed Open MPI 5.0.10 build.

### Branch M1: global reductions dominate

Screen at most two supported Allreduce algorithms against the default. Likely
families to inspect are recursive doubling and reduce-scatter/allgather, but
the actual Open MPI parameter names and numeric IDs must come from the installed
build. Change only the collective-selection setting.

### Branch M2: point-to-point/wait dominates

First record the active PML/MTL/BTL or UCX path. If both `ob1` and `ucx` are
present and usable, compare current/default against one explicit alternative.
Treat a PML change as a software transport screen and keep every other setting
fixed. Do not mix transport and collective tuning in the same first-round run.

### Branch M3: rank imbalance dominates

Stop MPI parameter work temporarily and return to P2. Reducing the slowest
rank's communication/work tail has more explanatory value than changing a
collective algorithm around an imbalanced partition.

### Paired screening format

For each MPI candidate use:

- A0: default MCA control, 40 steps;
- B: exactly one tuning change, 40 steps;
- A1: default MCA control, 40 steps.

Advance a candidate when the gain against the bracketing controls is at least
3%, or when a 1–3% gain repeats in a second independent allocation. Capture a
short mpiP profile of the winning candidate to verify that the intended call
category improved.

## 7. Phase 4 — toolchain work

### Current compiler evidence

Existing single results differ only slightly:

- AOCC 5.0 + Open MPI 5.0.10: `2.875901 s/step`;
- GCC 15.2 + Open MPI 5.0.10: `2.880512 s/step`, 0.16% slower;
- ICX 2025.1.3 + Intel MPI: `2.898109 s/step`, 0.77% slower.

These gaps are too small for a strong compiler ranking without repeats. After
the communication work, repeat AOCC versus GCC with the same Open MPI,
partition, placement and measurement window. This is the clean compiler-only
comparison.

### Cray MPICH status

Do not schedule a Cray MPICH performance run yet. Three minimal probes showed
that the compute node lacks the login-node libfabric path, so PALS launch,
`MPI_Init` and OpenFOAM compatibility remain unproved. The next step is
read-only discovery of a compute-node-visible supported libfabric/runtime path
or guidance from the site team. Only after a minimal MPI initialization probe
succeeds should an AOCC + Cray MPICH Pstream build be considered.

If a CCE + Cray MPICH stack is eventually tested, label it software-stack
screening because compiler and MPI change together. It cannot attribute a win
to either factor.

## 8. Phase 5 — placement and NUMA

Explicit binding changed the existing KaHIP result from `2.875901` to
`2.869257 s/step`, approximately 0.23%. Keep explicit core binding in the
baseline, but do not prioritize a broad placement matrix.

Promote placement experiments only if the per-rank analysis finds NUMA or
node-local outliers. Then compare exactly two policies with the same partition:

1. current `ppr:128:node:PE=1`, bound to core;
2. one topology-aware mapping supported by the installed Open MPI/hwloc.

Capture the actual affinity map in both arms. Launcher syntax is not evidence
that the intended placement occurred.

## 9. Phase 6 — final validation

For every candidate that survives screening:

1. run two independent 150-step 4-node candidate measurements;
2. bracket them with current-baseline measurements or alternate A/B order;
3. verify all input, binary, MPI, partition and mapping fingerprints;
4. compare full Cd trajectories, residuals and continuity against the control
   repeat envelope;
5. report mean, range and individual run values rather than only the best run;
6. rerun 1-node/40-step and 2-node/80-step points with the final champion
   configuration for the competition scaling plot.

A slide result requires raw logs, scheduler completion, hashes, mapping,
partition identity, correctness checks and repeatability. A 40-step screen or
profiled wall time is never a scored result.

## 10. Recommended execution order

1. P0.1–P0.3: repair Cd provenance and finish mpiP call/rank analysis.
2. R0–R2: establish clean baseline repeatability and fresh mapping evidence.
3. D0–D4 decompose-only sweep; run solver A/B/A only for the two best KaHIP
   candidates.
4. Select one MPI branch from the measured mpiP call mix and screen no more
   than two MPI settings initially.
5. Profile the winning partition/MPI candidate once to confirm mechanism.
6. Repeat AOCC versus GCC only after communication choices are frozen.
7. Run 150-step 4-node validation and final 1/2/4-node scaling for the winner.

The first compute experiment should be **R0/R1: two clean, identical bound
KaHIP 40-step controls in one 4-node allocation**, with fresh Cd files, raw
mpiP disabled, complete fingerprints and actual affinity capture. This repairs
the correctness provenance and establishes the noise floor needed to interpret
every later percentage.
