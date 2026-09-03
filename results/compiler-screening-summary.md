# OpenFOAM v2512 compiler screening

> **Deprecated as an official-contest baseline.** This table is pre-rule
> Cascade Lake development work. Official Gadi scoring requires `normalsr`
> Sapphire Rapids and Average wall-clock time per time step as the primary metric.

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
| C1 | ICC 2021.10 | OpenMPI 4.1.7 | `178141482.gadi-pbs`: reached L5 and **compiled ThirdParty successfully**, then stopped on a missing `wmkdepend` | pending | — | — | — | — | — | Not a compiler result. Root cause found offline and fixed; see below. |
| C2 | ICX 2025.1.1 | OpenMPI 4.1.7 | Original `178140527.gadi-pbs`: same common defect before L5 | pending | — | — | — | — | — | SOURCE_ID_V2 and L4 passed; not a compiler result. |
| C3 | ICX 2023.2.0 | OpenMPI 4.1.7 | Original `178140528.gadi-pbs`: cancelled before execution | pending | — | — | — | — | — | Cancelled after the confirmed common ThirdParty-path defect; not a compiler/build failure. |
| S1 | ICC 2021.10 | Intel MPI 2021.10 | deferred | — | — | — | — | — | — | Deferred at L4 OpenFOAM environment/compiler-MPI integration. |

## Table B — scaling / official-result matrix

Normalized timestep cost, rather than raw ClockTime ratios, is the intended
comparison when controlled 1N/2N/4N workloads use different iteration counts.
The Cascade Lake development row and the official Sapphire Rapids row are
retained separately: they differ in hardware and ranks, so neither is a
compiler-only speedup comparison against the other.

| Compiler | Metric | Decomposition / SCOTCH | 1N Clock | 1N mean/step | 2N Clock | 2N mean/step | 4N Clock | 4N mean/step |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GCC 8.5 + OpenMPI 4.1.7 — Cascade Lake development, 192 ranks | Mean measured solver timestep (non-official) | hierarchical `(16 6 2)`; SCOTCH not used | — | — | — | — | 797.5 s provisional | 5.144659 s (four-run median) |
| GCC 8.5 + OpenMPI 4.1.7 — **official SPR baseline**, 416 ranks | **Official average wall-clock time/step** | hierarchical `(16 13 2)`; SCOTCH not used | — | — | — | — | **336 s** (`178149002`) | **2.139565 s** |
| ICC 2021.10 + OpenMPI 4.1.7 | — | — | — | — | — | — | — | — |
| ICX 2025.1.1 + OpenMPI 4.1.7 | — | — | — | — | — | — | — | — |
| ICX 2023.2.0 + OpenMPI 4.1.7 | — | — | — | — | — | — | — | — |

No performance, binding, MPI, decomposition, or numerical tuning is part of
this screening.  ClockTime results will be appended without suppressing valid
anomalies.

## C1 diagnosis (2026-09-03, offline from existing logs — no SU spent)

Job `178141482` is the furthest any build has reached: 24:08 walltime, **38.61 SU
actually billed**, Exit_status 2. It is *not* a compiler-compatibility result.

ThirdParty built cleanly under ICC — scotch, boost and CGAL all completed, and
`flex 2.6.1` was found. The build then stopped at:

```
make: .../platforms/tools/linux64Icc/wmkdepend: Command not found
make: *** No rule to make target '.../POSIX.C.dep', needed by '.../POSIX.o'.  Stop.
```

**Root cause.** `wmkdepend` is wmake's own dependency generator, built from
`wmake/src/`, and it is installed into `platforms/tools/${WM_ARCH}${WM_COMPILER}`.
That path is **compiler-specific**, and the site tree ships only
`platforms/tools/linux64Gcc`. Switching to ICC therefore requires rebuilding the
wmake toolchain as `linux64Icc` before any library can be compiled. Grepping the
whole 4.6 MB log for `wmake/src`, `wmakeBuildTools` or `dirToString` returns
nothing: **the step was never run**.

Why it was missed: a normal OpenFOAM source distribution has a top-level
`Allwmake` that sequences `wmake/src` -> `src` -> `applications`. The site
installation has **no top-level `Allwmake`**, so the build scripts drive the
per-directory steps by hand — and reproduced only the last two.

**Fix applied** to `common/build_openfoam_v2512_openmpi.sh` (which C1/C2/C3 all
exec into) and to the three s-series scripts: run
`"${WM_PROJECT_DIR}/wmake/src/Allmake"` first, then assert
`platforms/tools/${WM_ARCH}${WM_COMPILER}/wmkdepend` is executable before
continuing. `wmake/src/Allmake` is also added to the staged-source preflight list.
The post-condition check means this failure can no longer appear 24 minutes deep
as a confusing `make` error.

**Remaining known blocker for the s-series only.** Intel MPI candidates still hit
`etc/bashrc` resetting `WM_MPLIB=INTELMPI` to `SYSTEMOPENMPI`, after which
`mpicc --showme:link` (an Open MPI flag) is handed to Intel MPI's wrapper. The
OpenMPI candidates C1/C2/C3 do not have this problem, which is why C1 is the
right first target.

**Scheduling note, not a cost note.** These builds are cheap to run — 38.61 SU
for 24 minutes on 48 `normal` cores. The hazard is the **8 h walltime request**,
which reserves ~768 SU and can starve a concurrent `normalsr` job of allocation.
That is exactly what happened to baseline attempt 1 (`178142339`). Do not run
builds concurrently with a scored run; the walltime itself is defensible until a
full build time is measured.
