# OpenFOAM HPC Competition — Control Repository

> **查近期记录请先看 [项目导航](PROJECT-INDEX.md)：[ASPIRE2A](planning/aspire2a-guide.md) / [Gadi](planning/gadi-guide.md)。** 本页下方保留早期项目快照；其中 ASPIRE2A “blocked”、旧 Gadi 站点栈为“当前 baseline”等状态已被后续结果替代。运行数字以各集群导航所链的日志和登记表为准。

This is the **authoritative control repository** for our 2026 APAC HPC-AI
OpenFOAM competition work: every build script, benchmark script, result
record, and failure analysis lives here, and every cluster job is submitted
from a clone of this repository.

Start with [`PROJECT-INDEX.md`](PROJECT-INDEX.md) for the latest locally
recorded state and separate ASPIRE2A/Gadi evidence paths. The detailed sections
below retain the early project snapshot; their words "current", "official"
and "blocked" describe that historical context, not a verified final
competition submission or today's scheduler state.

---

## 1. What is this repository for?

To find the fastest **correct** way to run a fixed OpenFOAM workload on
supercomputer hardware, and to keep an auditable record of how we got there.

The scientific problem is fixed by the competition rules. We are not allowed
to change the physics. We are optimising *how the same computation is
executed*: compiler, MPI library, node/rank layout, and domain decomposition.

## 2. What is the workload?

| Item | Value |
| --- | --- |
| Application | OpenFOAM (openfoam.com) |
| Release | **v2512** |
| Case | `occDrivAerStaticMesh` (DrivAer open-cooling automotive aerodynamics) |
| Mesh | ~65 million cells |
| Solver | `simpleFoam` (steady-state RANS) |
| Official metric | **Average wall-clock time per time step**, from the `simpleFoam` log |
| Secondary metrics | `ClockTime`, `ExecutionTime`, per-step statistics, peak memory |
| Correctness check | drag coefficient `Cd` within the expected per-point range |

**Frozen by the rules:** the mesh, `simpleFoam` source, `fvSchemes`, and
`fvSolution`. See [`APPLICATION.md`](APPLICATION.md).

**Open for optimisation:** compiler and build flags, MPI implementation, rank
count and placement, and decomposition — subject to rules and approval.

## 3. What platforms are involved?

Two different supercomputers appear in this repository. Do not mix their
results.

| Platform | Site | Hardware | Role today |
| --- | --- | --- | --- |
| **Gadi** | NCI, Australia | `normalsr` = Xeon Platinum 8470Q (Sapphire Rapids, 104 cores/node)<br>`normal` = Xeon Platinum 8274 (Cascade Lake, 48 cores/node) | **Active.** All official scored results and all current work happen here. |
| **ASPIRE2A** | NSCC, Singapore | AMD/Cray, PALS MPI | **Blocked / historical.** Multi-node runs die with `signal 7`; see [`results/hpc-lessons.md`](results/hpc-lessons.md). |

Only `normalsr` (Sapphire Rapids) results count as official. Gadi `normal`
(Cascade Lake) is used for cheap development and compiler screening.

## 4. What results are currently authoritative?

**Official scored baseline — Gadi `normalsr`, site OpenFOAM/2512 module
(GCC 8.5.0 + OpenMPI 4.1.7), one rank per physical core:**

| Nodes | Ranks | Decomposition | Steps | **Avg wall-clock / step** | ClockTime | Cd | PBS job | Status |
| ---: | ---: | --- | ---: | ---: | ---: | ---: | --- | --- |
| 1 | 104 | `(4 13 2)` | 40 | **8.824444 s** | 378 s | 0.43087 | `178153587.gadi-pbs` | `OFFICIAL` `VALID` |
| 2 | 208 | `(8 13 2)` | 80 | **4.296500 s** | 362 s | 0.33201 | `178154724.gadi-pbs` | `OFFICIAL` `VALID` |
| 4 | 416 | `(16 13 2)` | 150 | **2.139565 s** | 336 s | 0.28231 | `178149002.gadi-pbs` | `OFFICIAL` `VALID` — **the baseline to beat** |

Scaling: **2.053868×** at 2 nodes and **4.124410×** at 4 nodes, normalised
per step because the three points use different iteration counts.

Everything else in this repository is *development evidence*, not an official
result. The full run-by-run table is
[`results/experiment-index.md`](results/experiment-index.md).

## 5. What optimisation stage are we at?

We have a valid official baseline and we are screening **alternative compiler
toolchains** to beat it, on the evidence that the site module was built with
GCC 8.5.0 (2021) — which predates Sapphire Rapids support in GCC and therefore
emits generic x86-64 code with no AVX-512 tuning for the scored hardware.

Current step: **C1 is built, runtime-validated and screened.** Its one 65M
screening run came out about 2.66% *slower* than the GCC baseline on identical
hardware. Both builds use `-O3` with no architecture targeting, so the AVX-512
headroom argument remains untested — see
[`results/experiment-index.md`](results/experiment-index.md) section 3.3.

## 6. What is C1?

`C1` is one candidate software stack:

> **C1 = Intel ICC Classic 2021.10.0 + OpenMPI 4.1.7 + OpenFOAM v2512**

C1 has passed a chain of increasingly strong validations. Each stage means
something different, and passing one does **not** grant the status of the next:

| Stage | Meaning | Status |
| --- | --- | --- |
| Build validation | The stack compiles and produces a `simpleFoam` binary | `PASS` — job `178166771.gadi-pbs` |
| Runtime archive repair | The portable runtime tarball is complete and re-hashed | `PASS` — job `178252413.gadi-pbs`, token `C1_RUNTIME_ARCHIVE_V2_PASS` |
| Runtime smoke | A tiny 5-rank tutorial case actually runs to completion | `PASS` — job `178254935.gadi-pbs`, token `C1_RUNTIME_SMOKE_PASS`, 14 s on `gadi-cpu-clx-2372` |
| **65M benchmark** | The real competition workload produces a timing | **`VALID SCREENING`** — job `178570241.gadi-pbs`, **5.281517 s/step**, Cd 0.28120622. About **2.66% slower** than the Phase 0 GCC baseline (5.144659 s/step); one run only, a negative screening signal, not a statistical conclusion |
| Official result | Same, on `normalsr`, under official rules | **not attempted** |

> **A passing smoke test proves the binary works. It does not produce a
> performance number, and it never makes a later C1 run "official".** The smoke
> ran `pitzDaily_fused`, a small OpenFOAM tutorial — not the 65M competition
> workload.

Both runtime-validation jobs were submitted from scripts that were untracked at
the time, so neither can cite a Git commit. See lesson L11 in
[`results/hpc-lessons.md`](results/hpc-lessons.md).

The candidate 65M script is written and statically verified but **uncommitted
and unsubmitted**:
`builds/build-scripts/c1-icc2021-openmpi417/benchmark_c1_65m_4n.pbs` plus its
per-node staging helper `stage_c1_runtime_node.sh`. It runs on Gadi `normal`
(Cascade Lake, 4 nodes × 48 ranks) and is labelled `SCREENING`, not official.

## 7. Experiment status vocabulary

Used consistently across [`results/experiment-index.md`](results/experiment-index.md):

| Label | Meaning |
| --- | --- |
| `OFFICIAL` | Run on `normalsr` under the official rules; may be quoted as a competition result |
| `VALID` | Completed correctly and its numbers may be used |
| `SCREENING` | A real measurement, but on development hardware or outside official conditions |
| `PASS` | A validation gate was met (build, smoke, checksum) — **not** a performance result |
| `FAILED` | Did not complete; kept because the failure explains something |
| `OUTLIER` | Correctness-valid but performance-anomalous; retained, never silently dropped |
| `SUPERSEDED` | Correct when recorded, but replaced by a better-controlled measurement |
| `PENDING` | Prepared but not yet run |

## 8. Where are the important scripts?

| Purpose | Location |
| --- | --- |
| Official `normalsr` baselines (1N/2N/4N) + static gate + metric extractor | [`official-gadi-spr/`](official-gadi-spr/) |
| Phase 0 controlled repeat runs (R1–R4) | [`phase0/`](phase0/) |
| Compiler/MPI stack builds (C1/C2/C3, S1/S2/S3, A1) | [`builds/build-scripts/`](builds/build-scripts/) |
| C1 runtime repair, smoke, and the pending 65M benchmark | [`builds/build-scripts/c1-icc2021-openmpi417/`](builds/build-scripts/c1-icc2021-openmpi417/) |
| Generic (non-C1) compiler-screening harness, archived legacy implementation, not a current execution plan | [`scripts/compiler-screening/`](scripts/compiler-screening/) |
| ASPIRE2A baseline and diagnosis runs | [`experiments/`](experiments/) |

**These scripts contain hard-coded repository-relative paths and must not be
moved.** See [§10](#10-do-not-move-these-files).

## 9. Where are the results?

| What | Where |
| --- | --- |
| **Master index of every experiment, with status and provenance** | [`results/experiment-index.md`](results/experiment-index.md) |
| Official run-by-run registry (including failed attempts) | [`results/official-gadi-spr/run-registry.md`](results/official-gadi-spr/run-registry.md) |
| Performance matrix and compiler-screening narrative | [`results/compiler-screening-summary.md`](results/compiler-screening-summary.md) |
| Structured machine-readable rows (Phase 0 R1–R4) | [`results/metrics.csv`](results/metrics.csv) |
| Phase 0 statistics and validity classification | [`phase0/README.md`](phase0/README.md) |
| **Failure and scheduler lessons** | [`results/hpc-lessons.md`](results/hpc-lessons.md) |
| Metric definitions (metric vs measurement vs statistic) | [`results/README.md`](results/README.md) |

Raw evidence (PBS logs, solver logs, checksums) stays on Gadi under
`/scratch/pm78/kj7183/openfoam_cpu/`. This repository records **where it is
and what it showed**, not copies of it.

## 10. Do not move these files

Several scripts resolve other files by path. Moving them silently breaks jobs
that then fail 20 minutes into an allocation. Before any `git mv`, check:

- `builds/build-scripts/*/build_*.pbs` — run `exec bash builds/build-scripts/<id>/build_<id>.sh` after `cd $PBS_O_WORKDIR`
- `builds/build-scripts/*/build_*.sh` — reach `../common/build_openfoam_v2512_openmpi.sh` relative to their own directory
- `official-gadi-spr/validate_official_baselines.sh` — hard-codes the three `official-gadi-spr/official_baseline_*.pbs` paths
- `scripts/compiler-screening/*.pbs` — invoke `scripts/compiler-screening/stage_candidate_runtime_node.sh`
- `builds/build-scripts/c1-icc2021-openmpi417/benchmark_c1_65m_4n.pbs` — asserts `PBS_O_WORKDIR` equals the Gadi control repo and builds an absolute path to its staging helper

Absolute Gadi paths (`/scratch/pm78/kj7183/openfoam_cpu/...`, `/apps/...`) are
cluster locations and are unaffected by repository layout.

## 11. Repository map

```
├── README.md                 ← you are here: the control center
├── APPLICATION.md            what the workload is and what is frozen
├── AGENTS.md                 rules for AI agents working in this repo
├── MANUAL_INSPECTION_ERROR.md open error records requiring human judgement
│
├── official-gadi-spr/        OFFICIAL scored runs (normalsr / Sapphire Rapids)
├── phase0/                   controlled reproducibility repeats R1–R4 (Cascade Lake)
├── builds/                   how each compiler/MPI stack is built
├── scripts/                  reusable harnesses not tied to one stack
├── experiments/              ASPIRE2A (NSCC) baseline and diagnosis runs
│
├── results/                  extracted numbers, indexes, registries, lessons
├── planning/                 what we intend to do next and why
├── progress/                 dated session handoffs
├── workflow/                 reusable HPC/Git working rules
├── references/               last year's material (read-only reference)
└── artifacts/                slides, spreadsheets, PDFs for reporting
```

The conceptual difference between the directories is explained in
[§12](#12-why-the-directories-are-separate).

## 12. Why the directories are separate

They are split by **evidential status**, not by file type:

- **`official-gadi-spr/`** — scripts whose output may be quoted as a
  competition result. Isolated so nothing accidentally launders a development
  run into an official one.
- **`phase0/`** — controlled *repeat* runs of one frozen configuration.
  Answers "is our measurement stable?", not "is it fast?".
- **`builds/`** — how to *produce* a binary. No performance claims live here.
- **`scripts/`** — reusable harnesses shared across candidate stacks.
- **`experiments/`** — the ASPIRE2A cluster line of work, currently blocked.
- **`results/`** — extracted numbers and their provenance, separated from the
  scripts that produced them so results can be reviewed without reading code.
- **`planning/`** — intent and analysis before execution.
- **`progress/`** — a dated narrative so a reader can reconstruct *when* we
  knew what.
- **`workflow/`** — rules that outlive this competition.

`workflow/02-Repo-Structure.md` describes the original skeleton;
`official-gadi-spr/` and `phase0/` were added later as the work grew.

## 13. What should be done next?

Ordered, with the current blocker first. Full reasoning in
[`progress/2026-09-09-repo-organisation-and-git-state.md`](progress/2026-09-09-repo-organisation-and-git-state.md).

1. **Resolve the Mac / GitHub / Gadi Git divergence** — the Gadi clone and this
   clone have separate commits for the same C1 fixes. Must be settled before
   the 65M job, so the run has an unambiguous commit for its provenance.
2. **Commit and push the C1 65M benchmark script** — the Gadi clone can only
   receive it through Git.
3. **Run the C1 65M screening benchmark** (4 nodes × 48 ranks, Gadi `normal`)
   and record ClockTime + average step time as `SCREENING`.
4. **Compare C1 against the Cascade Lake GCC reference** (797.5 s median,
   5.144659 s/step) — same hardware, same 192 ranks, so compiler is the only
   changed variable.
5. **Only if C1 wins**, plan a `normalsr` official C1 run under the rules.
6. Then: decomposition/rank screening, affinity, profiling, submission package.

## 14. Working rules

- Develop and commit **on the Mac**; the Gadi clone should only ever `pull`.
- Never edit scripts directly on Gadi — that is what caused the current split.
- Every result must carry: commit, PBS job ID, node type, queue, ranks,
  decomposition, and completion evidence.
- Keep failed runs. In HPC a failure that explains scheduler, compiler, or MPI
  behaviour is worth more than a duplicate success.

See [`workflow/01-Git-Sync-Policy.md`](workflow/01-Git-Sync-Policy.md) and
[`AGENTS.md`](AGENTS.md).
