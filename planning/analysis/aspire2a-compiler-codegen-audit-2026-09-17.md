# ASPIRE2A compiler and binary code-generation audit

**Date:** 2026-09-17. **Scope:** AOCC 5.0, GCC 15.2, and ICX used for the recorded 4-node/512-rank KaHIP runs. Read-only analysis. This report deliberately excludes partition-topology and MPI-screening design assigned to the other agent. No build, solver, PBS job, remote write, or compute allocation was used.

## Evidence boundary

The teammate clone contains PBS run output and an **actual ASPIRE2A ICX build log**, but no locally readable `simpleFoam`, `libOpenFOAM`, `libfiniteVolume`, or object-file ELF for any of the three builds. The AOCC and GCC **ASPIRE2A build stdout** is absent locally; their build READMEs record success, and the run stdout records the selected executable path and MPI linkage. Full AOCC/GCC compilation logs exist for an earlier **personal-account** build using the same named modules and stock `Opt` recipe. Those logs establish what that separate build compiled, not the bytes in the competition-account binaries. No instruction-level `objdump` comparison of the three actual binaries is possible within the authorized evidence. The teammate binary tree lies outside the authorized remote case path.

## Compiler build reconstruction: intended versus proven

| Build / recorded 4N result | Script intent | Direct evidence for the ASPIRE2A competition build/run | Missing |
| --- | --- | --- | --- |
| **AOCC 5.0**, bound KaHIP 2.869256832 s/step, job `20092999` | [`build_a2a_comp_aocc_openmpi.pbs`](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-aocc-openmpi/build_a2a_comp_aocc_openmpi.pbs) loads `aocc/5.0`, `gcc/11.2.0`, `openmpi/5.0.10-gcc11`; prepends `/app/apps/aocc/5.0/bin`; `CC=clang`, `CXX=clang++`, `OMPI_CXX=clang++`; stock `WM_COMPILER=Amd`, `WM_MPLIB=SYSTEMOPENMPI`, `WM_COMPILE_OPTION=Opt`. Build script sets `FOAM_EXTRA_LDFLAGS` to scratch `libfabric.so.1`. | Build [README](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-aocc-openmpi/README.md) records job `19046275` Build OK. [Run stdout](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_4node_aocc_kahip_pin_v1.o) selects `.../platforms/linux64AmdDPInt32Opt/bin/simpleFoam`, prints `WM_COMPILER=Amd`, `WM_MPLIB=SYSTEMOPENMPI`, `WM_COMPILE_OPTION=Opt`, and resolves `libmpi.so.40` from `/app/apps/openmpi/5.0.10-gcc11/lib/`. The separate personal [AOCC build log](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/aocc-openmpi/outputs/aocc_openmpi_v2512_v1.o) records `/app/apps/aocc/5.0/bin/clang++`, **AMD clang 17.0.6, AOCC_5.0.0-Build#1377**, and `-O3` with no explicit `-march/-mcpu/-mtune` in `lduMatrix.C`/`GAMGSolver.C` compile lines. | Exact compiler banner, final flags, hot-library code and SHA256 of the *competition* binary; actual `libkahipDecomp`/OpenFOAM library paths. The personal compiler banner is not a per-job binary fingerprint. |
| **GCC 15.2**, bound KaHIP 2.879642479 s/step, job `20087243` | [`build_a2a_comp_gcc_openmpi.pbs`](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-gcc-openmpi/build_a2a_comp_gcc_openmpi.pbs) selects `gcc/15.2.0-nscc`, `openmpi/5.0.10-gcc11`; `CC=gcc`, `CXX=g++`; stock `WM_COMPILER=Gcc`, `WM_MPLIB=SYSTEMOPENMPI`, `Opt`. Same scratch-libfabric link mechanism. | Build [README](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-gcc-openmpi/README.md) records job `19103241` Build OK. [Bound run stdout](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_4node_gcc_kahip_pin_v1.o) selects `.../linux64GccDPInt32Opt/bin/simpleFoam` and resolves the same Open MPI `libmpi.so.40` path. The separate personal [GCC build log](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/gcc15-openmpi/outputs/gcc15_openmpi_v2512_v1.o) records `/app/apps/gcc/15.2.0-nscc/bin/g++`, `g++ (GCC) 15.2.0`, and `-O3` without explicit architecture flags in the same two hot-source compile lines. | Actual competition build compile commands, binary hash and machine code; resolved hot-library/plugin paths. |
| **ICX**, KaHIP 2.898108864 s/step unpinned, job `19389011`; 2.897710920 s/step with Intel MPI core pinning | [`build_a2a_comp_icx_intelmpi.pbs`](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-icx-intelmpi/build_a2a_comp_icx_intelmpi.pbs) loads **module `intel/2025.1.3`**, plus CMake/Flex; `CC=icx`, `CXX=icpx`, `WM_COMPILER=Icx`, `WM_MPLIB=INTELMPI`, stock `Opt`. | Actual [ASPIRE2A build stdout](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-icx-intelmpi/outputs/a2a_comp_icx_intelmpi_v2512_v1.o) identifies `/app/apps/oneapi/2025.1.3/compiler/2025.1/bin/icpx` and compiler banner **2025.1.1 (2025.1.1.20250418)**. `WM_OPTIONS=linux64IcxDPInt32Opt`. Its `lduMatrix.C` and `GAMGSolver.C` lines use `-O3 -fp-model=precise -fPIC`, with no explicit architecture, LTO, fast-math, or OpenMP flag. [Unpinned run stdout](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_4node_p2_kahip_v1.o) resolves `libmpi.so.12` to `/app/apps/oneapi/2025.1.3/mpi/latest/lib/release/`. The [pinned run](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_4node_p5_kahip_pin_v1.o) uses `I_MPI_PIN=on`, `I_MPI_PIN_DOMAIN=core`. | Binary hash, actual ISA/disassembly, exact runtime Intel MPI patch version from the run (build README names Intel MPI 2021.15), complete linked hot-library paths. The module's `2025.1.3` suffix **must not** be reported as the compiler executable's version. |

The AOCC/GCC personal logs and the ICX competition log show `-O3`, C++17, `-fPIC`, and `-pthread` for representative `lduMatrix` and `GAMG` compilation. `-pthread` is **not** evidence that the solver was built with OpenMP. ThirdParty CMake found OpenMP during some builds, but the sampled OpenFOAM hot-source lines have no `-fopenmp`. AOCC/GCC personal sampled lines have no explicit fast-math or LTO option; ICX uses `-fp-model=precise`. The run/build scripts do not request PGO or architecture flags for these stock `Opt` paths. This is not proof that every object in the installed libraries has identical flags.

## CPU targeting and machine-code comparison

The three **stock build recipes** provide no explicit `-march=znver3`, `-mcpu`, `-mtune`, `-mavx2`, `-mfma`, or `-mavx512` setting in the representative compilation records. The ICX competition build directly confirms this for `lduMatrix.C` and `GAMGSolver.C`; analogous personal AOCC/GCC logs confirm it for their corresponding builds. `-O3` can optimize and vectorize loops, but it does not by itself establish which instructions occur in these binaries. Because no actual ELF was available under the authorized paths, **xmm/ymm/zmm instruction counts, FMA usage, generic dispatch, Zen-family tuning, and Zen 3 targeting remain UNKNOWN for the three competition binaries**. The evidence supports *generic-target configuration intent*, not a verified statement that the machine code is exclusively generic x86-64 or lacks AVX/AVX2/FMA.

Representative numerical functions to inspect when path access is separately authorized: `Foam::lduMatrix::Amul` / `Tmul` in `libOpenFOAM`, `Foam::GAMGSolver::solve` and smoother/matrix kernels in `libOpenFOAM`, and `fvMatrix` assembly in `libfiniteVolume`. A small `readelf -p .comment`, `readelf -d`, `sha256sum`, and bounded `objdump -d -C` around those symbols in *each* actual binary/library would answer the ISA question. Inspecting only the `simpleFoam` launcher would not answer it. No such disassembly was performed here, so **material differences in generated hot-path machine code are not established**.

## `OptZnver3`: separate GCC result, unbuilt AOCC proposal

The teammate's [`a2a-comp-aocc-znver3` recipe](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-aocc-znver3/build_a2a_comp_aocc_znver3.sh) proposes a separate `linux64AmdDPInt32OptZnver3` platform. It copies `wmake/rules/linux64Amd/c++Opt`, then intends to set `c++OPT = -O3 -march=znver3`; it retains AOCC 5.0 and Open MPI 5.0.10. **This is a proposed recipe, not evidence of an AOCC tuned binary.** The analogous personal AOCC Allwmake job `20128815` [failed because `linux64Amd/c++Opt` was missing](../../references/teammate/OpenFoam-HPCAI-26/progress/2026-09-14-compiler-paths.md). The competition-account AOCC `OptZnver3` output directory has no build log, no Build OK record, no binary hash, and no recorded 65M run. Its required libraries, ABI compatibility, and actual `znver3` instructions are therefore UNKNOWN. The official AOCC runs explicitly selected `linux64AmdDPInt32Opt`; no evidence shows they loaded an AOCC `OptZnver3` component.

The **GCC** [`OptZnver3` recipe](../../references/teammate/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-gcc-znver3/build_a2a_comp_gcc_znver3.sh) used the separate `linux64GccDPInt32OptZnver3` path with intended `-O3 -march=znver3`. The teammate [plan](../../references/teammate/OpenFoam-HPCAI-26/planning/PLANS.md) records successful Allwmake job `20030923`; the [150-step run stdout](../../references/teammate/OpenFoam-HPCAI-26/experiments/occdrivaer-static/outputs/occdrivaer_4node_gcc_kahip_znver3_v1.o) proves that the selected binary path was `...OptZnver3/bin/simpleFoam`, Open MPI `libmpi.so.40` resolved, and the run completed at **2.882655290 s/step, Cd 0.279509**. Stock GCC unbound KaHIP was **2.880511907 s/step**, so this single tuned run was **0.074% slower**; that is far too small to establish a real regression. No actual tuned-binary hash/disassembly or complete linked-library map was retained. Separate platform paths reduce accidental overwrite risk, but `ldd` in run stdout was filtered to MPI/fabric, so a possible cross-platform third-party/plugin library mix was not independently ruled out.

The `OptZnver3` scripts replace or append the C++ optimization rule with `-O3 -march=znver3`; whether *all* relevant C/C++ rules and linked third-party libraries share the target is unverified. The AOCC failed source-rule lookup must be resolved through a read-only inspection of the exact competition source tree before preparing an executable build patch. The local project-root checkout inspected in this task (`84c262431117f5c921db8335e368a12d0e9fa3f0`) is a case/source-control repository and has no `wmake/rules` tree; it cannot answer that question.

## Explanations for the small timing gap

| Hypothesis | Assessment |
| --- | --- |
| H1: compiler code generation matters little | **Unknown.** No actual hot-path machine-code comparison or controlled repeat isolates it. |
| H2: the builds are largely generic-target, so architecture tuning has not been tested well | **Supported for the three stock build recipes**, directly for ICX and by analogous personal AOCC/GCC logs plus competition build scripts. **Actual ISA is unknown.** GCC `OptZnver3` has one completed 150-step result; AOCC `OptZnver3` has none. |
| H3: computation is masked by communication/memory cost at 512 ranks | **Plausible, unproven.** No MPI/CPU or memory profile in this audit; code generation may still matter in hot kernels. |
| H4: ICX comparison changes MPI as well as compiler | **Supported.** ICX run linked Intel MPI `libmpi.so.12`; AOCC/GCC linked Open MPI `libmpi.so.40`. AOCC versus GCC retains the same Open MPI family/path. |
| H5: noise is comparable to the compiler gap | **Plausible.** AOCC/GCC bound runs differ 0.362%; ICX is 1.006% slower than bound AOCC, with a different MPI stack; GCC stock versus `OptZnver3` differs 0.074%. Single runs do not estimate variance. |

## Controlled architecture experiment: useful design, blocked implementation

AOCC stock `Opt` versus AOCC architecture-targeted `OptZnver3` would be scientifically useful **if** the candidate can be built into a complete separate platform and both arms use identical source, AOCC executable/version, Open MPI, binary/library provenance, KaHIP partition, 4×128 ranks, binding, and numerical inputs. The existing recipe names `-march=znver3`; use that documented flag only. The personal stock AOCC log shows `-O3`, and the candidate proposes `-O3 -march=znver3`, but the competition build's stock rule and actual compile commands are not archived. Thus a true “CPU target only” comparison is conditional on proving the base rule already uses the same `-O3` and all other flags. The personal candidate recipe failed; an executable build diff is **not yet safely specifiable** from authorized evidence.

**Local proposed configuration diff only; not applied or executable:**

```diff
--- AOCC 5.0 / Open MPI 5.0.10 stock Opt control
+++ AOCC 5.0 / Open MPI 5.0.10 proposed CPU-target candidate
 WM_COMPILER=Amd
 WM_MPLIB=SYSTEMOPENMPI
-WM_COMPILE_OPTION=Opt
+WM_COMPILE_OPTION=OptZnver3        # separate platform; base rule must first be located
-c++OPT = -O3                        # conditional: verify actual competition-source rule
+c++OPT = -O3 -march=znver3          # existing documented candidate flag
```

The diff is a review target, not permission to alter a build setting. It cannot be turned into a PBS/build script until the missing AOCC rule, `WM_OPTIONS` selection, full library/plugin paths, and flags are verified. No remote-affecting file was prepared or edited.

**Provenance and state:** Local records above; original ASPIRE2A build binaries were not accessed. The only remote commands this task used were `ssh -O check aspire2a-comp` and `ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/src/openfoam-hpc-develop && ls -ld wmake/rules/linux64Amd wmake/rules/linux64Clang wmake/rules/linux64Gcc 2>&1; ls -la wmake/rules/linux64Amd 2>&1 | head -40; git rev-parse HEAD'`. **DISCOVERED AND VERIFIED:** that checkout was at `84c262431117f5c921db8335e368a12d0e9fa3f0` and lacks the OpenFOAM `wmake/rules` tree. **TBD:** actual competition AOCC/GCC compile commands, AOCC rule location, binary hashes, hot-library linkage and ISA. No scheduler command was issued; remote state did not change. Only this report was created locally, and pre-existing Git changes were preserved. The next read-only evidence step, if the teammate's build tree is authorized, is to inspect its rules, build logs, and hot-library ELF metadata.

## Candidate slide statement

**Observation:** AOCC, GCC, and ICX KaHIP timings differ by about 0.4–1.0% in existing single runs.  
**Evidence:** The stock recipes use `Opt`; sampled hot-source commands show `-O3` without an explicit Milan target. Actual binary ISA has not been inspected.  
**Interpretation:** No compiler code-generation win is established; ICX also changes MPI.  
**Next experiment:** After repairing and verifying a separate AOCC `OptZnver3` build, compare it with AOCC stock `Opt` under identical runtime controls.

## Final decision record

1. **Existing compiler comparison:** Each cell is a single 4N/512-rank KaHIP observation. Percentages use the bound AOCC run as reference.

   | Compiler / MPI | Binding | s/step | Difference |
   | --- | --- | ---: | ---: |
   | AOCC 5.0 / Open MPI 5.0.10 | Open MPI core binding | 2.869256832 | reference |
   | GCC 15.2 / Open MPI 5.0.10 | Open MPI core binding | 2.879642479 | +0.362% |
   | ICX 2025.1.1 / Intel MPI | no explicit pinning | 2.898108864 | +1.006% |
   | ICX 2025.1.1 / Intel MPI | Intel MPI core pinning | 2.897710920 | +0.992% |

   ICX changes MPI, and its pinning method is not identical to Open MPI placement.
2. **Flags proved:** Actual competition ICX hot-source commands: `-O3 -fp-model=precise -fPIC`, no explicit ISA/LTO/fast-math/OpenMP flag. Separate personal AOCC and GCC stock hot-source commands: `-O3 -fPIC`, no explicit ISA/LTO/fast-math/OpenMP flag. AOCC/GCC competition final commands remain unavailable. GCC tuned recipe intends `-O3 -march=znver3` but its raw build command is unavailable.
3. **ISA evidence:** No actual competition ELF is accessible in the authorized paths, so AVX/AVX2/FMA/AVX-512 and xmm/ymm/zmm usage are UNKNOWN for all three. Script flags alone do not prove instructions.
4. **Generic or tuned:** Three stock configurations show generic-*target intent* rather than explicit Zen 3 tuning; their actual code is not proven generic. Only GCC `OptZnver3` has a recorded architecture-targeted 150-step run, without disassembly proof.
5. **What `OptZnver3` is:** GCC's separate build ran and was 0.074% slower in one run. AOCC's separate build is **unverified/unbuilt for the competition account**; the personal attempt failed before completion. Official AOCC runs used stock `Opt`.
6. **Meaning of current compiler gap:** The 0.362–1.006% spread is descriptive, not a demonstrated compiler advantage. ICX changes MPI; all cells lack repeat-based uncertainty and actual code-generation fingerprints.
7. **Worth testing?** Yes, a controlled AOCC stock-versus-`-march=znver3` test is informative, but only after the missing rule and complete binary/library provenance are resolved. GCC's one null result does not settle AOCC.
8. **Single best next compiler experiment:** A fresh AOCC 5.0/Open MPI 5.0.10 `OptZnver3` build in a separate platform, followed by a matched KaHIP 4N/512-rank stock-versus-candidate comparison. **Do not execute until an executable local diff is reviewed and explicitly authorized.**
9. **Meaningful result:** `<1%` is inconclusive without unusually tight paired variance; `1–3%` needs repeated paired 150-step runs and a stable median; `≥3%` merits full validation but still needs correctness, linkage and repeat evidence before a win claim.
10. **Slides evidence:** Exact source revision, actual AOCC compiler banner, complete hot-source compile/link commands, stock/candidate rule diff, binary and key-library SHA256, resolved `libOpenFOAM`/`libfiniteVolume`/`libPstream`/`libkahipDecomp`/`libmpi` paths, bounded hot-symbol disassembly or vectorization evidence, fixed case/partition/rank/binding hashes, 150-step Cd and solver completion, and all paired timings with variability. No result from this audit alone qualifies as a compiler optimisation claim.
