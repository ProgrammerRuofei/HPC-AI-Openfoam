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

## Cd sanity targets per scaling point

Read from the official rules page on 2026-09-03. The earlier project notes only
recorded the 150-step value; the 40/80-step targets are needed before the 1N and
2N scaling runs can be validated.

| Nodes | Iterations | Expected Cd |
| ---: | ---: | --- |
| 1 | 40 | ~0.43 |
| 2 | 80 | ~0.34 |
| 4 | 150 | 0.28-0.29 |

Cd comes from `postProcessing/forceCoeffsAll/*/coefficient.dat` and never appears
in the `simpleFoam` log. The primary metric line
`Average wall-clock time per time step` is emitted by `simpleFoam` directly, so it
is extracted from the solver log rather than computed from `ClockTime`.

## Gadi allocation constraint (2026-09-03)

Reservation is charged on the **requested** walltime; actual billing uses real
elapsed time. On `normalsr` the rate is 2 SU per resource-hour and a 4-node
request resolves to 416 resources, so a 2 h request reserves 1664 SU while a
1:15 request reserves 1040 SU for the same run. Project `pm78` holds a 4.00 KSU
quarterly grant, which makes requested walltime a first-class budget variable
rather than a free safety margin.
