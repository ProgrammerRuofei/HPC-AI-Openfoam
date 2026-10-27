# ASPIRE2A OpenFOAM Basic: evidence, gaps and follow-up work (2026-10-08)

English companion to [the original](2026-10-08-basic-readiness-and-extra-work.md).
Translation prepared 2026-10-28. **Historical snapshot:** later staging,
decomposition, PGO/binding and stall investigations supersede some pending
items. Use the [current guide](aspire2a-guide.en.md) before acting. This plan
does not authorize jobs; "formal" and "submission" below describe the source's
candidate/packaging context, not verified delivery or scoring.

The score metric is `simpleFoam`'s `Average wall-clock time per time step`.
Four nodes/150 steps is the scoring point; one/two nodes run 40/80 steps for
scaling. Basic uses official v2512, unchanged scientific workload and
`hierarchical` or `scotch`; KaHIP is Bonus.
[Source rule reference, F1-F2](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md).

## 1. Available Basic candidate at the time

AOCC 5.0 + Open MPI 5.0.10, 128 ranks/node, Scotch, stock `Opt`. Raw logs/Cd
had been checked remotely but not yet packaged in this dated snapshot.

| Nodes | Steps | PBS job | s/step | Final Cd | Status in source |
| ---: | ---: | --- | ---: | ---: | --- |
| 1 | 40 | `19730481` | 13.352080 | 0.435988 | Raw run checked; single measurement |
| 2 | 80 | `20047559` | 6.378504 | 0.327139 | Raw run checked; Cd below the approximately 0.34 rule reference, needing explanation/review |
| 4 | 150 | `20064271` | 2.912440 | 0.284051 | Raw run checked; single formal Basic candidate |

For the checked same-stack, 4-node/512-rank, 150-step, no-explicit-binding
comparison, hierarchical `(8 8 8)` was 3.355476 s/step with Cd about 0.2984;
Scotch was 2.912440, about 13.2% lower observed time. The hierarchical Cd was
outside the approximately 0.28-0.29 reference and only one run existed: an
exploratory comparison, not a strictly valid baseline. Other hierarchical XYZ
build/binding conditions were not fully matched and cannot isolate decomposition
effects. KaHIP 2.875901 (unbound) and 2.869257 (bound) are Bonus, not Basic.

## 2. Organize first: no new jobs needed

| Priority | Work | Deliverable / acceptance check |
| --- | --- | --- |
| P0 | Lock evidence for the three Basic runs | Preserve raw solver logs, coefficient files, PBS stdout/stderr and all preparation logs; align steps, metric, Cd and final status. Review the two-node Cd trajectory/dictionaries especially. |
| P0 | Check Basic rules/provenance | Preserve actual `caseDefinition`, `decomposeParDict`, `controlDict`; semantic diff against official case. Check `fvSchemes`, `fvSolution`, function objects, full Allrun and `-ybl`; record v2512 source, `WM_*`, compiler/MPI, stock `-O3` and any `wmake/rules/*` patch. Disclose missing per-run historical binary hashes. |
| P0 | Build text package and summary | One row per formal run: nodes/ranks/steps/decomposition/binding/build/job/s-per-step/Cd/evidence/Basic-or-Bonus. Separate Basic/Bonus directories. Package text, figures and presentation, not mesh/processor trees/binaries. |
| P0 | Complete Basic presentation | Workload/rules, Basic 1/2/4 scaling, matched 4-node decomposition, Cd, selected configuration and limits. Label each single run; PBS walltime is not the score. |
| P1 | Parse existing profiling | Old Scotch/KaHIP/hierarchical mpiP is directional evidence, but its 40-step Cd was inherited from old 150-step runs and does not prove profile correctness. The source says clean KaHIP A0/P0/A1 v2 completed; parse reports/controls locally first. |

The source lists 4-node log/Cd, 1/2/4 scaling, dictionaries, build/full-chain
description and slides as submission material. MPI profiling is strongly
recommended, not a mandatory score. At this date the main risk was unreadable,
unpackaged evidence, not a missing new solver time.

## 3. Follow-up runs ranked by incremental value

### E1. Uninstrumented four-node Scotch repeat, before new flags

- Question: 2.912440 s/step is a single run. Unbound Scotch/KaHIP differ by
  only about 1.27%; noise must be measured.
- Design: preserve AOCC/Open MPI, Scotch, 512 ranks, binding, inputs and full
  Allrun; add at least one independent 150-step repeat. Preserve fresh Cd,
  raw metric, resource/job provenance. Three total samples would be stronger
  if quota/time permit.
- Value: strengthen score credibility; do not delay packaging a compliant
  existing result solely while waiting for repeats.

### E2. Clean Scotch A0/P0/A1 mpiP, to connect the narrative

- Question: old Scotch Cd was inherited; the clean v2 profile was KaHIP only.
  A verifiable Basic mechanism view was missing at this date.
- Design: 4 nodes/512 ranks, same AOCC/Open MPI binary and fixed Scotch
  partition. Within one allocation run uninstrumented A0, mpiP P0 and
  uninstrumented A1, each 40 steps. Start each from a clean case, generate new
  coefficient files, retain reports, rank mapping, binding and identical
  steps-20-40 windows. Match binding/other controls for direct KaHIP v2
  comparisons; otherwise discuss Scotch alone.
- Value: explain Allreduce/Waitall, rank distribution and instrumentation
  overhead. A 40-step diagnostic does not replace a 150-step unprofiled score.

### E3. Controlled Basic A/B only with a clear hypothesis

Choose one variable, e.g. Scotch rank/NUMA placement or an IEEE-safe AOCC
`znver3` build. Keep everything else equal and do not overwrite the existing
Basic build. Screen with short windows and uninstrumented controls. Only a
gain beyond noise with acceptable Cd/numerical behavior merits 150-step
validation. Avoid a last-minute flag x MPI x decomposition matrix.
`-Ofast`/`-ffast-math` belong to Bonus in this plan.

### E4. Optional matched hierarchical Basic comparison

To say Scotch beats the best hierarchical candidate, compare XYZ candidates
under identical build, binding, ranks and inputs, check Cd, then repeat against
Scotch. Existing `(32 16 1)` results use another build tree and do not establish
this claim. Before a deadline this ranks below P0 and E1/E2.

## 4. Decision and presentation boundaries

- Supported **at that date**: Scotch is a checked 4-node Basic candidate at
  2.912440 s/step; 1/2/4 results exist; one matched `(8 8 8)` comparison shows
  a sizable observed difference; old mpiP trends align with partition surfaces.
- Unsupported: a global optimum over all Basic parameters; AOCC as a stable
  fastest compiler in isolation; profiling preceding and causing Scotch
  selection; bound KaHIP as a pure decomposition gain; clean correctness
  validation for the old Scotch profile.
- If only one action is possible: complete P0 packaging. If a job window is
  available, choose E1 for score credibility or E2 for explanatory evidence,
  according to the actual evidence gap.

Any new job, build or remote change requires a concrete script/config diff
and the authorization in `AGENTS.md`. This document prepared/executed no
remote script.

## 5. Evidence index

- [Submission readiness](analysis/aspire2a-submission-readiness-2026-10-07.md):
  Basic logs/Cd, build and package gaps.
- [4n512 evidence QA](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md):
  decomposition comparison and limits.
- [Step 1 mpiP evidence](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md):
  old profiles and inherited Cd.
- [Results/storyline](2026-10-08-openfoam-results-and-storyline.en.md):
  overall narrative and other follow-ups.
