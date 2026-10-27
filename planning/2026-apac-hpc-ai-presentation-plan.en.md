# 2026 APAC HPC-AI presentation content plan

English companion to [the original](2026-apac-hpc-ai-presentation-plan.md),
prepared 2026-10-28. **Historical team-review draft dated 2026-10-08**, not a
current result registry or final submission receipt. OpenFOAM selection, PGO
and repeatability status evolved later; consult the [current guide](aspire2a-guide.en.md).
Qwen numbers below are translated claims from a teammate-supplied slide PDF,
**not independently validated raw benchmark results in this repository**.

Presentation order: OpenFOAM → Qwen → shared conclusions. This file is the
speaker/evidence plan; projected slides should contain titles, key values and
necessary charts, not source paths, production notes or tiny footnotes.

## 1. Scope and timing

- One deck covers both tasks. The source records a 15-20 minute talk and
  10-minute Q&A, proposing about eight minutes OpenFOAM, seven Qwen and two
  opening/closing.
- Approximately 15 main slides; raw logs/scripts/dictionaries, complete sweeps
  and failures belong in submission material or backup slides, not dense tables
  unreadable on a projector.
- Separate OpenFOAM Basic, Bonus and diagnostic profiling. Separate Qwen's
  selected Basic script, Bonus sticky router and rejected experiments.
- Follow the prior NTU/HPC-AI palette: mainly white with large dark-blue titles;
  one principal conclusion and visual per slide, readable chart text.

| Slide | Section | Title | Main content |
| ---: | --- | --- | --- |
| 1 | Opening | 2026 APAC HPC-AI | Team and university |
| 2 | Opening | Outline | OpenFOAM, Qwen, conclusions |
| 3 | OpenFOAM | Workload and Evaluation | Fixed case, score, constraints |
| 4 | OpenFOAM | Optimization Search | Dimensions and screening logic |
| 5 | OpenFOAM | Compiler and Flags | Stacks, znver3, PGO status |
| 6 | OpenFOAM | Decomposition | Hierarchical, Basic Scotch, Bonus KaHIP |
| 7 | OpenFOAM | Basic Scaling and Cd | 1/2/4-node timing/Cd |
| 8 | OpenFOAM | Profiling | Interfaces, MPI calls, bottleneck interpretation |
| 9 | OpenFOAM | OpenFOAM Takeaways | Selected Basic/Bonus and limits |
| 10 | Qwen | Workload and Deployment | Model, hardware, PD, SLA |
| 11 | Qwen | Routing Bottleneck and Fix | 0.5→13 req/s diagnosis and two groups |
| 12 | Qwen | Tuning and Bottleneck | Performance steps, prefill limit, negative results |
| 13 | Qwen | Declared Basic Result | N=60 metrics and selection rationale |
| 14 | Qwen | Bonus and Reproducibility | Sticky router, scripts, unresolved checks |
| 15 | Closing | Conclusions | One result/method per task |

## 2. OpenFOAM slide content

### Slide 3: Workload and Evaluation

On slide: `OpenFOAM v2512`, `occDrivAerStaticMesh`, about 65M cells,
`simpleFoam`, ASPIRE2A AMD EPYC 7713, four-node average wall-clock per step.
Show the preparation/solver chain simply.

Speaking notes: fixed mesh/solver/`fvSchemes`/`fvSolution`. Prescribed 1/2/4
nodes use 40/80/150 steps; four nodes is scored. Preserve the full commands:
`decomposePar -constant`, `restore0Dir -processor`,
`renumberMesh -constant -overwrite -parallel`,
`potentialFoam -initialiseUBCs -parallel`,
`applyBoundaryLayer -ybl 0.0450244 -parallel`, `simpleFoam -parallel`.
Use the solver average-per-step line, not PBS walltime or `ExecutionTime/150`.

Package mapping: build method, node-specific PBS scripts, actual dictionaries,
all phase logs, four-node solver log/Cd. Full commands/paths belong in readable
text evidence, not crammed into slides.

### Slide 4: Optimization Search

On slide: compiler/MPI, flags, decomposition, ranks/placement, with
measure→compare→retain/reject status.

Speaking notes: the team tested more than Scotch: AOCC/GCC/ICX builds/runs,
GCC znver3, hierarchical/plain/weighted Scotch/KaHIP, some rank/binding
configurations and mpiP. Lead with the larger decomposition differences,
then explain why small stack/flag/binding differences are not established
gains. Survey breadth here; details later.

Limits: different-MPI ICX/AOCC is not compiler-only A/B. Single sub-1% gaps
are not stable improvement. KaHIP is Bonus, not a Basic replacement.

### Slide 5: Compiler and Flags

| Item | Source-era presentation conclusion |
| --- | --- |
| Selected Basic build | AOCC 5.0 + Open MPI 5.0.10, official v2512, stock Opt, `-O3` |
| GCC targeting | Stock KaHIP ~2.8805 vs `-O3 -march=znver3` ~2.8827 s/step; no observed single-run benefit |
| PGO | Source says training/build attempts existed but no verifiable final 4-node result had been assembled at that date; later records supersede this status |

`-O3` is the adopted optimization level, not a later independently discovered
gain. GCC znver3 differs about 0.074%, insufficient for a one-run conclusion:
say the measurement did not support adopting this flag. AOCC OptZnver3 had no
usable competition-account build then and cannot enter performance rankings.
Stack representatives can be backup; ICX also changes MPI. Without actual
binary disassembly, do not claim proof of specific SIMD presence/absence.

Visual: only the matched 4-node KaHIP GCC pair if needed; otherwise a compact
table is clearer than tiny bar differences.

### Slide 6: Decomposition

Main figure: 4 nodes, 512 ranks, 150 steps: hierarchical `(8 8 8)`
**3.355476**, Basic Scotch **2.912440**, Bonus KaHIP `fast/0.01`
**2.875901 s/step**. Distinguish Basic/Bonus. Scotch's observed time reduction
is about **13.2%**; KaHIP/Scotch differ about **1.3%**.

All three use AOCC/Open MPI, 4 x 128 ranks, no explicit binding. Partitioning
changes interfaces and cross-node exchange requirements. Analyzed cross-node
interfaces are approximately KaHIP **213,435**, Scotch **337,324**,
hierarchical **2,048,418**, ordered consistently with timing and diagnostic
MPI totals. This correlation is not independent causal proof. Bound KaHIP
2.869257 versus unbound Scotch 2.912440 is not pure decomposition A/B.

Cd values about **0.2800 / 0.2841 / 0.2984** in KaHIP/Scotch/hierarchical
order differ. Hierarchical is above the approximate 0.28-0.29 reference, not
strictly equivalent or tolerance-validated. Each is one formal measurement;
the small KaHIP gap needs repetition. Basic remains Scotch in this dated plan.

### Slide 7: Basic Scaling and Cd

Plot mean wall-clock per step, with small steps/ranks/Cd table:

| Nodes | Ranks | Steps | Average wall / step | Final Cd | Job |
| ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 128 | 40 | 13.352080 s | 0.435988 | `19730481` |
| 2 | 256 | 80 | 6.378504 s | 0.327139 | `20047559` |
| 4 | 512 | 150 | 2.912440 s | 0.284051 | `20064271` |

Source-reported normalized speedups **2.0933x / 4.5845x** are
`13.352080/6.378504` and `13.352080/2.912440`, rounded. These are observations
from single runs with unequal steps, not established superlinear scaling.
Raw logs ended at required steps and coefficient files contain 40/80/150 rows.
Two-node Cd 0.3271 is below the ~0.34 reference; Basic has no stated hard
percentage tolerance in this source, so disclose rather than mark strict pass.

An optional trajectory plot must use this year's original coefficients, not
the prior team's 2,000-step flow-field images.

### Slide 8: Profiling

Use one evidence view: partition → cross-node interfaces → waits/collectives.
Emphasize Allreduce/Waitall, not a dense 512-rank table.

Archived diagnostic mpiP gives reconstructed aggregate MPI time about
**18,836 / 22,499 / 28,901 rank-seconds** for KaHIP/Scotch/hierarchical.
These are rank-summed diagnostics, not four-node solver walltime. The source
reports clean v2 A0/P0/A1 completed 40 steps on 2026-10-07, identical fresh
coefficient files, control difference **0.335%**, overhead about **10.1%**.
Diagnostic timing cannot replace 150-step scores. Old profiling directories
contained inherited 150-step Cd incorrectly read as 40-step output; it does
not establish fresh correctness for old profiles.

Supported: communication/synchronization deserves investigation. Unsupported:
a particular MPI tuning parameter has already delivered stable acceleration.

### Slide 9: OpenFOAM Takeaways

1. Basic in this snapshot: AOCC/Open MPI/Scotch, **2.912 s/step** at four
   nodes, with 1/2/4-node data.
2. Bonus: KaHIP fast/0.01, **2.876 s/step**, about **1.3%** difference from
   equally unbound Scotch in single runs.
3. Interface/MPI trends agree; small benefits remain noise/repetition-limited.

Raw logs and Cd are authoritative. Source/build identity, actual dictionaries
and log packaging still needed archival review in this snapshot; slides alone
cannot establish that. Later weighted Scotch staging has separate records.

## 3. Qwen: compress the teammate's 21-slide draft into five slides

Source: teammate-provided local `HPCAI.pdf` (the original document records its
absolute local path). Figures are transcribed from that deck, **not independently
checked against raw metrics.csv or AIPerf JSON**. The Qwen owner must confirm
final script, versions and result status. These are team-context claims, not
OpenFOAM benchmark evidence or the maintainer's personal execution.

### Slide 10: Workload and Deployment

On slide: official `Qwen3-235B-A22B-Instruct-2507-FP8`, Firmus 2 x HGX H200 /
16 GPUs, prefill/decode (PD) separation, 4,000 input + 200 output tokens;
SLA TTFT ≤3,000 ms, mean ITL ≤20 ms, good-request fraction ≥0.90.

The PDF declares SGLang 0.5.17, sglang-router 0.3.2, NIXL 1.3.2, AIPerf
0.12.0. Benchmark enters a single gateway `/v1/chat/completions`, closed-loop,
60/120/30-second phases and fixed seed. Diagram: AIPerf→gateway→two independent
PD groups, each TP=4 prefill + TP=4 decode, using all 16 GPUs. Confirm software
and topology with the owner before delivery.

### Slide 11: Routing Bottleneck and Fix

Visual: old one-PD-router, four-prefill/two-decode setup versus one gateway,
two isolated one-prefill/one-decode groups. Reported **0.5→13 requests/s**,
about **26x** (`13/0.5`).

According to the teammate, one old router paired multiple P/D combinations;
only one pairing bootstrapped, others queued to timeout and decode stayed idle.
Short windows counted only completed requests and overstated healthy fraction.
An 8-GPU 1:1 diagnostic excluded model/single-node failure; two isolated groups
fixed pairing. Eight GPUs was diagnostic, not the submitted configuration.

Correction: "strict 1:1 is always required" was too broad. The reported
stall condition was associated with **one decode per PD router**. Two prefills
and one decode can work, though a further TP=2 prefill variant performed worse.
Present the corrected mechanism, not the rejected generalization.

### Slide 12: Tuning and Bottleneck

Main figure: first threshold-passing **68.0** to final sample **2,668.7 good
output tok/s**, about **39x** (`2668.7/68.0`). Much came from routing repair,
then concurrency/configuration tuning. Do not merge this tok/s progression with
the 0.5→13 requests/s metric.

The teammate attributes the final bottleneck mainly to prefill: each of two
TP=4 workers about **26,500 input tok/s**, combined about **13.3 req/s**
(`2*26500/4000`), near final **13.5 req/s**, with decode headroom. Larger
chunks raised TTFT and reduced score. FP8 KV, FlashInfer decode attention,
DeepGEMM, CUDA graph lists and KV page sizes did not beat the owner's preset
**N=60 median +2%** promotion criterion. Selected scripts retain BF16 KV,
FA3 attention and default page size. Full negative-result table is backup.

### Slide 13: Declared Basic Result

On slide: **N=60**, about **2,660 good output tok/s** (rounded median of
four full-duration runs), good-request fraction **0.984**, TTFT p50 **837 ms**,
mean ITL **17.6 ms**.

Reported samples: **2,657.7 / 2,659.8 / 2,659.9 / 2,668.7**, each fraction
0.984. Rounded range is about **0.4%**; median is **2,659.85**, rounded 2,660.
Packaged no-override job **19927**, **2,659.8**, supports the teammate's
reproduction claim. N=64 had a higher single maximum **2,740.1** but four-run
variation and fraction **0.926–0.983**. The owner chose N=60 under the preset
"every sample >0.95" rule. **0.926 still exceeds official 0.90**: do not call
it an official threshold failure. TTFT p99 **3,726 ms** above 3,000 is compatible
with fraction 0.984 because request-level gating permits some tail failures.

### Slide 14: Bonus and Reproducibility

Left: Bonus sticky PD router, N=64, three full-duration samples, median
**2,763.2 good tok/s**, fraction **0.982**. Right: Basic reproduction material
`build/setup.sh`, `run/submit.sbatch`, packaged no-override job 19927.

The teammate's custom router pins request P/D pairings; it is not in the Basic
rerun script. Difference versus N=60 Basic 2,660 is about **3.9%**
(`2763.2/2660-1`), but concurrency changes too, so not a routing-only gain.
Bonus needs change/equal-compute/accuracy/self-Basic-gain evidence; PDF says
organizer accuracy checking was still outstanding. Basic retains official FP8
model, BF16 KV, no draft model, and unmodified official AIPerf after deployment.
EAGLE3/vLLM/TensorRT-LLM branches remain backup, not main-talk distractions.

## 4. Closing, backup and unresolved confirmations

### Slide 15: Conclusions

Two columns: OpenFOAM source-era Basic Scotch **2.912 s/step**, decomposition /
communication as the main investigation; Qwen declared Basic **2,660 good
tok/s, fraction 0.984**, pairing repair and robust concurrency choice. Explain
that Basic is intended for organizer rerun and Bonus stays separate. This
presentation intent is not independent proof of delivery.

### Backup slides

- OpenFOAM: full configurations, stack table, negative flags, Cd trajectories,
  mpiP classes, job IDs, full Allrun/dictionary verification status.
- Qwen: concurrency sweep, four N=60 samples, N=64 internal 0.95 versus official
  0.90, corrected routing counterexample, negatives, Bonus evidence and scripts.
- Prior-team pressure/velocity ParaView slices are old-case postprocessing,
  not mandatory this year. Only add new field plots with this year's fields
  and clear provenance; never relabel old plots as this year's results.

### Team confirmation before delivery

1. Qwen owner confirms PDF scripts/N=60/four samples/versions/Bonus status and
   provides metrics.csv/AIPerf JSON for checking.
2. Package OpenFOAM logs/Cd/actual dictionaries/build scripts; disclose the
   two-node Cd deviation accurately.
3. Label units and conditions: do not mix s/step, requests/s and good output
   tok/s, Basic/Bonus, or profiled/unprofiled results.
4. Keep paths/hashes/footnotes/dense versions in text evidence and this plan,
   not projected slides; answer provenance questions verbally if needed.

## 5. Source references preserved from the draft

- [2026 OpenFOAM rules](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md)
- [2026 Qwen3 rules](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/1.%20Qwen3%20AI%20Task%20Rules.md)
- [2026 README addendum](https://github.com/hpcac/2026-APAC-HPC-AI)
- [OpenFOAM readiness](analysis/aspire2a-submission-readiness-2026-10-07.md)
- [4n512 QA](analysis/aspire2a-4n512-evidence-qa-2026-09-18.md)
- [Compiler/codegen audit](analysis/aspire2a-compiler-codegen-audit-2026-09-17.md)
- [Step 1 mpiP](analysis/aspire2a-step1-mpip-evidence-2026-09-23.md)
- Teammate-supplied 21-page `HPCAI.pdf`, external local source, not a raw
  result dataset bundled with this repository. No new external-rule or Qwen
  benchmark verification was performed to produce this translation.
