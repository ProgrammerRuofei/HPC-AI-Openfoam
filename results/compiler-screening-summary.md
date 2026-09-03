# OpenFOAM v2512 compiler screening

## Comparison rule

This is an initial **compiler screening**: the workload, 4-node/192-rank
layout, hierarchical `(16 6 2)` decomposition, and Open MPI 4.1.7 are fixed
where stated.  The **PROVISIONAL COMPILER-SCREENING REFERENCE** is **797.5 s**,
the median of all four correctness-valid B0 repeats: R1=802 s, R2=1045 s,
R3=793 s, and R4=790 s. Its stable-looking cluster is 790–802 s; R2 is a
valid sustained performance anomaly and remains in the stated median.

| ID | Compiler | MPI | Build | Smoke | 65M Job | ClockTime | ExecutionTime | Mean step | Speedup | Status |
| -- | -------- | --- | ----- | ----- | ------- | --------- | ------------- | --------- | ------- | ------ |
| B0 | GCC 8.5 | OpenMPI 4.1.7 | existing validated | existing validated | R1/R2/R3/R4 | 802 / 1045 / 793 / 790 s | — | — | 1.000 (reference) | Provisional screening reference: 797.5 s median; R2 retained anomalous. |
| C1 | ICC 2021.10 | OpenMPI 4.1.7 | Original `178140361.gadi-pbs`: common ThirdParty-path defect before L5 | pending | — | — | — | — | — | SOURCE_ID_V2 and L4 passed; not a compiler result. |
| C2 | ICX 2025.1.1 | OpenMPI 4.1.7 | Original `178140527.gadi-pbs`: same common defect before L5 | pending | — | — | — | — | — | SOURCE_ID_V2 and L4 passed; not a compiler result. |
| C3 | ICX 2023.2.0 | OpenMPI 4.1.7 | Original `178140528.gadi-pbs`: cancelled before execution | pending | — | — | — | — | — | Cancelled after the confirmed common ThirdParty-path defect; not a compiler/build failure. |
| S1 | ICC 2021.10 | Intel MPI 2021.10 | deferred | — | — | — | — | — | — | Deferred at L4 OpenFOAM environment/compiler-MPI integration. |

## Table B — later scaling matrix

Normalized timestep cost, rather than raw ClockTime ratios, is the intended
comparison when controlled 1N/2N/4N workloads use different iteration counts.

| Compiler | 1N Clock | 1N mean/step | 2N Clock | 2N mean/step | 4N Clock | 4N mean/step |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GCC 8.5 + OpenMPI 4.1.7 | — | — | — | — | 797.5 s provisional | 5.144659 s (four-run median) |
| ICC 2021.10 + OpenMPI 4.1.7 | — | — | — | — | — | — |
| ICX 2025.1.1 + OpenMPI 4.1.7 | — | — | — | — | — | — |
| ICX 2023.2.0 + OpenMPI 4.1.7 | — | — | — | — | — | — |

No performance, binding, MPI, decomposition, or numerical tuning is part of
this screening.  ClockTime results will be appended without suppressing valid
anomalies.
