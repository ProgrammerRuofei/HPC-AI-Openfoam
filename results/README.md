# Results

`metrics.csv` is the structured source of truth for extracted run results.
It currently contains headers only; no ASPIRE2A measurements have been
recorded. Phase 0 Gadi evidence remains in its remote experiment directory
until a user-approved extraction/schema update is performed.

The initial columns preserve experiment identity, environment/resource
metadata, runtime, correctness, and raw-output provenance. Confirm any new
columns or changed semantics with the user before a sweep.

## Two-layer performance metric framework

A **metric** is the defined quantity being measured. A completed run produces
one **measurement** (value) of that metric. Summary statistics are calculated
only across repeated measurements of the same controlled metric.

### Layer 1 — Official Competition Metric

**Metric:** Solver `ClockTime` [s].

This is the primary competition-oriented comparison metric: it answers “did
the configuration become faster according to the scoring objective?” Record
the exact solver ClockTime for every valid run. Once controlled repeats exist,
compare configurations using the repeat median, not a selected fastest run.

Example: Phase 0 produced the measurement `Solver ClockTime = 802 s`.

### Layer 2 — Performance Characterization Metrics

These explain the observed Layer 1 result rather than replace it:

- Solver `ExecutionTime` [s]
- mean measured timestep wall time [s/step]
- standard deviation of measured timestep wall time [s/step]
- number of measured timesteps
- PBS walltime
- peak memory usage

When profiling is authorised and available, also record MPI communication
time/fraction, MPI wait time, load imbalance, CPU hotspots, and I/O
contribution. Example: Phase 0 produced `mean measured timestep wall time =
5.1367 s/step`.

## Repeatability reporting

For each controlled repeated-run set, retain every individual measurement and
report the median, mean where useful, minimum, maximum, range, and standard
deviation. Do not confuse a metric with a summary statistic: the hierarchy is
`metric → repeated measurements → summary statistics`.
