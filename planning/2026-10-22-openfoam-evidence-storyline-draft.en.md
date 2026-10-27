# OpenFOAM presentation storyline and follow-up plan

English companion to [the original draft](2026-10-22-openfoam-evidence-storyline-draft.md).
Original updated 2026-10-25; translation prepared 2026-10-28.

**Historical-status warning:** this is the source's presentation-planning
snapshot, not a final submission certificate. Its "final/submitted" language
is preserved as historical wording; delivery and score need independent
evidence. The later [2026-10-26 PGO/binding stall audit](../progress/2026-10-26-aspire2a-scotch-pgo-binding-stall-audit.md)
supersedes proposals that treat those matched Scotch tests as not yet done.
"Compute share" in the source PMPI table means **non-MPI**, not pure compute.
For current navigation use the [ASPIRE2A guide](aspire2a-guide.en.md).

This draft rearranges the presentation. All solver times are the coded average
wall-clock seconds per step, lower is better. New stock Opt `(16 8 4)` evidence
was checked; all three Scotch A/B/C blocks completed, but timing variation and
B's Cd limit conclusions. [Job review](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md).

## One-sentence narrative

With fixed DrivAer workload, AOCC/Open MPI stock Opt and four-node conditions,
screen hierarchical XYZ, compare Basic hierarchical/plain/weighted Scotch,
use 150-step timing and Cd to document the selected candidate, then diagnose
communication with one consistent PMPI method. KaHIP, flags, PGO and binding
are separate explorations, not retroactive causes of the Basic selection.

## 1. Workload and evaluation

- `occDrivAerStaticMesh`, approximately 65,334,765 cells, external automotive
  flow with cooling inlets closed.
- OpenFOAM.com v2512 `simpleFoam`; ASPIRE2A AMD EPYC 7713.
- Full chain: `decomposePar` → `restore0Dir` → `renumberMesh` →
  `potentialFoam` → `applyBoundaryLayer` → `simpleFoam`. Mesh, solver source,
  `fvSchemes` and `fvSolution` stay unchanged.
- One node: 40 steps / 128 ranks; two: 80 / 256; four: 150 / 512. The
  four-node point is the scoring target.
- Use `Average wall-clock time per time step`, not PBS walltime or total time
  divided by steps. Correctness requires fresh `coefficient.dat`, Cd and trajectory.

Suggested visual: case/solver on the left, native nodes/ranks/steps table on the
right, score-metric line below.

## 2. Strategy and controls

AOCC 5.0 + Open MPI 5.0.10, v2512 stock `Opt` (`-O3`), 128 ranks/node,
`ppr:128:node`, no explicit binding. Four-node decomposition comparisons keep
inputs and 150 steps fixed. AOCC continues a working build with complete Basic
data; screening did not prove it fastest at every node count.

Visual: Stack feasibility → Hierarchical XYZ → Basic decomposition → Scored
candidate & PMPI diagnosis. Show Bonus/flags/PGO as branches.

## 3. Compiler / MPI survey: context, not a decisive winner

Four-node KaHIP representatives: AOCC/Open MPI 2.8759, GCC/Open MPI 2.8805,
ICX/Intel MPI 2.8981 s/step. AOCC/GCC differ about 0.16%, both single runs;
ICX changes MPI too, so this is whole-stack, not compiler-only. Historical
one/two-node representatives need individual build/decomposition checks; do
not connect unmatched settings into a controlled three-compiler scaling plot.
Intel MPI was the chosen ICX pairing, not a requirement of ICX.

Claim: insufficient evidence for a universally fastest compiler; AOCC/Open MPI
is a consistent platform for Basic decomposition experiments.

## 4. Hierarchical XYZ screening

| XYZ | Build / conditions | 4-node 150-step s/step | Cd(150) | Interpretation |
| --- | --- | ---: | ---: | --- |
| `(8 8 8)` | Historical stock Opt; at-run binary hash absent | 3.3555 | 0.298430 | Historical reference; Cd trajectory needs review |
| `(16 8 4)` | Stock Opt, no profiler; `25906053.pbs101` | 3.291328 | 0.273561 | Fresh 150-step comparison; Cd trajectory needs review |
| `(32 16 1)` | Stock Opt, no profiler; `25826705.pbs101` | 3.064002 | 0.290022 | Faster of the two newly matched hierarchical results |

The new `(16 8 4)` PBS/script exit codes were zero, solver reached 150 steps,
and the coefficient file was newly generated during the job with 150 rows.
Its time is about **7.42% higher** than matched `(32 16 1)`, using the latter
as denominator. Thus `(32 16 1)` is fastest **among these two new matched
results**. Cd around 0.2736 is below the approximately 0.28-0.29 reference band;
technical success alone is not scientific validation. Inspect full Cd/residual
trajectories. Historical PgoUse `(16 8 4)` 3.1909 and `(32 16 1)` 3.0079 do
not belong in stock Opt ranking. With no at-run hash for `(8 8 8)`, do not call
all three points strictly same-build experiments.

Evidence: job-keyed scratch case `hier1684-opt-4n-v1-25906053`,
`evidence/logs/50_simpleFoam_A0.log` records
**3.291327721919464 s/step** and 150 steps; same-run
`case/postProcessing/forceCoeffsAll/0/coefficient.dat` records
**0.27356125421800065** at step 150. Historical `qstat -x -f` reported
`Exit_status = 0`; `evidence/exit-status.txt` had `script_exit_rc=0`.
The full original scratch-root pointer is retained in the Chinese source and
[experiment record](../experiments/aspire2a-hier1684-opt-4n/README.md).

Visual: horizontal dot plot, solid new points, hollow historical `(8 8 8)`;
caption binary-provenance and Cd limitations.

## 5. Main Basic decomposition comparison

Same AOCC/Open MPI stock Opt, 4 nodes / 512 ranks / 150 steps, no explicit binding:

| Decomposition | s/step | Cd(150) | Job | Note |
| --- | ---: | ---: | --- | --- |
| Hierarchical `(32 16 1)` | 3.0640 | 0.290022 | `25826705` | New matched-build comparison |
| Plain Scotch | 2.9124 | 0.284051 | `20064271` | Basic |
| Weighted Scotch | 2.9052 | 0.288551 | `20072244` | Selected staging configuration; `domains (4 8 16)`, `domainWeights (1 1 0.01)` |

Weighted is about 5.18% below `(32 16 1)` and 0.25% below plain in these single
runs. Plain/weighted change both `domains` and `domainWeights`: not proof of a
stable weight-only gain. "Fastest observed Basic configuration in this snapshot"
is the intended strength, subject to later repeatability caveats. New `(16 8 4)`
does not change selection of `(32 16 1)` as the faster hierarchical comparator.

Visual: dots/short bars; if using 2.85-3.12 s/step limits explicitly mark the
truncated axis. Label values and a small Cd table. Do not mix KaHIP into Basic ranking.

## 6. Selected Basic runs and scaling

| Nodes | Ranks | Steps | Weighted Scotch s/step | Final Cd | Job |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 128 | 40 | 13.3451 | 0.434536 | `19730482` |
| 2 | 256 | 80 | 6.3961 | 0.340263 | `20030920` |
| 4 | 512 | 150 | 2.9052 | 0.288551 | `20072244` |

Required step counts differ and Cd is at different stages of convergence.
This is the trend across prescribed task points, not strict equal-length
strong scaling or proof of superlinearity. Only the four-node unprofiled log
is the scoring candidate. Visual: three points/bars beside a nodes/steps table.

## 7. PMPI diagnosis: same method, three decompositions

Job `25826770` completed all three 150-step arms with fresh Cd on the same
stock Opt, four-node/512-rank configuration.

| Decomposition | Instrumented s/step | Mean rank time in MPI | Non-MPI share |
| --- | ---: | ---: | ---: |
| Hierarchical `(32 16 1)` | 3.0650 | 27.29% | 72.71% |
| Plain Scotch | 2.9635 | 19.68% | 80.32% |
| Weighted Scotch | 2.9212 | 19.03% | 80.97% |

Hierarchical's higher MPI fraction is consistent with a communication /
synchronization explanation. This was diagnosis **after** identifying faster
configurations, not profiling that originally selected Scotch. Instrumented
times do not replace unprofiled scores. Old mpiP and PMPI scopes/methods differ:
do not combine them in a quantitative comparison.

Visual: three 100% stacked MPI/non-MPI bars. Rank-block-based cross-node cut
estimates require mapping assumptions and are not measured network traffic.

## 8. Bonus and build explorations: separate branches

- KaHIP `fast/0.01`, stock Opt: **2.8759 s/step**, Cd **0.280044**, job
  `20030922`. Bonus, not Basic best. About 1.01% below weighted Scotch, single run.
- GCC `-march=znver3` versus stock KaHIP: **2.8827 vs 2.8805 s/step**;
  no reliable gain established.
- AOCC PGO + KaHIP + binding **2.86785** versus matched Opt + KaHIP + binding
  **2.86926**, about **0.05%** difference: not established PGO gain. PgoGen
  training precedes PgoUse; do not fold this branch into the stock Basic story.
- Binding differs by decomposition: weighted Scotch **2.905→2.949** (slower),
  KaHIP **2.876→2.869** (faster), all exploratory single pairs.

Visual: separate exploration slide, Basic/Bonus labels, modest comparison table
without exaggerated axes for tiny PGO/flag differences.

## 9. Intended final claim and limits in this draft

The source calls AOCC 5.0/Open MPI 5.0.10 stock Opt, 4 x 128 ranks, weighted
Scotch, 150 steps, no explicit binding its final Basic submission configuration:
**2.9052 s/step**, **Cd 0.288551**. Read this as the retained selected/staged
candidate, not verified final delivery. It supports an observed result, not
proof that weighted stably beats plain or AOCC/PGO is optimal.

Backup notes must disclose `(16 8 4)` Cd about 0.2736 needing trajectory review;
`(8 8 8)` lacks at-run binary hash and also needs Cd review; plain/weighted
repeats vary too much for a stable winner; tiny stack/PGO differences lack
adequate matched repetition in this snapshot; PMPI is consistent mechanism
evidence, not causal proof.

## 10. Scotch A/B/C follow-up: explain variation before rerunning

Three unprofiled 4-node/512-rank/150-step blocks completed. A is plain; B uses
`domains (4 8 16)` with uniform `(1 1 1)`; C uses the same domains and
`(1 1 0.01)`. Within each allocation the arm order changes. All blocks share
the same AOCC stock Opt binary SHA256; each arm's effective input hashes match
across blocks; all nine solver logs reach 150. These are **diagnostic repeats,
not replacements for the staged single-run measurement**.

| Block / PBS | Order | A plain | B uniform | C weighted | Unit |
| --- | --- | ---: | ---: | ---: | --- |
| 1 / `25909583` | A-B-C | 2.929377 | 3.030054 | 3.201184 | s/step |
| 2 / `25909584` | B-C-A | 3.166639 | 2.912308 | 3.086675 | s/step |
| 3 / `25909585` | C-A-B | 5.565019 | 4.918194 | 4.113459 | s/step |

Final Cd repeats by arm: A **0.284051**, B **0.274010**, C **0.288551**.
B's 40/80/120/150 trajectory repeats too, but its final value is below the
working 0.28-0.29 reference band: not an accepted optimization candidate until
scientific review. Each block's winner changes A→B→C. Relative to A, C is
9.28% slower, 2.53% faster, then 26.08% faster. Block 3 is generally slower;
blocks use different physical hosts; its `ClockTime`/`ExecutionTime` gap grows.
This suggests investigating waits/node environment, not a proven cause.
Do not take the minimum or pooled mean of all nine to prove weighting helps.
Retain historical C 2.9052/Cd 0.288551 and label its 0.25% difference from A a
single observation, not reproducibility.

Proposed order, **not authorization for new jobs**:

1. **Zero-SU audit:** nine Cd/residual trajectories, phase times, cells/interfaces,
   cross-node cuts, rank→node/core mapping, hosts and PBS output. Resolve B's
   scientific issue and investigate block 3 before asserting cross-rack causes.
2. **Only after controlling variation, pair A/C:** same stack/input/resources,
   150 steps, no profiler/explicit binding; order-balanced repetitions in one
   allocation, preserving hosts, affinity, hashes, timing and fresh Cd. Do not
   blindly repeat the full noisy design. On 2026-10-25, after direct-login
   authentication recovered, neither `qstat -x` nor `tracejob -n 7` retained
   these jobs' historical events. Saved files locate block 3 around 2026-10-23
   07:17–08:56 Singapore time for site investigation.
   [Node-event follow-up](../progress/2026-10-25-aspire2a-scotch-abc-site-event-followup.md).
3. **Only after valid, reproducible A/C separation, test new weights:** choose
   one/two topology-informed ratios; change only `domainWeights`. B is a
   diagnostic factor-separation arm, not a winner.
4. **PGO/binding are optional extensions, already explored:** KaHIP/bound PGO
   2.86926→2.86785; weighted Scotch binding 2.90519→2.94881. Basic Scotch
   claims need matched Opt/PgoUse or bound/unbound pairs on the chosen Scotch
   partition; KaHIP gains cannot transfer by assertion. In this dated plan
   they rank below A/C variation and B correctness. Later matched Scotch
   evidence exists in the 2026-10-26 audit linked above.

Detailed job paths/status: [review](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md).

## Suggested slide order

1. Cover; 2. Team; 3. OpenFOAM section; 4. Workload/evaluation;
5. Strategy/controls; 6. Stack survey; 7. Hierarchical XYZ;
8. Basic decomposition; 9. Selected configuration; 10. Scaling/Cd;
11. PMPI method; 12. Three-way MPI share; 13. Bonus KaHIP;
14. Architecture flag; 15. PGO; 16. Binding; 17. Results;
18. Limits; 19. Next step; 20. Thanks.

One question per slide; English short phrases and native editable charts/tables.
The Chinese source preserves explanatory notes and evidence limits, translated here.

## 11. Graph explanation and the scope of our claims (2026-10-25)

Model cells as vertices and adjacent-cell internal faces as edges. Edges cut
between MPI ranks form processor interfaces that normally require field
exchange. Partitioning seeks balanced work and fewer expensive cut edges.
Hierarchical uses geometric coordinate cuts; Scotch/METIS/KaHIP use graph
connectivity. Graph methods **may** be faster, not universally. Faces are not
network bytes or MPI time. This project's observations support a mechanism
interpretation of fewer interfaces/waits in faster graph partitions relative
to hierarchical; weighted versus plain Scotch remains unresolved.

The prior team's term is **multi-level Scotch**, not "module-level". v2512
supports `coeffs { domains ...; domainWeights ...; }` for hierarchical
communication weights. Their `(4 56)` / `(1 0.01)` and our C `(4 8 16)` /
`(1 1 0.01)` use the same mechanism class, not the same configuration or
experiment. A is plain, B shares C's domains with uniform weights, C is weighted.
These experiments are ASPIRE2A, not Gadi. Whether model levels correspond
to physical node/socket/core levels requires actual rank mapping.

Across blocks C is slowest, middle, then fastest. B Cd **0.274010** is below
the working band; this is not a hard rule threshold, so scientific acceptability
needs evaluation. Block-1 total processor-interface faces are A **2,927,022**,
B **2,958,587**, C **3,033,594**: C has **more total cut faces**. Do not claim
it won by reducing total communication edges. The [zero-SU audit](../progress/2026-10-25-aspire2a-scotch-abc-zero-su-audit.md)
uses actual rank→host maps for cross-node faces: A **337,324**, B **279,728**,
C **271,614**. Weighting may relocate cuts; these are not traffic measurements.
Within each arm, full Cd files are byte-identical across blocks, whereas block
3 has multiple tens-of-seconds wall-clock jumps. Root cause is not identified;
do not rank A/C from this alone.

### Profiling by time versus by count

For old 4-node/40-step plain Scotch mpiP, the top cumulative MPI-time calls
are Allreduce **11,650.9 rank-s**, Waitall **6,856.2**, Isend **1,053.4**.
By count the leaders are Isend **305.68M**, Irecv **305.68M**, Test **304.25M**,
then Allreduce **32.32M**. This is not the prior slide's Isend/Irecv/Allreduce
top-three count ordering. Rank-s is neither walltime nor pure transfer time.
Inherited Cd cannot prove fresh 40-step correctness.

The later consistent 150-step PMPI comparison gives hierarchical/plain/weighted
MPI fractions **27.29/19.68/19.03%** and can be the Basic mechanism main plot.
For call-type time/count plots, extract all three **PMPI raw reports** with one
method; do not splice old mpiP quantities into them. Gadi Scotch PMPI rank/peer
analysis is useful separate context, not part of this ASPIRE2A comparison.

### METIS was tested: keep it in the Bonus branch

The teammate's earliest one-node ICX/Intel MPI METIS attempt failed because
actual `libmetisDecomp` was missing. Later separate METIS builds succeeded:
AOCC/Open MPI stock Opt, 1 node/40 steps about **13.390 s/step**, job
`25246701`; 4 nodes/150 steps with **core binding**, about **2.934 s/step**,
Cd about **0.2927**, job `25252675`. Binding differs from plain/weighted
unbound Scotch, so this is not a one-variable A/B. METIS and KaHIP remain
Bonus explorations. Another METIS run is not needed just to tell the Basic story.

### Execution priorities in this snapshot

1. **Completed read-only zero-SU audit:** nine timing/Cd/residual traces,
   rank→node/allowed CPU masks, total and cross-node interfaces. Discrete
   long wall-clock jumps drive block-3 slowdown; root cause unidentified.
   B still needs comparison to reference trajectories. No new job submitted.
2. Consider order-balanced A/C repeats only after controlling variation;
   do not simply rerun unchanged A/B/C.
3. PGO/binding are optional Scotch extensions; matched Basic evidence is
   needed, and new weight ratios wait until A/C separation is reproducible.

Sources: [v2512 scotchDecomp multi-level documentation](https://api.openfoam.com/2512/scotchDecomp_8H_source.html),
[mpiP call-type CSV](evidence/aspire2a-mpip-4n512-2026-09-23/mpip-call-type-summary.csv),
[mpiP correctness limits](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md),
[4-node QA](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md),
[A/B/C review](../progress/2026-10-25-aspire2a-scotch-abc-evidence.md).
The original also cites teammate `references/teammate/OpenFoam-HPCAI-26/results/metrics.csv`;
that nested checkout is local-only and is not included in a fresh clone.
