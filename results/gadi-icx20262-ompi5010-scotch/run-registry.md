# Gadi ICX 2026.2 / Open MPI 5.0.10 / site UCX 1.18.1 — four-node registry

| PBS job | Configuration | Status | Step time | Final Cd | SPR SU |
| --- | --- | --- | ---: | ---: | ---: |
| `182508542.gadi-pbs` | `normalsr`; 4 Sapphire Rapids nodes × 104 ranks; 416 ranks; ICX 2026.2; private Open MPI 5.0.10; site UCX 1.18.1 and UCC 1.4.4 loaded; HCOLL excluded; OpenFOAM v2512; Scotch; fixed ~65M-cell `occDrivAerStaticMesh`; 150 steps | Submitted once; outcome pending | pending | pending | pending |

The source mesh, `simpleFoam` source, `fvSchemes`, `fvSolution`, case
definition, and 150-step control follow the established four-node template.
The script verifies input and archive SHA-256, all four hosts and their rank
counts, node-local processor staging, full application chain, final `Time =
150`, coded mean seconds per step, and Cd within 0.27–0.30. UCC's module is
loaded, but its collective is not claimed as selected. This run's HCOLL
exclusion means timing differences from older runs cannot be assigned to
compiler changes alone.

Script: `builds/build-scripts/gadi-icx20262-ompi5010/run_baseline_4n_scotch_ucx118_v1.pbs`
(SHA-256 `62cb3502f5939ce9f19b49a2d3554a332c284204ab2ae54f0772de4df8adf9f1`).
PBS stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/run_baseline_4n_scotch_ucx118_v1.pbs.out`.
Job-keyed evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/baseline-4n-scotch-ucx118/182508542.gadi-pbs/evidence/`.
