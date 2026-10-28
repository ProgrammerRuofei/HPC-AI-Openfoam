# Gadi ICX 2026.2 / Open MPI 5.0.10 / site UCX 1.18.1 — four-node registry

| PBS job | Configuration | Status | Step time | Final Cd | SPR SU |
| --- | --- | --- | ---: | ---: | ---: |
| `182508542.gadi-pbs` | `normalsr`; 4 Sapphire Rapids nodes × 104 ranks; 416 ranks; ICX 2026.2; private Open MPI 5.0.10; site UCX 1.18.1 and UCC 1.4.4 loaded; HCOLL excluded; OpenFOAM v2512; Scotch; fixed ~65M-cell `occDrivAerStaticMesh`; 150 steps | PBS Exit 0; pass marker; full chain and `Time = 150`/`End` | 2.120806765 s | 0.2918762717 | 279.64 |

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

PBS walltime was 00:20:10 (416 requested CPUs; 760 GB RAM and 100 GB
JOBFS requested). `rank-host-map.txt` contains exactly 104 ranks on each of
`gadi-cpu-spr-0665` through `0668`; node staging passed on all four hosts.
The script's source/archive/library SHA-256 gates passed before the case ran.
`case-inputs.sha256` records unchanged `fvSchemes`
`064bb50455d37a7edd2c0fb24bbe30baaf851623f0250d550450c10e407889b3`
and `fvSolution`
`5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba`.
All four preparation logs and `simpleFoam.log` ended normally; the latter
records `Time = 150`, coded average 2.120806764543624 s/step over 149
measured steps, and MPI finalisation. Final `coefficient.dat` Cd is
0.29187627172981750, inside the 0.27–0.30 acceptance band. The script
printed `ICX20262_OMPI5010_UCX118_OF2512_SCOTCH_4N_PASS` and NCI's job
receipt charged 279.64 SPR SU. Site UCP 1.18.1 was verified in the
preceding MPI-initialized probes and its four-library preload is recorded
here; `simpleFoam.preloaded.ldd` shows the preloaded site UCP path. The
static `simpleFoam.ldd` alone resolves `/usr/lib64/libucp.so.0` and must
not be used to infer this run's preloaded UCP version. UCC was loaded, not
verified as the selected collective.

The two GCC 16.2/Open MPI 5.0.10/Scotch 4N runs averaged 1.989910155
s/step with Cd 0.2918759493. This ICX 2026.2 run is 6.58% slower than
that mean; its Cd differs by about 0.0000003224. The HCOLL exclusion and
UCX preload differ from the older GCC configuration, so this is a stack
comparison, not an isolated compiler comparison. No repeat was submitted.
