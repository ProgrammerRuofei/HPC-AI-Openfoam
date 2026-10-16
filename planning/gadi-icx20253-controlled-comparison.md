# ICX 2025.3.2 controlled comparison on Gadi

## Purpose and current gate

Compare the available ICX 2025.3.2 OpenFOAM v2512 build with the
validated GCC 16.2.0 build on the same Gadi Sapphire Rapids workload.
The successful ICX build is `181392981.gadi-pbs` and the separate
runtime smoke is `181399119.gadi-pbs`. The first four-node ICX result
is `181399707.gadi-pbs` at 1.976664844 s/step, Cd 0.2918761744;
a same-build repeat `181402435.gadi-pbs` was submitted because the first
run is only 0.666% faster than the GCC two-run mean, then cancelled
at the user's request before it produced a result. Future repeats
require explicit user permission. The other team's
ICX 2026.1 result is context only: that module was unavailable on Gadi
when inspected. Existing Open MPI 5.0.10 plus UCX 1.18.1 and UCC 1.4.4
is retained so the measured change is primarily the OpenFOAM compiler.
The MPI library itself was built with GCC 16.2.0; its compatibility with
ICX was established by the two-rank C++ probe `181382175.gadi-pbs`.

## Fresh-job smoke gate

After the build ends, pin the ICX OpenFOAM archive SHA-256 and
`simpleFoam` binary SHA-256 from job evidence. Adapt the validated
`builds/build-scripts/gadi-gcc162-ompi5010/smoke_openfoam_v2512_v4.pbs`:

- Load `intel-compiler-llvm/2025.3.2`, `ucx/1.18.1`, `ucc/1.4.4`.
- Extract the same GCC runtime and MPI archives plus the ICX OpenFOAM
  runtime archive into a new job's JOBFS; verify all three hashes.
- Set `OMPI_CC=icx`, `OMPI_CXX=icpx`, and all three relocated MPI prefix
  variables; source OpenFOAM with `WM_COMPILER=Icx`.
- Require the `linux64IcxDPInt32Opt` `simpleFoam`, its pinned hash,
  `libmpi.so.40` from the private MPI, and no missing dynamic libraries.
- Use only the separate `pitzDaily_fused` tutorial copy; require real
  Scotch decomposition, five UCX MPI ranks, the coded wall-clock output,
  solver `End`, and PBS `Exit_status=0`.

## Four-node comparison gate

Only after the smoke passes, adapt the validated GCC
`run_baseline_4n_scotch_v1.pbs` and its per-node runtime helper with an
ICX job ID/output root and the pinned ICX archive/binary hashes. The
processor staging helper and scientific input hashes must remain
identical. Before submission, inspect the full local diff and verify:

| Control | Required value |
| --- | --- |
| Queue / nodes | `normalsr`, four Xeon Platinum 8470Q SPR nodes |
| Ranks | 416 total, exactly 104 per node |
| MPI / transport | Private Open MPI 5.0.10, UCX 1.18.1, UCC 1.4.4 |
| OpenFOAM | v2512, same pinned `OPENFOAM_SOURCE_ID_V2`; ICX `Opt` build |
| Case | Same `occDrivAerStaticMesh` ~65M mesh, same source hashes |
| Science | Identical `simpleFoam` source, `fvSchemes`, `fvSolution`, 150 steps |
| Decomposition | Scotch, 416 domains |
| Launch and storage | `ppr:104:node`, UCX PML, per-node JOBFS processor data |
| Acceptance | Full preparation logs and solver `End`, `Time = 150`, coded s/step, Cd 0.27–0.30 |

The GCC controls are jobs `181368883.gadi-pbs` and
`181371071.gadi-pbs`: 1.991194389 and 1.988625920 s/step,
respectively, with Cd 0.291875949 in both. The comparison must show
each new job's configuration, full-chain result and actual SU. Treat a
single small timing difference cautiously; repeat the same ICX
configuration if it could change the build choice. Do not infer a
compiler-only speedup from the older site-module/hierarchical result.
