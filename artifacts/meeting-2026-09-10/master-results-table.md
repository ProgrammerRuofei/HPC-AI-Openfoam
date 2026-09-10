# Master results table — 2026-09-10

Every value verified against the PBS evidence directories and
`results/experiment-index.md`. Status labels are used strictly; the categories
are not interchangeable.

| Stage | Platform | Configuration | Job | Metric | Result | Comparison | Status | Decision |
| --- | --- | --- | --- | --- | ---: | --- | --- | --- |
| Scaling | SPR | 1N / 104 ranks, `(4 13 2)`, 40 steps | `178153587` | avg s/step | **8.824444** | baseline | `OFFICIAL VALID` | — |
| Scaling | SPR | 2N / 208 ranks, `(8 13 2)`, 80 steps | `178154724` | avg s/step | **4.296500** | 2.0539× (eff. 102.69%) | `OFFICIAL VALID` | observed per-step scaling |
| Scaling | SPR | 4N / 416 ranks, `(16 13 2)`, 150 steps | `178149002` | avg s/step | **2.139565** | 4.1244× (eff. 103.11%) | `OFFICIAL VALID` | observed per-step scaling |
| Decomposition | SPR | `(16 13 2)` baseline | `178576776` | avg s/step | **2.147363** | reference arm | `CONTROLLED VALID` | reference |
| Decomposition | SPR | `(26 8 2)` candidate | `178577482` | avg s/step | **2.127211** | headline +0.94% | `CONTROLLED VALID` | needs repeat |
| Decomposition | SPR | `(26 8 2)` repeat | `178616881` | avg s/step | **2.118657** | robust +0.13–0.22%; same-tuple scatter 0.40% | `CONTROLLED VALID` | **stop tuple search** |
| MPI placement | SPR | site-default `mpirun` | `178623596` | placement | **1 rank/core, no SMT** | already compact | `DIAGNOSTIC PASS` | no binding tuning |
| Compiler ref | CLX | GCC 8.5 site build | `178063948` / `178073350` / `178107780` (+ retained outlier `178073349`) | avg s/step | **5.144659** | median of 4 repeats; one retained slowdown outlier | `HISTORICAL CLX GCC REFERENCE` | comparison anchor |
| Compiler | CLX | ICC 2021.10 generic `Opt` | `178570241` | avg s/step | **5.281517** | **2.66% slower** vs historical CLX GCC reference (confidence MEDIUM) | `SCREENING VALID` | not a win |
| Compiler build | CLX | ICC `OptAVX512` | `178640018` | build | **PASS** | `-xCORE-AVX512` ×4,399; substantial 256-bit YMM, zero zmm | `BUILD VALID` | smoke required |
| Smoke | CLX | ICC `OptAVX512` | `178663697` | correctness | **SIGFPE** | GAMG tail vectorization; root cause identified | `DIAGNOSTIC FAIL` | blocks the branch |
| Profiling | CLX | ICC generic, 25-step diagnostic | `178677055` | IPC / stalls | **IPC ≈ 1.0; stalls 63.12%** | L3-miss stalls 33.64% of cycles | `PROFILING VALID` | **memory hierarchy first** |

> The three scaling rows are **observed per-step scaling on official
> configurations**, not a controlled strong-scaling experiment: the official
> runs use different `endTime` values (40 / 80 / 150). Efficiency above 100%
> must not be read as a controlled superlinear-scaling result.

> The ICC-vs-GCC comparison is against a **historical** reference set, not a
> strict paired A/B experiment. Confidence: MEDIUM.

## What we learned

| Question | Evidence | Answer | Confidence |
| --- | --- | --- | --- |
| Scaling through 4 SPR nodes? | official per-step scaling points | good — near-proportional | HIGH |
| More decomposition optimization? | A/B + repeat + interface analysis | very little runtime headroom remains | HIGH |
| Need MPI placement tuning? | placement audit | no immediate evidence | HIGH |
| Is ICC generic faster than GCC? | controlled CLX screening vs historical reference | no, ~2.66% slower | MEDIUM |
| Does architecture targeting generate SIMD? | binary disassembly | yes, mainly 256-bit; zero 512-bit | HIGH |
| Is the targeted build currently safe? | smoke + static root-cause analysis | no — FP-trap incompatibility in GAMG | HIGH |
| Is arithmetic throughput the dominant bottleneck? | valid perf profile | probably not | MEDIUM-HIGH |
| Is the memory hierarchy important? | L3-stall + LLC evidence | yes, strongly | MEDIUM-HIGH |
| Do we know the MPI time fraction? | perf limitation | no | LOW / NOT MEASURED |
