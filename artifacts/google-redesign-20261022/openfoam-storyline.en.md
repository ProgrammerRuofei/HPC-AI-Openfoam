# OpenFOAM presentation storyline and follow-up plan: 2026-10-22 snapshot

English companion to [the preserved original](openfoam-storyline.md), prepared
2026-10-28. The original is a historical design source and remains byte-for-byte
unchanged. This translation preserves its then-pending results and proposed
tests; **do not treat them as current state**. Later `(16 8 4)`, A/B/C and
Scotch PGO/binding results exist in the [current guide](../../planning/aspire2a-guide.en.md).
Source-era "final/submitted" wording is not proof of final competition delivery.
The PMPI complement is labeled non-MPI here, not pure compute.

The source was updated 2026-10-22 for slide rearrangement. All times are solver
average wall-clock seconds per step, lower is better. The new stock Opt
`(16 8 4)` result was not available then, so cells were intentionally blank.

## One-sentence narrative

With fixed DrivAer, AOCC/Open MPI stock Opt and four-node conditions, screen
hierarchical XYZ, compare Basic hierarchical/plain/weighted Scotch, validate
the selected candidate with 150-step timing/Cd, then explain communication
with the same PMPI method. KaHIP, flags, PGO and binding are independent
branches, not retroactive causes of the Basic selection.

## 1. Workload and evaluation

- `occDrivAerStaticMesh`, approximately 65,334,765 cells, external flow with
  cooling inlets closed.
- OpenFOAM.com v2512 `simpleFoam`, ASPIRE2A EPYC 7713.
- Chain: `decomposePar` → `restore0Dir` → `renumberMesh` → `potentialFoam` →
  `applyBoundaryLayer` → `simpleFoam`; mesh, solver, `fvSchemes`, `fvSolution` fixed.
- 1/2/4 nodes: 40/80/150 steps and 128/256/512 ranks. Four nodes is the score point.
- `Average wall-clock time per time step` is the metric, not PBS walltime or
  total time divided by steps. Check fresh coefficient files and Cd trajectories.

Visual: case/solver at left, native nodes/ranks/steps table at right, metric below.

## 2. Strategy and controls

AOCC 5.0/Open MPI 5.0.10, v2512 stock Opt (`-O3`), 128 ranks/node,
`ppr:128:node`, no explicit binding. Four-node comparisons fix input and 150
steps while changing decomposition. AOCC continues an operational build with
complete Basic data, not a proven universally fastest compiler.

Visual: Stack feasibility → Hierarchical XYZ → Basic decomposition → Scored
candidate & PMPI diagnosis; Bonus/flags/PGO on side branches.

## 3. Compiler / MPI survey: context, not a decisive winner

Four-node KaHIP: AOCC/Open MPI **2.8759**, GCC/Open MPI **2.8805**,
ICX/Intel MPI **2.8981 s/step**. AOCC/GCC differ about **0.16%**, single
runs. ICX changes MPI too: whole-stack rather than compiler-only comparison.
Historical one/two-node representatives need matched build/decomposition
checks before any three-compiler scaling plot. Intel MPI is a chosen ICX
pairing, not a requirement. Claim only that AOCC/Open MPI provides consistency
for the Basic study, not universal compiler superiority.

## 4. Hierarchical XYZ screening

| XYZ | Build / condition | 4-node 150-step s/step | Cd(150) | Interpretation at the time |
| --- | --- | ---: | ---: | --- |
| `(8 8 8)` | Historical stock Opt; no at-run hash | 3.3555 | 0.298430 | Reference; Cd trajectory needs review |
| `(16 8 4)` | New stock Opt comparison, job `25906053` | Pending | Pending | Match `(32 16 1)`; do not insert old PgoUse values |
| `(32 16 1)` | Stock Opt, no profiler, job `25826705` | 3.0640 | 0.290022 | Faster verifiable candidate in this snapshot |

Historical PgoUse `(16 8 4)` is **3.1909**, Cd **0.273561**; PgoUse
`(32 16 1)` is **3.0079**. Neither belongs in the stock Opt ranking. The source
waits for new `(16 8 4)` before final XYZ ranking; leave it blank in that snapshot.

Visual: dot plot, hollow pending point, `(8 8 8)` provenance caveat. Do not
draw an unmeasured value. The later result is documented separately, not
silently inserted into this archival design source.

## 5. Main Basic decomposition comparison

Same AOCC/Open MPI stock Opt, 4 nodes/512 ranks, 150 steps, no explicit binding:

| Decomposition | s/step | Cd(150) | Job | Note |
| --- | ---: | ---: | --- | --- |
| Hierarchical `(32 16 1)` | 3.0640 | 0.290022 | `25826705` | New matched-build reference |
| Plain Scotch | 2.9124 | 0.284051 | `20064271` | Basic |
| Weighted Scotch | 2.9052 | 0.288551 | `20072244` | Selected staging config; `domains (4 8 16)`, `domainWeights (1 1 0.01)` |

Weighted time is about **5.18%** below hierarchical and **0.25%** below plain.
The latter is single-run and changes both domains and weights: not a stable
weight-only gain. Use "fastest observed Basic configuration in this snapshot."
The source planned to review the hierarchical reference after `(16 8 4)` completed.

Visual: dots/short bars, explicitly marked truncated 2.85-3.12 axis if used,
values plus a small Cd table; no KaHIP in Basic ranking.

## 6. Selected Basic runs and scaling

| Nodes | Ranks | Steps | Weighted s/step | Final Cd | Job |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 128 | 40 | 13.3451 | 0.434536 | `19730482` |
| 2 | 256 | 80 | 6.3961 | 0.340263 | `20030920` |
| 4 | 512 | 150 | 2.9052 | 0.288551 | `20072244` |

Different required steps and convergence stages mean a prescribed-point trend,
not strict equal-length strong scaling or proof of superlinearity. Score
candidate comes from the four-node unprofiled log. Visual: three points/bars
beside a native step-count table.

## 7. PMPI mechanism diagnosis with a common method

Job `25826770` completed all three 150-step arms with fresh Cd, same stock Opt,
four nodes and 512 ranks:

| Decomposition | Instrumented s/step | Mean rank MPI fraction | Non-MPI share |
| --- | ---: | ---: | ---: |
| Hierarchical `(32 16 1)` | 3.0650 | 27.29% | 72.71% |
| Plain Scotch | 2.9635 | 19.68% | 80.32% |
| Weighted Scotch | 2.9212 | 19.03% | 80.97% |

Higher hierarchical MPI fraction is consistent with communication/synchronization
differences. Diagnosis followed selection; do not invent profiling-first
chronology. Instrumented timing is not the formal score. Old mpiP/PMPI methods
and scopes differ; do not quantify them together.

Visual: MPI/non-MPI stacked bars. Cross-node cut estimates based on rank-block
mapping require an explicit assumption and are not measured network traffic.

## 8. Bonus and build explorations: independent branches

- KaHIP `fast/0.01`, stock Opt: **2.8759 s/step**, Cd **0.280044**, job
  `20030922`. Bonus, about **1.01%** below weighted in single runs, not Basic best.
- GCC `-march=znver3` vs stock, KaHIP: **2.8827 vs 2.8805**; no reliable gain.
- AOCC PGO + KaHIP + binding **2.86785** vs matched Opt + KaHIP + binding
  **2.86926**, about **0.05%**: not demonstrated PGO improvement. PgoGen
  training precedes PgoUse, separate from the stock Basic narrative.
- Binding: weighted **2.905→2.949** slower; KaHIP **2.876→2.869** faster.
  Single-run exploration, not a general binding conclusion.

Visual: separate exploration page, explicit Basic/Bonus, compact PGO/flag table
without amplified tiny differences.

## 9. Intended final claim and evidence limits in the source

Source-selected/staged Basic: AOCC 5.0/Open MPI 5.0.10 stock Opt, 4 x 128
ranks, weighted Scotch, 150 steps, no explicit binding; **2.9052 s/step**,
**Cd 0.288551**. "Fastest observed" does not prove stable superiority over
plain or optimal AOCC/PGO. Nor does it establish final upload or scoring.

At this date new `(16 8 4)` was pending, `(8 8 8)` lacked at-run hash and
needed Cd review; small plain/weighted, stack and PGO differences lacked
repeats. PMPI is consistent mechanism evidence, not causal proof. Later
completed tests must be read from the current guide rather than these old labels.

## 10. Proposed next step: make the 0.25% difference testable

1. Interleave plain/weighted repeats under the same build/input, four nodes,
   512 ranks, 150 steps and launcher; retain rank→node/core and variability.
2. Separate factors: A plain; B fixed `(4 8 16)` domains with uniform weights
   after checking dictionary semantics; C same domains/current `(1 1 0.01)`.
   Change one factor at a time.
3. Only if C exceeds noise, choose one/two topology-informed ratios, change
   only weights, and inspect total/cross-node cut assumptions, worst-rank
   interfaces, balance, full timing and Cd/residuals.
4. Upgrade "currently fastest" to "stable improvement" only with reproducible
   performance and acceptable correctness; otherwise retain near-equality.

These were **future proposals**, not completed or authorized jobs in this
historical source. Later A/B/C and PGO/binding completion did not establish
a stable weighted winner.

## Suggested slide order

Cover; Team; OpenFOAM; Workload/evaluation; Strategy/controls; Stack survey;
Hierarchical XYZ; Basic decomposition; Selected configuration; Scaling/Cd;
PMPI method; MPI shares; Bonus KaHIP; Architecture flag; PGO; Binding;
Results; Limits; Next step; Thanks.

One question per slide, short English phrases, native editable charts/tables.
The original Chinese explanations and evidence limitations are preserved above
in English; the original source and figures have not been regenerated.
