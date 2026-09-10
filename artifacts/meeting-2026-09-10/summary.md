# Meeting summary — 2026-09-10

**One-line conclusion.** Scaling and communication-layout tuning now show
limited remaining headroom. Compiler architecture targeting successfully
introduced SIMD, but runtime profiling indicates substantial memory-hierarchy
stalls. Therefore further ICC architecture targeting is not the current
priority.

**Caveat.** MPI wall-time fraction and full socket/NUMA behaviour remain
unresolved.

## The story in six steps

1. **Baseline** — 65.3M-cell `occDrivAerStaticMesh`, `simpleFoam`, OpenFOAM
   v2512, `fixedIter`, endTime 150.
2. **Scaling** — per-step runtime falls near-proportionally from 1 to 4 SPR
   nodes (8.824 → 4.297 → 2.140 s/step).
3. **Decomposition** — `(26 8 2)` improves partition structure measurably
   (−4.73% interface faces, −12.1% max faces on a rank) but the robust runtime
   gain is 0.13–0.22%, smaller than the 0.40% scatter between two runs of the
   same tuple. Tuple search stops.
4. **MPI placement** — the site MCA configuration already maps one rank per
   physical core with no SMT and no oversubscription. No tuning.
5. **Compiler** — ICC generic is 2.66% slower than the historical CLX GCC
   reference. Architecture targeting produces substantial 256-bit SIMD and
   zero 512-bit arithmetic, but the smoke run hits SIGFPE in `GAMGSolver::scale`.
6. **Profiling** — a valid perf profile shows IPC ≈ 1.0, 63.12% of cycles
   stalled and 33.64% of cycles attributed directly to L3 misses.

## Next

Memory / cache behaviour before further compiler tuning. Remaining allocation
is low, so the practical next action is to preserve evidence and resume runtime
profiling and optimisation after the allocation resets.

## Files

- `slides.html` — 16:9 deck, arrow-key navigation, print CSS for PDF export
- `chart-data.json` — single verified source for every number in the charts
- `chart-scaling.svg`, `chart-decomposition.svg`, `chart-profiling.svg`
- `master-results-table.md` — master results table and the "what we learned" table
