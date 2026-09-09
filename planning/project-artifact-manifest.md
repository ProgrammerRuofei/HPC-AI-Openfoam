# OpenFOAM HPC Project Artifact Manifest

**Canonical root:** `/Users/sofia/Projects/openfoam-aspire2a`  
**Helper root:** `/Users/sofia/openfoam-hpc-helper`  
**Last scanned:** 2026-09-02

This manifest records provenance for project artifacts discovered during safe
local consolidation. All copies were made with metadata preservation where
possible. No original file was moved, deleted, overwritten, or content-edited.

## Core workflow/config

| Artifact | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| Project policy | `/Users/sofia/Projects/openfoam-aspire2a/AGENTS.md` | Markdown | Workflow and authorization rules | Already present | Present, unchanged |
| Workflow pack | `/Users/sofia/Projects/openfoam-aspire2a/workflow/` | Markdown | General workflow policies | Already present | Present, unchanged |
| Gadi adapter | `/Users/sofia/Projects/openfoam-aspire2a/workflow/gadi-cluster-config.md` | Markdown | Independent Gadi configuration | Already present | Present, unchanged during consolidation |
| ASPIRE2A adapter | `/Users/sofia/Projects/openfoam-aspire2a/workflow/00-General-SSH-Rules.md` | Markdown | ASPIRE2A configuration | Already present | Present, unchanged |
| Application overview | `/Users/sofia/Projects/openfoam-aspire2a/APPLICATION.md` | Markdown | Workload and boundaries | Already present | Present, unchanged |

## Methodology and planning

| Artifact | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| Performance methodology | `/Users/sofia/Projects/openfoam-aspire2a/planning/openfoam-performance-methodology.md` | Markdown | Historical lessons and provisional 2026 methodology | Already present | Present, unchanged |
| Optimisation plans | `/Users/sofia/Projects/openfoam-aspire2a/planning/PLANS.md` | Markdown | Current planning state | Already present | Present, unchanged |
| NSCC support draft | `/Users/sofia/Projects/openfoam-aspire2a/planning/aspire2a-nscc-support-draft.md` | Markdown | ASPIRE2A signal-7 support case | Already present | Present, unchanged |

## Gadi baseline and profiling

| Artifact | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| 1-node baseline script | `/Users/sofia/Downloads/gadi_openfoam_benchmark.txt` | PBS shell script | Local copy of 1-node Gadi-style benchmark script | Source retained; not copied as active script | Recorded; legacy account references excluded from active config |
| Gadi profiling deck | `/Users/sofia/Downloads/openfoam_gadi_profile.pptx` | PPTX | Gadi profiling/performance narrative | `artifacts/presentations/openfoam_gadi_profile.pptx` | Copied; SHA-256 `c2db460649f692f91cc0e55f6b3bc243de7a160cde0d190703b0b591ad887653` |
| Gadi baseline deck | `/Users/sofia/Desktop/HPC/slides/openfoam_gadi_baseline_v2_副本.pptx` | PPTX | Earlier Gadi baseline/scaling presentation | `artifacts/presentations/openfoam_gadi_baseline_v2_copy.pptx` | Copied; SHA-256 `de8fe6bf00d40e9e3da45474cafcff464296134a02bb14db9f940bb63157dcbc` |
| OpenFOAM runtime tracker | `/Users/sofia/Downloads/OpenFOAM Runtime.xlsx` | XLSX | Experiment/runtime table | `artifacts/spreadsheets/OpenFOAM_Runtime.xlsx` | Copied; SHA-256 `6d660f3bf955ed70e19f3810de72cd8a9bce5196c036aae46f32596919836f6e` |
| Current Gadi facts | `/Users/sofia/Projects/openfoam-aspire2a/APPLICATION.md` | Markdown | Official `normalsr` 1/2/4-node scored table (2.139565 s/step at 4N) plus the pre-rule Cascade Lake references incl. 787 s | Already present | Updated 2026-09-09: the scored reference is now the official SPR table; 787 s is retained as labelled historical evidence |
| Gadi profiler notes | `/Users/sofia/Projects/openfoam-aspire2a/planning/openfoam-performance-methodology.md` | Markdown | Arm Performance Reports/MAP aggregates | Already present | Present, unchanged |

Raw Gadi solver logs and scripts were verified remotely under:

```text
/scratch/pm78/kj7183/openfoam_cpu/scripts/
/scratch/pm78/kj7183/openfoam_cpu/results/gadi_1n_baseline/
/scratch/pm78/kj7183/openfoam_cpu/results/gadi_2n_baseline/
/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh/logFiles/
```

They were not copied locally in this phase because the task prohibited remote
modification and this phase was limited to safe local consolidation. Their
remote provenance is documented in `workflow/gadi-cluster-config.md`.

## ASPIRE2A diagnosis

| Artifact | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| Baseline repair scripts | `/Users/sofia/Projects/openfoam-aspire2a/experiments/aspire2a-baseline/` | PBS/Markdown | v2512 baseline workflow repair and signal-7 evidence | Already present | Present, unchanged |
| T0–T4 scripts | `/Users/sofia/Projects/openfoam-aspire2a/experiments/aspire2a-diagnosis/` | PBS | Fresh decomposition and renumberMesh diagnostics | Already present | Present, unchanged |
| Diagnosis summary | `/Users/sofia/Projects/openfoam-aspire2a/planning/aspire2a-nscc-support-draft.md` | Markdown | T1/T2/T4 evidence and support draft | Already present | Present, unchanged |

## Phase 0

| Artifact | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| Phase 0 repeat script | `/Users/sofia/openfoam-hpc-helper/phase0/phase0_baseline_repeat_4n.pbs` | PBS | Candidate Gadi baseline repeat | `/Users/sofia/Projects/openfoam-aspire2a/phase0/phase0_baseline_repeat_4n.pbs` | Copied byte-for-byte |
| Historical 4-node script | `/Users/sofia/openfoam-hpc-helper/phase0/historical_drivaer_4n.pbs` | PBS | Historical reference script | `/Users/sofia/Projects/openfoam-aspire2a/phase0/historical_drivaer_4n.pbs` | Copied byte-for-byte |
| Phase 0 README | `/Users/sofia/openfoam-hpc-helper/phase0/README.md` | Markdown | Phase 0 context and provenance | `/Users/sofia/Projects/openfoam-aspire2a/phase0/README.md` | Copied byte-for-byte |

SHA-256 verification for all three copies:

```text
phase0/README.md                    792b8019ba5fadc5204bd8ae79cd9f26debe97a175c9e02f912d8b56e7ea1083
phase0/historical_drivaer_4n.pbs    c92003460300d5aa5f0ca6ccf7f68052c47454650bf87fcb40a6ef5b22172756
phase0/phase0_baseline_repeat_4n.pbs 0d6414d137b8528501c62f0cfa00b3445f8da2a013a0ce35bb32c823d090d37a
```

## Slides and historical references

| Artifact | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| ISC26 NTU presentation | `/Users/sofia/Projects/openfoam-aspire2a/references/last-year/slides/HPC-AI.ISC.26.Virtual.NTU.pptx` | PPTX | Historical OpenFOAM performance-engineering deck | Already present | Present, unchanged |
| Historical OpenFOAM repository | `/Users/sofia/Projects/openfoam-aspire2a/references/last-year/OpenFOAM-v2412-isc26/` | Repository tree | Scripts, spreadsheets, profiler outputs, archived results | Already present | Present, unchanged |
| Historical SCC repository | `/Users/sofia/Projects/openfoam-aspire2a/references/last-year/scc/` | Repository tree | ISC26/SCC reference material | Already present | Present, unchanged |
| OpenFOAM optimisation walkthrough | `/Users/sofia/Desktop/HPC/HPC-AI 2026/5. OpenFOAM Foundation, and Multi-Node CPU Workload Optimization Walk-through.pdf` | PDF | Senior-team/reference methodology | `artifacts/references/OpenFOAM_Multi-Node_CPU_Workload_Optimization_Walk-through.pdf` | Copied; SHA-256 `cd1ef833b26ea0a667b157b4f72159de4efd9ffcba07de6f9e85718a659fbbac` |

The historical trees already contain presentation figures, Nsys reports, VTune
HTML, IPM XML, spreadsheets, scripts, and archived result material. They were
not duplicated.

## Figures and results

| Artifact group | Original path | Type | Purpose | Copy destination | Status |
|---|---|---|---|---|---|
| Historical presentation figures | `/Users/sofia/Projects/openfoam-aspire2a/references/last-year/OpenFOAM-v2412-isc26/presentation/` | PNG/MP4 | Charts and scientific visuals | Already present | Present, unchanged |
| Historical profiling outputs | `/Users/sofia/Projects/openfoam-aspire2a/references/last-year/OpenFOAM-v2412-isc26/vtune/`, `ipm/`, `nsys/` | HTML/XML/NSYS | Performance evidence | Already present | Present, unchanged |
| Structured results | `/Users/sofia/Projects/openfoam-aspire2a/results/` | CSV/Markdown | Current result schema and summaries | Already present | Present, unchanged |

## Conflicts and omissions

- No destination-name conflict occurred during copying.
- The helper Phase 0 files were absent from the canonical root and were copied
  into a new `phase0/` directory.
- Gadi local decks/tracker were copied with explicit non-conflicting names.
- The obsolete `vr32` local PBS example was not copied into active configuration.
- Remote Gadi raw logs/scripts remain at their verified remote paths; they were
  not downloaded or modified in this consolidation phase.
- No artifact content was edited.
