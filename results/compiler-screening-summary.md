# OpenFOAM v2512 performance matrix

The official competition metric is **Average wall-clock time per time step**
from the `simpleFoam` log. It is the primary value in every official-result
table; `ClockTime` is retained as secondary provenance. Official results run
on Gadi `normalsr` Sapphire Rapids and must not be compared as compiler-only
speedups with the earlier Cascade Lake development runs.

## Official Gadi Sapphire Rapids performance matrix

| ID | Changed variable | Nodes | Ranks | Ranks/node | Compiler | MPI | Decomposition | Avg wall-clock / step | ClockTime | Cd | Improvement vs baseline | Validity |
| --- | --- | ---: | ---: | ---: | --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| B0-SPR-1N | official scaling point | 1 | 104 | 104 | GCC 8.5.0 site OpenFOAM v2512 | OpenMPI 4.1.7 | hierarchical `(4 13 2)`; SCOTCH not used | **8.824444 s** | 378 s | 0.43087 | 0.243× of 4N | **VALID** |
| B0-SPR-2N | official scaling point | 2 | 208 | 104 | GCC 8.5.0 site OpenFOAM v2512 | OpenMPI 4.1.7 | hierarchical `(8 13 2)`; SCOTCH not used | **4.296500 s** | 362 s | 0.33201 | 0.498× of 4N | **VALID** |
| B0-SPR | baseline | 4 | 416 | 104 | GCC 8.5.0 site OpenFOAM v2512 | OpenMPI 4.1.7 | hierarchical `(16 13 2)`; SCOTCH not used | **2.139565 s** | 336 s | 0.28231 | 0.0% | **VALID — first official baseline** |

## Official 1N / 2N / 4N scaling

Average step time is normalized because the official workloads use 40, 80, and
150 steps at 1, 2, and 4 nodes respectively. No raw `ClockTime` ratio is used
to infer scaling.

| Configuration | 1N Avg step | 2N Avg step | 4N Avg step | 2N Speedup | 4N Speedup | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| GCC 8.5.0 site OpenFOAM / OpenMPI 4.1.7 / hierarchical | **8.824444 s** | **4.296500 s** | **2.139565 s** | **2.053868×** | **4.124410×** | 104 ranks/node throughout; parallel efficiency is 102.69% at 2N and 103.11% at 4N. |

## Optimization progression

| Attempt | Change from previous | Compiler | MPI | Ranks | Decomposition | Avg wall-clock / step | Improvement | What we learned |
| --- | --- | --- | --- | ---: | --- | ---: | ---: | --- |
| B0-SPR-1N | Official 1N scaling point | GCC 8.5.0 | OpenMPI 4.1.7 | 104 | hierarchical `(4 13 2)`; SCOTCH not used | **8.824444 s** | — | Valid 40-step point; Cd 0.43087 is within the expected 40-step range. |
| B0-SPR-2N | Official 2N scaling point | GCC 8.5.0 | OpenMPI 4.1.7 | 208 | hierarchical `(8 13 2)`; SCOTCH not used | **4.296500 s** | **2.053868× vs 1N** | Valid 80-step point; Cd 0.33201 is within the expected 80-step range. |
| B0-SPR | Untuned official site-module baseline | GCC 8.5.0 | OpenMPI 4.1.7 | 416 | hierarchical `(16 13 2)`; SCOTCH not used | **2.139565 s** | 0.0% | Valid competition baseline on four SPR nodes; later rank, decomposition, affinity, compiler, and MPI experiments compare against this row. |

## Historical pre-rule Cascade Lake results

These are retained as workload-validation evidence only. They use four
Cascade Lake nodes, 192 ranks, hierarchical `(16 6 2)`, and the pre-rule
measurement convention; they are **not** an official baseline and their
797.5-second median is not a competition headline reference.

| ID | Hardware | Nodes | Ranks | Compiler | MPI | Decomposition | Avg wall-clock / step | ClockTime | Cd | Status |
| --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- | --- |
| B0-CLX | Gadi Cascade Lake | 4 | 192 | GCC 8.5 | OpenMPI 4.1.7 | hierarchical `(16 6 2)`; SCOTCH not used | Historical mean timestep: 5.144659 s (four-run median) | 802 / 1045 / 793 / 790 s; 797.5 s median | — | Pre-rule reference; R2 is correctness-valid but performance-anomalous and retained. |

## Deferred compiler build attempts

No row below is a performance result: none has produced a valid solver run on
the official workload.

| ID | Hardware / scope | Compiler | MPI | Performance | Status |
| --- | --- | --- | --- | --- | --- |
| C1 | Cascade Lake build attempt | ICC 2021.10 | OpenMPI 4.1.7 | — | ThirdParty passed; OpenFOAM build stopped on missing `wmkdepend`. |
| C2 | Cascade Lake build attempt | ICX 2025.1.1 | OpenMPI 4.1.7 | — | Build not completed. |
| C3 | Cascade Lake build attempt | ICX 2023.2.0 | OpenMPI 4.1.7 | — | Cancelled before execution. |
| S1 | Deferred compiler/MPI integration | ICC 2021.10 | Intel MPI 2021.10 | — | Deferred at OpenFOAM compiler/MPI environment integration. |

## Build and workflow provenance

Build and scheduler diagnostics are intentionally separated from the
performance-first tables above.

| ID | Build / PBS job | Commit | Build / workflow state | Failure layer | Notes |
| --- | --- | --- | --- | --- | --- |
| B0-SPR | `178149002.gadi-pbs` | `d13aea1` | PASS | — | Four SPR nodes, 416 ranks; full official chain, Time=150, final parallel completion, Cd sanity, and Exit_status=0 all passed. |
| C1 | `178141482.gadi-pbs` | — | ThirdParty PASS; OpenFOAM build stopped | L5 | Missing compiler-specific `wmkdepend`; SOURCE_ID_V2 and L4 passed. |
| C2 | `178140527.gadi-pbs` | — | Not completed | Before L5 | Same common ThirdParty-path defect; SOURCE_ID_V2 and L4 passed. |
| C3 | `178140528.gadi-pbs` | — | Cancelled | Pre-execution | Cancelled after the common ThirdParty-path defect was identified; not a compiler/build failure. |
| S1 | `178136462.gadi-pbs` | `70d6dc0` | Not completed | PBS startup / pre-build | Exit_status=127; build workflow not entered. |

Detailed official job-by-job evidence, including unsuccessful attempts, remains
in `results/official-gadi-spr/run-registry.md`.

### C1 diagnostic record

Job `178141482.gadi-pbs` reached the furthest point of the compiler builds:
ThirdParty built successfully with ICC, including SCOTCH, boost, and CGAL, then
the OpenFOAM build stopped because the compiler-specific
`platforms/tools/linux64Icc/wmkdepend` did not exist. `wmkdepend` is wmake's
own dependency generator; the site tree supplied only the GCC variant. The
common build workflow was subsequently corrected to run
`wmake/src/Allmake` and assert that the matching `wmkdepend` is executable
before it starts the OpenFOAM libraries. This is build provenance, not a
compiler-performance result.
