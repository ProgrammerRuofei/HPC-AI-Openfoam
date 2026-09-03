# Official 2026 OpenFOAM rules audit

Official source: [2026 APAC OpenFOAM HPC Task Rules](https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md), read 2026-09-03.

| Official requirement | Previous implementation/evidence | Status | Required action |
| --- | --- | --- | --- |
| `normalsr` Sapphire Rapids is the Gadi scored hardware | Phase 0 used `normal` and `gadi-cpu-clx-*` Cascade Lake. | NON-SCORED HARDWARE | Establish a new normalsr site-module baseline. |
| Primary metric: Average wall-clock time per time step from step two | Phase 0 centered ClockTime. | PARTIALLY COMPLIANT | Make the solver-log metric primary. |
| 1/2/4 nodes: 40/80/150 steps | Phase 0 only used 4N/150. | PARTIALLY COMPLIANT | Create official 1N/2N/4N definitions. |
| Full chain includes potentialFoam and applyBoundaryLayer `-ybl 0.0450244` | `Allrun.gadi` only ran decomposePar and simpleFoam. | NON-COMPLIANT | Use the complete official chain verbatim. |
| fixedIter/noWrite, unchanged mesh/solver/schemes/solution, DP | Phase 0 has supporting checks. | PARTIALLY COMPLIANT | Re-verify in every official fresh case. |
| Cd from `forceCoeffsAll/*/coefficient.dat` | Not captured in Phase 0 summary. | UNKNOWN / NEEDS EVIDENCE | Extract and validate Cd for every official run. |

## Historical classification

R1–R4 are **pre-rule development / Cascade Lake workflow-validation results**.
They remain useful for workflow validation and variability analysis, but are not
official Gadi contest baselines and must never be mixed with normalsr results.
