# Official 2026 OpenFOAM competition progress

## Official target

- Gadi `normalsr`, Intel Xeon Platinum 8470Q Sapphire Rapids
- OpenFOAM v2512 site module; official metric: Average wall-clock time per time step

## Status

- [x] Official rules audited
- [x] Previous Cascade Lake results reclassified
- [x] normalsr hardware validated
- [ ] Official 4N baseline (416 ranks; hierarchical `(16 13 2)`) - scripts ready and gated; **blocked on SU**
- [ ] Official 1N / 2N scaling - scripts ready and gated; **blocked on SU**
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
