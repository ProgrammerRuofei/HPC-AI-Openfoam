# OpenFOAM Performance-Engineering Methodology / OpenFOAM 性能工程方法论

**Purpose.** This is a durable engineering reference for the ISC26 OpenFOAM work. It records what is evidenced by last year's NTU work, what is currently known locally, and a controlled method to apply after the official 2026 input is released. It is **not** an approved optimisation implementation or a final experiment plan.

## Executive summary / 执行摘要

**[CONFIRMED 2026 FACT]** The current project targets OpenFOAM.com v2512 and a CPU OpenFOAM task based on `occDrivAerStaticMesh` (about 65M cells) using `simpleFoam`/SIMPLE. The present working convention is 40, 80, and 150 iterations for one, two, and four nodes respectively; the four-CPU-node configuration is the intended scored configuration. Official final input files and final rules have not yet been released, so this convention is not a substitute for the official specification.

**[HISTORICAL 2025/ISC26 REFERENCE]** Last year's evidence supports a sequence of baseline measurement, software-stack screening, compiler/architecture testing, decomposition and placement tuning, PGO, scaling, profiling, and scientific validation. Its reported solver-time improvement was from about 1904.578 s to 1553.055 s (about 18.46%). This is useful methodology, not an ASPIRE2A configuration recipe.

**[PROVISIONAL 2026 PLAN]** Establish a reproducible baseline first, screen one principal performance dimension at a time, profile only stable shortlisted candidates, and turn profiling evidence into targeted follow-up tests. Preserve raw logs and structured metrics so that charts and presentations cannot silently diverge from measurements.

简言之：去年证明了“先建立可复现实验基线，再做受控筛选，再用 profiling 解释差异”的工作流；它没有证明任何 Iris/Cascade Lake 的具体 rank 数、flags 或绑定语法可直接移植到 ASPIRE2A。

## 1. Status labels, scope, and evidence rules / 状态标签、范围与证据规则

The following labels are deliberately used throughout this document.

| Label | Meaning |
| --- | --- |
| **[CONFIRMED 2026 FACT]** | Current project fact or user-provided 2026 context. It is not automatically an official competition rule. |
| **[CURRENT EXPERIMENTAL EVIDENCE]** | Measured or observed current-work evidence. Platform scope is stated explicitly. |
| **[HISTORICAL 2025/ISC26 REFERENCE]** | Evidence from the previous NTU/Iris OpenFOAM work. It is informative, not prescriptive. |
| **[PROVISIONAL 2026 PLAN]** | A method proposed for future authorised experiments, conditional on final rules and platform discovery. |
| **[TBD AFTER OFFICIAL INPUT RELEASE]** | A decision, value, or constraint that must wait for the official input/rule release or ASPIRE2A discovery. |

This document permits no remote action, no build change, no scheduler-script change, and no experiment. It does not alter the workload, scientific configuration, OpenFOAM source, case files, compiler environment, MPI environment, or historical references.

### Sources and source-of-truth rule

This reference was reconstructed by read-only review of:

- `references/last-year/OpenFOAM-v2412-isc26/Compilation stuff.xlsx`;
- `references/last-year/OpenFOAM-v2412-isc26/` build/run scripts, archived timing output, VTune/APS/IPM outputs, and README material;
- `references/last-year/scc/isc26/OpenFOAM_SPUMA/Virtual/` README, build/run scripts, environment snapshot, and archived output;
- `references/last-year/slides/HPC-AI.ISC.26.Virtual.NTU.pptx`, especially slides 39–58; and
- current local project documentation, including `APPLICATION.md`, `planning/PLANS.md`, and `results/`.

Presentation slides are narrative evidence. Raw solver logs and validated structured records are the quantitative source of truth. When they differ, retain the conflict and investigate the measurement definition; do not choose the more favourable number.

## 2. How to use this document during the project / 项目中如何使用本文档

Before authorising or preparing each new experiment, record answers to these questions:

1. What hypothesis are we testing?
2. What **one** main variable changes?
3. What remains fixed?
4. What metric determines success?
5. What correctness check is required?
6. What evidence/log will be preserved?
7. What result would cause us to profile?
8. What result would determine the next experiment?

**[PROVISIONAL 2026 PLAN]** A result is actionable only when the build, launch, case, timing definition, correctness status, and raw log are known. “Faster” without that provenance is a lead to reproduce, not a result to adopt.

## 3. Current 2026 context and current evidence / 当前 2026 背景与证据

### 3.1 Workload boundary

| Item | Status | Current statement |
| --- | --- | --- |
| Application | **[CONFIRMED 2026 FACT]** | OpenFOAM.com, target release v2512. |
| Case | **[CONFIRMED 2026 FACT]** | `occDrivAerStaticMesh`, approximately 65M cells. |
| Solver and algorithm | **[CONFIRMED 2026 FACT]** | `simpleFoam` with SIMPLE. Scientific inputs remain fixed within the optimisation scope. |
| Primary performance measure | **[CONFIRMED 2026 FACT]** | Layer 1 solver `ClockTime` [s]; record it exactly for every valid run and compare controlled repeat medians once repeats exist. |
| Working iteration convention | **[CONFIRMED 2026 FACT]** | 1 node: 40; 2 nodes: 80; 4 nodes: 150 SIMPLE iterations. |
| Intended scored configuration | **[CONFIRMED 2026 FACT]** | Four CPU nodes. |
| Official case/rules | **[TBD AFTER OFFICIAL INPUT RELEASE]** | Final input files, exact iteration rule, scoring wording, rank/decomposition constraints, and correctness acceptance criteria. |

The local `APPLICATION.md` also records a Gadi four-node reference of 192 MPI ranks, 150 steps, and `ClockTime` 787 s. **[HISTORICAL PRE-RULE EVIDENCE]** This is a Gadi reference only; it is not an ASPIRE2A baseline and must not be compared directly with Iris times or transferred as an ASPIRE2A rank count. *(Updated 2026-09-09: 787 s is the uncontrolled 4-node run `177602742.gadi-pbs` on Cascade Lake. The current **scored** reference is the official Sapphire Rapids `normalsr` result, 2.139565 s per time step at 4 nodes / 416 ranks, job `178149002.gadi-pbs`; the controlled Cascade Lake reference is the Phase 0 median, 797.5 s. See [`results/experiment-index.md`](../results/experiment-index.md).)*

### 3.1.1 Two-layer performance evaluation

**Metric** means the defined quantity under measurement; a run produces a
**measurement** (value) of that metric. Summary statistics describe a set of
controlled repeated measurements and are not themselves metrics.

**Layer 1 — Official Competition Metric.** Solver `ClockTime` [s] is the
primary competition-oriented comparison metric: “did the configuration become
faster according to the scoring objective?” Record the exact value for every
valid run. After repeatability runs exist, use the controlled-run median for
baseline and optimized comparisons; never select the single fastest run.

**Layer 2 — Performance Characterization Metrics.** Record solver
`ExecutionTime` [s], mean and standard deviation of measured timestep wall
time [s/step], measured timestep count, PBS walltime, and peak memory usage.
When authorised profiling is available, add MPI communication time/fraction,
MPI wait time, load imbalance, CPU hotspots, and I/O contribution. These
metrics answer “why did the competition result change?” and do not replace
Layer 1.

For example, Phase 0 produced the measurements `Solver ClockTime = 802 s` and
`mean measured timestep wall time = 5.1367 s/step`.

### 3.2 Gadi profiling lessons

**[CURRENT EXPERIMENTAL EVIDENCE — Gadi only]** Current work includes baseline/scaling runs, four-node `simpleFoam` execution, Arm Performance Reports, and MAP diagnostic profiling. Reported Arm Performance Reports aggregates were approximately:

| Observation | Approximate value | Interpretation boundary |
| --- | ---: | --- |
| Compute | 82.4% | Gadi measurement; not an ASPIRE2A prediction. |
| MPI | 17.6% | Non-trivial communication is worth measuring, but not automatically the dominant improvement target. |
| Memory accesses within CPU time | 77.9% | Suggests memory-heavy behaviour on the measured Gadi run. |
| MPI collective calls within MPI time | 53.3% | Collectives deserve comparative diagnosis. |
| MPI point-to-point calls within MPI time | 46.7% | Point-to-point traffic also matters; do not reduce the story to collectives alone. |

The current local repository does not contain the underlying raw Gadi profiler outputs for these supplied aggregate values. Therefore they remain recorded evidence with the stated platform scope, rather than a numerical basis for an ASPIRE2A decision.

### 3.3 Reproducibility is a performance prerequisite

**[CURRENT EXPERIMENTAL EVIDENCE — ASPIRE2A workflow inspection]** Existing 512-rank scripts invoked:

```sh
restore0Dir -processor
```

without sourcing OpenFOAM `RunFunctions`. `restore0Dir` is a shell function made available through `RunFunctions`, not a standalone executable. The observed outcome was `command not found`, exit code 127, before `simpleFoam` launched.

This is not a performance result and this document does not fix the scripts. It demonstrates why an experiment record must include environment setup and a pre-run validation: an allocation can appear to have run while producing no solver measurement.

## 4. Historical 2025/ISC26 reconstruction / 去年工作流重建

### 4.1 Platform and baseline

**[HISTORICAL 2025/ISC26 REFERENCE]** The historical platform was Iris with two Intel Xeon Platinum 8280 processors per node: 56 physical cores, two NUMA domains, and Cascade Lake characteristics. The deck also describes AVX-512 frequency behaviour and InfiniBand. These facts bound the applicability of its flags, rank count, and binding syntax.

The archived spreadsheet and deck identify the historical baseline as follows:

| Baseline dimension | Historical value |
| --- | --- |
| OpenFOAM | v2412 |
| Compiler / MPI stack | ICC 2023.2 + HPC-X |
| Allocation | 4 nodes × 56 ranks/node = 224 MPI ranks; 1 thread/rank |
| Decomposition | `nHierarchical`, shown as `(8 7 4)` |
| Workload | 300 iterations |
| Recorded solver time | about 1904.578 s |

The spreadsheet labels its timing column “Total walltime”, while the deck describes its main comparison as “solver time” excluding decomposition/preprocessing. **Conflict to retain:** the timing terminology is not perfectly consistent. A future tracker must record solver wall time and preprocessing diagnostics in separate fields.

### 4.2 Chronological workflow actually evidenced

**[HISTORICAL 2025/ISC26 REFERENCE]** The material supports the following sequence. Some workstreams may have overlapped; this is the best evidence-based reconstruction, not a claim that every row was run serially.

| Phase | What was done | Evidence and reasoning |
| --- | --- | --- |
| 1. Baseline | ICC 2023.2 + HPC-X, `nHierarchical`, 4×56 ranks. | Spreadsheet baseline and deck slide 47 establish the reference. |
| 2. Software-stack screen | Compared ICC+HPC-X, GCC+Open MPI, and ICX+Open MPI. | Deck slides 41–42 and spreadsheet rows show ICC+HPC-X slower; GCC/Open MPI and ICX/Open MPI were close enough to tune further. |
| 3. Compiler/architecture tests | Tested optimisation level, Cascade Lake targeting, and later LTO/IPO/PGO variants. | Spreadsheet contains GCC `-O3 -march=cascadelake`, GCC `-flto`, ICX `-ipo`, ICX `-Ofast`, and ICX Cascade Lake variants. |
| 4. Decomposition screen | Moved from `nHierarchical` toward SCOTCH/topology-hinted domain decomposition. | Slides 43, 56–57, spreadsheet decomposition matrix, and SCC README. |
| 5. Placement/binding | Tested NUMA map/bind behavior for the short list. | Deck slide 46 and final SCC run script use `--map-by numa --bind-to numa`. |
| 6. PGO | Built/trained and used an ICX profile-guided build. | Final build script uses `-fprofile-use=...merged.profdata`; deck slide 45 says ICX 2026 was slightly better. |
| 7. Best-build validation | Ran the chosen stack and recorded final time. | SCC archived `slurm_job.err` reports `real 25m53.055s`; solver output shows 300 iterations. |
| 8. Scaling and profiling | Presented 1→2→4-node scaling and profiled the selected/representative run. | Slides 48–50; VTune APS report and IPM XML. |
| 9. Scientific validation | Checked aerodynamic/scientific results and visualisation. | Slides 51–55. |

### 4.3 Historical comparisons: what they prove and what they do not

**[HISTORICAL 2025/ISC26 REFERENCE]** The primary comparison was:

```text
ICC + HPC-X  vs  GCC + Open MPI  vs  ICX + Open MPI
```

It changed compiler and MPI implementation simultaneously. It is therefore principally a **software-stack comparison**, not a controlled compiler-only comparison. The historical conclusion that ICC+HPC-X was slower is valid for those tested stacks and settings; it does not isolate whether compiler, MPI, integration, or their interaction caused the difference.

**[PROVISIONAL 2026 PLAN]** Screen complete stacks early if that is operationally useful, then use a factorial or paired design where feasible: hold MPI fixed while comparing compilers, and hold compiler/build flags fixed while comparing MPI. One primary variable per phase makes causal interpretation much stronger.

### 4.4 Historical flags, decomposition, binding, and PGO

**[HISTORICAL 2025/ISC26 REFERENCE]** Representative historical measurements included GCC 15.2 with `-O3 -march=cascadelake` and ICX 2025.1.3 with `-O3 -xCASCADELAKE`; the spreadsheet also contains GCC LTO (`-flto`), ICX IPO (`-ipo`), and `-Ofast` rows. The final archived SCC build is ICX 2026.0.0 with custom Open MPI 5.0.10 and:

```text
-O3 -xCASCADELAKE -fprofile-use=<merged.profdata>
```

Its final run uses a SCOTCH/topology-hinted decomposition represented in the archived material as domains `(4 56)` and domain weights `(1 .01)`, plus Open MPI NUMA mapping/binding:

```text
--map-by numa --bind-to numa
```

The deck reports the final configuration as about 1553.055 s, versus 1904.578 s baseline, an improvement of approximately 18.46%. The SCC final job output independently records `real 25m53.055s` (1553.055 s), so this final timing is corroborated. Its exact contribution cannot be apportioned between compiler generation, MPI, flags, decomposition, binding, and PGO because the final configuration differs from the baseline in several dimensions.

### 4.5 Scaling shown historically

**[HISTORICAL 2025/ISC26 REFERENCE]** Slide 48 presents near-linear scaling for the selected work: 1→2 nodes at 2.04× and 1→4 nodes at 4.13×. These values describe the historical workload/platform and should be treated as a sanity-check pattern rather than a target for a different mesh, solver version, machine, or iteration convention.

### 4.6 Profiling evidence and bottleneck interpretation

**[HISTORICAL 2025/ISC26 REFERENCE]** The deck’s IPM narrative distinguishes MPI calls by count from MPI calls by time:

| View | Slide narrative | Engineering interpretation |
| --- | --- | --- |
| By count | `Isend`, `Irecv`, `Allreduce` are prominent. | High invocation count identifies communication shape, not necessarily elapsed-time impact. |
| By time | `Waitall`, `Allreduce`, `Isend` are highlighted. | Waiting and collective synchronization are likely more consequential than count alone. |

The raw reports support the broad mixed-bottleneck conclusion, but not every slide annotation exactly. A VTune APS HTML report for a 224-rank run reports roughly 20.3% MPI time, with `MPI_Allreduce` about 11.55% and `MPI_Waitall` about 7.35%; it also reports memory stalls around 56.6%, cache stalls around 13.32%, and packed floating-point/vector work around 15.65%. IPM rank-level data show substantial `Allreduce` and `Waitall` time, while `Isend` has very high call count and traffic.

**Conflict to retain:** slide 50 annotates 8.8% MPI and 91.2% computation. This does not fully agree with the approximately 20% MPI accounting in the VTune report or the rank-level IPM accounting. The difference may arise from a different run, aggregation, timing definition, or profiler accounting, but the archived material does not prove which. Do not cite 8.8% as a universal historical MPI fraction.

The actionable historical lesson is a **mixed bottleneck**: memory/cache behavior, collective synchronization (`Allreduce`), waiting (`Waitall`), and possible load imbalance/locality all warrant evidence-led testing. High call count is not equal to a performance bottleneck.

### 4.7 Which historical changes were evidence-led?

| Optimisation family | Historical motivation | Assessment |
| --- | --- | --- |
| SCOTCH/topology-aware decomposition | Deck discussion of hierarchy/communication; archived decomposition screen and improved chosen configuration. | Reasoned from topology and communication structure; should be re-tested, not copied. |
| NUMA map/bind | Deck slide 46 connects binding with memory bandwidth; VTune identifies memory/cache stalls. | Profiling-consistent and evidence-led, although the exact isolated gain is historical and platform-specific. |
| PGO | Deck says profile-guided build improved ICX 2026; final script contains PGO profile use. | Evidence-led build refinement after candidate selection, but historical training/run design must be rediscovered. |
| Compiler/architecture target | Cascade Lake-specific test matrix. | Empirical on Iris; target flag itself is not reusable on another microarchitecture. |
| LTO/IPO/`-Ofast` | Spreadsheet screening variants. | Useful candidates to evaluate only after correctness and supported toolchain are known; no blanket winner is established. |

## 5. Reusable performance-engineering principles / 可复用原则

| Principle | Why it matters |
| --- | --- |
| 1. Explicit compiler configuration | Compiler name alone is insufficient: version, target flags, optimisation level, and build mode affect code generation. |
| 2. Explicit MPI configuration | MPI implementation/version and transport/runtime settings can alter communication and rank behavior. |
| 3. Reproducible build | A build ID, command, source revision, and environment make an observed gain reproducible and auditable. |
| 4. Controlled launch | Nodes, ranks/node, threads, placement, binding, and launcher syntax must be captured to interpret timings. |
| 5. Fixed benchmark workload | Holding mesh, iterations, solver settings, and correctness criteria fixed prevents a faster but different computation. |
| 6. Clean logging and provenance | Logs must show that the solver actually launched and what it executed; this catches failures such as missing `RunFunctions`. |
| 7. One primary variable per experiment phase | It enables causal conclusions and prevents a large configuration change from becoming an unexplainable speedup. |
| 8. Scientific correctness before accepting performance | A shorter run with invalid convergence or aerodynamic output is not an optimisation. |
| 9. Repeat shortlisted measurements | Run-to-run variance can exceed a small claimed improvement; use median and range. |
| 10. Profile stable candidates, not every experiment | Profiling is expensive and most useful after screening identifies meaningful, repeatable differences. |

## 6. Proposed 2026 experiment journey / 建议的 2026 实验流程

All stages below are **[PROVISIONAL 2026 PLAN]**. They require official-input confirmation, platform discovery, and separate approval before any future experiment or environment change.

### Stage A — Platform discovery

Discover and record CPU model/microarchitecture, sockets, NUMA domains, physical cores, SMT status, memory architecture, available compiler modules, MPI implementations/versions, scheduler and launcher behavior, and supported placement/binding capabilities. None of these may be inferred from Iris.

### Stage B — Reproducible baseline

Use the correct official case and workload; fix the scientific configuration;
collect Layer 1 solver ClockTime and Layer 2 characterization metrics; validate
successful completion, convergence, and required science outputs; record
environment and launch provenance; and repeat the baseline when practical.
Pre-run validation must verify that the solver command and all required shell
functions are available before the timed run.

### Stage C — Coarse screening

Test the major dimensions before dozens of micro-flags: compiler, MPI, decomposition, basic architecture target, and placement/binding. Keep all non-tested dimensions fixed. A complete-stack screen may be useful first, but it must be labelled as such rather than as a compiler-only conclusion.

### Stage D — Shortlisting

Discard configurations that are clearly slower or scientifically invalid. Retain configurations with a meaningful measured difference, and retain near ties when run variation or an unresolved bottleneck makes a deeper comparison worthwhile.

### Stage E — Comparative profiling

Profile stable short-listed candidates to determine *why* they differ. Candidate measures include compute/MPI fraction; MPI count and time; `Allreduce`, `Waitall`, and point-to-point traffic; memory bandwidth; cache behavior; vectorisation; IPC; rank imbalance; NUMA locality; and I/O where relevant.

### Stage F — Profiling-guided optimisation

Use evidence to map bottlenecks to small targeted experiments:

| Evidence pattern | Targeted follow-up candidates |
| --- | --- |
| Memory-bound | NUMA placement, decomposition/locality, and compiler/architecture behavior. |
| Collective or wait dominated | Decomposition, placement, MPI implementation, permitted collective settings, and load-balance checks. |
| Low vectorisation or compute-bound hotspot | Compiler, architecture flags, PGO, and possibly LTO, subject to correctness and rules. |

### Stage G — Final confirmation

Repeat the winning configuration, report median and range, validate scientific correctness, preserve logs/provenance, optionally run final profiling once, and generate final tables/plots from the validated structured record.

## 7. Compact controlled experiment matrix / 紧凑受控实验矩阵

**[PROVISIONAL 2026 PLAN]** Candidate settings below are categories, not commands or approved configurations. Every entry remains **[TBD AFTER OFFICIAL INPUT RELEASE]** until platform capability and competition constraints are known.

| Phase / controlled variable | Candidate settings | Fixed variables | Metric | Profiling trigger | Decision rule |
| --- | --- | --- | --- | --- | --- |
| Baseline reproducibility | One documented valid build/launch | Official case, iteration rule, science settings, nodes | Solver wall time; completion/correctness | Failure, unexplained variance, or absent solver timing | Establish a repeatable valid reference before tuning. |
| Compiler | Supported compiler/version, one at a time | MPI, flags where portable, ranks, decomposition, binding | Median solver time and range | Meaningful or ambiguous difference after repeats | Keep faster valid candidates; do not attribute stack effects to compiler alone. |
| MPI | Supported MPI implementation/version | Compiler/build, ranks, decomposition, binding | Median solver time; MPI-related symptoms | Candidate differs materially or shows MPI-heavy behavior | Keep valid faster implementation; profile close or explanatory candidates. |
| Architecture/build target | Supported safe target flags; `-O3`; later LTO/PGO if allowed | Compiler/MPI, case, launch | Solver time plus correctness | Compute/vector/cache evidence or close timing | Reject invalid/unsupported flags; retain a repeatably faster build. |
| Decomposition | Officially permitted methods/parameters | Build, MPI, total ranks, node count, binding | Solver time; imbalance/communication | Wait/collective time, rank imbalance, or locality evidence | Select by repeatable valid solver time, not decomposition time alone. |
| Placement/binding | Launcher-supported policies | Build, MPI, ranks/node, decomposition | Solver time; NUMA/cache indicators | Memory/cache stalls or node/rank variation | Retain only explicitly recorded, repeatably beneficial policies. |
| PGO/LTO refinement | Supported PGO workflow, optional LTO | Best short-listed stack and launch | Solver time, build provenance, correctness | Stable bottleneck/candidate after coarse screening | Use only if improvement survives repeat/validation and policy permits. |
| Final validation | Winning configuration repeats | Everything fixed | Median/range, solver time, science results | Unexpected variance or validity concern | Report only a reproducible valid result with preserved evidence. |

## 8. Performance-engineering notebook / 实验记录簿设计

**[PROVISIONAL 2026 PLAN]** Do not create a spreadsheet yet. The eventual tracker should use one row per completed run (or a parent experiment plus repeat rows), with immutable IDs and links to raw artifacts.

### Required analysis columns

| Profiling | Bottleneck | Interpretation | Decision |
| --- | --- | --- | --- |
| ARM Performance Reports | Memory-heavy behaviour | Memory access dominates CPU work | Test NUMA/locality candidates. |
| MPI profiler | `Allreduce` / `Waitall` high | Synchronization or load imbalance may matter | Test decomposition/placement. |
| VTune/hardware counters | Cache stalls | Poor locality | Investigate binding, decomposition, and compiler behavior. |

These rows are examples of analytical reasoning, not a claim that every platform will show the same bottleneck.

### Recommended record schema

| Group | Fields |
| --- | --- |
| Identity and provenance | Experiment ID; date; platform; source-log path; git commit; build ID; operator; parent hypothesis. |
| Build | OpenFOAM version; compiler; compiler version; compiler flags; MPI; MPI version; LTO status; PGO status/profile provenance. |
| Launch | Nodes; ranks/node; total ranks; threads; launcher; placement; binding; relevant runtime environment. |
| Case | Mesh/cell count; SIMPLE iterations; decomposition method; decomposition parameters; input/case revision. |
| Performance | **Layer 1:** exact `simpleFoam` `ClockTime`. **Layer 2:** `ExecutionTime`; mean/stddev measured timestep wall time; measured timestep count; PBS walltime; peak memory; plus `decomposePar` and other preprocessing diagnostics. Record repeat number and calculate median, mean where useful, minimum, maximum, range, and standard deviation across controlled measurements. |
| Correctness | Completion status; Cd validation; convergence; scientific validity; exception/diagnostic notes. |
| Analysis | Profiling tool; profiling result; bottleneck; interpretation; decision; next experiment. |

Preprocessing metrics are diagnostic. Where the competition scores solver wall-clock time, `simpleFoam` solver wall-clock time is the primary metric and preprocessing must not be silently included or substituted.

## 9. Data flow and numerical source of truth / 数据流与数值唯一来源

**[PROVISIONAL 2026 PLAN]** Use one controlled path for each numerical result:

```text
raw logs
    ↓
parser
    ↓
structured results / metrics.csv
    ↓
experiment tracker
    ↓
analysis
    ↓
plots
    ↓
PowerPoint
```

The raw log records what occurred. The validated structured record captures extracted metrics with their definitions and provenance. The tracker, analysis, plots, and slides should consume that record; numerical values must not be independently typed into multiple spreadsheets, charts, and presentations. This prevents transcription errors and makes a changed parsing rule or timing definition traceable.

## 10. What not to copy from last year / 不应照搬去年的内容

| Historical setting | Why it cannot be copied blindly | What must be discovered this year |
| --- | --- | --- |
| 56 ranks/node | It matched Iris’s 56 physical Cascade Lake cores and its workload. | ASPIRE2A physical cores, SMT, memory bandwidth, and best ranks/node. |
| 224 total ranks | It was 4×56 on Iris, not a generic four-node rule. | Official node/rank constraints and ASPIRE2A scaling behavior. |
| Cascade Lake architecture flags | They target a different Intel microarchitecture and instruction/frequency trade-offs. | ASPIRE2A CPU model and each supported compiler’s correct target option. |
| `-xCASCADELAKE` / `-march=cascadelake` | These could be ineffective, invalid, or misleading elsewhere. | Valid portable/native target policy and correctness-tested flags. |
| Exact Open MPI NUMA syntax | Launcher version, scheduler integration, topology, and MPI implementation may differ. | ASPIRE2A launcher, binding syntax, and observed binding map. |
| HPC-X assumptions | HPC-X version, transport configuration, and fabric integration were historical stack details. | Supported MPI stacks and their permitted configuration. |
| Iris `topo`/`domainWeights` | The `(4 56)` and `(1 .01)` hints encode historical topology assumptions. | ASPIRE2A topology and an independently measured decomposition matrix. |
| 300-iteration workload | The current working convention is different and final rules are pending. | Official 2026 iteration/workload requirements. |
| Iris hardware hierarchy | Two sockets/two NUMA domains/InfiniBand informed the historical choices. | ASPIRE2A sockets, NUMA domains, cache/memory hierarchy, and network. |

## 11. Open questions / TBD after official input release

This is a living checklist. All entries are **[TBD AFTER OFFICIAL INPUT RELEASE]** unless and until a dated, preserved source resolves them.

- [ ] Final 2026 official input/case.
- [ ] Exact official iteration rules.
- [ ] Official scored-metric wording and timing boundaries.
- [ ] ASPIRE2A CPU microarchitecture.
- [ ] ASPIRE2A NUMA topology, physical-core count, SMT policy, and memory hierarchy.
- [ ] Supported compiler candidates and versions.
- [ ] Supported MPI candidates and versions.
- [ ] Scheduler launcher and placement/binding syntax and verification method.
- [ ] Allowed optimisation boundaries, including compiler flags, PGO, LTO, runtime tuning, and decomposition.
- [ ] Final decomposition constraints.
- [ ] Correctness acceptance criteria, convergence checks, and aerodynamic validation values.
- [ ] Profiling tools available on ASPIRE2A and their permitted collection modes.
- [ ] Practical number of repeated measurements within SU/time limits.
- [ ] Final rank counts, ranks/node, and thread policy for the scored run.

## 12. Review checklist and conclusion / 自检与结论

Self-review performed for this reference:

- Historical timings, tool versions, flags, rank counts, and profiler fractions are labelled historical and tied to the reviewed artifacts.
- Gadi profiling aggregates are explicitly scoped to Gadi; the ASPIRE2A shell-function failure is scoped to workflow inspection, not performance.
- The 8.8% slide MPI annotation is retained as a conflict with raw profiling rather than repeated as fact.
- Iris/Cascade Lake settings are listed as historical examples and explicitly excluded from automatic ASPIRE2A adoption.
- Future work is described as provisional and TBD pending official inputs, platform discovery, and future explicit approvals.
- No claim is made that a historical isolated compiler, MPI, LTO, PGO, decomposition, or binding effect will reproduce on ASPIRE2A.

The durable lesson is not a particular flag or rank map. It is a disciplined loop: establish a valid reproducible baseline, change one principal variable, measure with a declared metric, repeat credible candidates, profile differences, and preserve enough evidence that the final result can be reconstructed.
