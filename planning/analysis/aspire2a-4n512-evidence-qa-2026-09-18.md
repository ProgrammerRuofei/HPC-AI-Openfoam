# ASPIRE2A 4-node / 512-rank decomposition evidence QA

**Date:** 2026-09-18. **Scope:** Independent read-only check of five retained AOCC 5.0 / Open MPI 5.0.10 runs. No new computation, build, scheduler action, remote modification, or edit to the ongoing screening report/scripts.

## 1. Provenance and comparability

The five PBS scripts request select=4:ncpus=128:mpiprocs=128:mem=400gb, place=scatter, 512 ranks, and 150 SIMPLE steps. They load aocc/5.0, gcc/11.2.0, and openmpi/5.0.10-gcc11, then use WM_COMPILER=Amd, WM_MPLIB=SYSTEMOPENMPI, and the same linux64AmdDPInt32Opt/bin/simpleFoam path. Each PBS stdout records ldd resolving libmpi.so.40 to /app/apps/openmpi/5.0.10-gcc11/lib/libmpi.so.40; original solver logs identify OpenFOAM v2512, 512 ranks on four hosts with 128 ranks per host, Time = 150, 149 measured step times, End, and Finalising parallel run. The retained .o files end in DRIVAER_OK. This establishes the recorded launch/run configuration, **not** a per-job binary hash, exact rank-to-host/core mapping, or independently queried PBS accounting status.

The four decomposition comparisons use mpirun with a PBS hostfile, --map-by ppr:128:node, and -np 512, with **no explicit bind option**. The fifth, KaHIP bound, adds --bind-to core and --map-by ppr:128:node:PE=1. “No explicit binding” does not prove that processes were actually unbound. Compare the first four directly as configured; keep the bound KaHIP result separate.

Remote SHA256 values match across all five for active fvSchemes (064bb504…), fvSolution (5e1db854…), controlDict (6aa140b6…), forceCoeffsAll (4a66f979…), 0.orig/U (bcec9e7b…), transportProperties (4994e93e…), and turbulenceProperties (aa80a06d…). caseDefinition changes with the selected method. Weighted Scotch also appends domains (4 8 16) and domainWeights (1 1 0.01) to decomposeParDict. Each original decomposition log sums to **65,334,765 cells**, but byte identity of the large source mesh and all initial files was not re-established here. The common binary path is not a preserved hash of the binary at each run time.

## 2. Direct measurements

The timing column is the original simpleFoam line “Average wall-clock time per time step”, not PBS walltime or ExecutionTime/150. Percentage is (run/KaHIP-unbound − 1) × 100. The five retained cases and local PBS .o/.e files are identified in §6.

| Method / setting | PBS job | Binding requested | Measured s/step | Vs unbound KaHIP | Cd(40 / 80 / 150) |
| --- | ---: | --- | ---: | ---: | --- |
| KaHIP fast, imbalance 0.01 | 20030922 | No explicit bind | **2.875901458550335** | reference | 0.434716 / 0.338902 / **0.280043747** |
| Scotch | 20064271 | No explicit bind | **2.912440185442953** | +1.2705% | 0.435469 / 0.336759 / **0.284050597** |
| Weighted Scotch, domains (4 8 16), weights (1 1 0.01) | 20072244 | No explicit bind | **2.905191457389262** | +1.0185% | 0.431943 / 0.338476 / **0.288550963** |
| Hierarchical (8 8 8) | 20061437 | No explicit bind | **3.355476165798657** | **+16.6756%** | 0.439100 / 0.338107 / **0.298429569** |
| KaHIP fast, imbalance 0.01 | 20092999 | Explicit core bind | **2.869256832046979** | −0.2310%; separate binding comparison | Same coefficient file as unbound KaHIP |

All five coefficient.dat files have 150 numeric rows and one Time-150 row. The two KaHIP coefficient files are byte-identical (SHA256 8e9b543c1f8780c154a86e9790d6d7e17e2770b4fe409f6df89b3e561d3bfda7). The Scotch, weighted Scotch, and hierarchical files have different trajectories. These are **one run per configuration**, with different allocations; the 1.0–1.3% Scotch gaps and 0.23% binding gap need same-system repeats before claims of robust ranking. The 16.68% hierarchical gap is much larger, though its numerical trajectory needs review.

The original decomposePar reports support these **mapping-independent** partition statistics. A processor face is reported once by each adjacent rank, so the paired cut below is half the summed processor-face count; parsing the rank-pair listings gives the same total.

| Method | Cells (sum) | Distinct cut faces | Max processor faces on one rank | Communicating rank pairs | Max cells / mean cells |
| --- | ---: | ---: | ---: | ---: | ---: |
| KaHIP, bound and unbound | 65,334,765 | 2,786,035 | 21,408 | 2,757 | 1.00999 |
| Scotch | 65,334,765 | 2,927,022 | 22,214 | 2,887 | 1.01072 |
| Weighted Scotch | 65,334,765 | 3,033,594 | 22,829 | 2,895 | 1.01055 |
| Hierarchical (8 8 8) | 65,334,765 | 5,679,671 | 214,672 (rank 135) | 2,901 | 1.00005 |

Hierarchical has **2.04×** the KaHIP cut and **10.03×** its worst-rank interface-face count despite more even cell counts. The log alone does not reveal bytes transferred, MPI wait, cache misses, or the cost of a face.

The four unbound simpleFoam logs show pressure p = 12 and Ux/Uy/Uz = 15/15/15 linear-solver iterations at every step; the bound KaHIP log agrees. For steps 100–150 inclusive, mean pressure initial→final residual is KaHIP 2.3243e−3 → 1.0589e−7 versus hierarchical 2.4573e−3 → 1.1524e−5 (about **109×** higher final residual). Mean absolute global continuity error is 3.0125e−8 versus 6.8142e−8. The measured step-time gap persists through the run. **Extra reported iterations do not explain the slowdown; a higher per-step cost and a changed numerical trajectory are observed.** The logs do not identify what part of each step consumed that extra time.

## 3. Estimated topology and the “1.9% remaining” claim

Grouping ranks 0–127, 128–255, 256–383, and 384–511 into four nodes yields the following **conditional cross-node interface-face counts** from the original rank-pair listings: KaHIP **213,435**, Scotch **337,324**, weighted Scotch **271,614**, hierarchical **2,048,418**. The solver logs list four hosts at 128 ranks each, and the command requests ppr:128:node, but no retained per-rank hostname/affinity manifest proves that *these specific rank blocks* occupied those nodes. Even if the assumed mapping is correct, an interface-face count is **not** measured network traffic or MPI time.

The screening report fits the four single-run (conditional faces, s/step) points with an intercept and slope of about 2.58e−7 s/face (R² ≈ 0.9993). Multiplying that slope by KaHIP's 213,435 assumed cross-node faces gives **0.0551 s/step**, or **1.915%** of 2.875901 s/step. Repeating the arithmetic confirms the report's number, but **does not validate its interpretation**:

- The four points vary in many coupled properties: total cut, worst-rank surface, numerical trajectory, and possibly rank placement. The fit is dominated by the distant hierarchical point; excluding it leaves three single-run near points and R² ≈ 0.869. ASPIRE2A between-run variation is not measured. The report's 0.79% noise estimate comes from Gadi and cannot be an ASPIRE2A uncertainty bound.
- A fitted association is not an MPI timing decomposition. The slope has not been measured as marginal network cost; the intercept is not proven “all other work.” Zero cross-node faces is an extrapolation and is not shown to be a feasible 512-rank partition.
- Decomposition may change on-node communication, local work, memory behavior, and numerical convergence. Therefore **“only 1.9% partition space remains,” “90% of all decomposition gain recovered,” and “decomposition is closed” are not evidence-backed bounds**. The defensible statement is narrower: *for these four partitions under the assumed mapping, estimated cross-node interface area tracks their single-run time ranking*. Profiling and repeated controlled runs are needed for causal attribution or a headroom estimate.

## 4. Hierarchical Cd: review, not automatic failure

The retained coefficient files show KaHIP Cd(120) **0.296204439** and hierarchical **0.295213805**; by step 150 they are **0.280043747** and **0.298429569**. From 145 to 150, KaHIP falls 0.281749743 → 0.280043747, while hierarchical rises 0.293143049 → 0.298429569. This late divergence is real in the output and is reinforced by the much higher pressure final residual. It merits a **numerical correctness review**.

The task rules say Cd at 40/80/150 should *largely match* reference examples, with step-150 values 0.289, 0.287, 0.284, and 0.292, summarized as “~0.28–0.29.” They state **no hard 0.29 cutoff**. The project's separate broad local gate is 0.27–0.30, which 0.29843 passes. Hence the report's categorical “outside official Cd window” / “fails correctness” is **too strong**. Do not call hierarchical competition-valid either until the team agrees an acceptance rule and reviews the trajectory and input identity. Label it **Cd review pending** on slides.

## 5. One-node KaHIP comparison correction

The screening report's 1-node table pairs KaHIP **13.333 s/step** and cut **1,566,478** with AOCC hierarchical splits. Original PBS stdout and decomposition logs show that this KaHIP row is job **19332675**, **ICX 2025.1.3 / Intel MPI**, 128 ranks, 40 steps: **13.3329703585641 s/step**, cut **1,566,478**. It is the wrong software stack for the AOCC comparisons.

The same-stack AOCC 5.0 / Open MPI 5.0.10 KaHIP reference is job **19399157**, 1 node / 128 ranks / 40 steps: **13.30693129451282 s/step**, cut **1,558,450**, max rank interface faces **50,069**. The AOCC hierarchical (4 8 4) job **19730480** is **13.83567520974359 s/step**, cut **2,992,854**. Thus the same-stack descriptive penalty is **+3.9734%**, with **+92.04%** cut, versus the report's mixed-stack +3.77% / +91%. These are single runs on different allocated nodes, without a preserved binary/launcher identity check. The 1-node observation is consistent with partition-associated costs arising even without inter-node traffic; it does **not** quantify what fraction of the 4-node gap is on-node versus off-node, because the ranks, partitions, run length, and allocations differ.

## 6. Source trail and evidence classes

- **Original remote case root, read only:** /home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/. For each case below, inspected logFiles/10_decomposePar.log, its sole logFiles/50_simpleFoam*.log, postProcessing/forceCoeffsAll/0/coefficient.dat, and selected small configuration-file hashes. Cases: occdrivaer-occdrivaer_4node_aocc_kahip_v1.1, occdrivaer-occdrivaer_4node_aocc_scotch_v1, occdrivaer-occdrivaer_4node_aocc_scotch_w_v1, occdrivaer-occdrivaer_4node_aocc_hier888_v1, occdrivaer-occdrivaer_4node_aocc_kahip_pin_v1. One-node cross-check cases: occdrivaer-occdrivaer_1node_p2_kahip_v1, occdrivaer-occdrivaer_1node_p4_aocc_kahip_v1, occdrivaer-occdrivaer_1node_aocc_hier484_v1.

| Job | Case directory under the remote root | Exact solver log under logFiles/ |
| --- | --- | --- |
| 20030922 | occdrivaer-occdrivaer_4node_aocc_kahip_v1.1 | 50_simpleFoam.2026-09-14_03-01-50.log |
| 20064271 | occdrivaer-occdrivaer_4node_aocc_scotch_v1 | 50_simpleFoam.2026-09-14_03-47-42.log |
| 20072244 | occdrivaer-occdrivaer_4node_aocc_scotch_w_v1 | 50_simpleFoam.2026-09-14_04-05-25.log |
| 20061437 | occdrivaer-occdrivaer_4node_aocc_hier888_v1 | 50_simpleFoam.2026-09-14_03-40-46.log |
| 20092999 | occdrivaer-occdrivaer_4node_aocc_kahip_pin_v1 | 50_simpleFoam.2026-09-14_04-36-57.log |

- **Retained local PBS evidence:** [AOCC scripts and outputs](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/) named run_occdrivaer_4node_aocc_{kahip_v1.1,scotch_v1,scotch_w_v1,hier888_v1,kahip_pin_v1}.pbs and matching outputs/occdrivaer_4node_aocc_*.o/.e; [results registry](../../references/teammate/OpenFoam-HPCAI-26/results/metrics.csv) is secondary. The [shared runner](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/run_occdrivaer.sh) records the launcher, stages, and source of its AVG_WALL_PER_STEP echo.
- **Correctness wording:** [task rules](../../references/teammate/OpenFoam-HPCAI-26/Resources/2026-APAC-HPC-AI-OpenFOAM-HPC-Task-Rules.md), “Sanity check”; [prior input/Cd audit](../../progress/2026-09-17-input-cd-audit.md). [Screening report](fast-performance-screening-2026-09-17.md) §§17.2–17.3 and 19.1–19.5 contains the claims reviewed here.
- **Evidence classes:** logged wall times, Cd values, cell/cut/interface statistics are **measured or directly counted**; cross-node interface values are **derived under unverified rank→node blocks**; the regression's 1.9% is **model extrapolation**; a network bottleneck, MPI wait, and a causal explanation for the runtime gap are **unverified mechanisms**.

## 7. Slide-safe wording and perf-report questions

**Safe for slides:** “On ASPIRE2A, OpenFOAM v2512, AOCC 5.0 / Open MPI 5.0.10, 4 nodes × 128 ranks, 150 steps, KaHIP recorded 2.875901 s/step, Scotch 2.912440, weighted Scotch 2.905191, and hierarchical (8 8 8) 3.355476. KaHIP is fastest in these retained single runs; hierarchical is 16.68% slower than the matched unbound KaHIP run. The decomposition logs show 2.04× more total processor-interface faces and a 10.03× higher worst-rank interface count for hierarchical, while reported solver iteration counts are identical. The cause of the timing gap and hierarchical's late Cd trajectory require further validation.” If presenting the 2.869257 bound KaHIP baseline, mark it as a **different binding configuration**. Do not present a 1.9% bound or a proven hierarchical correctness failure.

When perf-report is available, ask:

1. For the **same bound 4N/512 KaHIP baseline**, what are the per-rank fractions and absolute times for useful computation, point-to-point MPI, reductions/collectives, and waiting/imbalance? Does the report cover a steady-state window, and how much timing overhead does instrumentation add? Preserve the uninstrumented official 150-step metric separately.
2. Is actual rank→host→core/NUMA placement recorded? Does it confirm the floor(rank/128) assumption and core affinity? If not, treat all “inter-node faces” as conditional.
3. If a **matched hierarchical profile** is later approved and scientifically valid, do ranks with the largest interface counts (for example rank 135) spend more time in point-to-point exchange, while other ranks wait? Or is the gap mainly computation, collectives, cache/NUMA, or another stage? A KaHIP-only profile cannot attribute the hierarchical-minus-KaHIP difference.
4. Can MPI bytes/messages and per-rank timing distinguish total cut, cross-node cut, message count, and worst-rank effects? Do not equate counted faces with transferred bytes.
5. After defining a Cd acceptance criterion, does the numerical trajectory and pressure residual difference persist under repeated controlled runs with input, mesh, binary, partition, and placement identities recorded?

**Remaining evidence gaps:** ASPIRE2A repeat variability, historical per-job binary hashes, full mesh/initial-field identity, exact rank mapping/affinity, independent PBS accounting, an approved numeric Cd tolerance, and an MPI/per-rank profile. None was filled by inference.

## 8. Read-only action record

Checked local Git state; read the required workflow, application, and latest progress records; parsed retained local PBS scripts/outputs; checked the pre-existing SSH control connection with ssh -O check aspire2a-comp; then used only ssh aspire2a-comp with read-only command bodies within the previously authorized cases root. Remote bodies were case-directory listings; bounded sed/grep; sha256sum of named small inputs; and cat of named original logs/coefficient files to local **in-memory** Python parsers. The Python parsers counted rank-pair faces, time points, coefficients, and solver residuals without writing files. **No scheduler command, PBS submission, OpenFOAM execution, build, transfer, or remote write occurred; remote state changes: none.** The only local change is this new report. No existing report or script was edited.
