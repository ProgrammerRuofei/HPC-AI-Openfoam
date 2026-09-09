# Master experiment index

Every run and validation attempt in this project, with its status and enough
provenance to reproduce or explain it. This is the navigation layer: the
detailed narrative for each group lives in the linked document.

**Status vocabulary** (defined in the [root README](../README.md#7-experiment-status-vocabulary)):
`OFFICIAL` `VALID` `SCREENING` `PASS` `FAILED` `OUTLIER` `SUPERSEDED` `PENDING`

Raw evidence (PBS stdout, solver logs, checksums, `coefficient.dat`) remains
on Gadi under `/scratch/pm78/kj7183/openfoam_cpu/`. This index records what it
showed and where to find it.

---

## 1. Official Gadi Sapphire Rapids results — `OFFICIAL`

Queue `normalsr`, Intel Xeon Platinum 8470Q (2×52 cores, 8 NUMA domains of 13),
site `OpenFOAM/2512` module, GCC 8.5.0, Open MPI 4.1.7, one rank per physical
core, hierarchical decomposition, SCOTCH not used.

Detail: [`results/official-gadi-spr/run-registry.md`](official-gadi-spr/run-registry.md) ·
Scripts: [`official-gadi-spr/`](../official-gadi-spr/)

| Run | PBS job | Commit | Nodes | Ranks | Decomp. | Steps | Avg s/step | ClockTime | Cd | Exit | Status |
| --- | --- | --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | --- |
| baseline-1n | `178153587.gadi-pbs` | `bc45f06` | 1 | 104 | `(4 13 2)` | 40 | **8.824444** | 378 s | 0.43087 | 0 | `OFFICIAL` `VALID` |
| baseline-2n | `178154724.gadi-pbs` | `bc45f06` | 2 | 208 | `(8 13 2)` | 80 | **4.296500** | 362 s | 0.33201 | 0 | `OFFICIAL` `VALID` |
| baseline-4n attempt 4 | `178149002.gadi-pbs` | `d13aea1` | 4 | 416 | `(16 13 2)` | 150 | **2.139565** | 336 s | 0.28231 | 0 | `OFFICIAL` `VALID` — **baseline to beat** |
| hardware-probe | `178141693.gadi-pbs` | `8d9d2e1` | 1 | — | — | — | — | — | — | 0 | `VALID` probe — confirmed 2×52 cores, 8 NUMA, 503 GiB |
| baseline-4n attempt 1 | `178142339.gadi-pbs` | `85277f1` | 4 | 416 | `(16 13 2)` | 150 | — | — | — | cancelled | `FAILED` — operator cancelled a *running* job (~45 SU lost) |
| baseline-4n attempt 2 | `178147674.gadi-pbs` | `198ac97` | 4 | 416 | `(16 13 2)` | 150 | — | — | — | 127 | `FAILED` — `restore0Dir` is a shell function, not a binary |
| baseline-4n attempt 3 | `178148324.gadi-pbs` | `c3f6f06` | 4 | 416 | `(16 13 2)` | 150 | — | — | — | 134 | `FAILED` — `-parallel` prep steps launched without `mpirun` |

4N resource record: PBS walltime 00:13:12, cput 54:56:51, peak memory 313.7 GB,
~183 SU. 1N peak 181.3 GB; 2N peak 249.2 GB.

### Scaling, recomputed from the raw timings

Recomputed 2026-09-09 directly from the per-step values above rather than from
any previously written percentage. Definitions:
`Speedup(N) = T1 / TN`, `Parallel efficiency(N) = Speedup(N) / N`.

Speedup uses **average wall-clock time per measured step**, not ClockTime,
because the three points run 40, 80, and 150 steps. Comparing raw ClockTime
across them would be meaningless.

| Nodes | Ranks | Steps | Avg s/step (T<sub>N</sub>) | Speedup = T₁/T<sub>N</sub> | Efficiency = S/N | PBS job | Decomposition | Toolchain |
| ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 104 | 40 | 8.824444 | 1.000000 | 100.000% | `178153587.gadi-pbs` | hierarchical `(4 13 2)` | site `OpenFOAM/2512`, GCC 8.5.0, OpenMPI 4.1.7 |
| 2 | 208 | 80 | 4.296500 | **2.053868** | **102.693%** | `178154724.gadi-pbs` | hierarchical `(8 13 2)` | same |
| 4 | 416 | 150 | 2.139565 | **4.124410** | **103.110%** | `178149002.gadi-pbs` | hierarchical `(16 13 2)` | same |

The recomputed values reproduce the previously recorded 2.053868× and
4.124410× exactly. SCOTCH is not used at any point; one MPI rank per physical
core throughout.

**`superlinear scaling` — flagged, not corrected.** The measured parallel
efficiencies are **102.693%** at 2 nodes and **103.110%** at 4 nodes, i.e. mildly
above 100%.

Mild superlinear scaling is **physically plausible** for this workload:

- **Cache residency and locality.** Doubling the node count halves the cells per
  rank, so each rank's working set shrinks and a larger fraction of it is served
  from L2/L3. For a 65M-cell mesh the per-rank subdomain remains far larger than
  cache, but the resident *fraction* rises with rank count.
- **Aggregate memory bandwidth.** `simpleFoam` on a mesh this size is
  bandwidth-bound. Adding nodes adds aggregate memory bandwidth in proportion to
  the node count, which is the classic source of mild superlinearity.

**However, each SPR scaling point currently appears to have only one measurement
recorded in this repository** — one valid run at each of 1, 2, and 4 nodes.
A single measurement per point cannot separate a genuine superlinear effect from
ordinary system and run-to-run variation.

**Repeated runs at each point would be required** to distinguish true superlinear
behaviour from normal variation; a median across repeats is the value that should
carry any such claim. Until then, treat the >100% efficiencies as *observed and
unexplained-by-repetition*, not as an established property of the configuration.

No universal efficiency threshold separates "real" from "erroneous" — the
question is settled by repetition and by evidence for a mechanism, not by a
fixed cut-off. **The benchmark data is not adjusted to force efficiency below
100%.**

### Is the comparison apples-to-apples?

Verified 2026-09-09 by reading the three scripts
[`official_baseline_1n.pbs`](../official-gadi-spr/official_baseline_1n.pbs),
[`official_baseline_2n.pbs`](../official-gadi-spr/official_baseline_2n.pbs), and
[`official_baseline_4n.pbs`](../official-gadi-spr/official_baseline_4n.pbs).

**Held constant across all three points:**

| Factor | Value | How verified |
| --- | --- | --- |
| Case / workload | `/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh` | identical `SOURCE_CASE=` in all three |
| OpenFOAM version | site module v2512 | identical `module purge; module load OpenFOAM/2512` |
| Compiler / MPI | GCC 8.5.0 / Open MPI 4.1.7 (site module) | same module; registry rows agree |
| Solver | `simpleFoam -parallel` | identical final chain step |
| Preparation chain | `decomposePar` (serial) → `restore0Dir` → `renumberMesh` → `potentialFoam` → `applyBoundaryLayer -ybl 0.0450244` → `simpleFoam`, all `-parallel` steps under `mpirun` | identical six-step block, same `-ybl` value |
| Scoring / fixedIter rule | `controlDict.noWrite` copied to `controlDict`; `fvSolution.fixedIter` copied to `fvSolution`, then asserted with `cmp -s` | identical lines in all three |
| Node architecture | Xeon Platinum 8470Q Sapphire Rapids, queue `normalsr` | identical `#PBS -q normalsr`; nodes named in the registry |
| Physical-core policy | 1 MPI rank per physical core, 104 ranks/node | `ncpus`/`mem` scale exactly 104/190 GB per node |
| Decomposition family | `hierarchical`, `y=13`, `z=2` fixed | only the streamwise `x` term changes |
| Timing definition | `Average wall-clock time per time step` from the `simpleFoam` log | single extractor, [`extract_official_metrics.sh`](../official-gadi-spr/extract_official_metrics.sh) |
| Allocation gate | `test "$PBS_NNODES" = N; test "$PBS_NCPUS" = NRANKS` | present in all three |

**Changed intentionally — these are the experiment's variables:**

| Factor | 1N | 2N | 4N |
| --- | --- | --- | --- |
| Node count | 1 | 2 | 4 |
| Rank count | 104 | 208 | 416 |
| Hierarchical tuple | `(4 13 2)` | `(8 13 2)` | `(16 13 2)` |
| Iteration count | 40 | 80 | 150 |

`13` is a **forced** factor because 104 = 2³ × 13 and each SPR node has 8 NUMA
domains of 13 cores; holding `y=13, z=2` and scaling only `x` keeps node count
the single moving variable of the decomposition.

### Why average s/step, not raw ClockTime

The iteration counts differ **by design** (40 / 80 / 150), so raw ClockTime is
not comparable across the three points: 1N ran 378 s of ClockTime for 40 steps
while 4N ran 336 s for 150 steps. Dividing by the measured step count removes
that difference and leaves the quantity strong scaling is actually about — the
cost of one unit of the same work as resources increase.

ClockTime also includes per-run fixed overhead (startup, I/O, finalisation) that
does not shrink with node count. Measured here as `ClockTime − steps ×
s_per_step`: **25.0 s** at 1N, **18.3 s** at 2N, **15.1 s** at 4N. Using
ClockTime would fold that non-scaling overhead into the speedup and understate
it, while the per-step metric isolates the scaling part. It is also the official
competition metric, so the same number serves both purposes.

## 2. Phase 0 controlled repeats R1–R4 — `SUPERSEDED` as a baseline

Queue `normal`, Intel Xeon Platinum 8274 (Cascade Lake, 2×24 cores, SMT 2),
site `OpenFOAM/2512`, GCC 8.5.0, Open MPI 4.1.7, 4 nodes × 48 ranks = 192,
hierarchical `(16 6 2)`, 150 SIMPLE steps, no explicit binding.

These were run **before the official rules were published**. They are
reproducibility evidence, not a competition baseline, and must never be
compared directly against the Sapphire Rapids numbers above.

Detail: [`phase0/README.md`](../phase0/README.md) ·
Structured rows: [`metrics.csv`](metrics.csv) ·
Report: [`RESULTS.md`](RESULTS.md) · Scripts: [`phase0/`](../phase0/)

| Run | PBS job | ClockTime | ExecutionTime | Mean s/step | SD s/step | Steps | PBS walltime | Exit | Status |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- |
| R1 | `178063948.gadi-pbs` | 802 s | 781.85 s | 5.136668 | 0.027106 | 149 | 17m54s | 0 | `VALID` |
| R2 | `178073349.gadi-pbs` | 1045 s | 1025.47 s | 6.842763 | 0.310174 | 149 | 21m52s | 0 | `VALID` `OUTLIER` — sustained slowdown, cause unexplained, **retained** |
| R3 | `178073350.gadi-pbs` | 793 s | 773.28 s | 5.152651 | 0.023207 | 149 | 17m48s | 0 | `VALID` |
| R4 | `178107780.gadi-pbs` | 790 s | 770.84 s | 5.129230 | 0.023586 | 149 | 17m40s | 0 | `VALID` — configured PBS stdout artifact absent; not repaired |

**Representative value: ClockTime median 797.5 s** (all four repeats, R2
retained), mean timestep 5.144659 s. The median is used deliberately instead
of the fastest run.

This is the correct comparison reference for the pending C1 65M screening run,
because C1 uses the same hardware, rank count, and decomposition.

## 3. Compiler / toolchain screening

Goal: beat the GCC 8.5.0 site module. Evidence for the attempt: the site
`simpleFoam` binary reports `GCC: (GNU) 8.5.0 20210514`, which predates
`-march=sapphirerapids` (GCC 11) and emits no AVX-512 tuning for the scored
hardware.

Detail: [`compiler-screening-summary.md`](compiler-screening-summary.md) ·
Scripts: [`builds/build-scripts/`](../builds/build-scripts/)

### 3.1 C1 — ICC Classic 2021.10.0 + OpenMPI 4.1.7

The only candidate that has produced a working binary.

| Stage | PBS job | Commit | Outcome | Status |
| --- | --- | --- | --- | --- |
| Build attempt 1 | `178140361.gadi-pbs` | — | Workflow referenced a non-existent nested `ThirdParty/Allwmake` path | `FAILED` (L5 setup) |
| Build attempt 2 | `178141482.gadi-pbs` | — | ThirdParty built (SCOTCH, boost, CGAL); stopped on missing `platforms/tools/linux64Icc/wmkdepend` | `FAILED` (L5) |
| Build attempt 3 | `178163598.gadi-pbs` | `bc45f06` | ICC did not expose the C++17 aligned-new declarations `ListPolicy` needs | `FAILED` (L6) |
| Build attempt 4 | `178166039.gadi-pbs` | `421908e` | Aligned-new fix held; ICC then rejected `CircularBuffer::toGlobal`'s `const` value parameter | `FAILED` (L6) |
| **Build attempt 5** | `178166771.gadi-pbs` | `cfc6c95` (Gadi) | `BUILD_VALIDATION_PASS` on Cascade Lake node `gadi-cpu-clx-1303`; walltime 01:26:52, peak 97.5 GiB | `PASS` |
| Runtime archive repair | `178252413.gadi-pbs` | *no commit — script untracked at submission* | `C1_RUNTIME_ARCHIVE_V2_PASS` — added the authoritative `bin/` tree + reviewed `META-INFO/api-info`, re-hashed; no rebuild, original archive not overwritten | `PASS` |
| Runtime smoke attempt 1 | `178249214.gadi-pbs` | — | SHA and OpenMPI provenance passed; archive lacked `bin/foamEtcFile` and `bin/foamCleanPath` | `FAILED` |
| Runtime smoke attempt 2 | `178254935.gadi-pbs` | *no commit — script untracked at submission* | `C1_RUNTIME_SMOKE_PASS` — see the detail table below | `PASS` |
| 65M attempt 1, 4N/192r | `178563232.gadi-pbs` | `37c842f` | Exit 7 after 2 s on an over-broad `env \| grep '^I_MPI_'` gate; `intel-compiler` legitimately exports `I_MPI_CC/CXX/F77/F90`. Harness defect, not an environment problem | `FAILED` |
| 65M attempt 2, 4N/192r | `178564210.gadi-pbs` | `37c842f` | Exit 271 (SIGTERM via `qdel`) after 00:32:36; 192 ranks deadlocked at 100% CPU before timestep 1 with `exec(wmake, ...) failed` — the runtime could not JIT-compile the `wallClockTimeStatistics` coded functionObject | `INVALID` — runtime dynamicCode/wmake capability missing before solver timestep loop |
| dynamicCode prepare attempt 1 | `178567913.gadi-pbs` | `9ed6d1f` | Reached the compile and failed on the same ICC aligned-new defect as build attempt 3 | `FAILED` (L6) |
| dynamicCode prepare attempt 2 | `178568099.gadi-pbs` | `5471b4f` | `C1_DYNAMICCODE_PREPARE_PASS` — built the ICC library with the reviewed `-D__cpp_aligned_new=201606L` workaround | `PASS` |
| dynamicCode no-JIT smoke | `178568271.gadi-pbs` | `5471b4f` | `C1_DYNAMICCODE_SMOKE_PASS` — library loads on a runtime with no wmake/src; zero JIT markers | `PASS` |
| **65M benchmark, 4N/192r** | **`178570241.gadi-pbs`** | **`e9f60aa`** | **`C1_65M_SCREEN_PASS`** — see the result table below | **`VALID SCREENING`** |

#### C1 65M screening result — `178570241.gadi-pbs` `VALID SCREENING`

**Not an official result.** Gadi `normal` (Cascade Lake), not `normalsr`
Sapphire Rapids, so it may not be quoted as a competition figure.

| Field | Value |
| --- | --- |
| PBS job | `178570241.gadi-pbs` |
| Git commit | `e9f60aad7c0d8e8543ba3645f9b12ee795206de8` |
| Queue / platform | `normal` / Intel Xeon Platinum 8274 @ 3.20 GHz (Cascade Lake) |
| Nodes | 4 — `gadi-cpu-clx-1956/1963/1964/1969` |
| Ranks | 192, 48 per node |
| Compiler | ICC Classic 2021.10.0 |
| MPI | OpenMPI 4.1.7 (`/apps/openmpi/4.1.7`) |
| OpenFOAM | v2512, `linux64IccDPInt32Opt`, `FOAM_MPI=sys-openmpi` |
| Decomposition | hierarchical `(16 6 2)` |
| dynamicCode artifact | `.../c1-icc2021-openmpi417/dynamiccode-artifact/libwallClockTimeStatistics_6e8d888ad28997c1bc9eebd1c08a1a15774516a4.so` |
| dynamicCode SHA256 | `e772e9d2af426f4d3997b88d07ea8f06c95b16b89efb0cb6d5ec9604c95a211b` |
| Completion token | `C1_65M_SCREEN_PASS` |
| **Average wall-clock time per time step** | **5.281516726617448 s** |
| Standard deviation | 0.02258265344653323 s (0.428% of mean) |
| Measured time steps | 149 |
| ExecutionTime / ClockTime | 790.87 s / 802 s |
| Cd | 0.28120622 — inside the expected 150-step range 0.28-0.29 |
| PBS walltime | 00:18:01 |
| Peak memory | 256,631,488 kb (about 244.7 GiB) |
| SU | about 115 (256 reserved at the 00:40:00 request) |
| Exit status | 0 |

All seven acceptance conditions passed: `Exit_status = 0`, `C1_65M_SCREEN_PASS`,
`Time = 150`, `Finalising parallel run`, `End`, every provenance/runtime/workload
gate, and zero dynamicCode JIT (`Creating new library` = 0, `Invoking wmake
libso` = 0, `Could not load` = 0, with the functionObject reported as used).

The correct Cd is a **correctness** confirmation: the ICC build reproduces the
same physics as the GCC baseline (official SPR 4N recorded 0.28231).

##### Comparison against the controlled Phase 0 GCC baseline

The primary comparison is the controlled Phase 0 Cascade Lake 4N/192-rank GCC
reference, **5.144659 s/step** — identical hardware, rank count and
decomposition, so compiler is the only changed variable.

```
speed ratio = 5.144659 / 5.281516727 = 0.974087
improvement = (5.144659 - 5.281516727) / 5.144659 x 100 = -2.660 %
```

**C1 is approximately 2.66% slower** than the GCC baseline on this metric.
Against each individual valid Phase 0 run: R1 -2.82%, R3 -2.50%, R4 -2.97%.
ClockTime 802 s versus the 797.5 s median is 0.56% slower, but ClockTime is
secondary here: this harness carries runtime staging overhead Phase 0 did not,
and the precompiled dynamicCode library removes a JIT compile the GCC baseline
did pay, both of which flatter C1 on ClockTime without affecting the per-step
metric.

Qualifications, all of which limit how far this may be taken:

- **One valid C1 performance run only.** Phase 0 has four.
- This is a **negative screening signal**, not a statistical conclusion. The
  within-run standard deviation is tight (0.428%, and the functionObject's own
  check reports `Minimum number of measured time steps for 2% error at 95%
  confidence level = 0`), and the gap is consistent against all three
  tightly-clustered valid GCC runs — but run-to-run variation is a separate
  matter, and Phase 0's R2 `OUTLIER` shows a single run can deviate by 33%.
- **Not directly comparable** to the official SPR 416-rank result
  (2.139565 s/step): different CPU architecture and rank policy.
- This says nothing about ICC in general, only about **this exact
  configuration**: ICC Classic 2021.10 at `-O3` with no architecture targeting,
  on Cascade Lake, at 4N/192 ranks with hierarchical `(16 6 2)`.

##### Verified compiler flags — the comparison is fair on optimization level

Read from the C1 build log of job `178166771` (85 MB) and from the OpenFOAM
v2512 wmake rules:

| | GCC (Phase 0, site module) | C1 (ICC) |
| --- | --- | --- |
| Optimization | `-O3` (`linux64Gcc/c++Opt`) | `-O3` — **5,878 occurrences** in the build log |
| `-O2` / `-O1` | — | **0 occurrences** |
| `-xCORE-AVX512` | not available in `linux64Gcc` | **0 occurrences** |
| `-xCORE-AVX2` | not available in `linux64Gcc` | **0 occurrences** |
| `-march=` / `-xHost` | none | **0 occurrences** |
| Observed ISA | `zmm=0 / ymm=0` — no AVX-512 | no architecture targeting requested |

Flag resolution for ICC under `WM_COMPILE_OPTION=Opt`:
`General/Icc/c++` sets `c++OPT := -O2`, then `sinclude
General/common/c++Opt` overrides it to `-O3`, then `linux64Icc/c++Opt` is
`sinclude`d but **does not exist** and is silently skipped. Net effect `-O3`,
confirmed by the build log.

**Therefore the current GCC-versus-ICC screening comparison is fair with respect
to optimization level and to the absence of architecture targeting.** Neither
build vectorizes for the host.

##### Correction: ICC 2021.10 does support Sapphire Rapids targeting

Verified directly with `icpc -help` under `intel-compiler/2021.10.0` on Gadi.
Supported `-x` targets include **`SAPPHIRERAPIDS`**, `ICELAKE-SERVER`,
`SKYLAKE-AVX512` and `CORE-AVX512`.

Any earlier suggestion that only the ICX candidates (C2/C3) could target
Sapphire Rapids is **incorrect and withdrawn**. Compiler vintage is not what
gates architecture targeting here.

OpenFOAM v2512 already ships the rules to use it:

| Rule file | Flags | Present |
| --- | --- | --- |
| `linux64Icc/c++OptAVX512` | `-O3 -xCORE-AVX512` | yes |
| `linux64Icc/c++OptAVX2` | `-O3 -xCORE-AVX2` | yes |
| `linux64Icx/c++OptAVX512` / `c++OptAVX2` | equivalent for ICX | yes |
| `linux64Gcc/c++OptAVX512` or `AVX2` | — | **absent**; GCC has only `c++Opt` |

**C1 was built with ordinary `Opt`, not `OptAVX512`.** The AVX-512 headroom
argument has therefore never been tested. Note also that Cascade Lake supports
AVX-512, so this is testable on the `normal` queue; `-xSAPPHIRERAPIDS` is not,
because a Cascade Lake node cannot execute Sapphire Rapids code.

##### Scaling status — not performed

**C1 scaling has NOT been performed.** C1 has exactly one performance point:
4 nodes, 192 ranks. **Do not construct an ICC scaling curve from it.**

The historical Cascade Lake 1N and 2N runs (`177590568`, 822 s, 1 node /
48 ranks / 40 steps; `177597315`, 831 s, 2 nodes / 96 ranks / 80 steps) are
**not** controlled equivalents of Phase 0 R1-R4: different rank counts,
different iteration counts, and pre-rule uncontrolled conditions. They must not
be combined into a C1-versus-GCC scaling comparison.

The official 1N/2N/4N SPR series is a different architecture and a different
ranks-per-node policy and must remain separate from any Cascade Lake
compiler screening.

#### C1 runtime smoke attempt 2 — `178254935.gadi-pbs` `PASS`

The validation that closed the C1 runtime chain. It is a **correctness and
isolation check on a tiny tutorial case**; it produces no performance number
and confers no official status.

| Field | Value |
| --- | --- |
| PBS job | `178254935.gadi-pbs` |
| Commit | *none — the smoke script was untracked in the Gadi clone at submission time* |
| Exit status | `0` |
| Node | `gadi-cpu-clx-2372` (Cascade Lake, queue `normal`) |
| Allocation | 1 node / 5 CPUs / 5 MPI ranks |
| PBS walltime | 14 s |
| Case | `pitzDaily_fused` (OpenFOAM tutorial, **not** the 65M competition workload) |
| Solver progress | reached `Time = 200` (the tutorial's own `endTime`) |
| Gates passed | `blockMesh`; `decomposePar`; 5-rank MPI rank probe; JOBFS-staged C1 runtime and library isolation |
| Completion token | `C1_RUNTIME_SMOKE_PASS` |
| Toolchain | ICC Classic 2021.10.0 + OpenMPI 4.1.7 + OpenFOAM v2512 |

The script emits `C1_RUNTIME_SMOKE_PASS` only after every gate succeeds,
including its `Finalising parallel run` and `^End$` checks, so the token
implies those passed. Script:
[`smoke_c1_icc2021_openmpi417.pbs`](../builds/build-scripts/c1-icc2021-openmpi417/smoke_c1_icc2021_openmpi417.pbs).

> **Provenance caveat, recorded rather than hidden.** Both `178252413` and
> `178254935` were submitted from scripts that were **untracked** in the Gadi
> clone, so neither run can cite a Git commit. The scripts exist on the Mac
> (`repair_c1_runtime_archive_v2.pbs` staged, `smoke_c1_icc2021_openmpi417.pbs`
> staged + modified) but are not yet in any commit on either side. Committing
> them is what makes this chain fully reproducible — see lesson L11.

**C1 identity and checksums** (pinned inside the benchmark script):

| Field | Value |
| --- | --- |
| Stack | ICC Classic 2021.10.0 + OpenMPI 4.1.7 + OpenFOAM v2512 |
| Platform string | `linux64IccDPInt32Opt` |
| Source identity `SOURCE_ID_V2` | `5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db` |
| `simpleFoam` SHA256 | `73a3260e2dfec970a9b76de990983fffd4ed8a47363aa497a89560f5c684533d` |
| runtime-v2 archive SHA256 | `16f5836b3084a284eb67e5e560d5ca245c29be14febec036b2e7f0cf7f4dc7eb` |
| MPI linkage | `libmpi.so.40` → `/apps/openmpi/4.1.7` (external module, not bundled) |
| ICC compatibility patches | C++17 aligned-new feature macro; `CircularBuffer::toGlobal` value-parameter declaration |

**65M workload identity** — the six authoritative SHA256 values, identical
across Phase 0 R1–R4 and hard-gated by the pending benchmark script:

| File | SHA256 |
| --- | --- |
| `Allrun.gadi` | `2a02ec456ce880b2242d566da6c5b28fae1aa99218169260030cd53f5a662ec3` |
| `system/include/caseDefinition` | `1da44731f5f723c1b8471bee6c6186c6f402f63154f84cacd26bf27e30e6a6c6` |
| `system/controlDict.noWrite` | `ce4ec0f52bcc88eea8402b454940dc5aad1f31dea6441e7d98413b651427ef06` |
| `system/fvSchemes` | `064bb50455d37a7edd2c0fb24bbe30baaf851623f0250d550450c10e407889b3` |
| `system/fvSolution` | `5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba` |
| `system/fvSolution.fixedIter` | `5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba` |

`fvSolution` and `fvSolution.fixedIter` share a hash because the baseline
protocol requires the fixed-iteration solution to be the active one.

### 3.2 Other candidate stacks

| ID | Stack | PBS job | Outcome | Status |
| --- | --- | --- | --- | --- |
| C2 | ICX 2025.1.1 + OpenMPI 4.1.7 | `178140527.gadi-pbs` | Stopped on the common ThirdParty/build-path defect; `SOURCE_ID_V2` and L4 passed | `FAILED UNDER EARLIER BUILD PATH — NOT RETESTED AFTER bc45f06` |
| C3 | ICX 2023.2.0 + OpenMPI 4.1.7 | `178140528.gadi-pbs` | Cancelled once the same common defect was identified — never a compiler failure | `FAILED UNDER EARLIER BUILD PATH — NOT RETESTED AFTER bc45f06` |
| S1 | ICC 2021.10 + **Intel MPI** 2021.10 | `178136462` / `178137625` / `178137861` / `178138805` | Four-layer debug; deferred at OpenFOAM compiler/MPI environment integration | `FAILED` — see [`s1-autonomous-debug-summary.md`](s1-autonomous-debug-summary.md) |
| S2 | ICX 2023.2.0 + Intel MPI | — | Out of scope while S1 is blocked | `PENDING` |
| S3 | ICX 2025.1.1 + Intel MPI | — | Out of scope while S1 is blocked | `PENDING` |
| A1 | GCC 11.2 + Cray MPICH, private source | — | ASPIRE2A private-source rebuild; separates a site-binary issue from the multi-node failure. Scripts untracked | `PENDING` |

> **C2 and C3 status is stale, not disproven.** Both stopped on the common
> ThirdParty/build-path defect that was subsequently repaired in `bc45f06`
> (run `wmake/src/Allmake` first and assert the matching `wmkdepend`; lesson
> L5). Neither has been retried since that fix, so their present viability is
> **unknown**. This is not a claim that they will now build.

### 3.3 Next experiment candidates — none started

Recorded for planning only. **No build or benchmark has been submitted for any
of these.**

| | Candidate | What changes | Why it is interesting |
| --- | --- | --- | --- |
| **A** | **ICC `OptAVX512`** | Same ICC 2021.10, same Cascade Lake hardware, same ranks and decomposition; only `WM_COMPILE_OPTION` changes from `Opt` to `OptAVX512` (`-O3 -xCORE-AVX512`) | Isolates the benefit of **architecture targeting**, the variable the C1 screening never tested. The rule file already exists; no new compiler is needed |
| B | GCC AVX-512 | Would need a new `linux64Gcc/c++OptAVX512` rule (GCC 8.5 syntax, e.g. `-march=skylake-avx512`) — it does not ship | Only needed later, to compare compilers at *matched* architecture targeting. Without it, "ICC+AVX512 vs GCC generic" measures vectorization, not compiler |
| C | C2 / C3 retry | Rebuild the ICX candidates on the repaired build path | Their failure status is stale after `bc45f06`; viability is currently unknown |
| D | ICC scaling (1N/2N) | Add C1 points at 1 and 2 nodes | **Lower priority**: no controlled GCC 1N/2N Cascade Lake reference exists to compare against, so the design question must be settled first |

## 4. ASPIRE2A (NSCC) — `FAILED` / blocked

A separate cluster and a separate line of work. Single-node runs succeed;
every multi-node run dies with `signal 7` **after** OpenFOAM prints `End` and
`Finalising parallel run`, so the solver completes and the failure is in
teardown.

Detail: [`planning/aspire2a-nscc-support-draft.md`](../planning/aspire2a-nscc-support-draft.md) ·
[`MANUAL_INSPECTION_ERROR.md`](../MANUAL_INSPECTION_ERROR.md) ·
Scripts: [`experiments/`](../experiments/)

| Test | Allocation | PBS job | Outcome | Status |
| --- | --- | --- | --- | --- |
| T1 | 1 node × 128 ranks | — | Completed | `PASS` |
| T4 | 2 nodes × 64 ranks | — | `signal 7` after `End` | `FAILED` |
| T2 | 2 nodes × 128 ranks | — | `signal 7` after `End` | `FAILED` |
| baseline v2 | 4 nodes × 128 ranks (512) | `15811806.pbs101` | rank 100 `signal 7` during `renumberMesh`; exit 143, 68 s | `FAILED` |

T1 and T4 use the **same total rank count** with different node counts, so the
evidence supports `MULTI-NODE / INTER-NODE PALS-MPI RUNTIME SUSPECT` rather
than a total-rank limit. No OpenFOAM fatal error, NaN, or explicit MPI error
was found. `MANUAL_INSPECTION_ERROR.md` remains `OPEN`.

Current ASPIRE2A blocker: the documented persistent SSH master accepts the
control check but no command channel returns.

## 5. Historical pre-rule Gadi runs — `SUPERSEDED`

| Run | PBS job | Nodes | Ranks | Steps | ClockTime | Note |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| gadi 1N baseline | `177590568.gadi-pbs` | 1 | 48 | 40 | 822 s | Pre-rule Cascade Lake development |
| gadi 2N baseline | `177597315.gadi-pbs` | 2 | 96 | 80 | 831 s | Pre-rule Cascade Lake development |
| gadi 4N historical | `177602742.gadi-pbs` | 4 | 192 | 150 | **787 s** (ExecutionTime 776.52 s) | Source of the historical `drivaer_4n.pbs` protocol |

Retained as workload-validation evidence and as the origin of the
`Allrun.gadi` protocol reused by Phase 0. Not comparable with official results.
Raw solver-log paths are recorded in
[`workflow/gadi-cluster-config.md`](../workflow/gadi-cluster-config.md).

> **787 s is not a Phase 0 number.** It is this single uncontrolled 4-node run.
> The Phase 0 controlled repeats are 802 / 1045 / 793 / 790 s, so their range is
> **790-1045 s** and their median is 797.5 s. A statement of the Phase 0 range
> as "787-1045 s" is a conflation of the two; one such instance was corrected in
> `planning/official-4n-optimization-matrix.md` on 2026-09-09.

> **Two different Cascade Lake step times — both correct, do not merge them.**
> `5.174129850805368 s/step` is the mean measured timestep of the **single
> historical run** `177602742.gadi-pbs` above, recorded in
> [`phase0/README.md`](../phase0/README.md) §7 alongside its 787 s ClockTime.
> `5.144659 s/step` is the **Phase 0 four-run median** (R1-R4). Both are
> verified from repository evidence; they measure different things.
>
> [`official-gadi-spr/run-registry.md`](official-gadi-spr/run-registry.md)
> correctly cites the historical 5.174 value and derives "2.42x slower" against
> the official 4N result — recomputed, `5.174 / 2.139565 = 2.4182x`, so the
> registry is right. Against the Phase 0 median the ratio would instead be
> `5.144659 / 2.139565 = 2.4045x`. Quote whichever reference you name, and name
> it.
