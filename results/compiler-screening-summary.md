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
| C1-CLX | Gadi Cascade Lake | 4 | 192 | ICC Classic 2021.10.0 | OpenMPI 4.1.7 | hierarchical `(16 6 2)`; SCOTCH not used | **5.281516726617448 s** (single run, SD 0.02258 s over 149 steps) | 802 s | 0.28120622 | `VALID SCREENING`, job `178570241`, commit `e9f60aa`. **2.66% slower** than the B0-CLX GCC median. One run only; negative screening signal, not a statistical conclusion. Not comparable with the SPR rows. |

## Compiler build candidates

No row below is an official performance result. Build and runtime validation
do not supply an official `normalsr` timing measurement.

| ID | Hardware / scope | Compiler | MPI | Performance | Status |
| --- | --- | --- | --- | --- | --- |
| C1 | Cascade Lake build/runtime artifact | ICC 2021.10 | OpenMPI 4.1.7 | **5.281516726617448 s/step** (`SCREENING`, Cascade Lake 4N/192r, job `178570241`) | **BUILD PASS**, **RUNTIME ARCHIVE V2 PASS** (`178252413`), **RUNTIME SMOKE PASS** (`178254935`), **65M SCREENING VALID** (`178570241`); still **no official `normalsr` result**. |
| C2 | Cascade Lake build attempt | ICX 2025.1.1 | OpenMPI 4.1.7 | — | FAILED UNDER EARLIER BUILD PATH — NOT RETESTED AFTER `bc45f06`; present viability unknown. |
| C3 | Cascade Lake build attempt | ICX 2023.2.0 | OpenMPI 4.1.7 | — | FAILED UNDER EARLIER BUILD PATH — NOT RETESTED AFTER `bc45f06`; present viability unknown. |
| S1 | Deferred compiler/MPI integration | ICC 2021.10 | Intel MPI 2021.10 | — | Deferred at OpenFOAM compiler/MPI environment integration. |

## Build and workflow provenance

Build and scheduler diagnostics are intentionally separated from the
performance-first tables above.

| ID | Build / PBS job | Commit | Build / workflow state | Failure layer | Notes |
| --- | --- | --- | --- | --- | --- |
| B0-SPR | `178149002.gadi-pbs` | `d13aea1` | PASS | — | Four SPR nodes, 416 ranks; full official chain, Time=150, final parallel completion, Cd sanity, and Exit_status=0 all passed. |
| C1 | `178140361.gadi-pbs` | — | Source identity PASS; build stopped | L5 setup | Common workflow referenced a non-existent nested `OpenFOAM-v2512/ThirdParty/Allwmake` path. |
| C1 | `178141482.gadi-pbs` | — | ThirdParty PASS; OpenFOAM build stopped | L5 | Missing compiler-specific `wmkdepend`; SOURCE_ID_V2 and L4 passed. |
| C1 | `178163598.gadi-pbs` | `bc45f06` | ThirdParty PASS; OpenFOAM build stopped | L6 | ICC 2021.10 did not expose the C++17 aligned-new declarations required by `ListPolicy`; no runtime artifact. |
| C1 | `178166039.gadi-pbs` | `421908e` | ThirdParty PASS; OpenFOAM build stopped | L6 | The aligned-new workaround passed its former failure point; ICC then propagated the `const` value-parameter declaration of `CircularBuffer::toGlobal`, producing non-modifiable-lvalue errors. |
| C1 | `178166771.gadi-pbs` | `cfc6c9514024f07713b3f0664633b3118387e3e3` | **BUILD_VALIDATION_PASS** | — | ICC/OpenMPI candidate runtime produced on one Cascade Lake build node. This is not an official performance result. |
| C2 | `178140527.gadi-pbs` | — | Not completed | Before L5 | Same common ThirdParty-path defect; SOURCE_ID_V2 and L4 passed. |
| C3 | `178140528.gadi-pbs` | — | Cancelled | Pre-execution | Cancelled after the common ThirdParty-path defect was identified; not a compiler/build failure. |
| C1 | `178252413.gadi-pbs` | *untracked script* | **C1_RUNTIME_ARCHIVE_V2_PASS** | — | Runtime archive closure: added the authoritative v2512 `bin/` tree and reviewed `META-INFO/api-info`, re-hashed. No rebuild; the original archive was not overwritten. |
| C1 | `178254935.gadi-pbs` | *untracked script* | **C1_RUNTIME_SMOKE_PASS** | — | Five-rank `pitzDaily_fused` correctness/isolation smoke on `gadi-cpu-clx-2372`; Exit_status=0, 14 s. Not a performance result. |
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

### C1 successful build and runtime evidence

Candidate C1 is ICC 2021.10.0 with OpenMPI 4.1.7 and OpenFOAM v2512. The
successful PBS build ran on Cascade Lake node `gadi-cpu-clx-1303`; the build
node is acceptable for artifact production but supplies no official
competition timing.

| Field | Evidence |
| --- | --- |
| PBS job | `178166771.gadi-pbs` |
| Gadi build commit | `cfc6c9514024f07713b3f0664633b3118387e3e3` |
| Content-equivalent local commit | `1765c86b47ad937e52504fdc17319311a8e7562c` |
| Exit status | `0` |
| PBS walltime | `01:26:52` |
| Peak memory | `102240748 KiB` (about 97.5 GiB) |
| SOURCE_ID_V2 | Authoritative and JOBFS staged values both matched `5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db` |
| ICC compatibility fixes | C++17 aligned-new feature macro; staged `CircularBuffer::toGlobal` value-parameter declaration correction |
| `simpleFoam` | ELF x86-64, dynamically linked, not stripped; validation PASS |
| `simpleFoam` SHA256 | `73a3260e2dfec970a9b76de990983fffd4ed8a47363aa497a89560f5c684533d` |
| Runtime archive | `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/c1-icc2021-openmpi417/runtime-archive/c1-icc2021-openmpi417.178166771.gadi-pbs.tar.gz` |
| Runtime archive SHA256 | `8362364c1dbe44f53a2e9db213d2ef2eb378a3cbb38e7d38a40457abcac2d825` |
| Runtime contents | ICC platform `linux64IccDPInt32Opt`, validated `simpleFoam`, OpenFOAM libraries, and `sys-openmpi` Pstream libraries present |
| MPI linkage | `libmpi.so.40` resolves to `/apps/openmpi/4.1.7`; OpenMPI itself is an external Gadi module dependency and is not bundled in the archive |
| Runtime smoke attempt 1 | `178249214.gadi-pbs`: archive and binary SHA plus OpenMPI 4.1.7 provenance passed; runtime setup stopped before MPI because the archive omitted `OpenFOAM-v2512/bin/foamEtcFile` and `foamCleanPath` |
| Runtime archive v2 repair | `178252413.gadi-pbs`: **C1_RUNTIME_ARCHIVE_V2_PASS**. Added only the authoritative v2512 `bin/` tree and the reviewed `META-INFO/api-info`; re-hashed. No rebuild; the original archive was preserved. Submitted from an untracked script, so no commit provenance |
| runtime-v2 archive SHA256 | `16f5836b3084a284eb67e5e560d5ca245c29be14febec036b2e7f0cf7f4dc7eb` |
| Runtime smoke attempt 2 | `178254935.gadi-pbs`: **C1_RUNTIME_SMOKE_PASS**. Node `gadi-cpu-clx-2372`, 1 node / 5 CPUs / 5 ranks, Exit_status 0, walltime 14 s, `pitzDaily_fused` reached `Time = 200`. `blockMesh`, `decomposePar`, the five-rank MPI probe, and JOBFS-staged runtime/library isolation all passed. Submitted from an untracked script, so no commit provenance |
| Next validation | The 65M Cascade Lake screening benchmark (4 nodes / 192 ranks, hierarchical `(16 6 2)`) is prepared but **not submitted**. No official `normalsr` C1 result exists or has been attempted |

The archive-member `simpleFoam` was streamed directly from the tarball and
re-hashed as `73a3260e...`, matching the build evidence. The archive contains
414 ICC-platform entries, including 136 shared-library entries and three
`sys-openmpi` entries. No official 65M or Cascade Lake performance benchmark
was submitted as part of this build validation.

The prepared correctness-only smoke definition is
`builds/build-scripts/c1-icc2021-openmpi417/smoke_c1_icc2021_openmpi417.pbs`.
It retains the trusted five-rank `pitzDaily_fused` decomposition and requests
one normal-queue allocation with 5 CPUs, 10 GB memory, 5 GB JOBFS, and a
10-minute walltime. Attempt 1 stopped after 10 seconds with `Exit_status=1`
when `etc/bashrc` proved that the runtime archive lacked the OpenFOAM `bin/`
support scripts. Archive SHA, binary SHA, and OpenMPI 4.1.7 provenance had
already passed. It verifies archive and binary hashes, candidate-path and
`ldd` closure, OpenMPI 4.1.7 provenance, five-rank launch, and normal solver
completion. It records no performance result.

The low-cost archive-v2 repair then ran as `178252413.gadi-pbs` and returned
**C1_RUNTIME_ARCHIVE_V2_PASS**: it added only the authoritative v2512 `bin/`
tree and reviewed API metadata, did not rebuild OpenFOAM, and did not overwrite
the original archive. Smoke attempt 2 (`178254935.gadi-pbs`) then returned
**C1_RUNTIME_SMOKE_PASS** on `gadi-cpu-clx-2372` in 14 s with Exit_status 0.

The C1 runtime chain is therefore closed: **build PASS -> archive PASS ->
smoke PASS**. None of those steps produces a timing. The 65M screening
benchmark has since run as job `178570241` and is recorded below and in
[`results/experiment-index.md`](experiment-index.md); it is a `SCREENING`
result on Cascade Lake and still not an official `normalsr` result.

## Compiler flags actually used, and the untested AVX-512 variable

Verified from the C1 build log (job `178166771`, 85 MB) and the OpenFOAM v2512
wmake rules on Gadi.

| | GCC 8.5.0 (site module) | C1 ICC 2021.10.0 |
| --- | --- | --- |
| Optimization | `-O3` (`linux64Gcc/c++Opt`) | `-O3` — 5,878 occurrences in the build log |
| `-O2` / `-O1` | — | 0 occurrences |
| `-xCORE-AVX512` / `-xCORE-AVX2` | rule files do not exist for `linux64Gcc` | 0 occurrences |
| `-march=` / `-xHost` | none | 0 occurrences |
| Observed ISA in the shipped binary | `zmm=0 / ymm=0` — no AVX-512 | no architecture targeting requested |

For ICC under `WM_COMPILE_OPTION=Opt` the flag resolves as: `General/Icc/c++`
sets `c++OPT := -O2`; `sinclude General/common/c++Opt` overrides it to `-O3`;
`linux64Icc/c++Opt` is `sinclude`d but does not exist and is silently skipped.
Net effect `-O3`, as the build log confirms.

**The GCC-versus-ICC screening comparison is therefore fair with respect to
optimization level and to the absence of architecture targeting.** Neither
build vectorizes for the host.

### Correction — ICC 2021.10 does support Sapphire Rapids targeting

Verified with `icpc -help` under `intel-compiler/2021.10.0`: the supported `-x`
targets include **`SAPPHIRERAPIDS`**, `ICELAKE-SERVER`, `SKYLAKE-AVX512` and
`CORE-AVX512`.

Any earlier statement that only the ICX candidates C2/C3 could target Sapphire
Rapids is **incorrect and withdrawn**. Compiler vintage is not what gates
architecture targeting here.

OpenFOAM v2512 already ships `linux64Icc/c++OptAVX512` (`-O3 -xCORE-AVX512`)
and `linux64Icc/c++OptAVX2`, with equivalents under `linux64Icx`. There is no
AVX variant for `linux64Gcc`. **C1 was built with ordinary `Opt`, not
`OptAVX512`, so the AVX-512 headroom argument has never been tested.** Cascade
Lake supports AVX-512, so this is testable on the `normal` queue;
`-xSAPPHIRERAPIDS` is not, since a Cascade Lake node cannot execute Sapphire
Rapids code.

### Scaling status

**C1 scaling has not been performed.** C1 has one performance point only:
4 nodes, 192 ranks. No ICC scaling curve may be constructed from it. The
historical Cascade Lake 1N/2N runs are not controlled equivalents of Phase 0
R1-R4 and must not be combined with C1 into a scaling comparison; the official
SPR 1N/2N/4N series is a different architecture and ranks-per-node policy and
stays separate.

Candidate next experiments are listed in
[`experiment-index.md`](experiment-index.md) section 3.3. **None has been
started.**


---

## Status as of 2026-09-10 — profiling closes the compiler branch

The ICC comparison anchor `5.144659 s/step` is a **`HISTORICAL CLX GCC
REFERENCE`** — the median of four repeats with one retained slowdown outlier
(R2, `178073349`, 6.842763 s/step). It is not a strict paired compiler A/B
experiment, so the ICC generic result (`178570241`, 5.281517 s/step,
**2.66% slower**) carries **MEDIUM** confidence, not high.

A valid runtime profile of the ICC generic configuration
(`178677055.gadi-pbs`, commit `b6272eae`, `PROFILING VALID`) shows IPC ≈ 1.0,
63.12% of cycles stalled and 33.64% of cycles attributed directly to L3-miss
stalls, with 87.90% of retired FP arithmetic elements still scalar. Architecture
targeting (`OptAVX512`) does generate substantial 256-bit SIMD and zero 512-bit
arithmetic, but its smoke run fails with SIGFPE from an unmasked `vdivpd` on
zero-filled tail lanes under the shipped `-fp-trap=common`.

Conclusion: **arithmetic width is probably not the dominant bottleneck**, so
the ICC architecture-targeting branch is paused. Full detail, raw counters,
sampling limitations and the measured/inferred/unknown split are in
`results/experiment-index.md` under *Valid runtime profiling — 2026-09-10*.
Meeting material: `artifacts/meeting-2026-09-10/`.
