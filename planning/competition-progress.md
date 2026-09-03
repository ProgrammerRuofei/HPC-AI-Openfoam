# Official 2026 OpenFOAM competition progress

## Official target

- Gadi `normalsr`, Intel Xeon Platinum 8470Q Sapphire Rapids
- OpenFOAM v2512 site module; official metric: Average wall-clock time per time step

## Status

- [x] Official rules audited
- [x] Previous Cascade Lake results reclassified
- [x] normalsr hardware validated
- [x] Official 4N baseline (416 ranks; hierarchical `(16 13 2)`) - **2.1396 s/step**, Cd 0.28231, job `178149002`
- [x] Official 1N / 2N scaling - valid: 8.824444 / 4.296500 / 2.139565 s per step at 1N / 2N / 4N
- [ ] Decomposition and rank-count screening - planned in `planning/official-4n-optimization-matrix.md`
- [ ] Profiling, affinity, compiler optimization, final validation, submission package, presentation

## Blocker (2026-09-03)

Project `pm78` shows 137.15 SU available against a 4.00 KSU quarterly grant, with
2.05 KSU still reported as Reserved while **no jobs are queued or running**. A 4N
run needs ~1040 SU reserved, so nothing can be submitted until additional SU is
granted. A request to the organizers is in progress.

All local preparation that does not consume SU is complete: 1N/2N/4N scripts,
a negative-tested static gate, metric/Cd extraction, and the costed optimization
matrix.

## Correction (2026-09-03, later)

Two earlier readings were wrong and are corrected here rather than edited away:

1. **Job `178142339` was not permanently blocked.** The
   `Could not reserve allocation from project` comment was transient. PBS
   scheduled the job at 20:28:15 on four verified SPR nodes once a concurrent
   build released its reservation. Cancelling it was an operator error costing
   ~45 SU. A queue comment is a snapshot, not a terminal state.
2. **The grant is not exhausted.** The 2.05 KSU shown as Reserved was a pending
   hold that reconciled, mostly released rather than charged. Actual position is
   Used 2.12 KSU, Reserved 0, **Avail 1.88 KSU** - enough for the 4N baseline.

Measured from the cancelled run: `decomposePar -constant` wrote 183 of 416
processor directories in ~143 s, so the full decomposition takes ~5-6 min. The
1:15 walltime request has ample margin.

Hardware confirmed from the same log: 2 sockets x 52 cores, **8 NUMA domains of
13 cores each**, which is why 13 is a forced factor of every decomposition and
why 104 ranks/node maps to exactly 13 ranks per NUMA domain.

## First valid official baseline (2026-09-03)

| Metric | Value |
| --- | --- |
| **Average wall-clock time per time step** | **2.1396 s** |
| Cd (target 0.28-0.29) | 0.28231 |
| ClockTime / ExecutionTime | 336 s / 319.73 s |
| PBS walltime | 00:13:12 |
| Nodes | gadi-cpu-spr-0681/0682/0683/0684 |
| Ranks / decomposition | 416, hierarchical (16 13 2) |
| Job / commit | `178149002.gadi-pbs` / `d13aea1` |
| Cost | ~183 SU |

Reached on the fourth attempt. The three failures are kept in the registry: one
operator cancellation of a running job, one exit 127 (`restore0Dir` is a shell
function, not a binary), and one exit 134 (`-parallel` steps launched without
`mpirun`). Both defects were inherited from the original chain and both were
invisible to a gate that only checked whether command strings were present.

## Official scaling complete (2026-09-04)

| Nodes | Ranks | Hierarchical decomposition | Avg wall-clock / step | ClockTime | Cd | PBS walltime | Job |
| ---: | ---: | --- | ---: | ---: | ---: | --- | --- |
| 1 | 104 | `(4 13 2)` | **8.824444 s** | 378 s | 0.43087 | 00:12:11 | `178153587` |
| 2 | 208 | `(8 13 2)` | **4.296500 s** | 362 s | 0.33201 | 00:12:36 | `178154724` |
| 4 | 416 | `(16 13 2)` | **2.139565 s** | 336 s | 0.28231 | 00:13:12 | `178149002` |

The normalized 1N-to-2N speedup is 2.053868× and the 1N-to-4N speedup is
4.124410×. All three points used 104 ranks per node, the site GCC 8.5.0 /
Open MPI 4.1.7 v2512 module, no SCOTCH, the full official preparation chain,
and their expected Cd sanity range.
