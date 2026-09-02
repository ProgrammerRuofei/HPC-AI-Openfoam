# Application Overview

## Confirmed project facts

- **Application:** OpenFOAM
- **Target release:** openfoam.com v2512
- **Case:** `occDrivAerStaticMesh`
- **Mesh:** approximately 65 million cells
- **Solver:** `simpleFoam`
- **Scientific workload:** fixed

## Scientific boundaries

Do not change the mesh, `simpleFoam` source, `fvSchemes`, or `fvSolution`.

## Current optimisation scope

Compiler/build settings, MPI, rank placement/binding, and decomposition may
be considered, subject to competition rules and explicit approval.

## Current scored reference

| System | Nodes | MPI ranks | SIMPLE steps | ClockTime |
| --- | ---: | ---: | ---: | ---: |
| Gadi | 4 | 192 | 150 | 787 s |

## ASPIRE2A configuration

Not yet filled in.
