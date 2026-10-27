# Fast ASPIRE2A performance screening: evidence and next run

**Date:** 2026-09-17. **Scope:** Existing records and read-only inspection of the previously authorized teammate case directory; no build, run, PBS submission, remote write, or compute allocation. This is a screening proposal, not permission to execute it. The official workload remains the fixed 65M `occDrivAerStaticMesh` case and 150 SIMPLE steps.

## 1. Concise summary

The current recorded ASPIRE2A winner is the AOCC 5.0 / Open MPI 5.0.10 / KaHIP / 4-node, 512-rank run with explicit core binding: **2.869257 s/step** (job `20092999`). Its unbound counterpart is 2.875901, a 0.23% difference. Under the same scripted AOCC/Open MPI stack and unbound mapping, hierarchical is **3.355476**, 16.68% slower than KaHIP. The run scripts selected the same binary path, though a per-job binary hash was not retained. Existing GCC/Open MPI and ICX/Intel MPI results show a similar KaHIP advantage, so decomposition is the strongest current signal. The hierarchical late Cd trajectory and weaker pressure residuals remain correctness concerns.

## 2. Scope, evidence status, and toolchain fingerprints

`UNKNOWN` means the exact requested fact was not retained for the *specific run*. Module/script intent is separated from measured runtime linkage. Gadi job `178149002.gadi-pbs` is the valid official four-node result, but its original run directory was not accessed in this task.

| Field | Gadi 4N `178149002` | ASPIRE KaHIP bound `20092999` (unbound `20030922`) | ASPIRE hierarchical `20061437` |
| --- | --- | --- | --- |
| OpenFOAM | Site `OpenFOAM/2512`, v2512 (recorded) | v2512 (solver header); `linux64AmdDPInt32Opt` binary path | Same v2512 binary path |
| Compiler | GCC 8.5.0, binary strings `Red Hat 8.5.0-26/-28`; exact flags **UNKNOWN**. Prior disassembly found generic x86-64 hot path, not the compile command. | AOCC module `aocc/5.0`, `clang/clang++`; precise patch/build string **UNKNOWN**. Stock OpenFOAM `Opt` platform; exact flags **UNKNOWN**. `OptZnver3` is a *different* build and must not be attributed to these jobs. | Same AOCC module and stock `Opt` platform; exact flags **UNKNOWN**. |
| MPI and binary linkage | Open MPI 4.1.7, prior adapter records `ldd simpleFoam`; exact resolved `libmpi` path and binary hash for this job **UNKNOWN**. | Open MPI 5.0.10; archived PBS `ldd` resolves `libmpi.so.40` to `/app/apps/openmpi/5.0.10-gcc11/lib/libmpi.so.40` (both KaHIP runs). | Same resolved `libmpi.so.40` path in archived PBS output. |
| OpenFOAM environment | `WM_MPLIB=SYSTEMOPENMPI` recorded for site stack; job-specific `WM_COMPILER` and `FOAM_MPI` values **UNKNOWN**. | `WM_COMPILER=Amd`, `WM_MPLIB=SYSTEMOPENMPI`, `WM_COMPILE_OPTION=Opt` printed by run. `FOAM_MPI` is exported to ranks but its value was not printed: **UNKNOWN**. | Same printed WM values; `FOAM_MPI` value **UNKNOWN**. |
| Modules | Script runs `module purge; module load OpenFOAM/2512`; full `module list` was printed to unavailable original job output: **UNKNOWN**. | Run script explicitly loads `aocc/5.0`, `gcc/11.2.0`, `openmpi/5.0.10-gcc11`. Build script additionally loaded `cmake/3.31.3`, `flex/2.6.4`. Full dependency-expanded run module list **UNKNOWN**. | Same explicit run modules; full expanded list **UNKNOWN**. |
| Resources | `normalsr`, 4 nodes, 104 ranks/node, 416 total, one rank per physical core. | PBS `select=4:ncpus=128:mpiprocs=128`, `place=scatter`; 128 ranks/node, 512 total. | Same 4 × 128 = 512. |
| Launcher and placement | `mpirun -np 416`; no explicit binding flags. Actual CPU affinity map **UNKNOWN**. | Open MPI `mpirun --hostfile ... -np 512`; bound run adds `--bind-to core --map-by ppr:128:node:PE=1`. Unbound run uses `--map-by ppr:128:node`. Actual affinity map **UNKNOWN**. | Same unbound `ppr:128:node` launcher; actual affinity map **UNKNOWN**. |
| Decomposition | `hierarchical (16 13 2)` | `kahip`; `nHierarchical=(8 8 8)` remains in case definition but is not the selected method. | `hierarchical (8 8 8)` |

**Cheapest read-only closure for unknowns:** Gadi: inspect the retained `modules.txt`/job stdout, `foam-env.txt` if present, binary path and `ldd` from the *original* job evidence; no Gadi access is authorized here. ASPIRE: inspect already retained build stdout or the exact binary's ELF `.comment`, original wmake rule and compile command for compiler/flags; inspect original run `module list`, `printenv FOAM_MPI`, and `ldd` in the matching environment for full modules/FOAM setting. The teammate binary/build tree lies outside the previously approved case directory, so do not enter it without a path-specific read-only authorization. A new compute-node probe is needed only if archived runtime evidence cannot establish actual rank affinity or library resolution on compute nodes.

## 3. Data and analysis

### Performance differences

| Comparison | Difference | Relative to comparator | Interpretation |
| --- | ---: | ---: | --- |
| KaHIP bound vs unbound | 0.006644 s/step faster | 0.23% | Single runs; likely within run-to-run noise until repeated. |
| Hierarchical vs unbound KaHIP | 0.479575 s/step slower | 16.68% | Same AOCC/Open MPI, 4 × 128, unbound launcher; strong decomposition signal. |
| Hierarchical vs bound KaHIP | 0.486219 s/step slower | 16.95% | Includes both decomposition and binding difference. |
| Bound KaHIP vs Gadi official | 0.729692 s/step slower | 34.10% | **Descriptive only:** 512 vs 416 ranks, different CPUs, MPI, compiler and decomposition. |

The teammate results registry additionally records GCC 15.2/Open MPI KaHIP 2.880 vs hierarchical 3.352 (hierarchical +16.39%) and ICX 2025.1.3/Intel MPI KaHIP 2.898 vs hierarchical 3.311 (+14.25%). These are supporting single-run observations, not controlled repeats. Existing compiler-stack differences near the current winner are small: GCC/Open MPI 2.880 and ICX/Intel MPI 2.898 versus AOCC/Open MPI bound 2.869; compiler and MPI change together in the ICX comparison.

### Existing solver-log comparison: unbound KaHIP versus hierarchical

The original 150-step logs were parsed without changing remote files. `ClockTime` is integer seconds, so its per-step increments are quantized; `ExecutionTime` increments provide a finer secondary view. The official metric remains the logged average wall-clock time per step.

| Window | KaHIP mean ΔClockTime / mean ΔExecutionTime (s) | Hierarchical (s) | Pressure iterations | Ux/Uy/Uz iterations | Mean pressure initial → final residual | Mean absolute global continuity error |
| --- | ---: | ---: | --- | --- | --- | ---: |
| Steps 20–40 | 2.857 / 2.840 | 3.333 / 3.311 | 12 in both | 15/15/15 in both | See 100–150 below | — |
| Steps 100–150 | 2.882 / 2.861 | 3.373 / 3.348 | 12 in both | 15/15/15 in both | KaHIP `2.324e-3 → 1.059e-7`; hierarchical `2.457e-3 → 1.152e-5` | KaHIP `3.012e-8`; hierarchical `6.814e-8` |
| Steps 121–150 | 2.900 / 2.862 | 3.367 / 3.349 | 12 in both | 15/15/15 in both | KaHIP `2.061e-3 → 1.006e-7`; hierarchical `2.293e-3 → 1.165e-5` | KaHIP `2.493e-8`; hierarchical `4.210e-8` |

Both runs use fixed linear-solver iteration counts throughout all 150 SIMPLE steps: `p=12`, `Ux=Uy=Uz=15`. Thus **additional solver iterations do not explain** hierarchical's ~0.48 s/step penalty. The gap is present at steps 20–40 and remains at 100–150. The hierarchical pressure final residual is ~109× higher on average in steps 100–150 despite similar initial residuals; velocity final residuals and continuity errors are also higher. Cd at step 120 is 0.296204 (KaHIP) vs 0.295214 (hierarchical), but at step 150 it is 0.280044 vs 0.298430. This supports *both* a stable extra per-iteration cost associated with the partition and an altered numerical trajectory. The logs cannot separate communication surface, global reductions, load imbalance, cache locality, or rank placement as the timing mechanism; they cannot prove that the pressure-residual difference causes the runtime gap.

## 4. Small screening matrix and profiling ladder — SUPERSEDED (see §7–§12)

Keep the mesh, `simpleFoam` source, `fvSchemes`, `fvSolution`, initial fields, 4 nodes, 128 ranks/node, 512 ranks, KaHIP partition, launcher placement, and measurement window fixed **within each comparison**. Before treating two runs as a controlled pair, verify partition identity (processor files or partition manifest), exact binary and `libmpi` hashes, and the input hashes. Screening uses fresh cases to step 40 and compares mean per-step time for steps 20–40; archive existing AOCC/Open MPI 20–40 value is **2.840 s/step ExecutionTime increment**. A contemporaneous control is required when the candidate is within ~3% of that archival value. Screening requires normal completion, finite residuals and Cd, and a Cd trajectory close to the matching KaHIP control; the exact scientific tolerance must be agreed before execution. A screening win is ≥3% lower steps-20–40 time against a contemporaneous control, or a repeatable 1–3% improvement worth validation. Screening alone never qualifies for competition slides.

| Order / type | Hypothesis and variable | Fixed controls | Metric, correctness, success / information gained |
| --- | --- | --- | --- |
| 1. **Controlled MPI attribution**, if a verified AOCC 5.0 + Cray MPICH build is feasible | Cray MPICH 8.1.15 may reduce the per-iteration communication cost. Change **MPI implementation only** from Open MPI 5.0.10, holding AOCC 5.0 and compile flags fixed. | Same KaHIP partition, 4×128, explicit core binding (equivalent affinity across launchers), case hashes, 40-step screen; rebuild all OpenFOAM MPI-dependent libraries against Cray MPICH. | Steps-20–40 s/step and completion; validate `ldd` and `FOAM_MPI`, residual/Cd trajectory. ≥3% repeatable speedup advances to 150-step validation. Isolates MPI's contribution if all controls hold. Compatibility and `WM_MPLIB` mapping are **not yet established**; do not swap `libmpi` under the existing binary. |
| 2. **Software-stack screen**, if order 1 is infeasible or underperforms | CCE 13.0.2 + Cray MPICH 8.1.15 might outperform AOCC/Open MPI as a site-integrated stack. **Compiler and MPI change together**. | Same case, KaHIP partition, resources, placement and window; fresh private build; record exact flags and binary linkage. | Same screen metric/checks; ≥3% repeatable gain advances to 150 steps. Identifies a promising stack **without attributing** any win to compiler versus MPI. |
| 3. **Controlled compiler attribution**, only if stack screen wins | With Cray MPICH fixed, compare AOCC 5.0 and CCE 13.0.2 under matched optimization intent. Change **compiler only**. | Same MPI version, case/partition, mapping and screening window. | Same metric/checks; resolves whether compiler explains the stack win. If exact flags/ABI cannot be matched, classify as a stack comparison instead. |

Do not spend an early job on binding alone: existing AOCC KaHIP runs differ by only 0.23%, and actual affinity has not been captured. Keep hierarchical as a diagnostic comparison, but do not promote its runtime to a scored candidate until Cd is reviewed. Existing GCC/Open MPI and ICX/Intel MPI 150-step results should be reused as context rather than repeated immediately.

**Final scored validation:** For a screened candidate, run fresh 150-step cases with the official controlDict, verify original input and partition manifests, actual binary/`libmpi`, module list, 4×128 allocation, normal `End`/parallel finalisation, finite residuals, Cd curve and final Cd against the approved criterion, then compare the official average wall-clock s/step. Use at least two independent candidate/control measurements and report the median plus all attempts; the 40-step screen is not a substitute.

**Profiling ladder:** (1) Existing per-step `ExecutionTime`/`ClockTime`, fixed solver iteration counts, pressure/U residuals, continuity and Cd; test whether lost time follows iteration count (it does not here). (2) From existing decomposition logs or a later authorized bounded probe, count cells/faces and processor-interface faces per rank, neighbor count and max/mean imbalance; high cut surface suggests communication, high max cell or work count suggests imbalance. (3) Capture actual rank-to-core/NUMA affinity and compare with PBS placement; test pinning only if placement differs or remote-NUMA traffic is plausible. (4) Only after site availability *and compute-node usability* are verified, use MPI/Cray profiling to separate point-to-point, collectives/reductions and computation. `cray-mpich/8.1.15`, `PrgEnv-aocc/8.3.3`, `cce/13.0.2` and `perftools` modulefiles are visible on the ASPIRE2A login node; that does **not** prove compatible OpenFOAM builds or usable profiling. ARM Forge availability/usability is **UNKNOWN**.

## 5. Proposed local configuration diff for experiment 1 — SUPERSEDED (see §11)

This is the reviewable change boundary for a future private build/run patch. The exact OpenFOAM `WM_MPLIB` value and launcher syntax are intentionally unresolved; an executable PBS/build patch must be completed and shown before approval. No existing script or build was edited.

```diff
--- current AOCC/Open MPI KaHIP screening configuration
+++ proposed AOCC/Cray MPICH KaHIP screening configuration
 compiler: AOCC 5.0, stock Opt
-MPI: Open MPI 5.0.10; libmpi.so.40
+MPI: Cray MPICH 8.1.15; verify resolved libmpi from a private rebuild
 decomposition: KaHIP; same processor partition and 4 × 128 ranks
 placement: one rank per core; capture actual affinity on both arms
-launcher: Open MPI mpirun --hostfile ... --bind-to core --map-by ppr:128:node:PE=1
+launcher: site-supported Cray MPICH/PALS form, to verify before scripting
 endTime for screening: 40; compare steps 20–40 in both arms
 correctness: same input hashes, finite residuals/Cd, matched trajectory
```

The remote project root still lacks `.git`; the project's reviewed Git synchronization gate must be resolved before any new remote script or job. Future build, module, launcher, resource, remote write and PBS actions need a separate explicit authorization and a local diff review.

## 6. Provenance and handoff

Primary local records: [`run-registry.md`](../../results/official-gadi-spr/run-registry.md), [`official_baseline_4n.pbs`](../../official-gadi-spr/official_baseline_4n.pbs), [`gadi-cluster-config.md`](../../workflow/gadi-cluster-config.md), teammate [`results/metrics.csv`](../../references/teammate/OpenFoam-HPCAI-26/results/metrics.csv), teammate AOCC run scripts and archived `.o` files under [`experiments/occdrivaer-static`](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/), teammate AOCC build [`README.md`](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-aocc-openmpi/README.md), and the prior [input/Cd audit](../../progress/2026-09-17-input-cd-audit.md). Original ASPIRE logs read only: `.../cases/occdrivaer-occdrivaer_4node_aocc_kahip_v1.1/logFiles/50_simpleFoam.2026-09-14_03-01-50.log` and `.../cases/occdrivaer-occdrivaer_4node_aocc_hier888_v1/logFiles/50_simpleFoam.2026-09-14_03-40-46.log`, plus their `postProcessing/forceCoeffsAll/0/coefficient.dat` files. Local parsing was in memory; no raw log copy or script was written.

**Exact unique remote reads** (the `cat` reads were repeated by local in-memory parsers):

```sh
ssh -O check aspire2a-comp
ssh aspire2a-comp 'cd /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases && for n in occdrivaer-occdrivaer_4node_aocc_kahip_v1.1 occdrivaer-occdrivaer_4node_aocc_hier888_v1; do echo CASE=$n; ls -lh "$n"/logFiles/50_simpleFoam*.log; head -45 "$n"/logFiles/50_simpleFoam*.log; done'
ssh aspire2a-comp 'cd /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_hier888_v1/logFiles && grep -E "^(Version:|Build:|Time = |smoothSolver:|GAMG:|PBiCGStab:|DICPCG:|DILUPBiCGStab:|time step continuity errors|ExecutionTime =|Solving for)" 50_simpleFoam*.log | tail -70'
ssh aspire2a-comp 'module -t avail cray-mpich 2>&1 | head -30; module -t avail cce 2>&1 | head -30; module -t avail perftools 2>&1 | head -30'
ssh aspire2a-comp 'cd /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases && for n in occdrivaer-occdrivaer_4node_aocc_kahip_v1.1 occdrivaer-occdrivaer_4node_aocc_hier888_v1; do echo CASE=$n; grep -c "gdr copy" "$n"/logFiles/50_simpleFoam*.log; grep -E "^(Build:|Version:|Arch:|Time = 1$|Time = 150$|Average wall-clock time per time step)" "$n"/logFiles/50_simpleFoam*.log | head -10; done'
ssh aspire2a-comp 'cd /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_kahip_v1.1/logFiles && grep -n -m 12 -E "(OpenFOAM|Version:|Build:|Arch:|FOAM_MPI|processor|ExecutionTime)" 50_simpleFoam*.log'
ssh aspire2a-comp 'module -t avail PrgEnv-aocc 2>&1 | tail -15; module show cray-mpich/8.1.15 2>&1 | head -45; module show cce/13.0.2 2>&1 | head -35; module -t avail forge 2>&1 | tail -15'
ssh aspire2a-comp 'module show PrgEnv-aocc/8.3.3 2>&1 | head -75'
ssh aspire2a-comp 'cat /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_kahip_v1.1/logFiles/50_simpleFoam.2026-09-14_03-01-50.log'
ssh aspire2a-comp 'cat /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_hier888_v1/logFiles/50_simpleFoam.2026-09-14_03-40-46.log'
ssh aspire2a-comp 'cat /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_kahip_v1.1/postProcessing/forceCoeffsAll/0/coefficient.dat'
ssh aspire2a-comp 'cat /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/occdrivaer-occdrivaer_4node_aocc_hier888_v1/postProcessing/forceCoeffsAll/0/coefficient.dat'
```

No scheduler command was run. No remote state changed. Only this local report was created; all pre-existing Git changes and untracked files were preserved.

### Decision summary

1. **What we know now:** Three ASPIRE runs use v2512, AOCC 5.0/Open MPI 5.0.10 linked to `libmpi.so.40`, 4×128 ranks. Gadi's valid 4N baseline is v2512, GCC 8.5.0/Open MPI 4.1.7, 4×104 ranks. Exact compile flags and several job-specific environment/affinity details remain unknown.
2. **Strongest optimisation signal:** KaHIP is 16.68% faster than hierarchical under the matched unbound AOCC stack, with comparable advantages in existing GCC and ICX stack records. No extra solver iterations explain the gap; pressure residuals and Cd differ, so correctness and decomposition cost must both be investigated.
3. **Top three next experiments, ranked:** (1) AOCC 5.0/Cray MPICH versus AOCC 5.0/Open MPI controlled 40-step screen, highest information about MPI with possible network benefit; (2) CCE 13.0.2/Cray MPICH 40-step software-stack screen if (1) is infeasible or weak; (3) compiler-only CCE versus AOCC under a fixed Cray MPICH stack if (2) wins. Binding is deferred.
4. **Exact first experiment:** Once an AOCC 5.0 + Cray MPICH 8.1.15 private build and valid `WM_MPLIB`/`libmpi` linkage are demonstrated, run one fresh **4-node × 128-rank KaHIP, one-rank-per-core, 40-step** candidate with the unchanged case and compare steps 20–40 to a matching AOCC 5.0/Open MPI control; advance only a repeatable ≥3% screen win to 150-step scored validation. No such build/run was authorized or launched here.
5. **Remaining correctness risks:** hierarchical Cd late divergence and ~109× higher pressure final residual; large mesh byte identity and raw Gadi input/Cd remain unverified; candidate MPI/CCE builds may change numerical trajectories or fail ABI checks.
6. **Slides evidence gate:** Original 150-step logs and `coefficient.dat`, approved Cd criterion, complete input/mesh and partition identity, source/binary/`libmpi` hashes, exact compiler flags and modules, actual rank placement, valid PBS completion, and repeated official s/step measurements. Clearly label Gadi 416-rank versus ASPIRE 512-rank values as differing configurations.

---

# Revision 2 — 2026-09-17 (methodology update)

**Status of revision 2.** Sections 1–3 and 6 above remain the accepted evidence
base and are unchanged. Sections 4 and 5 are superseded by sections 7–12 below.
This revision adds partition-topology evidence (§7), a hypothesis verdict (§8),
an MPI-experiment classification (§9), a corrected timing method (§10), the
local script diffs (§11), and unresolved risks (§12).

**Authorization state.** Everything below was produced from read-only remote
reads and local computation. No job was submitted, no OpenFOAM build was run,
and no remote file was created, modified, or deleted. The scripts in §11 are
proposals held locally and are **not applied** anywhere.

## 7. Partition topology of the existing 512-rank KaHIP and hierarchical cases

### 7.1 Source and validity of the measurements

Both cases were decomposed by the same harness on the same mesh. The metrics
below were parsed from the retained `logFiles/10_decomposePar.log` of:

```text
.../cases/occdrivaer-occdrivaer_4node_aocc_kahip_v1.1/     (150-step run: 2.875901 s/step)
.../cases/occdrivaer-occdrivaer_4node_aocc_hier888_v1/     (150-step run: 3.355476 s/step)
```

Both are the unbound AOCC 5.0 / Open MPI 5.0.10 arm, so the pair differs in
decomposition method only. `decomposePar` reports, per rank, the cell count,
the point count, the face count shared with each neighbouring rank, the number
of processor patches, the total processor-face count, and the count of real
(non-processor) boundary faces.

Three validity checks were run before using the numbers:

| Check | KaHIP | hierarchical | Meaning |
| --- | ---: | ---: | --- |
| Total cells | 65,334,765 | 65,334,765 | Same mesh in both cases. |
| Total real boundary faces | 5,918,634 | 5,918,634 | Same geometry; only the internal cut differs. |
| Asymmetric interface entries | 0 | 0 | Every `A→B` face count equals its `B→A` count. |

**Double counting.** Each processor-interface face is reported twice, once on
each of the two ranks that share it. The per-rank `Number of processor faces`
value is therefore *not* inflated — it is the real local communication surface
of that rank — but the naive sum over ranks is exactly twice the number of
distinct interface faces. This was verified numerically rather than assumed:

```text
KaHIP        sum over ranks = 5,572,070   distinct pairs sum = 2,786,035   ratio = 2.000
hierarchical sum over ranks = 11,359,342  distinct pairs sum = 5,679,671   ratio = 2.000
```

All "total" and "unique" figures below are the de-duplicated (distinct-face)
values. All "per rank" figures are the un-halved local values.

**`renumberMesh` caveat.** The harness runs `renumberMesh -overwrite` *after*
`decomposePar`. That reorders cells *within* each rank for cache locality; it
does not move cells between ranks. Partition topology is therefore unaffected
and these metrics remain valid for the runs that were timed.

### 7.2 Load balance

| Metric | KaHIP | hierarchical (8 8 8) | Ratio h/K |
| --- | ---: | ---: | ---: |
| Cells min | 114,134 | 127,606 | |
| Cells mean | 127,606.96 | 127,606.96 | 1.000 |
| Cells max | 128,882 | 127,613 | |
| Cells standard deviation | 1,994.35 | **2.08** | 0.001 |
| **max-to-mean cell imbalance** | **1.00999 (+1.00%)** | **1.00005 (+0.005%)** | |
| min-to-mean | −10.56% | −0.0008% | |
| Ranks more than 2% below mean | 46 | 0 | |
| Ranks more than 5% below mean | 11 | 0 | |

KaHIP's +1.00% max-to-mean imbalance is not accidental: the log records
`kahipDecomp : config=fast imbalance=0.01`, i.e. it spent exactly its permitted
1% budget. Hierarchical, being a pure geometric cut of a structured index
range, is balanced to within 7 cells out of 127,607.

### 7.3 Communication surface

| Metric | KaHIP | hierarchical (8 8 8) | Ratio h/K |
| --- | ---: | ---: | ---: |
| Distinct processor-interface faces (edge cut) | 2,786,035 | 5,679,671 | **2.039** |
| Distinct communicating rank pairs | 2,757 | 2,901 | 1.052 |
| Processor faces per rank — min | 3,516 | 6,474 | 1.841 |
| Processor faces per rank — mean | 10,882.95 | 22,186.21 | **2.039** |
| Processor faces per rank — median | 10,402 | 16,390 | 1.576 |
| Processor faces per rank — 95th percentile | 16,733 | 43,939 | 2.626 |
| **Processor faces per rank — max** | **21,408** | **214,672** | **10.03** |
| Processor faces per rank — standard deviation | 3,062.25 | 23,808.97 | 7.775 |
| Ranks with >50,000 processor faces | 0 | 23 | |
| Ranks with >150,000 processor faces | 0 | 8 | |
| Surface-to-volume (proc faces / cells) — mean | 0.0853 | 0.1739 | 2.039 |
| Surface-to-volume — max | 0.1681 | **1.6823** | 10.01 |
| Points per rank — max | 161,017 | 237,943 | 1.478 |

The hierarchical tail is pathological rather than merely worse. Ranks 135, 191,
199 and 255 each carry exactly 127,607 cells (perfect compute balance) while
holding 212,757–214,672 processor faces — **more interface faces than they have
cells**. Those ranks have only 7–8 neighbours, so the excess is volume per
neighbour, not fan-out.

**Communication-work imbalance**, the load-balance metric that actually tracks
this partition's asymmetry:

| Metric | KaHIP | hierarchical (8 8 8) |
| --- | ---: | ---: |
| **max-to-mean of processor faces per rank** | **1.967** | **9.676** |

### 7.4 Neighbour count (message count proxy)

| Metric | KaHIP | hierarchical (8 8 8) |
| --- | ---: | ---: |
| Neighbours per rank — min | 3 | 4 |
| Neighbours per rank — mean | 10.77 | 11.33 |
| Neighbours per rank — max | **37** | **21** |
| Neighbours per rank — standard deviation | 4.16 | 2.89 |

Neighbour counts are effectively equal in the mean (1.05×), and KaHIP has the
*higher* maximum fan-out. Per-step message **count** therefore does not
distinguish the two partitions; per-step message **volume** does, by 2.04×.

### 7.5 On-node versus off-node surface (conditional)

With 4 nodes × 128 ranks and the recorded launcher `--map-by ppr:128:node`
against the PBS hostfile, rank *r* is expected on node *r*÷128. **Actual
affinity was never captured for these runs**, so this split is conditional on
that mapping and is the one result below that a future run must confirm rather
than inherit.

| Metric | KaHIP | hierarchical (8 8 8) | Ratio h/K |
| --- | ---: | ---: | ---: |
| Distinct intra-node interface faces | 2,572,600 | 3,631,253 | 1.411 |
| **Distinct inter-node interface faces** | **213,435** | **2,048,418** | **9.60** |
| Inter-node fraction of total cut | 7.66% | 36.07% | 4.71 |
| Inter-node faces per rank — mean | 833.73 | 8,001.63 | 9.60 |
| **Inter-node faces per rank — max** | **6,355** | **109,291** | **17.20** |
| Inter-node neighbours per rank — mean | 1.45 | 4.05 | 2.81 |
| Per-node off-node surface (nodes 0–3) | 109,786 / 101,612 / 134,244 / 81,228 | 896,292 / 1,535,786 / 1,130,488 / 534,270 | |

KaHIP confines 92.3% of its cut inside a node. Hierarchical pushes 36.1% across
the network, and its worst node carries 15.1× the off-node surface of KaHIP's
worst node.

### 7.6 Order-of-magnitude consistency check — arithmetic, not measurement

The case solves with fixed iteration counts (`system/fvSolution`, read
read-only): `p` is **GAMG**, `maxIter 12`, `tolerance 0`, `relTol 0`, with a
`coarsestLevelCorr` PCG pinned at `minIter 35 / maxIter 35`; `U` is
`smoothSolver` `maxIter 15`; `k` and `omega` are `smoothSolver` `maxIter 8`.
Iteration counts are identical in both runs, so the 0.479575 s/step gap is not
bought with extra iterations — this reproduces and extends the §3 finding.

Taking O(10²) fine-level halo exchanges per SIMPLE step (12 GAMG cycles + 45 `U`
component sweeps + 16 `k`/`omega` sweeps, plus per-level GAMG exchanges), the
2,893,636 extra distinct cut faces at 8 bytes per face per direction imply an
extra aggregate volume of order 5 GB per step, of which order 3 GB crosses the
network. Spread over the observed 0.479575 s gap that is order 10 GB/s
aggregate, i.e. order 1.5 GB/s of extra injection per node.

**This is an order-of-magnitude plausibility bound computed from partition
geometry and solver settings. It is not a measurement of MPI time, it does not
attribute the gap to communication, and it must not be quoted as one.** Only
profiling (ladder step 4) can do that.

## 8. Hypothesis verdict

| Hypothesis | Verdict | Basis |
| --- | --- | --- |
| **H1** — hierarchical is slower because of load imbalance | **Refuted, in the direction tested** | Hierarchical has a max-to-mean cell imbalance of +0.005% against KaHIP's +1.00% — 200× better balance — and is 16.68% slower. The sign is opposite to H1. |
| **H2** — hierarchical is slower because of greater communication surface / more neighbours | **Supported for surface; refuted for neighbour count** | 2.04× the distinct cut, 10.03× the worst-rank surface, 9.60× the off-node surface, and a surface-to-volume ratio above 1.0 on 8 ranks. Neighbour counts are equal in the mean and KaHIP's maximum is higher, so message count is not the discriminator; message volume is. |
| **H3** — existing partition metrics do not explain the gap | **Not required for the direction; still required for the magnitude** | The metrics explain *why* hierarchical should be slower and are order-of-magnitude consistent with *how much*. They cannot close it quantitatively, and they do not explain the separate ~109× pressure final-residual difference reported in §3. |

**Refinement that matters for the next experiment.** H1 is refuted only for
*cell-count* balance. Cell count is not the whole load: halo assembly, interface
updates and GAMG interface agglomeration scale with processor faces, and by that
measure hierarchical is the badly imbalanced partition (max-to-mean 9.68 versus
1.97). H1 and H2 are therefore not independent here — the surviving mechanism is
best stated as **communication-work imbalance concentrated in a small number of
high-surface ranks**, which in a bulk-synchronous fixed-iteration solver sets the
step time for all 512 ranks. The four worst hierarchical ranks alone would be
enough to do this.

**What this does not settle.** Cache and TLB behaviour also differ (hierarchical
carries up to 237,943 points per rank versus KaHIP's 161,017), and GAMG's
agglomeration quality is partition-dependent, which is the likelier cause of the
residual difference. Neither is separable from communication without profiling.

**Consequence for planning.** Decomposition remains the strongest known signal
and it is already banked. Hierarchical stays a diagnostic, not a candidate. The
next experiment should not re-litigate decomposition.

## 9. Is AOCC 5.0 + Cray MPICH honest MPI-only attribution?

Answer: **no — but it is much closer than "Cray-native stack screening", and the
correct label is neither of those two.** The determination was made from the
build rules and modulefiles, read-only.

### 9.1 What the build system actually changes

`wmake/rules/General/mplibCRAY-MPICH` includes `mplibMPICH`, which is:

```make
PFLAGS = -DMPICH_SKIP_MPICXX -DOMPI_SKIP_MPICXX
PINC   = -isystem $(MPI_ARCH_PATH)/include
PLIBS  = -L$(MPI_ARCH_PATH)/lib$(WM_COMPILER_LIB_ARCH) -L$(MPI_ARCH_PATH)/lib -lmpi -lrt
```

The current control uses `mplibSYSTEMOPENMPI` → `mpi-mpicc-openmpi`:

```make
PFLAGS = -DMPICH_SKIP_MPICXX -DOMPI_SKIP_MPICXX
PINC   = $(shell mpicc --showme:compile)
PLIBS  = $(shell mpicc --showme:link)
```

`PFLAGS` are **byte-identical**. Only the include path and the link line differ.
Neither rule touches the compiler driver, the optimization rule, or any ABI
switch. `etc/config.sh/mpi` handles `CRAY-MPICH` by setting
`MPI_ARCH_PATH="$MPICH_DIR"` and nothing else — **it does not require `craype`,
`PrgEnv-aocc`, or the `cc`/`CC`/`ftn` wrappers.**

Critically, `WM_OPTIONS` (`linux64AmdDPInt32Opt`) does **not** contain the MPI
name. MPI-dependent libraries live in `platforms/$WM_OPTIONS/lib/$FOAM_MPI/`
(currently `sys-openmpi/`; a Cray build would create `cray-mpich/`), and
`ldd` on the existing binary confirms `libPstream.so` is resolved at **run
time**, not baked in. The compiled numerical code — `libOpenFOAM`,
`libfiniteVolume`, `libturbulenceModels`, and `simpleFoam` itself — can be the
same bytes in both arms.

### 9.2 Held fixed — verified

| Variable | Control | Candidate | Preserved? |
| --- | --- | --- | --- |
| Compiler identity | AOCC clang++ via `WM_COMPILER=Amd`, `wmake/rules/linux64Amd*` | identical | **Yes** |
| Compiler version | `aocc/5.0` (`/app/apps/aocc/5.0`) | identical | **Yes** |
| OpenFOAM source tree | `$HOME/scratch/openfoam-v2512/OpenFOAM-v2512` | identical | **Yes** |
| Optimization intent | `WM_COMPILE_OPTION=Opt`, `c++Opt` rule, `-O3` | identical | **Yes** |
| ABI settings | `WM_LABEL_SIZE=32`, DP, `WM_OPTIONS=linux64AmdDPInt32Opt` | identical | **Yes** |
| MPI C++ bindings | disabled by `PFLAGS` | disabled, same `PFLAGS` | **Yes — C ABI only** |
| Application binary | `platforms/linux64AmdDPInt32Opt/bin/simpleFoam` | same path, same bytes | **Yes, to be hash-verified** |

### 9.3 Changed — unavoidably, and more than the library alone

| Variable | Control | Candidate |
| --- | --- | --- |
| MPI library | `/app/apps/openmpi/5.0.10-gcc11/lib/libmpi.so.40` | `/opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so.12` |
| `FOAM_MPI` / Pstream shim | `sys-openmpi` | `cray-mpich` |
| Link line | `mpicc --showme:*` | `-isystem $MPICH_DIR/include`, `-L$MPICH_DIR/lib -lmpi -lrt` |
| **Launcher and process manager** | Open MPI `mpirun` / PRTE | **PALS `mpiexec`** (`/opt/cray/pe/pals/1.1.6/bin/mpiexec`), `libpals.so.0` |
| **Fabric library** | scratch `libfabric.so.1 → 1.25.0` | **Cray `/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1`** |
| MPI build compiler | GCC 11 | GNU 9.1 |

The last row is symmetric rather than a defect: the control's Open MPI was
*already* built by a different compiler than the application. Both arms are
"AOCC-built OpenFOAM against a third-party-built MPI".

The launcher and the fabric library are the honest confounds. Cray MPICH cannot
be launched by Open MPI's `mpirun`, and it links `libpals.so.0` and Cray's
libfabric directly; there is no configuration in which only `libmpi` changes.

### 9.4 Classification

> **"MPI runtime-stack attribution, compiler held fixed."**
> Changes the MPI library, its process manager/launcher, and its fabric provider
> together. Holds compiler identity, compiler version, source, optimization
> flags and ABI fixed, with the application binary hash-verified identical.

This is **not** "Cray-native software-stack screening" — that label applies to
the `PrgEnv-aocc` / `cce` path, which does swap the compiler and route through
`craype` wrappers, and which this design deliberately avoids. It is **not**
"MPI attribution" without qualification either. Use the full label in every
table, slide and commit message; do not shorten it to "MPI experiment".

### 9.5 Which Cray MPICH build to link, and why it matters

`module show cray-mpich/8.1.15` sets `MPICH_DIR=/opt/cray/pe/mpich/8.1.15/ofi/cray/10.0`
— the **CCE-built** variant. Per-compiler variants that exist on disk are
`aocc/3.0`, `cray/10.0`, `crayclang/10.0`, `gnu/9.1`, `intel/19.0`, `nvidia/20.7`.
The `amd/5.0` variant advertised by `PE_MPICH_GENCOMPILERS_AMD` **does not
exist**. `ldd` on the candidates, run on the login node:

| Variant | Unresolved dependencies |
| --- | --- |
| `aocc/3.0` | `libflang.so`, `libflangrti.so`, `libpgmath.so`, `libompstub.so` **not found** (AOCC 3.0 Fortran runtime; AOCC 5.0 ships same-named `.so` files, but satisfying a 3.0-built library with a 5.0 runtime is an untested substitution) |
| `cray/10.0` | requires CCE runtime |
| **`gnu/9.1`** | **none — all resolve**: Cray libfabric 1.22.0, `libgfortran.so.5` from `/opt/cray/pe/gcc-libs`, `libpals.so.0` |

**Recommendation: `MPICH_DIR=/opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1`.** OpenFOAM
uses only the MPI C API (C++ bindings are compiled out), so the C ABI is what
matters and it is stable across these builds. Do **not** set `MPICH_DIR` by
loading the module alone, which would silently select the CCE build.

### 9.6 Hard blocker that must be handled explicitly

The existing harness exports
`FOAM_EXTRA_LD_LIBRARY_PATH=$HOME/scratch/openfoam-v2512/ext/libfabric/lib` and
prepends it to `LD_LIBRARY_PATH`. That directory contains
`libfabric.so.1 → libfabric.so.1.25.0`. The **soname matches Cray's**, so on the
candidate arm it would shadow `/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1`.
Cray MPICH 8.1.15 is validated against Cray's libfabric and its site provider;
a generic 1.25.0 build is very unlikely to expose the same provider. The
candidate arm must **not** set `FOAM_EXTRA_LD_LIBRARY_PATH`.

This creates an arm asymmetry in the fabric library. Preferred resolution: a
pre-flight check of whether the **control** also runs correctly against Cray
libfabric 1.22.0. If it does, run both arms on 1.22.0 and the confound
disappears. If it does not, the asymmetry is real and must be stated in every
result table.

## 10. Timing method

### 10.1 Why `ExecutionTime` must be demoted — measured, not asserted

`ExecutionTime` is OpenFOAM's **CPU** time for rank 0. On the existing KaHIP
run, per-step `ExecutionTime` increments are 2.8561 s against `ClockTime`
increments of 2.8792 s over steps 2–150 — a CPU-to-wall ratio of **0.992**.
Open MPI 5.0.10 is therefore already busy-polling almost all of its wait time on
this system.

That is precisely what makes `ExecutionTime` unusable for an MPI comparison.
A candidate MPI that blocks or yields instead of spinning would report a
**lower `ExecutionTime` with unchanged wall time** — a fabricated win of exactly
the size of its wait fraction. Cray MPICH's polling behaviour is configurable
and not known here. `ExecutionTime` is retained only as a diagnostic, and the
ratio `ExecutionTime / wall` becomes a *reported quantity* precisely so this
failure mode is visible rather than silent.

`ClockTime` cannot be promoted in its place: it is emitted as an integer number
of seconds, so on a 21-step window of ~60 s its quantization is ±1.7%, larger
than the effects being screened.

### 10.2 Is the 20–40 window still supported? Yes, for ratios only

Per-step increments recomputed from both existing 150-step logs:

| Window | KaHIP Δ`ExecutionTime` | hierarchical Δ`ExecutionTime` | hier/KaHIP ratio |
| --- | ---: | ---: | ---: |
| steps 2–10 | 2.8556 | 3.3100 | 1.1591 |
| steps 11–20 | 2.8350 | 3.3050 | 1.1658 |
| **steps 20–40** | **2.8400** | **3.3114** | **1.1660** |
| steps 41–60 | 2.8575 | 3.3320 | 1.1661 |
| steps 61–100 | 2.8625 | 3.3435 | 1.1680 |
| steps 100–150 | 2.8614 | 3.3476 | 1.1699 |
| Official 150-step average wall-clock/step | 2.875901 | 3.355476 | **1.1668** |

Two facts follow.

1. **The window is stabilized from step ~11 onward.** Steps 2–10 carry startup
   transients; from step 11 the ratio is flat to within 0.4%.
2. **The window reads low in absolute terms but preserves the ratio.** Steps
   20–40 under-report the official figure by 1.25% (KaHIP) and 1.31%
   (hierarchical) because per-step cost drifts slowly upward across the run.
   Because both arms drift by almost the same relative amount, the 20–40 ratio
   (1.1660) matches the official ratio (1.1668) to **0.07%**.

**Therefore: steps 20–40 are retained as the screening window, and screening
results are reported as ratios against a contemporaneous control only. A
steps-20–40 number must never be quoted as an s/step result, compared against an
official 150-step figure, or put on a slide.** The official
`Average wall-clock time per time step` over 150 steps remains the only scored
metric.

### 10.3 Within-run precision

Standard deviation of per-step Δ`ExecutionTime` over steps 20–40: 0.0115 s
(KaHIP, cv 0.41%) and 0.0142 s (hierarchical, cv 0.43%). The standard error of
a 21-step window mean is therefore ~0.09%. **Within-run noise is not the
limiting factor** — between-run variation is (§12.2, §12.3).

### 10.4 The primary metric

> **Primary screening metric:** mean elapsed wall-clock seconds per SIMPLE step
> over steps 20–40 inclusive, derived from `CLOCK_MONOTONIC` timestamps applied
> to each `Time = N` line as it is emitted by rank 0, reported **only** as a
> ratio to a contemporaneous control measured in the same PBS job.
>
> **Scored metric (150-step validation only):** the solver's own
> `Average wall-clock time per time step`.
>
> **Secondary diagnostics:** total solver wall time, `ClockTime`,
> `ExecutionTime`, and the `ExecutionTime / wall` ratio.

`CLOCK_MONOTONIC` is specified rather than wall time so an NTP step cannot
corrupt a window. Line-level timestamping requires line-buffered output; the
harness in §11 forces this with `stdbuf -oL` and an unbuffered reader, and
**fails the run** if fewer timestamps are captured than steps executed, so a
buffering regression cannot silently degrade into a wrong answer.

### 10.5 Provenance recorded per arm, per run

| Field | How |
| --- | --- |
| high-resolution start/end wall time | `CLOCK_MONOTONIC` and `CLOCK_REALTIME` before/after the launcher |
| total solver wall time | end − start, monotonic |
| steps measured | count of timestamped `Time = N` lines |
| resulting s/step | window mean and whole-run mean, both reported |
| `ClockTime`, `ExecutionTime` | last values from the solver log |
| `ExecutionTime / wall` | computed; busy-wait diagnostic |
| exact binary hash | `sha256sum $FOAM_APPBIN/simpleFoam` |
| resolved `libmpi` path + hash | `ldd` → `readlink -f` → `sha256sum` |
| resolved `libPstream` path + hash | same; this is the library that actually differs |
| resolved `libfabric` path + hash | same; guards the §9.6 blocker |
| module list | `module list -t` |
| compiler version | `clang++ --version` |
| MPI version | `ompi_info --version` / `strings libmpi.so \| grep -m1 'MPI VERSION'` |
| rank count | `$NCORES` and `nProcs` from the solver log |
| **binding / affinity evidence** | a pre-launch probe run **with the identical launcher arguments** printing rank, host, `Cpus_allowed_list` and NUMA node per rank |
| partition identity | `sha256sum` of `10_decomposePar.log` plus recorded per-rank cell counts |
| input identity | `sha256sum` of `system/`, `0.orig/`, `constant/polyMesh/{owner,neighbour,boundary}` headers, plus a size manifest for the large mesh files |

The affinity probe closes the single largest gap in §2 — every existing
ASPIRE2A result has `actual affinity map: UNKNOWN` — and is the only way to
show that the Open MPI and PALS launchers placed ranks identically. Without it
the launcher confound of §9.3 stays open.

## 11. Proposed local scripts and diffs — NOT APPLIED

Nothing here exists on the cluster. The base for the diffs is the **current
remote** `experiments/occdrivaer-static/run_occdrivaer.sh` (154 lines), fetched
read-only. Note that the local mirror at
`references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/run_occdrivaer.sh`
is **stale** — it is missing the two-line `rm -rf "${CASE}"/processor*` fix — so
the mirror must be refreshed before it is used as a review base.

### 11.1 Build script — `build_a2a_comp_aocc_craympich.pbs` (new file)

```bash
#!/bin/bash
#PBS -N aocc_cmpich
#PBS -P 59000020
#PBS -q normal
#PBS -l select=1:ncpus=128:mpiprocs=1:mem=400gb
#PBS -l walltime=03:00:00
#PBS -o outputs/build_a2a_comp_aocc_craympich_v1.o
#PBS -e outputs/build_a2a_comp_aocc_craympich_v1.e

# AOCC 5.0 + Cray MPICH 8.1.15 (gnu/9.1 variant).
# Compiler, flags, source and ABI identical to the sys-openmpi build.
# Produces platforms/linux64AmdDPInt32Opt/lib/cray-mpich/ only.
# Does NOT touch lib/sys-openmpi/ and does NOT relink the Opt platform libs.

set -eo pipefail
cd "$PBS_O_WORKDIR"
module purge
module load aocc/5.0
module load gcc/11.2.0            # libstdc++ only; same as the control build
module load cmake/3.31.3
module load flex/2.6.4
export PATH="/app/apps/aocc/5.0/bin:${PATH}"

# Pin the MPI explicitly. Loading cray-mpich alone would select the CCE build.
export MPICH_DIR=/opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
[[ -e "${MPICH_DIR}/lib/libmpi.so" ]] || { echo "no libmpi at MPICH_DIR" >&2; exit 1; }
[[ -e "${MPICH_DIR}/include/mpi.h" ]] || { echo "no mpi.h at MPICH_DIR" >&2; exit 1; }
if ldd "${MPICH_DIR}/lib/libmpi.so" | grep -q "not found"; then
    echo "Cray MPICH has unresolved dependencies:" >&2
    ldd "${MPICH_DIR}/lib/libmpi.so" | grep "not found" >&2
    exit 1
fi

export FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
cd "${FOAM_INST_DIR}/OpenFOAM-v2512"
set +eu
source etc/bashrc WM_COMPILER=Amd WM_MPLIB=CRAY-MPICH \
    WM_COMPILE_OPTION=Opt WM_LABEL_SIZE=32
set -eu

# NOTE: deliberately NOT setting FOAM_EXTRA_LD_LIBRARY_PATH.
# The scratch libfabric 1.25.0 shadows Cray libfabric 1.22.0 (see plan 9.6).

[[ "${FOAM_MPI}" == "cray-mpich" ]] || { echo "FOAM_MPI=${FOAM_MPI}, expected cray-mpich" >&2; exit 1; }
[[ "${WM_OPTIONS}" == "linux64AmdDPInt32Opt" ]] || { echo "WM_OPTIONS drifted: ${WM_OPTIONS}" >&2; exit 1; }
echo "FOAM_MPI=${FOAM_MPI} MPI_ARCH_PATH=${MPI_ARCH_PATH} WM_OPTIONS=${WM_OPTIONS}"

# Record the pre-build binary hash. It must be unchanged afterwards.
BEFORE="$(sha256sum "${FOAM_APPBIN}/simpleFoam" | cut -d' ' -f1)"

# Only the MPI-dependent layer.
wmake libso src/Pstream/mpi
wmake libso src/parallel/decompose/decompositionMethods || true

AFTER="$(sha256sum "${FOAM_APPBIN}/simpleFoam" | cut -d' ' -f1)"
[[ "${BEFORE}" == "${AFTER}" ]] || {
    echo "REFUSING: simpleFoam changed (${BEFORE} -> ${AFTER});" >&2
    echo "the arms would no longer share one binary." >&2; exit 1; }

echo "BUILD_OK cray-mpich libPstream:"
ls -l "${FOAM_LIBBIN}/${FOAM_MPI}/"
sha256sum "${FOAM_LIBBIN}/${FOAM_MPI}/libPstream.so"
echo "simpleFoam unchanged: ${AFTER}"
```

The `BEFORE`/`AFTER` binary-hash gate is the mechanism that turns §9.2's claim
into a checked fact rather than an assumption.

### 11.2 Solver-only instrumented runner — `run_screen_solver.sh` (new file)

```bash
#!/bin/bash
# Run simpleFoam ONLY, in a pre-prepared case, with high-resolution wall timing
# and full provenance. Does not decompose, renumber, or initialise: the case
# must already be in the prepared state so that both arms start identically.
# Inputs: CASE, ARM, NCORES, WINDOW_LO, WINDOW_HI, LAUNCHER, PROV_DIR.

set -eo pipefail
: "${CASE:?}" "${ARM:?}" "${NCORES:?}" "${LAUNCHER:?}" "${PROV_DIR:?}"
WINDOW_LO="${WINDOW_LO:-20}"; WINDOW_HI="${WINDOW_HI:-40}"
mkdir -p "${PROV_DIR}"
P="${PROV_DIR}/${ARM}"

# ---- provenance before the run -------------------------------------------
{
  echo "arm=${ARM}"
  echo "date_realtime=$(date --iso-8601=ns)"
  echo "host=$(hostname)"
  echo "ncores=${NCORES}"
  echo "launcher=${LAUNCHER}"
  echo "FOAM_MPI=${FOAM_MPI}  WM_OPTIONS=${WM_OPTIONS}"
  echo "WM_COMPILER=${WM_COMPILER}  WM_COMPILE_OPTION=${WM_COMPILE_OPTION}  WM_MPLIB=${WM_MPLIB}"
  echo "clang=$(clang++ --version | head -1)"
  echo "simpleFoam_sha256=$(sha256sum "${FOAM_APPBIN}/simpleFoam" | cut -d' ' -f1)"
  for lib in libPstream.so libmpi.so.40 libmpi.so.12 libfabric.so.1; do
    r="$(ldd "${FOAM_APPBIN}/simpleFoam" 2>/dev/null | awk -v l="$lib" '$1==l {print $3}')"
    [[ -n "$r" ]] && echo "${lib}=$(readlink -f "$r") sha256=$(sha256sum "$(readlink -f "$r")" | cut -d' ' -f1)"
  done
  if command -v ompi_info >/dev/null 2>&1; then echo "mpi_version=$(ompi_info --version | head -1)"; fi
  if [[ -n "${MPICH_DIR:-}" ]]; then
    echo "mpi_version=$(strings "${MPICH_DIR}/lib/libmpi.so" | grep -m1 'MPI VERSION' || echo UNKNOWN)"
  fi
  echo "--- module list ---"; module list -t 2>&1
  echo "--- LD_LIBRARY_PATH ---"; tr ':' '\n' <<< "${LD_LIBRARY_PATH:-}"
} > "${P}.provenance.txt" 2>&1

# ---- affinity evidence, same launcher arguments as the solver -------------
${LAUNCHER} bash -c '
  read -r _ cpus < <(grep Cpus_allowed_list /proc/self/status)
  echo "$(hostname) cpus=${cpus} numa=$(cat /proc/self/status | awk "/Mems_allowed_list/{print \$2}")"
' 2>/dev/null | sort | uniq -c | sort -rn > "${P}.affinity.txt" || \
  echo "AFFINITY_PROBE_FAILED" > "${P}.affinity.txt"

# ---- the measured run ----------------------------------------------------
cd "${CASE}"
SFLOG="logFiles/50_simpleFoam.${ARM}.log"
STAMPS="${P}.stepstamps.txt"
mkdir -p logFiles

T0=$(python3 -c 'import time;print(repr(time.monotonic()))')
stdbuf -oL ${LAUNCHER} simpleFoam -parallel 2>&1 \
  | stdbuf -oL tee "${SFLOG}" \
  | python3 -u -c '
import sys, time
for line in sys.stdin:
    if line.startswith("Time = "):
        sys.stdout.write("%.9f %s" % (time.monotonic(), line))
' > "${STAMPS}"
T1=$(python3 -c 'import time;print(repr(time.monotonic()))')

# ---- gates ---------------------------------------------------------------
grep -q '^End' "${SFLOG}" || { echo "no End marker" >&2; exit 1; }
grep -Eiq '(^|[[:space:]])nan([[:space:]]|$)' "${SFLOG}" && { echo "NaN in log" >&2; exit 1; }
NSTEP=$(grep -c '^Time = ' "${SFLOG}")
NSTAMP=$(wc -l < "${STAMPS}")
[[ "${NSTEP}" -eq "${NSTAMP}" ]] || {
    echo "TIMING INVALID: ${NSTEP} steps but ${NSTAMP} timestamps (output buffering)" >&2
    exit 1; }

# ---- metrics -------------------------------------------------------------
python3 - "$STAMPS" "$SFLOG" "$T0" "$T1" "$WINDOW_LO" "$WINDOW_HI" "$ARM" <<'PY' | tee "${P}.metrics.txt"
import sys, re
stamps, log, t0, t1, lo, hi, arm = sys.argv[1:]
t0, t1, lo, hi = float(t0), float(t1), int(lo), int(hi)
ts = {}
for l in open(stamps):
    a, b = l.split(None, 1)
    ts[int(b.split('=')[1])] = float(a)
steps = sorted(ts)
wall = t1 - t0
win = [ts[s] - ts[s-1] for s in steps if lo <= s <= hi and (s-1) in ts]
ex = ck = None
for l in open(log):
    m = re.match(r'ExecutionTime = ([\d.]+) s  ClockTime = (\d+) s', l.strip())
    if m: ex, ck = float(m.group(1)), int(m.group(2))
print(f"arm={arm}")
print(f"wall_total_s={wall:.6f}")
print(f"steps_executed={len(steps)}")
print(f"window={lo}-{hi} steps_in_window={len(win)}")
print(f"PRIMARY_window_s_per_step={sum(win)/len(win):.6f}")
print(f"window_sd={(sum((x-sum(win)/len(win))**2 for x in win)/len(win))**0.5:.6f}")
print(f"wholerun_wall_s_per_step={(ts[steps[-1]]-ts[steps[0]])/(len(steps)-1):.6f}")
print(f"OpenFOAM_ClockTime={ck}")
print(f"OpenFOAM_ExecutionTime={ex}")
print(f"ExecutionTime_over_wall={ex/wall:.4f}")
PY
echo "SCREEN_OK arm=${ARM}"
```

### 11.3 Diff against the current remote `run_occdrivaer.sh`

The teammate's harness is **not modified**; the prepare phase is forked into
`prepare_screen_case.sh`. The diff below is what that fork changes:

```diff
--- run_occdrivaer.sh          (current remote, 154 lines)
+++ prepare_screen_case.sh     (proposed, not applied)
@@
-CASE="${FOAM_INST_DIR}/cases/occdrivaer-${ATTEMPT}"
+# One frozen partition shared by every arm. KaHIP determinism across separate
+# decomposePar invocations is NOT established (config=fast, imbalance=0.01),
+# so the partition must be produced once and reused, never re-derived per arm.
+CASE="${FOAM_INST_DIR}/cases/screen-base-${SCREEN_ID}"
@@
-rm -rf "${CASE}"
-mkdir -p "${CASE}"
-cp -a "${TEMPLATE_REAL}/." "${CASE}/"
+if [[ -d "${CASE}/processor0" ]]; then
+    echo "PREPARED case already exists; refusing to re-decompose." >&2
+    exit 0
+fi
+mkdir -p "${CASE}"
+cp -a "${TEMPLATE_REAL}/." "${CASE}/"
@@
-foamDictionary -entry endTime -set "${ENDTIME}" system/controlDict.noWrite
+foamDictionary -entry endTime -set 40 system/controlDict.noWrite
@@
 time decomposePar -constant > logFiles/10_decomposePar.log 2>&1
+sha256sum logFiles/10_decomposePar.log > logFiles/partition.sha256
+grep -c '^Processor ' logFiles/10_decomposePar.log >> logFiles/partition.sha256
 echo "restore0Dir"
 restore0Dir -processor
 echo "renumberMesh"
 time ${PAR} renumberMesh -constant -overwrite -parallel > logFiles/20_renumberMesh.log 2>&1
 echo "potentialFoam"
 time ${PAR} potentialFoam -initialiseUBCs -parallel > logFiles/30_potentialFoam.log 2>&1
 echo "applyBoundaryLayer"
 time ${PAR} applyBoundaryLayer -ybl 0.0450244 -parallel > logFiles/40_applyBoundaryLayer.log 2>&1
-STAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
-SFLOG="logFiles/50_simpleFoam.${STAMP}.log"
-echo "simpleFoam log=${SFLOG}"
-time ${PAR} simpleFoam -parallel > "${SFLOG}" 2>&1
+# STOP before simpleFoam. Snapshot the prepared initial fields so every arm
+# starts from byte-identical state, then hand off to run_screen_solver.sh.
+for d in processor*; do cp -a "$d/0" "$d/0.prepared"; done
+echo "PREPARED case=${CASE} partition=$(cut -d' ' -f1 logFiles/partition.sha256)"
-AVG="$(awk -F'=' '/Average wall-clock time per time step/ { v=$NF } END { print v }' "${SFLOG}" | tr -d ' ')"
-echo "AVG_WALL_PER_STEP=${AVG}"
```

The three substantive changes: the partition is produced once and frozen, the
prepared initial fields are snapshotted, and `ExecutionTime`-derived
`AVG_WALL_PER_STEP` is no longer the screening output.

### 11.4 Paired screening job — `screen_mpi_paired_v1.pbs` (new file)

```bash
#!/bin/bash
#PBS -N scr_mpi_p1
#PBS -P 59000020
#PBS -q normal
#PBS -l select=4:ncpus=128:mpiprocs=128:mem=400gb
#PBS -l place=scatter
#PBS -l walltime=01:00:00
#PBS -o outputs/screen_mpi_paired_v1.o
#PBS -e outputs/screen_mpi_paired_v1.e

# A-B-B-A paired screen inside ONE allocation, so the node set, the network
# neighbourhood and the partition are identical for both arms by construction.
set -eo pipefail
cd "$PBS_O_WORKDIR"
SCREEN_ID=v1
BASE="${HOME}/scratch/openfoam-v2512/cases/screen-base-${SCREEN_ID}"
PROV="${PBS_O_WORKDIR}/outputs/prov-${SCREEN_ID}-${PBS_JOBID%%.*}"
[[ -d "${BASE}/processor0" ]] || { echo "prepared case missing; run prepare first" >&2; exit 1; }

load_control() {
  module purge
  module load aocc/5.0 gcc/11.2.0 openmpi/5.0.10-gcc11
  export PATH="/app/apps/aocc/5.0/bin:${PATH}"
  export FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
  export FABRIC_LIB="${HOME}/scratch/openfoam-v2512/ext/libfabric/lib/libfabric.so.1"
  export FOAM_EXTRA_LD_LIBRARY_PATH="$(dirname "${FABRIC_LIB}")"
  cd "${FOAM_INST_DIR}/OpenFOAM-v2512"; set +eu
  source etc/bashrc WM_COMPILER=Amd WM_MPLIB=SYSTEMOPENMPI \
      WM_COMPILE_OPTION=Opt WM_LABEL_SIZE=32
  set -eu
  export LD_LIBRARY_PATH="${FOAM_EXTRA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"
  export LAUNCHER="mpirun --hostfile ${PBS_NODEFILE} -np 512 --bind-to core --map-by ppr:128:node:PE=1"
}

load_candidate() {
  module purge
  module load aocc/5.0 gcc/11.2.0 cray-pals/1.1.6
  export PATH="/app/apps/aocc/5.0/bin:/opt/cray/pe/pals/1.1.6/bin:${PATH}"
  export MPICH_DIR=/opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
  export FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
  # NO scratch libfabric here: it would shadow Cray libfabric 1.22.0.
  unset FOAM_EXTRA_LD_LIBRARY_PATH FABRIC_LIB
  cd "${FOAM_INST_DIR}/OpenFOAM-v2512"; set +eu
  source etc/bashrc WM_COMPILER=Amd WM_MPLIB=CRAY-MPICH \
      WM_COMPILE_OPTION=Opt WM_LABEL_SIZE=32
  set -eu
  export LAUNCHER="mpiexec -n 512 --ppn 128 --cpu-bind core"
}

run_arm() {   # $1 = arm label, $2 = loader
  local arm="$1" loader="$2"
  "${loader}"
  local C="${HOME}/scratch/openfoam-v2512/cases/screen-run-${SCREEN_ID}-${arm}"
  rm -rf "${C}"; cp -a "${BASE}" "${C}"
  for d in "${C}"/processor*; do rm -rf "$d/0"; cp -a "$d/0.prepared" "$d/0"; done
  CASE="${C}" ARM="${arm}" NCORES=512 WINDOW_LO=20 WINDOW_HI=40 \
    LAUNCHER="${LAUNCHER}" PROV_DIR="${PROV}" \
    bash "${PBS_O_WORKDIR}/run_screen_solver.sh"
}

# A-B-B-A cancels any monotonic drift (thermal, DVFS, shared-network load)
# across the job: each arm sits once early and once late.
run_arm ctrl_A  load_control
run_arm cand_B  load_candidate
run_arm cand_C  load_candidate
run_arm ctrl_D  load_control

echo "=== paired summary ==="
grep -H PRIMARY_window_s_per_step "${PROV}"/*.metrics.txt
grep -H ExecutionTime_over_wall   "${PROV}"/*.metrics.txt
echo "=== affinity agreement (must match between arms) ==="
for f in "${PROV}"/*.affinity.txt; do echo "-- $f"; head -4 "$f"; done
```

## 12. Fresh paired screen: design and repeat structure

### 12.1 Configuration

| | Control | Candidate |
| --- | --- | --- |
| Compiler | AOCC 5.0 (`/app/apps/aocc/5.0`) | **identical** |
| `WM_COMPILER` / `WM_COMPILE_OPTION` | `Amd` / `Opt` | **identical** |
| Platform | `linux64AmdDPInt32Opt` | **identical** |
| `simpleFoam` binary | hash-gated identical | hash-gated identical |
| MPI | Open MPI 5.0.10 (`sys-openmpi`) | Cray MPICH 8.1.15, `ofi/gnu/9.1` (`cray-mpich`) |
| Launcher | `mpirun --bind-to core --map-by ppr:128:node:PE=1` | `mpiexec -n 512 --ppn 128 --cpu-bind core` |
| libfabric | scratch 1.25.0 (or Cray 1.22.0 if pre-flight passes) | Cray 1.22.0 |
| Case | 65M `occDrivAerStaticMesh`, one frozen prepared copy | **same source case** |
| Partition | one KaHIP decomposition, produced once, reused | **same files** |
| Resources | 4 nodes × 128 ranks = 512, one rank/core, `place=scatter` | **identical** |
| Steps | 40 | 40 |
| Window | steps 20–40 | steps 20–40 |

The two arms run **inside the same PBS job on the same four nodes**. This is the
single most important change from the superseded §4: it removes node allocation
— the dominant between-run variance term — from the comparison entirely, rather
than trying to average it out.

### 12.2 What the noise actually is

The only controlled repeat evidence that exists is Gadi Phase 0, four repeats of
one frozen configuration: 802, 1045, 793, 790 s.

- Excluding the 1045 s anomaly: mean 795.0, sd 6.24, **cv 0.79%**.
- The anomaly is +31% and occurred in **1 of 4** runs.

This is a Gadi prior, not an ASPIRE2A measurement, and it is used only to size
the design. It carries two lessons: normal-regime between-run cv is around 0.8%,
and the distribution has a fat tail, so a **median over at least three
measurements** is required — a mean over two cannot survive one anomaly and
cannot even identify which of the two was anomalous.

### 12.3 Smallest repeat structure that separates the three regimes

Unpaired, two-sample, with σ ≈ 0.79%: the standard error of the difference is
σ·√(2/n).

| n per arm | SE of difference | 3% shows as | 1% shows as |
| ---: | ---: | ---: | ---: |
| 1 | 1.11% | 2.7σ | 0.9σ |
| 2 | 0.79% | 3.8σ | 1.3σ |
| 3 | 0.64% | 4.7σ | 1.6σ |
| 10 | 0.35% | 8.5σ | 2.8σ |

Unpaired, 1% needs about ten runs per arm — unaffordable and unnecessary.
Pairing within one allocation removes the allocation term; the residual is
bounded below by the 0.09% within-run window standard error of §10.3, and a
conservative working value is 0.3%.

> **Recommended structure: 3 PBS jobs, each running A-B-B-A.**
> 6 measurements per arm, 3 independent node allocations, 6 paired differences.
> Expected SE of the paired mean difference ≈ 0.3%/√6 ≈ 0.12%.

| Observed paired difference | Verdict | Action |
| --- | --- | --- |
| < 1% | Indistinguishable from noise | Record and stop. Do not report as a gain. |
| 1–3% | Potentially useful | Report with the confidence interval; requires 150-step validation before any claim. |
| ≥ 3% | Screening win | Advance to 150-step scored validation, ≥2 independent measurements per arm, report median and all attempts. |

**Minimum viable fallback:** one A-B-B-A job decides the ≥3% question on its own
(3% against a paired SE of ~0.21% is >14σ) and gives a first read on the 1–3%
band. It cannot survive an anomalous allocation, so it is a probe, not a result.

**Cost.** With the partition and the initial fields prepared once, each arm runs
only `simpleFoam` for 40 steps: ~115 s of solver plus case-copy overhead. One
A-B-B-A job is roughly 15–20 min of the 4-node allocation ≈ 130–170 SU billed.
Three jobs plus one preparation job ≈ **600 SU**, against a balance of
17,194.5 SU. Budget is not a constraint on this experiment.

**Explicitly forbidden:** comparing a Cray MPICH run against the archival
2.869257 figure. That number came from a different allocation, a different
decomposePar invocation, a 150-step run and an `ExecutionTime`-derived pipeline.
It is not a valid control for anything measured under §10.

### 12.4 Acceptance gates before any number is believed

1. `simpleFoam` sha256 identical in both arms (enforced in §11.1 and recorded).
2. `libPstream.so` resolved paths differ and `libmpi` hashes differ — i.e. the
   arms really are different MPI stacks.
3. Partition hash identical across all four segments.
4. Affinity probe output identical between arms; if it is not, the comparison is
   launcher-confounded and must be reported as such.
5. Timestamp count equals step count in every segment.
6. Normal `End`, finite residuals, no NaN.
7. Cd trajectory at step 40 within the agreed tolerance of the control.
8. `ExecutionTime / wall` reported for both arms; a large asymmetry means the
   busy-wait difference of §10.1 is present and `ExecutionTime` must not be
   quoted anywhere for that pair.

## 13. Unresolved risks

| # | Risk | Status | Mitigation |
| --- | --- | --- | --- |
| R1 | **Cray PE may not be usable on compute nodes.** All Cray MPICH, PALS and libfabric inspection was done on the login node. Login-node visibility does not prove compute-node mount, licence or fabric-provider availability. | **Open — cannot be closed without a job** | Make the first Cray MPICH action a ~2-minute, 1-node `mpiexec hostname` probe, not the 4-node screen. |
| R2 | **libfabric asymmetry.** The control uses scratch libfabric 1.25.0; the candidate must use Cray 1.22.0. The arms then differ in fabric library as well as MPI. | Open | Pre-flight: test the control against Cray 1.22.0. If it passes, run both arms on 1.22.0 and the confound disappears. If not, state the asymmetry in every table. |
| R3 | **Launcher confound is structural.** Cray MPICH cannot run under Open MPI `mpirun`. Process manager, PMI and binding syntax all change. | Open by construction | The §10.5 affinity probe makes placement an empirical check rather than an assumption. Gate 4 of §12.4 fails the comparison if placement differs. |
| R4 | **`amd/5.0` Cray MPICH does not exist**, so the linked MPI was built by GNU 9.1, not AOCC. | Accepted, symmetric | The control's Open MPI was built by GCC 11, so both arms are AOCC-application-against-foreign-built-MPI. Document; do not describe either arm as "fully AOCC". |
| R5 | **KaHIP partition reproducibility is unverified.** `config=fast, imbalance=0.01`; whether repeated `decomposePar` runs give identical partitions is not established. | Open | Structurally removed: the design decomposes once and reuses the files. Never re-derive a partition mid-experiment. |
| R6 | **Rank→node mapping in §7.5 is inferred, not measured.** The inter/intra-node split assumes rank *r* on node *r*÷128. | Open | Closed by the first affinity probe. Until then, §7.5 is labelled conditional and §7.3 (which needs no mapping assumption) carries the argument. |
| R7 | **Output buffering could corrupt the primary metric silently.** C++ iostream through a pipe is block-buffered. | Mitigated, not eliminated | `stdbuf -oL` plus `python3 -u`, and a hard failure when timestamp count ≠ step count. Verify on the 1-node probe before the 4-node screen. |
| R8 | **Cray MPICH busy-wait behaviour is unknown**, so `ExecutionTime` could move for reasons unrelated to wall time. | Managed | `ExecutionTime` is demoted to diagnostic and the `ExecutionTime / wall` ratio is reported explicitly. |
| R9 | **Only one anomaly estimate exists, and it is from Gadi.** ASPIRE2A's own between-run distribution has never been measured. | Open | The 3 × A-B-B-A structure yields ASPIRE2A's first real repeat statistics as a by-product. Report them. |
| R10 | **Numerical trajectory may change under a different MPI** (reduction order in global sums). Bitwise identity is not expected. | Open | Gate 7: compare the Cd trajectory and residuals at step 40; agree the tolerance before running, not after. |
| R11 | **Disk cost of four case copies.** A decomposed 65M-cell case copied four times is tens of GB per job. | Low | scratch holds 1.516 T of a 100 T quota. Delete `screen-run-*` copies at the end of each job; keep only `screen-base-*`. |
| R12 | **The local teammate mirror is stale** and would give a misleading diff base. | Open | Refresh `references/teammate/.../run_occdrivaer.sh` before review; it is missing the `rm -rf processor*` fix. |
| R13 | **No Git on the remote project root.** | **CLOSED 2026-09-17** | A bare transport `control.git` and a working checkout `control-repo` now exist under `/home/project/59000020/openfoam-isc26/`, verified against local `a8ecb34`. See `workflow/00-General-SSH-Rules.md`. |

## 14. Stop point

This revision ends here, before any build, remote write, or PBS submission. The
next authorized action, when it is authorized, is R1's one-node Cray MPICH
availability probe — not the paired screen, and not a build.

---

# Revision 3 — 2026-09-17 (Intel MPI feasibility audit)

**Why this revision exists.** The Cray MPICH route of §9 is **paused**, and R1
of §13 is now closed negatively rather than left open: three authorized one-node
PALS probes (`22693051`, `22803616`, `22815643`) all exited at the preflight
guard with `libfabric.so.1 => not found` and, in v2, `Unable to locate a
modulefile for 'libfabric/1.22.0'` on the compute node. The login-node
visibility recorded in §9.5 did **not** transfer to compute nodes. Full evidence
is in `MANUAL_INSPECTION_ERROR.md`. This revision audits a lower-risk substitute that
keeps the same experimental question — hold the application compiler at
AOCC 5.0, change the MPI runtime stack — using Intel MPI, which is already
proven to work on ASPIRE2A compute nodes by the completed ICX/Intel MPI
4-node runs.

**Authorization state.** Read-only audit. Nothing was built, submitted, or
written remotely. Sections 9–12 remain valid as method; only the candidate MPI
changes.

## 15. Feasibility audit — AOCC 5.0 + Intel MPI

### 15.1 Is `WM_COMPILER=Amd` + `WM_MPLIB=INTELMPI` supported? — Yes, explicitly

`wmake/rules/` ships a compiler-specific Intel MPI override for the AMD
compiler family:

```text
wmake/rules/linux64Amd/     ->  c  c++  general  mplibHPMPI  mplibINTELMPI
```

Its content, and the content of the rule the **working ICX build** used, are
byte-identical:

```make
# wmake/rules/linux64Amd/mplibINTELMPI
include $(GENERAL_RULES)/mplib-x86_64-INTELMPI

# wmake/rules/linux64Icx/mplibINTELMPI
include $(GENERAL_RULES)/mplib-x86_64-INTELMPI
```

`wmake/rules/General/mpi-rules` resolves `mplib$(WM_MPLIB)` from
`GENERAL_RULES`, then `DEFAULT_RULES`, then `$(RULES)` — the last being
`wmake/rules/linux64Amd`. The combination is therefore not merely tolerated;
upstream ships the rule for it, and AOCC and ICX resolve to the *same* MPI
include/link settings. The only untested delta versus the successful ICX runs
is "AOCC-compiled objects linked against Intel MPI's C library", not the build
plumbing.

### 15.2 What actually has to be rebuilt — two libraries, of which one matters

Everything MPI-dependent lives in `$FOAM_MPI_LIBBIN = $FOAM_LIBBIN/$FOAM_MPI`.
Both existing builds agree on the contents:

| `platforms/<WM_OPTIONS>/lib/<FOAM_MPI>/` | Contents |
| --- | --- |
| `linux64AmdDPInt32Opt/lib/sys-openmpi/` | `libPstream.so` (188,648 B), `libptscotchDecomp.so` (94,416 B) |
| `linux64IcxDPInt32Opt/lib/intelmpi/` | `libPstream.so` (190,904 B), `libptscotchDecomp.so` (95,064 B) |

**`libkahipDecomp.so` is not in either** — it sits in the MPI-independent
`lib/` directory (72,520 B, real implementation; the copy under `lib/dummy/` is
the stub). **The KaHIP decomposition path is unaffected by the MPI change.**

For this experiment the partition is frozen and `decomposePar` is not re-run, so
`libptscotchDecomp.so` is never loaded. **Only `libPstream.so` is required.**

### 15.3 Can the application binary and numerical libraries be preserved byte-for-byte? — Yes, structurally

Three independent pieces of evidence:

**(a) `WM_OPTIONS` contains no MPI term** (`etc/config.sh/settings:119`):

```sh
export WM_OPTIONS="$WM_ARCH$WM_COMPILER$WM_PRECISION_OPTION$WM_LABEL_OPTION$WM_COMPILE_OPTION"
```

Re-sourcing `etc/bashrc` with `WM_MPLIB=INTELMPI` leaves `WM_OPTIONS` at
`linux64AmdDPInt32Opt`, so `FOAM_APPBIN` and the main `FOAM_LIBBIN` are the
same directories — they are read, never rewritten.

**(b) The Pstream build writes to exactly one place**
(`src/Pstream/mpi/Make/files`, last line):

```make
LIB = $(FOAM_MPI_LIBBIN)/libPstream
```

and `src/Pstream/mpi/Make/options` only *reads* the main tree:

```make
EXE_INC     = $(PFLAGS) $(PINC) $(c++LESSWARN)
LIB_LIBS    = $(PLIBS)
PROJECT_LIBS = -L$(FOAM_LIBBIN) -lOpenFOAM
```

**(c) The MPI boundary is one file.** `DT_NEEDED` entries read from the existing
binaries:

| Object | NEEDED entries |
| --- | --- |
| `bin/simpleFoam` | `libPstream.so`, `libfabric.so.1`, `libstdc++.so.6`, `libgcc_s.so.1`, … — **no `libmpi`** |
| `lib/libOpenFOAM.so` | `libfabric.so.1`, `libz.so.1`, `libPstream.so`, `libstdc++.so.6`, … — **zero MPI references** |
| `lib/sys-openmpi/libPstream.so` | **`libmpi.so.40`**, `libfabric.so.1`, … |

`libPstream.so` is referenced by unversioned soname and resolved at run time
from `LD_LIBRARY_PATH`. Pointing `LD_LIBRARY_PATH` at `lib/intelmpi` instead of
`lib/sys-openmpi` swaps the entire MPI stack **under a byte-identical
application binary and byte-identical numerical libraries**.

> ⚠️ **Do not run `src/Pstream/Allwmake`.** Its first action is
> `wmake -no-openmp $targetType dummy`, which would relink
> `lib/dummy/libPstream.so` — a file the current serial tools depend on and one
> that must stay unchanged. Build the `mpi` subdirectory directly.

### 15.4 Exact Intel MPI used by the successful ICX runs

Taken from the ICX build script and the ICX 4-node run scripts:

```sh
module load intel/2025.1.3
export I_MPI_ROOT=/app/apps/oneapi/2025.1.3/mpi/latest
export PATH="${I_MPI_ROOT}/bin:${PATH}"
export LD_LIBRARY_PATH="${I_MPI_ROOT}/lib/release:${I_MPI_ROOT}/lib:${LD_LIBRARY_PATH:-}"
```

| Item | Value |
| --- | --- |
| Module | `intel/2025.1.3` |
| `I_MPI_ROOT` | `/app/apps/oneapi/2025.1.3/mpi/latest` |
| `intel64/` subdirectory | **absent** — paths resolve directly under the root |
| Header | `/app/apps/oneapi/2025.1.3/mpi/latest/include/mpi.h` |
| Library | `/app/apps/oneapi/2025.1.3/mpi/latest/lib/release/libmpi.so.12` |
| Launcher | `bin/mpirun`, `bin/mpiexec`, `bin/mpiexec.hydra` |
| Bootstrap | `I_MPI_HYDRA_BOOTSTRAP=pbs` (already set by `run_occdrivaer.sh` when `WM_MPLIB=INTELMPI`) |
| `prefs.intelmpi` override | **none present** in `etc/config.sh/` or `~/.OpenFOAM/` |

### 15.5 Rules and resolved settings

`wmake/rules/General/mplib-x86_64-INTELMPI`:

```make
intelmpi_subdir := $(shell test -d "$(MPI_ARCH_PATH)/intel64" && echo /intel64)

PFLAGS  = -DMPICH_SKIP_MPICXX -DOMPI_SKIP_MPICXX
PINC    = -isystem $(MPI_ARCH_PATH)$(intelmpi_subdir)/include
PLIBS   = -L$(MPI_ARCH_PATH)$(intelmpi_subdir)/lib/release -lmpi
```

With no `intel64/` directory present, `intelmpi_subdir` is empty, so the
expected resolved settings are:

```make
PFLAGS = -DMPICH_SKIP_MPICXX -DOMPI_SKIP_MPICXX
PINC   = -isystem /app/apps/oneapi/2025.1.3/mpi/latest/include
PLIBS  = -L/app/apps/oneapi/2025.1.3/mpi/latest/lib/release -lmpi
```

`PFLAGS` is **byte-identical** to the `SYSTEMOPENMPI` rule, so the C++ MPI
bindings are compiled out in both arms and only the C API is used. Only `PINC`
and `PLIBS` differ between the arms.

### 15.6 Does `FOAM_MPI` give a separate directory? — Yes, and no collision

`etc/config.sh/mpi`, `INTELMPI*` branch:

```sh
INTELMPI*)
    export FOAM_MPI=intelmpi
    ...
    MPI_ARCH_PATH="${I_MPI_ROOT}"
```

The version-qualified variant (`intelmpi-<version>`) exists only as commented-out
code, so the name stays plain `intelmpi`.

| Path | Status after the proposed build |
| --- | --- |
| `platforms/linux64AmdDPInt32Opt/lib/sys-openmpi/` | **untouched** — control arm |
| `platforms/linux64AmdDPInt32Opt/lib/intelmpi/` | **created** — candidate arm |
| `platforms/linux64IcxDPInt32Opt/lib/intelmpi/` | **untouched** — different `WM_OPTIONS`, different `FOAM_LIBBIN` |
| `platforms/linux64AmdDPInt32Opt/lib/dummy/` | untouched (only if `Allwmake` is avoided) |

### 15.7 ABI and runtime risk — the lowest of any candidate examined

`ldd /app/apps/oneapi/2025.1.3/mpi/latest/lib/release/libmpi.so.12`:

```text
librt.so.1, libdl.so.2, libc.so.6, libpthread.so.0, ld-linux-x86-64.so.2
```

That is the complete list. **No Intel runtime libraries** (`libimf`, `libintlc`,
`libsvml`, `libirc`), **no `libstdc++`**, **no `libgfortran`**. It is a pure C
library over glibc. Combined with `-DMPICH_SKIP_MPICXX` there is **no C++ ABI
surface at all** between AOCC-compiled OpenFOAM and Intel MPI.

Contrast with the paused Cray route, whose `gnu/9.1` variant required
`libgfortran.so.5`, `libpals.so.0` and a specific Cray libfabric.

| Risk | Assessment |
| --- | --- |
| C++ ABI mismatch | **None** — C++ bindings compiled out; `libmpi` has no `libstdc++` dependency |
| Fortran runtime mismatch | **None** — no `libgfortran`/`libflang` dependency |
| Intel compiler runtime needed by `libmpi` | **None** |
| `mpi.h` incompatible with AOCC clang | Low — the header is C; the build itself is the test |
| **libfabric asymmetry** | **None — and this is the decisive advantage.** `libfabric.so.1` is a `DT_NEEDED` of `simpleFoam`, `libOpenFOAM.so` and `libPstream.so` (a side effect of the team's `FOAM_EXTRA_LDFLAGS`). The existing ICX/Intel MPI runs already use the **same** scratch libfabric 1.25.0. Both arms can therefore run on an identical fabric library, which the Cray route could not do. |
| **Launcher / process manager** | **Changes — remains the one real confound.** Open MPI `mpirun`/PRTE → Intel Hydra with `I_MPI_HYDRA_BOOTSTRAP=pbs`. Binding syntax differs: `--bind-to core --map-by ppr:128:node:PE=1` versus `I_MPI_PIN=on I_MPI_PIN_DOMAIN=core`. |
| **Known placement anomaly between these two launchers** | The existing registry shows 4-node/256-rank (`mpiprocs=64`) results of ~2.89 s/step under Intel MPI against ~6.40 s/step under Open MPI — a 2.2× discrepancy at the same rank count that can only be placement. At 128 ranks/node both stacks behaved normally. The affinity probe of §10.5 is therefore **mandatory**, not optional. |

**Classification is unchanged in kind but stronger in degree:**

> **"MPI runtime-stack attribution, compiler held fixed."** Changes the MPI
> library and its launcher/process manager. Holds compiler identity, version,
> source, optimization flags, ABI, the application binary, the numerical
> libraries, the decomposition library **and the fabric library** fixed.

This is strictly closer to MPI-only attribution than the Cray route, because
fabric is no longer a changing variable.

### 15.8 Smallest possible build

```sh
wmake libso src/Pstream/mpi
```

One library. No `Allwmake`, no `Allwmake-mpi`, no `dummy` relink, no ThirdParty.
`libptscotchDecomp.so` is deliberately **not** built: it is not loaded at run
time with a frozen KaHIP partition, and building it would add a ThirdParty
dependency for no experimental benefit.

## 16. Exact change set

### 16.1 Files that would be created or changed

| Path | Change |
| --- | --- |
| `platforms/linux64AmdDPInt32Opt/lib/intelmpi/libPstream.so` | **created** (new directory + one library) |
| `build/linux64AmdDPInt32Opt/src/Pstream/mpi/` | object/dependency files for the new `FOAM_MPI`; build scratch only |

Nothing else. No existing file is written.

### 16.2 Files that must remain byte-identical — recorded baseline

Captured read-only on 2026-09-17 from
`platforms/linux64AmdDPInt32Opt`:

```text
7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f  bin/simpleFoam
aff8690fae76c41cae17abdf67cb49803a15b5c1b7b3e54c2ea7d5a0d20d74e4  lib/libOpenFOAM.so
a44ad17eb8a3d7767eb823744922035b729472e731354eea579fbf3f1f09cb64  lib/libfiniteVolume.so
dd1069a2eae8068d447648be64a97bbfcd15c238a8bd526ade4f69540a636ce6  lib/libkahipDecomp.so
0668195728e10e1327c6f31d0395541c3f45a0068a103b3e2197bfed00781887  lib/sys-openmpi/libPstream.so
```

Directory-level manifests (size + name, sorted, sha256 of the listing):

```text
aa773a4867dd5b4c661ddb9f5a6ac85b0209f7d47bfd9cff25f36a75ee21367e  lib/*.so   (150 libraries)
33683279473aa35b4d7418997201a9c75c031cb9e372257d5a0e4d165900f5c1  bin/       (285 entries)
```

These five hashes and two manifests are the acceptance baseline. Any change to
any of them invalidates the experiment.

### 16.3 Proposed build script — `build_a2a_comp_aocc_intelmpi.pbs`, NOT APPLIED

```bash
#!/bin/bash
#PBS -N aocc_impi
#PBS -P 59000020
#PBS -q normal
#PBS -l select=1:ncpus=128:mpiprocs=1:mem=400gb
#PBS -l walltime=00:30:00
#PBS -o outputs/build_a2a_comp_aocc_intelmpi_v1.o
#PBS -e outputs/build_a2a_comp_aocc_intelmpi_v1.e

# AOCC 5.0 application + Intel MPI 2025.1.3 runtime.
# Builds exactly one library: lib/intelmpi/libPstream.so
# Must not touch bin/, lib/*.so, lib/dummy/ or lib/sys-openmpi/.

set -eo pipefail
cd "$PBS_O_WORKDIR"
module purge
module load aocc/5.0
module load gcc/11.2.0            # libstdc++ only; identical to the control build
module load intel/2025.1.3
export PATH="/app/apps/aocc/5.0/bin:${PATH}"
export I_MPI_ROOT=/app/apps/oneapi/2025.1.3/mpi/latest
export PATH="${I_MPI_ROOT}/bin:${PATH}"

[[ -e "${I_MPI_ROOT}/include/mpi.h" ]]              || { echo "no mpi.h"  >&2; exit 1; }
[[ -e "${I_MPI_ROOT}/lib/release/libmpi.so" ]]      || { echo "no libmpi" >&2; exit 1; }
ldd "${I_MPI_ROOT}/lib/release/libmpi.so.12" | grep -q "not found" && {
    echo "Intel MPI has unresolved dependencies" >&2; exit 1; }

export FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
OF="${FOAM_INST_DIR}/OpenFOAM-v2512"

# ---- baseline BEFORE ------------------------------------------------------
P="${OF}/platforms/linux64AmdDPInt32Opt"
BEFORE_BIN="$(sha256sum "${P}/bin/simpleFoam"                | cut -d' ' -f1)"
BEFORE_OF="$( sha256sum "${P}/lib/libOpenFOAM.so"            | cut -d' ' -f1)"
BEFORE_FV="$( sha256sum "${P}/lib/libfiniteVolume.so"        | cut -d' ' -f1)"
BEFORE_KH="$( sha256sum "${P}/lib/libkahipDecomp.so"         | cut -d' ' -f1)"
BEFORE_OMPI="$(sha256sum "${P}/lib/sys-openmpi/libPstream.so"| cut -d' ' -f1)"
BEFORE_LIBS="$(ls -l "${P}"/lib/*.so | awk '{print $5, $9}' | sed 's|.*/||' | sort | sha256sum | cut -d' ' -f1)"
BEFORE_BINS="$(ls -l "${P}"/bin/     | awk '{print $5, $9}' | sort | sha256sum | cut -d' ' -f1)"

cd "${OF}"
set +eu
source etc/bashrc WM_COMPILER=Amd WM_MPLIB=INTELMPI \
    WM_COMPILE_OPTION=Opt WM_LABEL_SIZE=32
set -eu

# NOTE: FOAM_EXTRA_LD_LIBRARY_PATH deliberately left unset at BUILD time.
# The existing scratch libfabric is applied at RUN time in both arms.

[[ "${WM_OPTIONS}" == "linux64AmdDPInt32Opt" ]] || { echo "WM_OPTIONS drifted: ${WM_OPTIONS}" >&2; exit 1; }
[[ "${FOAM_MPI}"   == "intelmpi" ]]             || { echo "FOAM_MPI=${FOAM_MPI}" >&2; exit 1; }
[[ "${MPI_ARCH_PATH}" == "${I_MPI_ROOT}" ]]     || { echo "MPI_ARCH_PATH=${MPI_ARCH_PATH}" >&2; exit 1; }
echo "WM_OPTIONS=${WM_OPTIONS} FOAM_MPI=${FOAM_MPI} MPI_ARCH_PATH=${MPI_ARCH_PATH}"
echo "FOAM_MPI_LIBBIN=${FOAM_LIBBIN}/${FOAM_MPI}"

# ---- the ONLY build step --------------------------------------------------
# Deliberately NOT src/Pstream/Allwmake: that would relink lib/dummy/libPstream.so
wmake libso src/Pstream/mpi

# ---- verification ---------------------------------------------------------
NEW="${FOAM_LIBBIN}/${FOAM_MPI}/libPstream.so"
[[ -x "${NEW}" ]] || { echo "libPstream not produced" >&2; exit 1; }

fail=0
chk() { local n="$1" b="$2" f="$3"; local a
        a="$(sha256sum "$f" | cut -d' ' -f1)"
        if [[ "$a" != "$b" ]]; then echo "CHANGED: $n ($b -> $a)" >&2; fail=1
        else echo "unchanged: $n"; fi; }
chk simpleFoam           "$BEFORE_BIN"  "${P}/bin/simpleFoam"
chk libOpenFOAM.so       "$BEFORE_OF"   "${P}/lib/libOpenFOAM.so"
chk libfiniteVolume.so   "$BEFORE_FV"   "${P}/lib/libfiniteVolume.so"
chk libkahipDecomp.so    "$BEFORE_KH"   "${P}/lib/libkahipDecomp.so"
chk sys-openmpi/Pstream  "$BEFORE_OMPI" "${P}/lib/sys-openmpi/libPstream.so"

AFTER_LIBS="$(ls -l "${P}"/lib/*.so | awk '{print $5, $9}' | sed 's|.*/||' | sort | sha256sum | cut -d' ' -f1)"
AFTER_BINS="$(ls -l "${P}"/bin/     | awk '{print $5, $9}' | sort | sha256sum | cut -d' ' -f1)"
[[ "$AFTER_LIBS" == "$BEFORE_LIBS" ]] || { echo "CHANGED: lib/ manifest" >&2; fail=1; }
[[ "$AFTER_BINS" == "$BEFORE_BINS" ]] || { echo "CHANGED: bin/ manifest" >&2; fail=1; }
[[ "$fail" -eq 0 ]] || { echo "REFUSING: build perturbed preserved artefacts" >&2; exit 1; }

echo "--- new library ---"
ls -l "${NEW}"; sha256sum "${NEW}"
echo "--- DT_NEEDED (must show libmpi.so.12, NOT libmpi.so.40) ---"
objdump -p "${NEW}" | awk '/NEEDED/{print $2}'
echo "BUILD_OK aocc-intelmpi"
```

### 16.4 Runtime linkage checks before any timed run

Executed once per arm, on a compute node, before the paired screen:

```sh
# candidate arm environment
export LD_LIBRARY_PATH="${FOAM_LIBBIN}/intelmpi:${I_MPI_ROOT}/lib/release:${I_MPI_ROOT}/lib:${FABRIC_DIR}:${LD_LIBRARY_PATH}"

ldd "${FOAM_APPBIN}/simpleFoam" | grep -E 'libPstream|libmpi|libfabric'
#   expect: libPstream.so  -> .../lib/intelmpi/libPstream.so
#           libmpi.so.12   -> /app/apps/oneapi/2025.1.3/mpi/latest/lib/release/libmpi.so.12
#           libfabric.so.1 -> <same path as the control arm>
```

| Check | Control expectation | Candidate expectation |
| --- | --- | --- |
| `simpleFoam` sha256 | `7846a125…` | **identical** |
| `libOpenFOAM.so` sha256 | `aff8690f…` | **identical** |
| `libPstream.so` resolved path | `lib/sys-openmpi/` | `lib/intelmpi/` |
| `libPstream.so` sha256 | `06681957…` | **different** (this is the intended change) |
| `libmpi` soname | `libmpi.so.40` | `libmpi.so.12` |
| `libfabric.so.1` resolved path + sha256 | scratch 1.25.0 | **identical to control** |
| Rank affinity map | captured | **must match control** |

### 16.5 Success criteria

**Build stage.** `BUILD_OK`; all five preserved hashes and both directory
manifests unchanged; `lib/intelmpi/libPstream.so` exists and its `DT_NEEDED`
lists `libmpi.so.12` and not `libmpi.so.40`.

**Linkage stage.** Every row of the §16.4 table satisfied on a compute node,
including identical `libfabric` resolution and matching affinity maps.

**Correctness stage.** 40-step run completes with `End`, finite residuals, no
`NaN`, and a Cd trajectory at step 40 within the pre-agreed tolerance of the
control.

**Performance stage.** Paired A-B-B-A design, primary metric and repeat
structure exactly as §10 and §12.3. Decision bands unchanged: <1% noise,
1–3% requires 150-step validation, ≥3% is a screening win.

### 16.6 Residual risks specific to this route

| # | Risk | Mitigation |
| --- | --- | --- |
| R14 | **Launcher/placement confound.** Hydra versus PRTE; the registry already shows a 2.2× placement discrepancy between these launchers at 64 ranks/node. | Mandatory affinity probe with identical launcher arguments; §12.4 gate 4 fails the comparison if maps differ. Use 128 ranks/node, where both stacks are known to behave. |
| R15 | AOCC clang may reject something in Intel MPI's `mpi.h`. | The build is a 1-node, 30-minute, zero-risk test; it either compiles or it does not. Nothing else is touched. |
| R16 | Intel MPI default fabric/provider selection on these nodes is not recorded for the ICX runs. | Record `I_MPI_FABRICS`, `I_MPI_OFI_PROVIDER` and `FI_PROVIDER` in the provenance block; the harness already prints them. |
| R17 | Reduction order differs, so bitwise-identical fields are not expected. | Gate on the Cd/residual tolerance agreed in advance, per R10. |
| R18 | `libptscotchDecomp.so` absent from `lib/intelmpi/`. | Intentional. Not loaded with a frozen KaHIP partition. Would only matter if someone re-ran `decomposePar` with `ptscotch` under this arm — which the design forbids. |

### 16.7 Stop point

Audit only. No build, no submission, no remote write. The next authorized action
is the 1-node, 30-minute `build_a2a_comp_aocc_intelmpi.pbs` of §16.3, whose sole
purpose is to prove the link works and the preserved artefacts are untouched.

---

# Revision 4 — 2026-09-18 (hierarchical split coverage and profiling baseline)

Read-only analysis of retained `10_decomposePar.log` files. No job, no build,
no remote write.

## 17. Hierarchical `(x y z)` coverage audit

### 17.1 What was actually tested

Every hierarchical run, by resource tier and `nHierarchical` value:

| Tier | `(x y z)` values tested | Runs |
| --- | --- | ---: |
| 1 node / 128 ranks | `(16 4 2)`, `(8 8 2)`, `(8 4 4)`, `(4 8 4)` | 9 |
| 2 nodes / 256 ranks | `(8 8 4)` only | 5 |
| 4 nodes / 256 ranks | `(8 8 4)` only | 6 |
| **4 nodes / 512 ranks** | **`(8 8 8)` only** | **6** (3 compilers × bound/unbound) |

Confirmed: the scored tier has **one** hierarchical split and no second
512-rank hierarchical point to compare against. The registry claim is exact —
the supported statement is "KaHIP is 16.68% faster than the tested `(8 8 8)`",
not "faster than hierarchical in general".

### 17.2 The 1-node splits, re-analysed with partition metrics

All four 1-node AOCC cases retain their decomposition logs, so the split
sweep can be given topology as well as timing at zero SU cost:

| Split | Distinct cut faces | proc faces/rank max | proc faces/rank mean | Neighbours mean | s/step |
| --- | ---: | ---: | ---: | ---: | ---: |
| KaHIP | 1,566,478 | 51,731 | 24,476 | 9.70 | **13.333** |
| `(16 4 2)` | 2,109,346 | 131,252 | 32,959 | 9.08 | 13.445 |
| `(8 4 4)` | 2,317,968 | 195,170 | 36,218 | 9.73 | 13.664 |
| `(8 8 2)` | 2,372,207 | 139,052 | 37,066 | 9.52 | 13.499 |
| `(4 8 4)` | 2,992,854 | 188,079 | 46,763 | 9.39 | 13.836 |

Cut size and runtime are monotone apart from one inversion (`(8 4 4)` vs
`(8 8 2)`, which swap under total cut but order correctly under max-per-rank).
Cell imbalance is 1.0000 for every hierarchical split, so H1 is refuted at
1 node as well as at 4 nodes.

### 17.3 The on-node versus off-node cost of a cut, calibrated

Two comparisons with almost identical *relative* cut increases, at different
node counts:

| Comparison | Cut increase | Time increase | Normalised to +100% cut |
| --- | ---: | ---: | ---: |
| 1 node, KaHIP → `(4 8 4)` | +91% | +3.77% | ≈ **+4.1%** |
| 4 nodes, KaHIP → `(8 8 8)` | +104% | +16.68% | ≈ **+16.0%** |

At one node the entire cut is intra-node. The ≈12 percentage-point difference
is the part of the penalty that appears only once cut faces cross a node
boundary. This is an association drawn from two pairs, not a proven causal
split, but it is calibrated evidence rather than the order-of-magnitude bound
of §7.6, and it points the same way: **H2, dominated by the off-node component.**

### 17.4 Why `(8 8 8)` is close to the worst available choice

Cut faces can be attributed to a cutting axis exactly, because
`hierarchicalGeomDecomp` with the default `xyz` order numbers ranks as
`rank = i + nx·j + nx·ny·k`, so a neighbour pair's index difference identifies
the plane normal. For the 512-rank `(8 8 8)` case:

| Plane normal | Cut faces | Share | Planes | **Faces per plane** |
| --- | ---: | ---: | ---: | ---: |
| x | 228,900 | 4.0% | 7 | **32,700** |
| y | 795,368 | 14.0% | 7 | **113,624** |
| z | 3,769,475 | 66.4% | 7 | **538,496** |
| diagonal / staircase | 885,928 | 15.6% | — | — |

**Cutting in z costs 16.5× more per plane than cutting in x**, and `(8 8 8)`
spends a third of its planes there, producing two thirds of the cut.

It is worse than that. With 128 ranks per node and blocked rank placement,
`node = rank ÷ 128 = k ÷ 2`, so the three node boundaries are **z-planes**:
3 × 538,496 = 1,615,488 faces, which with the staircase term accounts for the
measured 2,048,418 inter-node faces of §7.5. `(8 8 8)` therefore both cuts the
most expensive axis the most times **and** routes every node boundary through
that same axis.

A split that reduces `nz` and increases `nx` should be substantially better.
**This analysis does not predict which split is best.** A separable per-axis
model is not supported by the data: `ny = 8` costs 113,624 faces/plane inside
`(8 8 8)` but 151,410 inside `(4 8 4)`, so the axes interact through the
staircase term. Any candidate must be measured, not extrapolated.

### 17.5 Recommendation — close the gap with `decomposePar`, not with 4-node runs

`decomposePar` is **serial**. It needs one node and does not need the solver, so
the entire `(x y z)` question can be answered from partition topology at roughly
one tenth the cost of running the comparison:

| Route | What it buys | Approx. cost |
| --- | --- | ---: |
| Decompose-only sweep, 1 node, 6 candidate splits | Full §7 metric set per split: cut, per-rank max, axis attribution, inter-node surface under the assumed mapping | ~13 SU each ≈ **80 SU** |
| One 4-node/512 confirmation of the best-on-paper split | The single extra timing point the report needs | ≈ **170 SU** |
| **Total** | Supports "KaHIP beats the best hierarchical split we could find" | **≈ 250 SU** |
| Running all 6 splits at 4 nodes instead | Same conclusion | **> 1,000 SU** |

Suggested candidates, chosen to move planes out of z and into x:
`(16 8 4)`, `(32 4 4)`, `(16 16 2)`, `(8 16 4)`, `(32 8 2)`, plus `(8 8 8)`
re-decomposed as an in-sweep control.

**Priority: low.** KaHIP already wins and is banked; a better hierarchical split
does not improve the score. This work buys report honesty — the difference
between "KaHIP beats the tested `(8 8 8)`" and "KaHIP beats the best
hierarchical split we found" — and nothing else. It should not precede §18.

## 18. Which baseline profiling should use

### 18.1 The baseline

> **AOCC 5.0 / Open MPI 5.0.10 / KaHIP / 4 nodes × 128 = 512 ranks / bound
> (`--bind-to core --map-by ppr:128:node:PE=1`) / stock `Opt`** — the
> 2.869257 s/step configuration.

Reasons:

1. It is the configuration that would actually be submitted, and it is the
   **control arm** of the Intel MPI screen of §15–§16. Profiling it produces
   numbers that are directly reusable.
2. Profiling `hierarchical (8 8 8)` instead would characterise a configuration
   already abandoned, and one with a different numerical trajectory (~109×
   pressure final residual, §3), so its time breakdown would not transfer.
3. The PGO platform must not be used: 1-node `PgoUse` is 14.252 against
   `Opt` KaHIP 13.333, a **6.9% regression**, above the noise threshold.
4. `Opt` bound versus unbound differ by 0.23%, inside noise; pick **bound**
   because that is what the screen and any scored run would use.

### 18.2 Ordering change — profile before spending SU on the MPI screen

The plan currently spends ≈600 SU on the paired Intel MPI screen without any
measurement of how much of a step is MPI at all. The profile sets the ceiling:

| Profiled MPI share of a step | Implication for the Intel MPI screen |
| --- | --- |
| ≲ 5% | A 3% screening win is close to the theoretical maximum. The screen is low value; spend the SU elsewhere. |
| 10–25% | The screen is the right experiment; proceed as designed. |
| ≳ 30% | The screen is high value, and collective-versus-point-to-point breakdown should steer the follow-up. |

Profiling is therefore promoted **above** the MPI screen in the ladder, not
below it. One 4-node profiled run costs about the same as one screen arm.

### 18.3 Apply the Cray lesson to the profiler

The Cray route died because a module visible on the login node was not usable
on compute nodes (three probes, §Revision 3). `linaro-forge/25.0.2`,
`perftools-lite` and `papi` are visible on the ASPIRE2A login node and that
proves nothing. **The first profiling action must be a 1-node, few-minute probe
that the profiler loads, licenses and attaches on a compute node** — not a
4-node profiled production run.

Cheapest ladder, in order:

1. **`I_MPI_STATS` (zero extra tooling, Intel MPI arm only).** Intel MPI can
   emit per-operation message counts, volumes and times from an environment
   variable alone — no licence, no external profiler. This is a reason to build
   the Intel MPI arm of §16 even if its *timing* turns out uninteresting: it is
   the cheapest communication profile available. To be verified for 2025.1.3.
2. **`perftools-lite`** on a 1-node probe, then 4 nodes if it attaches.
3. **`linaro-forge`** only if 1 and 2 fail; licence availability is unverified.

### 18.4 What the profile must separate

Point-to-point exchange, collectives and reductions, and computation — reported
per rank so the §7.3 tail can be tested directly. The specific prediction to
test: the eight `(8 8 8)` ranks carrying >150,000 interface faces should show
the rest of the job waiting on them. Under KaHIP, where the worst rank carries
21,408 faces, no such concentration should appear.

### 18.5 Revised next-action order

| # | Action | Cost | Gate |
| --- | --- | ---: | --- |
| 1 | 1-node profiler availability probe on a compute node | ~15 SU | Profiler attaches and reports |
| 2 | Profile the §18.1 baseline, 4 nodes, 40 steps | ~170 SU | MPI share measured |
| 3 | Intel MPI build (§16.3), 1 node | ~15 SU | 7 preserved hashes unchanged |
| 4 | Paired Intel MPI screen (§12.3) — **only if step 2 shows ≳10% MPI share** | ~600 SU | §12.4 gates |
| 5 | Hierarchical `(x y z)` decompose-only sweep (§17.5) | ~250 SU | Report honesty only; lowest priority |

---

# Revision 5 — 2026-09-18 (strategy reset: ASPIRE2A as Gadi reconnaissance)

**Direction change, user decision 2026-09-18.** Hierarchical `(x y z)` work of
§17.5 is **cancelled**. Gadi becomes first priority once the additional SU
arrives. ASPIRE2A work is re-scoped from "produce a result" to "**find the
fastest combination cheaply so that Gadi SU is not wasted**". Sections 19–21
replace the §18.5 action order.

All of §19 is computed from retained `10_decomposePar.log` files. **Zero SU
spent.**

## 19. Decomposition: scotch versus KaHIP, and the headroom that is left

### 19.1 Four 512-rank partitions, same mesh, same AOCC/Open MPI stack

| Metric | KaHIP | scotch | scotch+weights | hierarchical `(8 8 8)` |
| --- | ---: | ---: | ---: | ---: |
| **s/step** | **2.8759** | 2.9124 | 2.9052 | 3.3555 |
| Distinct cut faces | 2,786,035 | 2,927,022 | 3,033,594 | 5,679,671 |
| Communicating rank pairs | 2,757 | 2,887 | 2,895 | 2,901 |
| Cells max / min | 128,882 / 114,134 | 128,975 / 126,323 | 128,953 / 125,409 | 127,613 / 127,606 |
| Cell imbalance (max/mean) | 1.00999 | 1.01072 | 1.01055 | 1.00005 |
| proc faces/rank mean | 10,883 | 11,434 | 11,850 | 22,186 |
| proc faces/rank max | 21,408 | 22,214 | 22,829 | 214,672 |
| proc faces max/mean | 1.967 | 1.943 | 1.927 | 9.676 |
| Neighbours mean / max | 10.77 / 37 | 11.28 / 66 | 11.31 / 55 | 11.33 / 21 |
| **Inter-node faces** | **213,435** | **337,324** | **271,614** | **2,048,418** |
| Inter-node fraction | 7.66% | 11.52% | 8.95% | 36.07% |
| Inter-node max per rank | 6,355 | 11,786 | 10,451 | 109,291 |

### 19.2 What separates scotch from KaHIP — locality, not cut size

Total cut differs by only **4.8%** (2.79M vs 2.93M), but off-node surface differs
by **58%** (213k vs 337k). scotch and KaHIP produce partitions of nearly equal
global quality; KaHIP happens to place its subdomains so that far less of the
cut lands on a node boundary.

`scotch + domainWeights (1 0.01)` is the clean confirmation. Relative to plain
scotch it makes the **total cut worse** (+3.6%) while making **off-node traffic
better** (−19.5%) — exactly what the weighting is for — and it is the faster of
the two. Total cut therefore predicts the wrong sign for this pair; off-node
surface predicts the right one.

Fitting `s/step` against each candidate driver across all four partitions:

| Model | Slope | R² | Orders the three near partitions correctly? |
| --- | ---: | ---: | --- |
| **vs inter-node faces** | **2.58 × 10⁻⁷ s/face** | 0.9993 | **Yes** (KaHIP < scotch+w < scotch) |
| vs total cut faces | 1.65 × 10⁻⁷ s/face | 0.9980 | **No** — reverses scotch and scotch+w |

The pairwise marginal costs against KaHIP are mutually consistent:
scotch **2.95 × 10⁻⁷**, hierarchical **2.61 × 10⁻⁷** s per off-node face, a 13%
spread across a 15× difference in magnitude.

**Caveat, stated plainly.** R² is dominated by the hierarchical point; the three
near partitions are separated by 0.25–1.3%, which is at or below the 0.79%
between-run noise of §12.2, and every value is a single run. The *direction* and
the *slope* are well supported; the ranking of scotch versus scotch+weights is
not. This is why profiling is still required — the model says *what* correlates,
not *why*.

### 19.3 The headroom bound — decomposition is finished

Applying the fitted slope to each partition's own off-node surface gives the
portion of a step attributable to off-node communication:

| Partition | Inter-node faces | Implied off-node cost | Share of its own s/step |
| --- | ---: | ---: | ---: |
| hierarchical `(8 8 8)` | 2,048,418 | 0.529 s | 15.8% |
| scotch | 337,324 | 0.087 s | 3.0% |
| scotch+weights | 271,614 | 0.070 s | 2.4% |
| **KaHIP** | **213,435** | **0.055 s** | **1.9%** |

> **A hypothetically perfect partition with zero off-node traffic would save
> about 1.9% over KaHIP.** Going from hierarchical to KaHIP already recovered
> 0.477 s of a 0.532 s envelope — roughly 90% of everything decomposition had
> to give.

Even allowing a factor-of-two error in the slope, the remaining decomposition
headroom is under 4%. **Decomposition is closed. Do not spend further SU on it**
— neither on hierarchical splits (already cancelled), nor on scotch variants,
nor on chasing scotch-versus-KaHIP significance.

### 19.4 The untested KaHIP knobs, and why they stay unopened

`system/decomposeParDict` in every existing case reads:

```
kahipCoeffs
{
    config          fast;   // fast | eco | strong
    imbalance       0.01;
}
```

`eco` and `strong` exist in `kahipDecomp.C` (`configNames`, default `FAST`) and
have **never been tried**; `imbalance` has never been varied. These are
`decomposePar`-only parameters, cheap to sweep on one node, and fully
machine-independent.

They are nonetheless **low priority**, because §19.3 caps the entire prize at
~1.9%. A worthwhile use is as a *cheap ride-along*: if a 1-node job is being
submitted for another reason, add a `config strong` decomposition and read its
off-node count. If the fitted model predicts under ~1% gain — which it almost
certainly will — no 4-node confirmation is warranted.

### 19.5 Correctness finding: hierarchical is outside the official Cd window

The rules audit records the required 4-node/150-step target as **Cd ≈ 0.28–0.29**.
Measured final Cd at step 150:

| Partition | Cd(150) | Inside 0.28–0.29? |
| --- | ---: | --- |
| KaHIP | 0.28004 | yes |
| scotch | 0.28405 | yes |
| scotch+weights | 0.28855 | yes |
| **hierarchical `(8 8 8)`** | **0.29843** | **no — above the window** |

Independently of performance, hierarchical `(8 8 8)` fails the correctness
target. Cancelling it was the right call for two reasons, not one.

## 20. ASPIRE2A → Gadi transferability

The two machines differ in ways that decide which ASPIRE2A findings are worth
anything on Gadi.

| | ASPIRE2A | Gadi `normalsr` (scored) |
| --- | --- | --- |
| CPU | AMD Milan, Zen 3 | Intel Sapphire Rapids |
| Vector ISA | AVX2 — **no AVX-512** | **AVX-512** |
| Cores per node | 128 | 104 |
| 4-node rank count | 512 | **416** |
| Toolchain in use | AOCC 5.0 private build | Site `OpenFOAM/2512`, GCC 8.5.0, Open MPI 4.1.7 |
| Current decomposition | KaHIP | **hierarchical `(16 13 2)`** |
| Best 4-node result | 2.875901 s/step | 2.139565 s/step |

### 20.1 What transfers

| Lever | Testable on ASPIRE2A | Transfers to Gadi | Note |
| --- | --- | --- | --- |
| **Decomposition method** | ✅ done | **HIGH** | A graph property of mesh + rank count, not of the CPU. The single most valuable ASPIRE2A finding. |
| Decomposition tuning (`config`, `imbalance`) | ✅ cheap | HIGH | But capped at ~1.9% by §19.3. |
| The partition files themselves | — | **none** | 512 ranks ≠ 416 ranks. The *method* transfers; the partition must be regenerated. |
| `renumberMesh` ordering | ✅ | medium | Cache locality; Gadi's cache hierarchy differs. |
| Ranks per node / SMT | ✅ | low | 128 versus 104 cores changes the answer. |
| Binding / placement | ✅ | medium | Same principles, different launcher and topology. |
| MPI implementation | ✅ | **low–medium** | Different fabric and different Open MPI generation (5.0.10 vs 4.1.7). A ranking found here need not hold there. |
| **Compiler (AOCC 5.0)** | ✅ | **ZERO** | AOCC is an AMD compiler. Nothing about it informs an Intel SPR target. |
| **AVX-512 / `-march` targeting** | ❌ **impossible** | **Gadi-only, and the largest known lever** | See §20.2. |
| PGO | ✅ (refuted: −6.9% at 1 node) | low | Would have to be redone per machine anyway. |

### 20.2 The Gadi lever ASPIRE2A cannot test

`workflow/gadi-cluster-config.md` records, from disassembly of the shipped site
binary:

```text
simpleFoam      zmm=0  ymm=0      xmm=3027
libOpenFOAM     zmm=0  ymm=19162
libfiniteVolume zmm=0  ymm=92169
```

**Zero AVX-512 anywhere in the hot path**, on hardware (`normalsr`, Sapphire
Rapids) that has it. This is a private-rebuild opportunity worth potentially far
more than anything measured on ASPIRE2A — and Zen 3 has no AVX-512, so ASPIRE2A
**cannot** screen it even in principle. It must be done on Gadi, with Gadi SU.

### 20.3 Consequence for the ASPIRE2A programme

ASPIRE2A is a good proxy for **algorithm-level** choices and a poor proxy for
**toolchain-level** ones. Concretely:

- The decomposition finding is banked, transferable, and now bounded. **Done.**
- The Intel MPI screen of §15–§16 is *methodologically* sound but its result is
  low-transfer. It is now justified mainly by two side benefits: `I_MPI_STATS`
  gives a free communication profile (§18.3), and Gadi also offers Intel MPI, so
  a positive result is at least re-testable there. **Demote from "next" to
  "opportunistic".**
- AOCC/PGO/znver3 work has **zero** Gadi value. Stop.

## 21. Revised action order

| # | Action | Where | Cost | Why now |
| ---: | --- | --- | ---: | --- |
| 1 | **Read-only Gadi audit** — does the site `OpenFOAM/2512` ship `libkahipDecomp.so` / `libscotchDecomp.so`? What is the `normalsr` 416-rank decomposition and its Cd? | Gadi login | **0 SU** | Decides whether the single highest-value ASPIRE2A finding is even actionable on Gadi. Blocked only on restoring `ssh -MNf gadi-comp`. |
| 2 | Profiler availability probe on a compute node | ASPIRE2A, 1 node | ~15 SU | §18.3. Applies the Cray lesson: login-node visibility proves nothing. |
| 3 | **Profile the §18.1 baseline** — AOCC/Open MPI/KaHIP/512/bound | ASPIRE2A, 4 nodes | ~170 SU | Answers item 1 properly: where does the *other* 98% of the step go, now that off-node comms is bounded at 1.9%? Also gates action 5. |
| 4 | Gadi 416-rank KaHIP versus the existing hierarchical `(16 13 2)` baseline | **Gadi** | Gadi SU | The transfer test. Highest expected value of any single run in the project. |
| 5 | Intel MPI paired screen (§12.3) — **only if action 3 shows ≳10% MPI share** | ASPIRE2A | ~600 SU | Demoted; low transfer value. |
| 6 | Gadi private rebuild with AVX-512 targeting | **Gadi** | Gadi SU | Largest known Gadi lever; unscreenable on ASPIRE2A. Sequence after action 4. |
| — | ~~Hierarchical `(x y z)` sweep~~ | — | — | **Cancelled** (user decision; also fails the Cd window, §19.5). |
| — | ~~Further AOCC / PGO / znver3 work~~ | — | — | **Cancelled** — zero Gadi transfer value. |

**Open question that action 3 must answer.** With off-node communication bounded
at ~1.9% of a step and solver iteration counts fixed by the rules
(`fvSolution` may not be changed), the remaining ~98% is compute, memory
traffic, and intra-node exchange. Nobody has measured how that splits. Until
that profile exists, every further optimisation proposal on either machine is a
guess.

---

# Revision 6 — 2026-09-18 (Gadi audit + senior-team slides; §20.2 CORRECTED)

**Provenance warning.** §23 summarises photographed slides from another team's
presentation, relayed by the user. It is second-hand data that this project has
not reproduced. Treat every number in §23 as a claim to verify, not as our own
evidence. It is recorded because it changes our priorities materially.

## 22. Gadi read-only audit (login node, 0 SU)

### 22.1 KaHIP and scotch are available in the site module — no rebuild needed

`/apps/OpenFOAM/2512/platforms/linux64GccDPInt32Opt/lib/`:

```text
libdecompose.so  libdecompositionMethods.so  libfaDecompose.so
libkahipDecomp.so   libscotchDecomp.so
```

Real implementations, not stubs:

| Library | main `lib/` | `lib/dummy/` |
| --- | ---: | ---: |
| `libkahipDecomp.so` | **80,808 B** | 32,520 B |
| `libscotchDecomp.so` | **95,440 B** | 37,208 B |

`nm -D` shows 34 defined KaHIP symbols and `DT_NEEDED` includes `libkahip.so`,
confirming a real KaHIP backend. **The highest-value transferable ASPIRE2A
finding is actionable on Gadi with the stock module and zero build.**

### 22.2 Toolchain inventory versus what the senior team used

| Senior champion component | Gadi module status | Build required? |
| --- | --- | --- |
| **GCC 16.2** | ❌ newest is `gcc/15.1.0` | **yes** |
| **ICX 2026.1** | ❌ newest is `intel-compiler-llvm/2025.3.2` | **yes** |
| **Open MPI 5.0.10 (+UCX)** | ❌ newest is `openmpi/5.0.8` | **yes** |
| Open MPI 5.0.8 (their build "F") | ✅ `openmpi/5.0.8` | no |
| **Intel MPI 2021.18** (their H2, "own install") | ❌ newest is `intel-mpi/2021.17.2` | **yes** |
| Intel MPI 2021.17 (their H1, "module") | ✅ `intel-mpi/2021.17.2` | no |
| UCX 1.18 | ✅ `ucx/1.18.1` | no |
| UCC 1.4 | ✅ `ucc/1.4.4` | no |
| scotch 6.1.0 | no standalone module; bundled in the OpenFOAM site build | no |

The user's reading is correct: **GCC 16.2, ICX 2026 and Open MPI 5.0.10 are all
absent from Gadi and would have to be built.** The two ingredients the UCX
rebuild actually needs — `ucx/1.18.1` and `ucc/1.4.4` — are already present.

**Builds are not free.** `results/hpc-lessons.md` L1 records a compiler build on
48 `normal` cores billed at **38.61 SU** for ~24 minutes of real work, with a
much larger reservation held against the requested walltime. A GCC 16.2
bootstrap is a multi-hour job; budget on the order of 100–200 SU. Against a
2026.q4 grant of 1000 SU that is roughly one scored 4-node run per compiler.

## 23. Senior-team results (second-hand; to verify)

### 23.1 Their four-node ladder (416 ranks, 150 iterations, scotch)

| Step | Configuration | s/step | vs baseline |
| --- | --- | ---: | ---: |
| B0 | hierarchical (module) | 2.4925 | — |
| B0 | **scotch (module)** | **2.0752** | **−16.7%** |
| F | GCC 16.2 + OMPI 5.0.8 | 2.0301 | −18.6% |
| H1 | ICX + Intel MPI 2021.17 | 1.9969 | −19.9% |
| H2 | ICX + Intel MPI 2021.18 | 1.9882 | −20.2% |
| G3 | GCC + OMPI 5.0.10-ucx | 1.9868 | −20.3% |
| G4a-v2 | **GCC 16.2 (AVX2-256) + OMPI 5.0.10-ucx + scotch 6.1.0** | **1.9834** | **−20.4%** |

n=2 repeats, spread 0.02%; Cd = 0.29198, in band.

> **The decisive ratio: of the total 20.4%, decomposition alone delivers 16.7%
> with a stock module and no build. Every compiler and MPI build combined
> delivers the remaining ~3.7%.** 82% of the prize is free.

### 23.2 Independent confirmation of our decomposition finding

They measured hierarchical → scotch on Gadi at **−16.7%**. We measured
hierarchical `(8 8 8)` → KaHIP on ASPIRE2A at **−16.68%**, on different
hardware, a different rank count and a different MPI. The transfer hypothesis
of §20.1 is confirmed by an independent measurement.

### 23.3 ⚠️ §20.2 is CORRECTED — AVX-512 is worth nothing here

Their 2-node vector ladder:

```text
SSE2 4.1093   AVX2 4.1061   AVX-512 4.1152 s/step   — all within ±0.15%
```

with **true 512-bit codegen verified (71k zmm instructions in libfiniteVolume)**.
At the scored config: GCC 16.2 SSE2 1.9854, GCC 16.2 AVX2 1.9834,
ICX 2026.1 SSE2 1.9882, ICX 2026.1 AVX2 1.9969 — a ~1% span.

**§20.2 claimed AVX-512 targeting was "the largest known lever" on Gadi. That
claim is wrong and is withdrawn.** The zero-AVX-512 site binary recorded in
`workflow/gadi-cluster-config.md` is a real observation, but it is not a missed
opportunity: the solver saturates memory bandwidth, so wider vectors add
register pressure and no throughput. **Do not spend Gadi SU on vectorisation.**

### 23.4 Why — the workload is memory-bandwidth-bound

| | Gadi `normalsr` | ASPIRE2A |
| --- | --- | --- |
| CPU | 2× Xeon Platinum 8470Q (SPR) | 2× EPYC 7713 (Milan) |
| Cores/node | 104 | 128 |
| Memory | DDR5-4800, 8 channels | DDR4-3200 |
| Node bandwidth | **614 GB/s** | 410 GB/s |
| **Per-rank streaming BW at full packing** | **5.9 GB/s** | 3.2 GB/s |

1.84× in Gadi's favour. Their profiling concludes the solver is
memory-bandwidth-bound, which explains the vector-width null result and is
consistent with our own §19.3 bound: off-node communication is only ~1.9% of a
KaHIP step, so the remaining ~98% is memory-bound compute and intra-node
traffic. **This answers the open question left at the end of §21** — though it
is their measurement, not ours.

### 23.5 Their MPI finding is a configuration trap, not a version race

| Build | MPI | s/step |
| --- | --- | ---: |
| F | OMPI 5.0.8 (module) | 2.0301 |
| H1 | Intel MPI 2021.17 (module) | 1.9969 |
| H2 | Intel MPI 2021.18 (own install) | 1.9882 |
| G3 | OMPI 5.0.10-ucx (NCI-style rebuild) | 1.9854 |
| G4a-v2 | OMPI 5.0.10-ucx | 1.9834 |

The headline is not the 2.3% spread. It is: *"stock OMPI 5.0.10 system pairing
silently fell back to **TCP** → 5.06 s/step versus 4.85"* on Cascade Lake, fixed
by rebuilding Open MPI the NCI way with UCX 1.18 + UCC 1.4 and static
components. **Verifying that the transport is not TCP is a correctness check
worth far more than any MPI version choice**, and it costs nothing but reading
`ompi_info` / UCX environment output on a compute node.

### 23.6 Unreconciled discrepancy — do not paper over it

| Source | 4-node Gadi `normalsr`, hierarchical | s/step |
| --- | --- | ---: |
| **Our** official run `178149002.gadi-pbs` | `(16 13 2)`, 416 ranks | **2.139565** |
| **Their** B0 baseline | hierarchical (module) | **2.4925** |

Our hierarchical baseline is **14.1% faster than theirs**, and only 3.1% slower
than their *scotch* result. Either their B0 used a worse hierarchical split than
`(16 13 2)`, or the two runs differ in something not visible on a slide.
**Until this is reconciled, their −16.7% cannot be assumed to apply on top of
our 2.139565 baseline.** The honest expectation for switching our own Gadi run
to scotch or KaHIP is unknown and may be much smaller than 16.7%.

## 24. Action order, revised again

| # | Action | Where | SU | Rationale |
| ---: | --- | --- | ---: | --- |
| 1 | **Gadi: our own 416-rank scotch and KaHIP runs against our `(16 13 2)` 2.139565 baseline** | Gadi | ~2×140 | Settles §23.6, and tests our one genuinely novel angle: the seniors used **scotch**; ASPIRE2A evidence says **KaHIP is ~1.25% better**. Stock module, no build. |
| 2 | **Transport sanity check** — confirm the scored run is on UCX/IB and has not fallen back to TCP | Gadi | ~0 | §23.5. Cheapest high-value check in the project. |
| 3 | Profile the ASPIRE2A baseline | ASPIRE2A | ~170 | Still worth it, but its conclusion is now partly pre-empted by §23.4. Demote if SU is tight. |
| 4 | Open MPI 5.0.10 + UCX 1.18 + UCC 1.4 NCI-style build | Gadi | ~100 | Largest single toolchain item at ~2.3%; both dependencies already exist as modules. |
| 5 | GCC 16.2 build | Gadi | ~150 | ~1%. Only if SU remains after 1–4. |
| 6 | ICX 2026 install | Gadi | ~100 | ~1%, and slower than GCC at their scored config. Lowest priority. |
| — | ~~AVX-512 / vectorisation targeting~~ | — | — | **CANCELLED — measured at zero (§23.3).** |
| — | ~~Intel MPI paired screen on ASPIRE2A~~ | ASPIRE2A | — | **Demote to opportunistic.** Their H1/H2 already show Intel MPI is competitive but not winning on Gadi. |
| — | ~~hierarchical `(x y z)`, AOCC, PGO, znver3~~ | — | — | Cancelled previously; unchanged. |

---

# Revision 7 — 2026-09-18 (correction: build cost, and current Gadi affordability)

**Correction to §24.** §24 items 1–6 were presented as if items 1–2 ("no build
required") were cheaper or more immediately actionable than items 4–6
("requires build"). That framing conflated *build vs. no-build* with *free vs.
not-free*. **Every PBS job on Gadi, build or solver run, is billed
`resources × hours × queue_rate`.** There is no free tier. All six items are
equally blocked right now by the actual balance.

## 25. Current Gadi affordability (re-verified 2026-09-18)

```
Usage Report: Project=pm78 Period=2026.q3
    Grant: 4.00 KSU   Used: 3.96 KSU   Reserved: 0.00 SU   Avail: 41.15 SU
```

Unchanged since 2026-09-16; no response yet from Pengzhi on the SU top-up
request. The 2026.q4 grant (1000 SU) activates 2026-10-01 and is not usable
yet.

| Queue / tier | Rate | Requested walltime 41.15 SU buys |
| --- | ---: | ---: |
| `normalsr` 4 nodes | 832 SU/h | **3.0 min** |
| `normalsr` 2 nodes | 416 SU/h | **5.9 min** |
| `normalsr` 1 node | 208 SU/h | **11.9 min** |

For scale: the documented cost of one real E0 baseline run is **~624 SU
billed, 1040 SU reserved** (§ cost model, `official-4n-optimization-matrix.md`).
**41.15 SU does not cover the PBS reservation for a single 4-node job of any
kind — build, screen, or confirmation.** §24 items 1–6 are all blocked
identically. There is no cheaper item among them to start with; none can start.

## 26. What was actually free, and what it found

Two read-only, no-job, no-SU actions performed on the login node:

**(a) Module provenance of the official baseline.** The retained
`run.log` for job `178149002.gadi-pbs` records
`Currently Loaded Modulefiles: 1) openmpi/4.1.7  2) OpenFOAM/2512` — the stock
NCI module, not a private rebuild.

**(b) Build-time transport components of that module (`ompi_info`, login
node).** `openmpi/4.1.7` is configured with
`--with-ucx=/apps/ucx/1.17.0 --with-ucc=/apps/ucc/1.3.0`, and ships
`pml: ucx`, `pml: ob1`, `pml: cm`, `btl: tcp`, `btl: vader`, `btl: smcuda`,
`btl: self`.

**Partial answer to §23.5's transport-fallback concern.** The official
baseline used an NCI-maintained module that is genuinely UCX/UCC-enabled at
build time, unlike the senior team's own from-source Open MPI 5.0.10 rebuild
attempt that reportedly fell back to TCP before their fix. This lowers, but
does not eliminate, the concern: `ompi_info` reports what was *compiled in*,
not what was *selected at run time*. Confirming actual `pml`/`btl` selection
requires `OMPI_MCA_pml_base_verbose=10` (or similar) inside a real job, which
is blocked by §25 like everything else.

## 27. Revised state — nothing on Gadi is actionable until the balance changes

All of §24's ranked list is deferred, without internal ordering, pending
either the SU top-up or 2026-10-01. Work that remains available:

- **ASPIRE2A** (17,194.5 SU as of 2026-09-16): profiling (§18), Intel MPI
  screen (§15–16, low Gadi-transfer value per §20.1) can continue.
- **Gadi, read-only only**: further login-node module/log archaeology of the
  kind in §26, and reconciling the §23.6 discrepancy from documentation alone
  where possible. No `qsub` of any kind.

---

# Revision 8 — 2026-09-19 (perf-report probe: FAILED, stop)

**Job:** `23486768.pbs101` (`of_prof1`), submitted 2026-09-18 20:27:01, queued
in `qdev` for ~5h27m (congested shared dev queue, `comment: would exceed
overall limit on resource ncpus in queue` throughout), started 2026-09-19
01:53:52 on `x1001c5s6b1n0`, `Exit_status = 0` (the wrapper script itself
completed and exited cleanly; the probe's internal result is a failure,
correctly caught and reported by the script rather than crashing it).

**Environment (from the job's own `module list -t`):**
`aocc/5.0`, `gcc/11.2.0`, `openmpi/5.0.10-gcc11`, `arm-forge/25.0.2`.
`perf-report --version`: Linaro Performance Reports 25.0.2, Build ID
`6c46782c4493617e7c1c92bebd1ca073685204e3`, built 2025-07-26.

## Result: STEP_A_FAILED

Trivial test — `perf-report --output=stepA_hostname mpirun --hostfile
"${PBS_NODEFILE}" -np 128 ... hostname` — full 268-line log preserved at
`~/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/probe_perfreport_1n_v1_23486768/stepA.log`
(not truncated; read in full, not just the script's own `tail -40`).

```text
Waiting for licence
Performance Reports: This version of Linaro Performance Reports is over a year old.
Performance Reports: Linaro only provide support for the most recent version of Linaro Performance Reports.
Performance Reports: Please consider upgrading. ...
Performance Reports: Check that Linaro Performance Reports is using the correct
  MPI implementation for your system and that you can start MPI programs
  without Linaro Performance Reports. If you accidentally configured your
  job to use MPI, deselect it.
Performance Reports: See "Starting a program" in the user guide for help
  troubleshooting startup issues.
Performance Reports: Thread -1 exited.
x1001c5s6b1n0
x1001c5s6b1n0
... (128 lines total, unprefixed)
```

`perf-report` exit code: **1**. No `stepA_hostname.txt`/`.html` produced.

**Diagnosis.** The license wait resolved (does not hang at "Waiting for
licence"; proceeds past it) — this is not a license-server-reachability
failure like the Cray MPICH case. The underlying `mpirun -np 128 hostname`
under Open MPI 5.0.10 executed correctly and completely: all 128 ranks
returned the correct compute-node hostname. **The failure is specifically in
perf-report's own runtime instrumentation/sampling layer** ("Thread -1
exited"), which detached before producing any report, while the wrapped job
ran to completion unmonitored. perf-report's own printed guidance ("Check
that Linaro Performance Reports is using the correct MPI implementation")
indicates it detected this failure mode itself.

Step B (short simpleFoam run under perf-report) was correctly never attempted
— the script's own `STEP_A_FAILED` gate stopped it, as designed.

## Same failure shape as the Cray MPICH probes, different tool

Login-node `perf-report --version` and `--help` worked cleanly (Revision 6/
§18.3 prior investigation). Compute-node reality: the underlying MPI launch
works, but the profiling tool's attach mechanism does not. This is now the
**second** independent confirmation on ASPIRE2A that login-node tool
visibility does not predict compute-node functionality (first: Cray MPICH/
libfabric, `MANUAL_INSPECTION_ERROR.md`).

## Stop condition — per explicit user instruction

The user instructed: if the probe fails, stop and report; do not try other
module combinations. Accordingly, **no further profiler variant was
attempted** — not a different `arm-forge` version, not `map`, not
`I_MPI_STATS`, not `perftools-lite` (already independently ruled out in
Revision 6/§18.3 for a different reason — requires relink), not `papi`, not
`darshan`. Both prepared diffs (§29 below) remain unsubmitted.

## 28. Consequence for the plan

- **§18.5 action 2 (profiler probe): FAILED.** The Arm/Linaro Forge route to
  profiling the AOCC/Open MPI/KaHIP baseline is closed pending further
  authorization to investigate (e.g. a different Forge version, or direct
  contact with NSCC support about compute-node Forge compatibility — neither
  attempted here).
- **§18.5 action 3 (profile the baseline, 4 nodes, ~170 SU): blocked.** The
  prepared diff (§29.1 below) cannot currently produce a profile; it is not
  submitted.
- **§18.5 action 4 (Intel MPI build, 1 node, ~15 SU): independent, still
  available.** Does not depend on perf-report. The prepared diff (§29.2 below)
  remains a valid, reviewable next step if the user chooses to authorize it
  separately.
- **Remaining un-exhausted profiling options from §18.3's ladder:**
  `I_MPI_STATS` (requires the Intel MPI build to exist first; untested),
  and direct OpenFOAM-side instrumentation are not ruled out — only Forge is,
  and only via this specific probe. None have been attempted.

## 29. Prepared diffs — still unsubmitted, unchanged from this session's earlier presentation

Both diffs were written to local files only, never uploaded or submitted.
Recorded here for provenance; content unchanged from when first shown.

### 29.1 `run_occdrivaer_profiled.sh` + `run_occdrivaer_4node_aocc_kahip_pin_profiled_v1.pbs`

New standalone files (do not modify the shared `run_occdrivaer.sh`, which
changed under concurrent teammate use during this session — confirmed by
diffing a fresh fetch against yesterday's cached copy, +18 lines of PGO
handling). Wraps the identical `${PAR} simpleFoam -parallel` launch line from
the baseline job `occdrivaer_4node_aocc_kahip_pin_v1`
(2.869256832046979 s/step) in `perf-report`. Adds a binary sha256 gate
(`7846a125...`) before running. Writes to a new `ATTEMPT`/case directory;
does not touch the archived baseline evidence. **Currently blocked by the
Revision 8 probe failure — do not submit until the profiler question is
resolved.**

### 29.2 `build_a2a_comp_aocc_intelmpi_v1.pbs`

Finalized from the plan's §16.3 draft: builds only
`platforms/linux64AmdDPInt32Opt/lib/intelmpi/libPstream.so` via
`wmake libso src/Pstream/mpi` (never `Allwmake`), gated by 5 file hashes + 2
directory manifests before and after, plus a new pre-check refusing to
proceed if `lib/intelmpi/libPstream.so` already exists (do not overwrite a
prior attempt). Confirmed at write time that no other build was in flight
(the sole other queued job, `23486682.pbs101`, is a solver run). **Not
gated by the profiler outcome — independently available for separate
authorization.**
