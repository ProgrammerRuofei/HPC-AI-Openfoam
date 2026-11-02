# Results

Extracted numbers and their provenance, kept separate from the scripts that
produced them so results can be reviewed without reading code.

## Start here

| Document | What it is |
| --- | --- |
| [`experiment-index.md`](experiment-index.md) | **Master index** — every run and validation attempt, with status labels and provenance. Start here. |
| [`hpc-lessons.md`](hpc-lessons.md) | Failure and scheduler lessons (L1–L10), kept as permanent evidence |
| [`official-gadi-spr/run-registry.md`](official-gadi-spr/run-registry.md) | Official `normalsr` run-by-run registry, including the failed attempts |
| [`compiler-screening-summary.md`](compiler-screening-summary.md) | Performance matrix and the compiler-screening narrative |
| [`RESULTS.md`](RESULTS.md) | Phase 0 controlled-repeat report |
| [`metrics.csv`](metrics.csv) | Machine-readable rows — currently the four Phase 0 repeats (R1-R4) |
| `scripts/` | Extraction helpers |

`metrics.csv` is the structured source of truth for extracted run results. Its
columns preserve experiment identity, environment/resource metadata, runtime,
correctness, and raw-output provenance, with explicit ExecutionTime, timestep
statistics, PBS resources, and artifact-status fields so raw metrics are never
conflated.

Raw PBS, provenance, checksum, and solver files remain on Gadi under
`/scratch/pm78/kj7183/openfoam_cpu/` and are unchanged. CSV rows and the tables
in this directory are a documented extraction, **not** replacements for those
artifacts.

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

## 2026-11-02 ICX/GCC PMPI diagnostic archive

Two validated diagnostic rows (181908113 and 182940799) were added using the existing metrics.csv schema; actual SU appears once per job in notes and in [the companion table](gadi-icx20253-ompi5010-scotch/pmpi-comparison-2026-11-02.csv). These are PMPI measurements, not scored repeats. [Analysis](../planning/analysis/gadi-icx-gcc-pmpi-2026-11-02/README.md).
