# Official 4N optimization matrix

Written 2026-09-03, before any official normalsr result exists. Every entry is a
**proposal**, not a finding. Nothing here may be recorded as evidence until the
corresponding run has produced a validated `Average wall-clock time per time step`
and a Cd inside the official range.

## Cost model

Gadi charges `resources x hours x queue_rate`. On `normalsr` the rate is
2 SU/resource-hour, and all three scaling points are ncpus-dominated, so:

| Scaling point | Resources | SU per hour | SU per run at 45 min |
| --- | ---: | ---: | ---: |
| 1 node | 104 | 208 | ~104 (at ~30 min) |
| 2 nodes | 208 | 416 | ~278 (at ~40 min) |
| 4 nodes | 416 | 832 | ~624 |

Two separate numbers matter and are easy to confuse:

- **Reservation** uses the *requested* walltime and decides whether PBS will
  schedule the job at all. This is what refused job `178142339`.
- **Billing** uses *actual* elapsed time. Requesting a longer walltime costs
  nothing in billing but can make a job unschedulable.

## Methodology: screen cheap, confirm expensive

A 4N run costs ~6x a 1N run and ~2.2x a 2N run. Screening every candidate at 4N
would exhaust the grant before the interesting questions are reached. Therefore:

| Effect under test | Where it is observable | Screen at | Confirm at |
| --- | --- | --- | --- |
| NUMA binding, ranks per node, intra-node bandwidth | inside one node | **1N** | 4N |
| Decomposition shape, method, inter-node communication | needs >=2 nodes | **2N** | 4N |
| MPI transport/eager tuning | needs >=2 nodes | **2N** | 4N |
| Final scored configuration | 4N only | — | **4N, repeated** |

Only configurations that win at the screening scale earn a 4N confirmation run.
A screening result that does not transfer to 4N is itself a recorded finding.

## Experiments

Ordered by expected information per SU, not by expected speedup. E0 is mandatory;
everything after it is conditional on E0 producing a valid baseline.

---

### E0 - Official 4N baseline (mandatory, already prepared)

- **Hypothesis**: the committed configuration produces a compliant, reproducible official result.
- **Changed variable**: none; this defines the reference.
- **Mechanism**: n/a.
- **Config**: 416 ranks, 104/node, hierarchical `(16 13 2)`, 150 iterations.
- **Cost**: ~624 SU billed; 1040 SU reserved at the 1:15 request.
- **Success criterion**: full six-step chain completes, Time 150 reached, `Average
  wall-clock time per time step` present, Cd in 0.28-0.29, PBS Exit_status 0.

### E0b - Official 1N and 2N scaling (mandatory for the submission)

- **Hypothesis**: the workflow is compliant and the case scales sensibly across the mandated points.
- **Changed variable**: node count only, with the forced-13 decomposition family.
- **Config**: 1N 104 ranks `(4 13 2)` / 40 steps; 2N 208 ranks `(8 13 2)` / 80 steps.
- **Cost**: ~104 + ~278 = **~382 SU**.
- **Success criterion**: both valid; Cd ~0.43 at 40 steps and ~0.34 at 80 steps;
  parallel efficiency computed against E0 and recorded.

---

### E1 - Process placement and NUMA binding

- **Hypothesis**: the baseline passes no `--map-by` / `--bind-to` flags, so rank
  placement is left to Open MPI/PBS defaults. On a node with **8 NUMA domains of
  13 cores**, a default placement that does not respect those domains will cause
  remote-memory traffic on a bandwidth-bound solver.
- **Changed variable**: launcher binding only. Nothing in the case changes.
- **Mechanism**: SIMPLE/`simpleFoam` on 65M cells is memory-bandwidth-bound; keeping
  each rank's working set in its local NUMA domain raises effective bandwidth and
  cuts cross-socket interconnect traffic.
- **Candidates**: `--bind-to core`; `--map-by numa --bind-to core`; `--map-by socket --bind-to core`.
- **Cost**: 3 screening runs at 1N = **~312 SU**; one 4N confirmation = ~624 SU.
- **Success criterion**: >=3% improvement in average wall-clock/step at 1N versus the
  E0b 1N baseline, reproduced at 4N, with Cd unchanged within the official range.
- **Note**: this is the cheapest experiment with a plausible double-digit payoff and
  it touches no competition-controlled file. The handover sequences placement after
  rank/topology work; the argument for pulling it earlier is purely cost - it is
  screenable entirely at 1N. Sequencing is the user's call.

### E2 - Decomposition method: hierarchical vs scotch

- **Hypothesis**: `hierarchical` imposes a rigid structured cut that ignores the
  actual geometry. `scotch` minimizes the interface directly and commonly reduces
  halo-exchange volume on complex external-aero meshes.
- **Changed variable**: `decompositionMethod` in `caseDefinition`, rank count held at 416.
- **Mechanism**: less interface area -> less halo data per SIMPLE iteration -> less
  MPI time per step; also usually better cell-count balance.
- **Cost**: 1 screening run at 2N (~278 SU) + 1 confirmation at 4N (~624 SU) = **~902 SU**.
- **Success criterion**: >=5% improvement in average wall-clock/step at 4N; Cd unchanged.
- **RULE CHECK REQUIRED**: decomposition is explicitly an allowed optimization and the
  baseline already edits `nCores`/`nHierarchical`, but `decompositionMethod` sits in
  `caseDefinition` alongside physics entries. Confirm with the organizers before
  spending SU on this. Do not run it on an assumption.

### E3 - Decomposition shape at fixed 416 ranks

- **Hypothesis**: `(16 13 2)` was chosen for topology tidiness, not for interface
  minimization. A shape closer to cubic subdomains should communicate less.
- **Changed variable**: `nHierarchical` only; 416 ranks held constant. This is the
  cleanest single-variable experiment available.
- **Mechanism**: 416 = 2^5 x 13 forces a 13 into one dimension; within that constraint
  the split can still be rebalanced toward lower total interface area.
- **Candidates**: `(8 13 4)`, `(26 8 2)`, `(13 16 2)` against the `(16 13 2)` baseline.
- **Cost**: 3 screening runs at 2N with the equivalent 208-rank shapes (~834 SU),
  then 1 confirmation at 4N (~624 SU) = **~1458 SU**.
- **Success criterion**: >=3% improvement at 4N; Cd unchanged.

### E4 - Ranks per node

- **Hypothesis**: one rank per physical core maximizes core count but minimizes
  per-rank memory bandwidth. On a bandwidth-bound solver, fewer ranks per node can
  win despite using fewer cores.
- **Changed variable**: ranks/node (and unavoidably the decomposition shape with it).
- **Mechanism**: bandwidth per rank rises as ranks/node falls; the crossover point is
  where lost compute throughput overtakes the bandwidth gain.
- **Candidates at 4N**: 416 (104/node, baseline), 384 (96/node, `(16 8 3)`),
  312 (78/node, `(12 13 2)`), 208 (52/node, `(8 13 2)`).
- **Cost**: 3 screening runs at 1N (~312 SU) + 1 confirmation at 4N (~624 SU) = **~936 SU**.
- **Success criterion**: >=3% improvement at 4N; Cd unchanged.
- **CONFOUND**: rank count cannot be changed without also changing the decomposition
  shape. This is not a clean single-variable experiment and must be reported as a
  joint effect, with E3 run first so the shape contribution is already characterized.

### E5 - Profiling of the best configuration so far

- **Hypothesis**: without a communication-vs-compute split, further tuning is guesswork.
- **Changed variable**: instrumentation only; the configuration is unchanged.
- **Mechanism**: identifies whether the remaining cost is halo exchange, global
  reductions in the pressure solve, load imbalance, or local compute.
- **Cost**: 1-2 runs at 4N = **~624-1248 SU**.
- **Success criterion**: not a speedup. Success is a defensible breakdown that
  determines whether E6 is worth funding at all.

### E6 - MPI transport tuning

- **Hypothesis**: Open MPI defaults are not tuned for this message-size profile.
- **Changed variable**: MPI runtime parameters only.
- **Mechanism**: eager/rendezvous threshold and transport selection affect the many
  small halo exchanges per SIMPLE iteration.
- **Cost**: 2 screening runs at 2N = **~556 SU**, gated on E5 showing communication
  is actually a material cost.
- **Success criterion**: >=3% at 4N; Cd unchanged.

### E7 - Compiler and MPI stack rebuild

- **Status**: **deferred**, per the handover. Already consumed a large share of the
  quarterly grant with no completed build.
- **Precondition**: E0, E0b and at least E1-E3 complete, and enough SU remains that a
  rebuild campaign cannot displace final validation repeats.

### E8 - Final validation repeats

- **Hypothesis**: a single fast run may be favourable variance rather than a real gain.
  Phase 0 saw ClockTime range 787-1045 s across four nominally identical runs - a
  ~30% spread that would swamp every threshold above.
- **Changed variable**: none; repeats of the chosen final configuration.
- **Cost**: 3 runs at 4N = **~1872 SU**.
- **Success criterion**: report median and spread, not the best observed run.
- **This is not optional.** Given the Phase 0 variance, any single-run improvement
  below roughly 5% is indistinguishable from noise.

---

## Budget summary

| Tier | Contents | SU (billed estimate) |
| --- | --- | ---: |
| **Mandatory** | E0 + E0b | **~1000** |
| **High value** | E1 + E2 + E3 | ~2900 |
| **Conditional** | E4 + E5 + E6 | ~2700 |
| **Required to defend a result** | E8 | ~1900 |
| **Total for a credible campaign** | | **~8500** |

Reservation headroom sits above this: peak concurrent reservation is roughly 1.3x
the billed figure at the 1:15 request. A grant request should therefore be for
**about 10 KSU**, with **2 KSU** as the floor that buys only the mandatory tier.

## Standing rules for every entry above

1. One major variable per run, or the run is explicitly labelled a stack experiment.
2. Baseline -> single change -> official metric -> Cd sanity -> interpretation.
3. Failed and inconvenient runs stay in the registry.
4. Success is always measured on `Average wall-clock time per time step`, never on
   ClockTime and never on the fastest observed run.
5. Estimate the SU cost before submitting, and record actual cost afterwards.
