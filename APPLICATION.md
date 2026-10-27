# Application Overview

## Confirmed project facts

- **Application:** OpenFOAM
- **Target release:** openfoam.com v2512
- **Case:** `occDrivAerStaticMesh` (DrivAer open-cooling automotive aerodynamics)
- **Mesh:** approximately 65 million cells
- **Solver:** `simpleFoam` (steady-state RANS)
- **Scientific workload:** fixed

## Scientific boundaries

Do not change the mesh, `simpleFoam` source, `fvSchemes`, or `fvSolution`.

The 65M workload identity is pinned by six SHA256 values that were identical
across all four Phase 0 repeats; they are listed in
[`results/experiment-index.md`](results/experiment-index.md) and hard-gated by
the C1 benchmark script.

## Current optimisation scope

Compiler/build settings, MPI, rank placement/binding, and decomposition may
be considered, subject to competition rules and explicit approval.

## Official metric

**Average wall-clock time per time step**, taken from the `simpleFoam` log.
`ClockTime` and `ExecutionTime` are retained as secondary provenance.
Correctness is checked with the drag coefficient `Cd` against the expected
per-point range.

## Historical scored-case reference — Gadi site stack

Gadi `normalsr` (Intel Xeon Platinum 8470Q, Sapphire Rapids), site
`OpenFOAM/2512` module, GCC 8.5.0, Open MPI 4.1.7, one rank per physical core:

| System | Nodes | MPI ranks | Decomposition | SIMPLE steps | **Avg wall-clock / step** | ClockTime | Cd | PBS job |
| --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | --- |
| Gadi `normalsr` | 1 | 104 | `(4 13 2)` | 40 | 8.824444 s | 378 s | 0.43087 | `178153587.gadi-pbs` |
| Gadi `normalsr` | 2 | 208 | `(8 13 2)` | 80 | 4.296500 s | 362 s | 0.33201 | `178154724.gadi-pbs` |
| **Gadi `normalsr`** | **4** | **416** | **`(16 13 2)`** | **150** | **2.139565 s** | **336 s** | **0.28231** | **`178149002.gadi-pbs`** |

The 4-node row is the historical site-stack baseline. Later private-stack
and ASPIRE2A records are indexed in [`PROJECT-INDEX.md`](PROJECT-INDEX.md).
"Scored-case" here identifies the workload/rules context; it does not prove
final organizer submission, scoring or competition outcome.

### Historical pre-rule Gadi references (not official)

Gadi `normal` (Xeon Platinum 8274, Cascade Lake). These predate the 2026
official rules. They are development evidence only and must **not** be compared
with the Sapphire Rapids rows above, nor treated as an ASPIRE2A baseline.

| Reference | Nodes | MPI ranks | SIMPLE steps | ClockTime | Source |
| --- | ---: | ---: | ---: | ---: | --- |
| Original 4-node run | 4 | 192 | 150 | **787 s** (ExecutionTime 776.52 s) | job `177602742.gadi-pbs`; raw log path in [`workflow/gadi-cluster-config.md`](workflow/gadi-cluster-config.md) |
| Original 1-node run | 1 | 48 | 40 | 822 s | job `177590568.gadi-pbs` |
| Original 2-node run | 2 | 96 | 80 | 831 s | job `177597315.gadi-pbs` |
| Phase 0 controlled repeats R1-R4 | 4 | 192 | 150 | **median 797.5 s** (802 / 1045 / 793 / 790) | [`phase0/README.md`](phase0/README.md) |

The Phase 0 median (797.5 s, mean timestep 5.144659 s) is the correct
comparison reference for the pending C1 Cascade Lake screening benchmark,
because it uses the same hardware, rank count, and decomposition. The 787 s
single run is an earlier, uncontrolled measurement and is **superseded** by the
four-run Phase 0 set for that purpose.

## ASPIRE2A configuration

NSCC Singapore. The early Cray/PALS path had multi-node finalization failures
with `signal 7` after the solver printed `End`; those failed attempts remain
in lesson L9 in [`results/hpc-lessons.md`](results/hpc-lessons.md) and
[`MANUAL_INSPECTION_ERROR.md`](MANUAL_INSPECTION_ERROR.md).

That historical failure is not the current status of all ASPIRE2A work.
Later AOCC 5.0/Open MPI 5.0.10 runs completed on multiple nodes; use the
[ASPIRE2A evidence guide](planning/aspire2a-guide.md) for job-keyed records,
scientific-validity limits and the latest local handoff. No remote state was
checked as part of the 2026-10-28 repository organization.
