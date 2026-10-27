# OpenFOAM retained results and presentation storyline (2026-10-08)

English companion to [the original](2026-10-08-openfoam-results-and-storyline.md),
prepared 2026-10-28. **Historical snapshot:** later staging, repeats, PMPI and
stall audits supersede some plans/status. Read the [current guide](aspire2a-guide.en.md).
"Final" below is source-era selection language, not proof of final delivery.

This document organizes evidence before proposing more experiments. Values
are archived single runs; `s/step` is the coded `Average wall-clock time per
time step`. Node points use prescribed 40/80/150 steps. PBS walltime is not
the score metric.

## 1. Existing results: which comparisons are usable

### 1.1 Formal Basic candidate: AOCC / Open MPI / Scotch

| Nodes | Ranks | Steps | s/step | Final-step Cd | PBS job |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 128 | 40 | 13.352080 | 0.435988 | `19730481` |
| 2 | 256 | 80 | 6.378504 | 0.327139 | `20047559` |
| 4 | 512 | 150 | 2.912440 | 0.284051 | `20064271` |

[Source: readiness review](analysis/aspire2a-submission-readiness-2026-10-07.md).
At the time all raw solver/coefficient files were checked on scratch, not yet
packaged. Two-node Cd is below the approximately 0.34 rule reference; Basic
rules did not state a hard percentage threshold. Disclose it.

### 1.2 Controlled four-node decomposition comparison

All are ASPIRE2A, 4 x 128 ranks, 150 steps, AOCC 5.0 + Open MPI 5.0.10, stock
`Opt`, no explicit binding. These form the clearest main narrative at this date.

| Decomposition | Category | s/step | Cd | Interpretation |
| --- | --- | ---: | ---: | --- |
| Hierarchical `(8 8 8)` | Basic | 3.355476 | ~0.2984 | Diagnostic baseline; Cd above approximately 0.28-0.29 reference |
| Scotch | Basic | 2.912440 | 0.284051 | Selected Basic configuration in this snapshot |
| Weighted Scotch | Basic | 2.905191 | ~0.2886 | Single run about 0.25% faster than plain; no stable-gain claim |
| KaHIP `fast/0.01` | Bonus | 2.875901 | 0.280044 | Single run about 1.25% faster than Scotch; not Basic |

Scotch's single observed time reduction against hierarchical is about 13.2%.
These are not repeats, and Cd trajectories differ: not strict numerical
equivalence. Bound KaHIP job `20092999`, 2.869257 s/step, has different placement
and is excluded from a pure decomposition comparison.
[Sources: QA](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md),
[presentation plan](2026-apac-hpc-ai-presentation-plan.en.md).

### 1.3 Other hierarchical results cannot share the same ranking

- At 4 nodes/512 ranks, `(8 8 8)` ICX/GCC/AOCC results are about
  3.311/3.352/3.355 s/step. Different compiler/MPI stacks cannot select XYZ.
- At 4 nodes/256 ranks, `(8 8 4)` AOCC/GCC results are about 6.943/7.067;
  different rank counts cannot enter the 512-rank comparison.
- Read-only checks on 2026-10-08 found `(16 8 4)` at **3.190876 s/step,
  Cd 0.273561**, and `(32 16 1)` at **3.007944, Cd 0.290022**, both
  4-node/512-rank completed 150-step runs. The latter is the fastest
  hierarchical single result found in that snapshot, not `(8 8 8)`. Earlier
  analysis identifies PgoUse build trees, unmatched to stock `Opt`/binding
  controls above. Do not attribute the entire 3.355→3.008 difference to XYZ
  or use it as the matched main-plot baseline. Source pointers: remote cases
  `occdrivaer-occdrivaer_4node_aocc_hier32161_v1` / `...hier1684_v1`, their
  `logFiles/50_simpleFoam*.log`, `system/include/caseDefinition` and
  `coefficient.dat`; [six-step plan](analysis/aspire2a-post-teammate-six-step-plan-2026-09-24.md).

### 1.4 Stack screening does not prove AOCC is the fastest compiler

| Four nodes / 512 ranks / KaHIP / no explicit binding | s/step | Limit |
| --- | ---: | --- |
| AOCC 5.0 + Open MPI 5.0.10 | 2.875901 | Single run, Bonus decomposition |
| GCC 15.2 + Open MPI 5.0.10 | 2.880512 | About 0.16% slower; insufficient separation for a reliable winner |
| ICX 2025.1.1 + Intel MPI | 2.898109 | MPI changes too: whole-stack comparison |

Under hierarchical `(8 8 8)`, ICX's single result is slightly faster than
AOCC. AOCC is not established optimal for every decomposition. Keeping
AOCC/Open MPI is defensible because it has complete Basic Scotch 1/2/4-node
results and competitive 4-node timing, not because compiler-only superiority
was demonstrated. GCC `-O3 -march=znver3` versus stock is about
2.882655 versus 2.880512 s/step, a 0.074% single-run difference: no support for
adopting the flag, not proof that every other flag is ineffective.
[Source: compiler/codegen audit](analysis/aspire2a-compiler-codegen-audit-2026-09-17.md).

### 1.5 Strength of existing profiling

Old KaHIP/Scotch/hierarchical mpiP diagnostics report MPI fractions around
26.64%/29.80%/37.08%, aligned with runtime/interface ordering. Inherited Cd
in old directories prevents clean correctness validation. The source reports
clean 40-step KaHIP A0/P0/A1 v2 completed with identical coefficient files,
0.335% difference between uninstrumented controls and estimated 10.114%
profiling overhead, but raw v2 reports had not been independently parsed
locally. Parsed v1 P0 attributes about 51%/29% of measured **MPI time** to
Allreduce/Waitall; v1 lacks A1. Rank-seconds are not solver walltime.
[Sources: readiness](analysis/aspire2a-submission-readiness-2026-10-07.md),
[v1 record](../results/aspire2a-step3-mpip-v1-25695102.md).

## 2. Presentation order: real evidence, not an invented chronology

1. **Case/platform:** v2512, approximately 65M cells, `simpleFoam`, EPYC 7713;
   four-node/150-step score and Cd sanity check. The case README describes
   **open-closed cooling**, with cooling inlets closed. Earlier simple
   "open-cooling" wording was inaccurate.
2. **Strategy:** fixed workload; investigate stacks, decomposition,
   ranks/placement, flags and MPI. Borrow the prior team's dimensions layout,
   not an unsupported claim of a complete matrix.
3. **Initial screening/baseline:** early ICX/hierarchical exploration followed
   by crossed stack/decomposition screening. Say "tested stacks," not
   "pure compiler screening selected AOCC."
4. **Decomposition:** plot same AOCC/Open MPI, 4 x 128, stock Opt, unbound
   hierarchical/Scotch/KaHIP; weighted Scotch can be backup. Color Basic/Bonus
   separately and disclose Cd limits.
5. **Basic scaling:** AOCC/Open MPI/Scotch 1/2/4 with Cd. Scotch is a valid
   rule-permitted 4-node candidate with a substantial observed difference from
   `(8 8 8)`, not proof that AOCC won a compiler-only study.
6. **Build follow-up:** stack representatives, negative `znver3`, PGO limits;
   this follows decomposition naturally as exploration becomes more focused.
7. **Communication diagnosis:** interface/MPI trends agree; distinguish old
   multi-configuration diagnostics, clean v2 and formal 150-step timing.
8. **Best Basic/Bonus and limits at the time:** Scotch 2.912440, same-condition
   KaHIP 2.875901; bound KaHIP 2.869257 separately labeled.

For a single setup slide use Case/Hardware/Score above Optimization dimensions /
fixed workload. Do not copy prior-team inlet/Bernoulli statements without
checking this year's inputs and evidence.

## 3. Follow-up work: organize before deciding on jobs

### Priorities needing no new jobs

1. Build a table of job/input/build/ranks/decomposition/binding/steps/s-per-step/
   Cd/Basic-or-Bonus/evidence; separate profiling from formal runs.
2. Package logs, coefficient files, dictionaries, full chain and builds. In this
   snapshot raw scratch files were not yet local and transfer method was TBD.
3. Parse clean v2 reports; check call shares/footer and record 40-step scope
   and approximately 10% overhead.
4. Produce four plots: Basic scaling, matched decomposition, stack
   representatives, and interfaces/MPI. Label conditions and single runs.

### Minimal flag experiment proposal, not a complete matrix

First inspect AOCC `OptZnver3` rules and failed-build cause. If a separate
platform can avoid overwriting stock Opt, pair stock/tuned on the same
AOCC/Open MPI, fixed **Scotch**, 4 x 128, binding and input, changing only
`-march=znver3`. Screen clean 40-step windows; only a gain beyond noise with
acceptable Cd/residuals merits paired 150-step validation. A 0.1%-level single
change is not a gain claim. `-Ofast`/`-ffast-math` are Bonus. Builds/scripts/
modules/jobs/remote work require concrete diff and explicit authorization.

### Minimal verifiable profiling loop

1. Parse existing v2 without SU; determine Allreduce/Waitall and rank behavior,
   not an assumed speedup ceiling from MPI fraction.
2. To test lower MPI cost from decomposition, use the same clean 40-step
   A0/P0/A1 protocol for Scotch and hierarchical, holding binary, ranks,
   binding, inputs and window fixed, with fresh Cd. Label KaHIP v2 Bonus.
3. If profiles identify a controllable placement/MPI parameter, change one
   variable, confirm uninstrumented separation beyond noise, then validate
   150 steps/Cd. Without A/B benefit, stop the story at explaining observed
   differences and remaining bottlenecks.

New experiments are not prerequisites to packaging existing Basic results.
`AGENTS.md` requires a concrete diff and authorization before any optimization,
build, job submission, or preparation/synchronization of remote execution files.
