# Gadi: results, analysis and presentation navigation

English companion to [gadi-guide.md](gadi-guide.md), 2026-10-28.
[Project index](../PROJECT-INDEX.en.md) · ASPIRE2A has a [separate guide](aspire2a-guide.en.md).

## Start with results

| Material | Location | How to read it |
| --- | --- | --- |
| GCC 16.2 / Open MPI 5.0.10 / Scotch registry | [Run registry](../results/gadi-gcc162-ompi5010-scotch/run-registry.md) | Two completed 4-node runs: 1.991194389 and 1.988625920 s/step, mean 1.989910155; same-stack hierarchical `(16 13 2)` single result 2.058549642 s/step. |
| New-stack 1/2/4-node scaling | [Scaling note](../results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.md), [CSV](../results/gadi-gcc162-ompi5010-scotch/scaling-1n2n4n.csv) | 1N `182017873`: 8.373520290; 2N `182022356`: 4.137720656; 4N two-run mean: 1.989910155 s/step. 1N/2N each have one run. Efficiency above 100% does not prove superlinear scaling. |
| Old site-stack reference | [Official-labelled historical registry](../results/official-gadi-spr/run-registry.md) | GCC 8.5 / Open MPI 4.1.7 / hierarchical 1/2/4 nodes. A historical site reference, not a matched decomposition baseline for new-stack Scotch. |
| One-node binding comparison | [40-step comparison](../results/gadi-gcc162-ompi5010-scotch/binding-1n-40step.md) | Single-pair difference 0.324%; not validated at four nodes. |

The newer registry and scaling notes were copied here on 2026-10-23 from the
local `codex/gadi-gcc162-build` worktree, preserving job IDs and remote evidence
pointers. These are document copies: synchronize later conclusions if the
other worktree continues to change, to prevent divergent records.

On 2026-10-28, early [GCC16/Open MPI build files](../builds/build-scripts/gadi-gcc162-ompi5010/ARCHIVE-NOTES.md)
and a [legacy generic screening harness](../scripts/compiler-screening/README.md)
were archived unchanged. They are not a complete downstream reproduction
bundle or new execution authorization. [Workbook notes](../results/gadi-successful-4n-workbook-notes.md)
explain runtime-label limitations in the derived XLSX.

## Profiling and technical analysis

- [Full four-node PMPI rank/partition analysis](../results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md):
  distinguish call counts, steady-window timing and rank variation. PMPI time
  includes waiting and cannot be treated directly as network-transfer time.
- [PMPI peer-counter smoke](../results/gadi-gcc162-ompi5010-scotch/pmpi-peer-v2-smoke.md):
  method validation, not a scored 65M workload result.
- CPU/HPCToolkit sample findings and job/evidence pointers are in the
  [registry](../results/gadi-gcc162-ompi5010-scotch/run-registry.md#unscored-diagnostic-profile-attempt).
  Sampled CPU share is not solver walltime share.

## Plans and storyline

Suggested order: fixed case/metric → old site-stack reference → compare stacks
with hierarchical held fixed → compare hierarchical/Scotch on the new stack →
select GCC16/Scotch baseline → 1/2/4-node scaling → PMPI call volume/waiting
and CPU profile → one-node binding → ICX candidate and evidence limits.

- [ICX 2025.3.2 controlled-comparison plan](gadi-icx20253-controlled-comparison.md)
  includes a single 4-node ICX result and repeat status. A small single-run
  difference does not establish stable superiority.
- [Four-node PMPI results](../results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md),
  [presentation-retention boundaries](../artifacts/README.md),
  [slides](https://docs.google.com/presentation/d/1jExT8S3abLLzKy8NGVq5GVzljCAmUZfq-c31OjsBnh0/edit).
  Local tool dumps and deck iterations were not bulk-vendored into the evidence
  commits; later selected archival assets have their own notes.
- The [early experiment index](../results/experiment-index.md) records old
  site-stack and Phase 0 history. Its ASPIRE2A "blocked" section is obsolete,
  not a live project status.

Storyline in one sentence: observe the stack change with hierarchical held
fixed, then select Scotch within the newer stack; use the full GCC16/Scotch
scaling line as performance evidence and profiling to identify testable next
questions, without automatically attributing waiting to the network.
