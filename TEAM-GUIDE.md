# Teammate guide: OpenFOAM evidence and repository layout

Updated: 2026-10-28, Asia/Singapore. This guide describes the locally retained
record, not a live cluster check, a final submission receipt, or a new run plan.

## Read these first

1. [English project index](PROJECT-INDEX.en.md): choose **ASPIRE2A or Gadi**
   before comparing results.
2. [APPLICATION.md](APPLICATION.md): fixed workload, rules and scientific
   boundaries. Its "open-cooling" shorthand is historical. The later
   [case-README clarification](planning/2026-10-08-openfoam-results-and-storyline.en.md#2-presentation-order-real-evidence-not-an-invented-chronology)
   records closed cooling inlets; use that clarification, not the old label,
   when describing the supplied case.
3. [ASPIRE2A guide](planning/aspire2a-guide.en.md) or
   [Gadi guide](planning/gadi-guide.en.md): measurements, provenance and caveats.
4. [Workflow](workflow/README.md) and [AGENTS.md](AGENTS.md) before preparing
   or executing anything. A committed script is not authorization to run it.

## What the current evidence says

| Area | Retained evidence and interpretation | Start here |
| --- | --- | --- |
| ASPIRE2A Basic | AOCC/Open MPI/weighted Scotch 1/2/4-node logs, Cd and inputs are staged. These are team/teammate measurements, not automatically the repository maintainer's runs. Staging does not establish final delivery or scoring. | [Package README](submission/2026-apac-hpc-ai/openfoam/README.txt), [scaling CSV](submission/2026-apac-hpc-ai/openfoam/scaling/scaling.csv) |
| ASPIRE2A decomposition | Hierarchical, plain Scotch and weighted Scotch have timed and profiled comparisons. Later three-block A/B/C tests do **not** establish a reproducible plain-versus-weighted winner; timing varies and the uniform-weight arm needs scientific review. | [Completed blocks](progress/2026-10-25-aspire2a-scotch-abc-evidence.md), [zero-SU audit](progress/2026-10-25-aspire2a-scotch-abc-zero-su-audit.md) |
| ASPIRE2A PGO / binding | Both were tested. The later matched Scotch study completed, but intermittent long wall-clock steps reverse pairwise rankings. Do not promote a minimum or filtered median to the official result. | [Timing-stall audit](progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md) |
| ASPIRE2A profiling | Older mpiP reports support communication analysis but their inherited Cd is not fresh correctness evidence. Clean controls and the later same-method three-way PMPI comparison have separate provenance. | [Step 1 mpiP analysis](planning/analysis/aspire2a-step1-mpip-evidence-2026-09-23.md), [three-way PMPI](experiments/aspire2a-decomp-pmpi-3way/README.md) |
| Gadi | The newer GCC 16.2/Open MPI 5.0.10/Scotch line has 1/2/4-node records and a 4-node repeat. Old site-module hierarchical results are a different reference, not the same controlled baseline. | [Run registry](results/gadi-gcc162-ompi5010-scotch/run-registry.md), [scaling](results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.md) |
| Open questions | Stall root cause, some scientific trajectories and final delivery/score remain unresolved. The site inquiry is a draft, **not sent**. No extra jobs were submitted during repository organization. | [Unsent inquiry](progress/2026-10-26-aspire2a-scotch-pgo-binding-site-inquiry-draft.md) |

## How profiling connects to the earlier work

The earlier benchmarks identify promising configurations. Partition evidence
describes structural differences; mpiP/PMPI examines where MPI time and calls
accumulate; CPU profiling examines sampled on-CPU work. These are complementary
views, not interchangeable measurements. The later PMPI comparison diagnoses
already-selected configurations; do not retell it as profiling that originally
caused the selection.

MPI time includes synchronization and waiting, not just network transfer.
Call-type percentages may use **MPI time**, not application walltime, as their
denominator. Non-MPI time is not automatically pure compute. CPU sample shares
are not walltime shares. Cut-face counts are not transferred bytes. A consistent
ordering is supporting evidence, not causal proof of a network reduction.

The defensible next question is why matched runs occasionally stall and whether
plain/weighted Scotch or PGO/binding differences survive controlled repetition.
This is a hypothesis, not approval for new jobs or configuration changes.

## Where things belong

| Directory | Purpose | Important boundary |
| --- | --- | --- |
| `workflow/` | Authorization, Git, environment and job-operation rules | Read numbered files in order before workflow actions. |
| `builds/`, `experiments/`, `scripts/` | Build/run infrastructure and analysis tools | Some are historical snapshots; retain paths and read adjacent notes before use. |
| `results/` | Run registries, extracted metrics and outcomes | Follow job-specific provenance back to raw evidence. |
| `planning/analysis/`, `planning/evidence/` | Interpretation, extracted tables and supporting evidence | Old plans and profiles can be superseded without being deleted. |
| `progress/` | Dated handoffs and corrections | "Pending" means pending when written, not necessarily today. |
| `submission/2026-apac-hpc-ai/` | Archived team submission staging | Not proof of upload, acceptance, final selected platform or outcome. |
| `artifacts/` | Historical figures, design sources and selected deck snapshots | Derived presentation material, not the quantitative source of truth. |
| `references/` | Reference boundaries and provenance | Nested teammate/prior-year checkouts are local-only, not vendored. |

## What a fresh clone does and does not contain

The repository cleanup preserved all original evidence paths and bytes in the
reviewed 119-file cohort. It committed 53 originals; 60 generated/QA exports and
six draft decks remain ignored **on the original machine**, not on GitHub. The
[119-file manifest](planning/repository-audit/2026-10-28-untracked-files.csv)
records paths, sizes, hashes and decisions; the
[English classification](planning/2026-10-28-untracked-file-classification.en.md)
explains why. Nothing in that cohort was deleted.

Four large raw mpiP reports also remain local-only, with committed
[SHA256 fingerprints](planning/evidence/RAW-REPORTS.sha256). A fresh clone cannot
rerun their parsers until the matching reports are restored through an
authorized channel. Parser main functions can overwrite derived tables; do not
run them against historical evidence casually. Large meshes, processor trees,
private runtime installations, external worktrees, reference checkouts and
credentials are not a self-contained clone-and-run bundle.

## Rules for reusing a number or making a slide

- Quote the solver's `Average wall-clock time per time step` and identify the
  job, platform, stack, ranks, steps, decomposition, binding and profiler state.
- Match timing with the **same run's fresh** coefficient file and trajectory.
  Technical completion does not by itself establish scientific equivalence.
- For normalized scaling use `S(N)=T(1)/T(N)` and `E(N)=S(N)/N`. The required
  40/80/150-step runs have unequal iteration counts; efficiency above 100% is
  not proof of strict superlinear strong scaling. Do not claim weak scaling.
- Keep ASPIRE2A and Gadi curves separate. Do not rank platforms by absolute
  times across different hardware/compiler/MPI configurations.
- Label Basic, Bonus, unprofiled score candidates and profiled diagnostics
  separately. Keep single-run observations distinct from repeatable gains.
- Attribute execution, implementation and analysis separately. Imported
  teammate evidence remains team evidence even after local analysis; Git
  authorship alone does not identify the cluster operator. AI co-authorship
  markers do not establish independent hand-written implementation.
- Historical decks, generators and storylines contain stronger or outdated
  wording. Use current run records and later corrections before copying them.

## English access and safe collaboration

[LANGUAGE-COVERAGE.md](LANGUAGE-COVERAGE.md) maps every substantive tracked
Chinese document to an English companion. Historical translations preserve the
original snapshot and add status warnings; they are not new verified results.
The small bilingual headings and one original filename are explained there.

Use ordinary reviewed Git commits for documentation and evidence changes. Do
not commit credentials or password-file contents. No teammate needs another
person's authentication files to read this archive. Remote commands, transfers,
builds and PBS actions remain subject to the documented authorization rules.
This handoff changes no compiler/MPI setting or scientific input, and sends no
message or support request on anyone's behalf.
