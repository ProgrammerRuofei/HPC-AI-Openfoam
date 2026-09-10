# Master results table — 2026-09-10

This table matches slide 2 of `slides.html` cell for cell. Every value was
recomputed from the raw counters and the PBS evidence before commit.

## Slide 2 — Experiment results summary

| Experiment | Baseline | Change | Measured result | Improvement | Decision |
| --- | --- | --- | --- | --- | --- |
| **Scaling**<br><sub>SPR · GCC 8.5 + OpenMPI 4.1.7</sub> | 1N / 104 ranks<br>**8.824444** s/step | 2N / 208 ranks<br>4N / 416 ranks | **4.296500** → **2.139565** s/step | **2.053868×**<br>**4.124410×** | Good — not a priority |
| **Decomposition**<br><sub>SPR · 4N / 416 ranks</sub> | `(16 13 2)`<br>**2.147363** s/step | `(26 8 2)` | **2.127211** s/step<br>repeat **2.118657** | headline **0.94%**<br>robust **0.13–0.22%** | **STOP TUPLE SEARCH** |
| **MPI placement**<br><sub>SPR · 416 ranks</sub> | site-default OpenMPI placement | audit only, no change | 1 rank / physical core, no SMT<br>52/socket · 13/NUMA | already compact | **NO BINDING TUNING** |
| **ICC generic**<br><sub>CLX · 4N / 192 ranks · (16 6 2)</sub> | historical CLX GCC reference<br>**5.144659** s/step | ICC Classic 2021.10 `Opt` (`-O3`) | **5.281517** s/step | **−2.66%** (slower) | **NOT A WIN** |
| **Architecture targeting**<br><sub>CLX · ICC 2021.10</sub> | generic ICC: core libs `ymm=0 / zmm=0` | `-O3 -xCORE-AVX512` | 256-bit YMM across all 3 core libs<br>smoke **SIGFPE** | **Performance not measured** | **PAUSE — FP-trap issue** |
| **Profiling**<br><sub>CLX · ICC generic · 25-step</sub> | full run **5.281517** s/step | perf counters, 4 representative ranks | **5.246991** s/step (−0.65%)<br>IPC **1.03** · stalls **63.12%** · L3 **33.64%** | diagnostic — no runtime change | **MEMORY HIERARCHY NEXT** |

> Official scaling runs use different endTime values (40 / 80 / 150), so
> efficiency above 100% is not presented as controlled superlinear scaling.
>
> Static disassembly counts and runtime SIMD percentages are different kinds of
> evidence and are never interchanged. The architecture-targeting row shows
> **Performance not measured** because no valid targeted runtime result exists —
> SIMD instruction counts are not substituted for a performance metric.

Jobs: `178153587` · `178154724` · `178149002` · `178576776` · `178577482` ·
`178616881` · `178623596` · `178570241` · `178640018` · `178663697` · `178677055`

## Slide 4 — Compiler comparison

| | GCC reference | ICC generic | ICC targeted |
| --- | --- | --- | --- |
| Compiler | GCC 8.5.0 (site module) | ICC Classic 2021.10.0 | ICC Classic 2021.10.0 |
| Flags | `site build, -O3` | `-O3` | `-O3 -xCORE-AVX512` |
| Platform | CLX · 4N / 192 ranks · `(16 6 2)` | same | same |
| **Runtime** | **5.144659** s/step | **5.281517** s/step | **not valid — no run** |
| vs reference | — | **−2.66%** | — |
| SIMD in core libraries | `zmm=0 / ymm=0` | mostly scalar, `ymm=0` | `libfiniteVolume` **31,615**<br>`libOpenFOAM` **17,550**<br>`libincompressibleTurbulenceModels` **2,465**<br>`zmm=0` |
| Correctness | valid | valid · `178570241` | **SIGFPE smoke** · `178663697` |
| Status | `HISTORICAL CLX GCC REFERENCE` | `SCREENING VALID` | `BUILD VALID` / `DIAGNOSTIC FAIL` |

Root cause of the targeted smoke failure:

```
masked tail → zero-fill {%k1}{z} → unmasked vdivpd → 0.0 / 0.0
            → FE_INVALID → -fp-trap=common → SIGFPE
crash PC 0x92d6fe in Foam::GAMGSolver::scale()
```

This is a compiler/vectorization and FP-trap compatibility issue, **not** a
physical-model numerical failure. Both builds enter the solver under the
identical trap policy (`fegetexcept() = 0x000d`), so the difference is
generated code, not trap configuration.

> GCC reference = median of 4 repeats, one retained slowdown outlier
> (`178073349`). Not a controlled paired compiler baseline. Confidence MEDIUM.
>
> GCC `zmm=0 / ymm=0` source: prior shipped-binary disassembly recorded in
> `compiler-screening-summary.md` — existing static evidence from an earlier
> analysis window, not a new measurement from the current session.

## Slide 6 — Decision summary

| Area | Evidence | Decision |
| --- | --- | --- |
| Scaling | `8.824 → 4.297 → 2.140` s/step | Good; not priority |
| Decomposition | robust gain only ~0.2%; scatter 0.40% | Stop |
| MPI placement | already 1 rank/core, no SMT | Stop |
| ICC generic | 2.66% slower than GCC reference | Stop |
| Architecture targeting | 256-bit SIMD generated, but smoke SIGFPE | Pause |
| Memory / cache | 63.12% stalls; 33.64% L3 stalls | **NEXT** |
| MPI time fraction | not measured — perf cannot separate it | Later profiling |

**Main next step: MEMORY / CACHE BEHAVIOUR**, before any further compiler tuning.

## What we learned

| Question | Evidence | Answer | Confidence |
| --- | --- | --- | --- |
| Scaling through 4 SPR nodes? | official per-step scaling points | good — near-proportional | HIGH |
| More decomposition optimization? | A/B + repeat + interface analysis | very little runtime headroom remains | HIGH |
| Need MPI placement tuning? | placement audit | no immediate evidence | HIGH |
| Is ICC generic faster than GCC? | CLX screening vs historical reference | no, ~2.66% slower | MEDIUM |
| Does architecture targeting generate SIMD? | binary disassembly | yes, mainly 256-bit; zero 512-bit | HIGH |
| Is the targeted build currently safe? | smoke + static root-cause analysis | no — FP-trap incompatibility in GAMG | HIGH |
| Is arithmetic throughput the dominant bottleneck? | valid perf profile | probably not | MEDIUM-HIGH |
| Is the memory hierarchy important? | L3-stall + LLC evidence | yes, strongly | MEDIUM-HIGH |
| Do we know the MPI time fraction? | perf limitation | no | LOW / NOT MEASURED |
