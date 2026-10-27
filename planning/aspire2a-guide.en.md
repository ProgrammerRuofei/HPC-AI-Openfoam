# ASPIRE2A: results, analysis and presentation navigation

English companion to [aspire2a-guide.md](aspire2a-guide.md), 2026-10-28.
[Project index](../PROJECT-INDEX.en.md) · Gadi has a [separate guide](gadi-guide.en.md).

## Start with results

| Material | Location | How to read it |
| --- | --- | --- |
| Basic staging, 1/2/4 nodes | [Package notes](../submission/2026-apac-hpc-ai/openfoam/README.txt), [scaling.csv](../submission/2026-apac-hpc-ai/openfoam/scaling/scaling.csv) | AOCC 5.0 + Open MPI 5.0.10, weighted Scotch; 13.3451 / 6.3961 / 2.9052 s/step, jobs `19730482` / `20030920` / `20072244`. One completed record per node count. Team/teammate evidence, not automatically the maintainer's execution. |
| Raw solver logs and Cd | [1 node](../submission/2026-apac-hpc-ai/openfoam/results/1node/simpleFoam.log), [2 nodes](../submission/2026-apac-hpc-ai/openfoam/results/2node/simpleFoam.log), [4 nodes](../submission/2026-apac-hpc-ai/openfoam/results/4node/simpleFoam.log); adjacent `coefficient.dat` | Verify plotted values against logs and Cd from the same job. |
| 4-node decomposition | [Storyline draft, section 5](2026-10-22-openfoam-evidence-storyline-draft.en.md#5-main-basic-decomposition-comparison) | Hierarchical, plain Scotch and weighted Scotch; small differences remain single-run observations. |
| Hierarchical XYZ | [Draft, section 4](2026-10-22-openfoam-evidence-storyline-draft.en.md#4-hierarchical-xyz-screening), [new 16/8/4 experiment](../experiments/aspire2a-hier1684-opt-4n/README.md) | Some drafts predate newer results; start verification at job-specific experiment evidence. |

## Analysis and limits

Local organization on 2026-10-28: this package preserves configurations and
measurements, not independent proof of final delivery or score. Latest status
comes from the 2026-10-26 handoff; no live scheduler inspection was performed.

| Question | Document |
| --- | --- |
| 4-node validity and comparability | [4n512 evidence QA](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md) |
| Compiler stacks and flags | [Compiler/codegen audit](analysis/aspire2a-compiler-codegen-audit-2026-09-17.md) |
| Early repeatability | [Step 2 repeatability](analysis/aspire2a-step2-repeatability-2026-09-24.md) |
| Submission evidence | [Submission readiness](analysis/aspire2a-submission-readiness-2026-10-07.md) |

## Profiling and later experiments

- [Three-decomposition PMPI experiment/evidence](../experiments/aspire2a-decomp-pmpi-3way/README.md),
  [early mpiP analysis](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md) and
  [clean v1](../results/aspire2a-step3-mpip-v1-25695102.md) have different
  purposes and measurement scopes. Do not pool their percentages.
- [Scotch A/B/C design](../experiments/aspire2a-scotch-abc/README.md) and
  [three-block review](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md):
  all three full blocks completed. Timing variation is large and B's Cd is
  below the reference band; weighted Scotch's fastest single result is not a
  repeatable gain. "Queued" in the
  [2026-10-22 handoff](../progress/2026-10-22-aspire2a-scotch-abc-preflight-submitted.md)
  is historical.
- [Executed weighted Scotch PGO x binding design](../experiments/aspire2a-scotch-pgo-binding/README.md),
  [two-block/eight-arm timing audit](../progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md):
  completed, but intermittent long wall-clock steps reverse comparison
  directions. No stable PGO/binding benefit is established. A median after
  removing slow steps cannot replace the full official mean.
- The [site inquiry draft](../progress/2026-10-26-aspire2a-scotch-pgo-binding-site-inquiry-draft.md)
  has not been sent. The physical cause of stalls is unconfirmed; additional
  diagnostics/experiments require separate authorization.

## Plans and storyline

- [Presentation evidence and follow-up plan](2026-10-22-openfoam-evidence-storyline-draft.en.md):
  narrative order, checked values and the 2026-10-25 A/B/C update. PGO and
  binding are already explored; new Basic work should first address Scotch
  timing repeatability and correctness.
- [Earlier slide-by-slide plan](2026-apac-hpc-ai-presentation-plan.en.md) and
  [2026-10-08 results](2026-10-08-openfoam-results-and-storyline.en.md) are
  historical design references.
- [Presentation assets/retention](../artifacts/README.md),
  [slides](https://docs.google.com/presentation/d/1jExT8S3abLLzKy8NGVq5GVzljCAmUZfq-c31OjsBnh0/edit).
  Some figures/drafts are local-only and not in these commits. Slides are
  derived presentation output; logs and linked records remain authoritative.

Storyline in one sentence: fixed workload and AOCC/Open MPI build → compare
hierarchical and Scotch → select a Basic candidate and show 1/2/4 nodes → use
PMPI to explain overhead → keep flags, PGO, KaHIP and binding as separate
explorations. This narrative does not establish a reproducible weighted gain
or prove final competition submission.
