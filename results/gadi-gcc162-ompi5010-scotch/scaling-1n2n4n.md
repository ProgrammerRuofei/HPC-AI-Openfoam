# GCC 16.2 / Open MPI 5.0.10 / Scotch strong scaling on Gadi

The selected configuration is private GCC 16.2.0, private Open MPI 5.0.10, OpenFOAM.com v2512 (`linux64GccDPInt32Opt`), real Scotch 6.1.0, Gadi `normalsr` Sapphire Rapids Xeon Platinum 8470Q nodes, 104 MPI ranks per node, `--map-by ppr:104:node` without explicit core binding, and UCX PML. Jobs loaded `ucx/1.18.1` and `ucc/1.4.4` modules. Historical `ldd` evidence resolves `libucp.so.0` from `/usr/lib64`; its effective version and whether UCC handled collectives were not recorded, so the module versions must not be presented as proven effective runtime versions.

The fixed scientific workload is the official ~65M-cell `occDrivAerStaticMesh`, unmodified `simpleFoam`, `fvSchemes`, and `fvSolution.fixedIter`, plus the full Allrun chain: `decomposePar -constant`, `restore0Dir -processor`, `renumberMesh -constant -overwrite -parallel`, `potentialFoam -initialiseUBCs -parallel`, `applyBoundaryLayer -ybl 0.0450244 -parallel`, and `simpleFoam -parallel`. Only `nCores` and the prescribed `endTime` change with node count. The metric is the coded `Average wall-clock time per time step`, not raw PBS walltime; the rules prescribe 40/80/150 steps for 1/2/4 nodes.

| Point | Job | Nodes × ranks/node | Steps | Average wall s/step | Final Cd | PBS wall | Actual SU | Validation |
| --- | --- | --- | ---: | ---: | ---: | --- | ---: | --- |
| Selected 1N baseline, default binding | `182017873.gadi-pbs` | 1 × 104 | 40 | 8.373520290307694 | 0.43806006706848422 | 11:41 | 40.50 | Exit 0, full chain End |
| New 2N Scotch scaling point | `182022356.gadi-pbs` | 2 × 104 | 80 | 4.137720655924051 | 0.33963559075612176 | 13:47 | 95.56 | Exit 0, full chain End, Time=80, two hosts ×104 ranks |
| 4N baseline run 1 | `181368883.gadi-pbs` | 4 × 104 | 150 | 1.991194389201344 | 0.29187594927465327 | 16:19 | 226.26 | Exit 0, full chain End |
| 4N same-build repeat | `181371071.gadi-pbs` | 4 × 104 | 150 | 1.988625920 | 0.29187594927465327 | 16:36 | 230.19 | Exit 0, full chain End |

Define speedup S(N)=T(1)/T(N), efficiency E(N)=S(N)/N. With the two completed 4N timings averaged, T(4)=1.989910154600672 s/step:

| Nodes | T(N), s/step | Speedup from 1N | Efficiency |
| ---: | ---: | ---: | ---: |
| 1 | 8.373520290307694 | 1.000000 | 100.000% |
| 2 | 4.137720655924051 | 2.023704 | 101.185% |
| 4, two-run mean | 1.989910154600672 | 4.207989 | 105.200% |

The >100% efficiencies are **observations**, not established superlinear scaling: 1N and 2N each have a single run; physical hosts and prescribed step counts differ. Cd changes with iteration count as expected by the rules' sanity table (~0.43, ~0.34, ~0.28–0.29). The old site-module GCC 8.5/Open MPI 4.1.7/hierarchical results remain a separate historical reference. The explicit `--bind-to core` 1N job `182019151.gadi-pbs` is an affinity experiment and is excluded from this default-binding scaling line.

## Two-node provenance

Job-keyed evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/scaling-2n-scotch/182022356.gadi-pbs/evidence/`. Independent PBS stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_scaling_2n_scotch_v1.pbs.out`. The NCI receipt in that stdout reports Exit Status 0 and 95.56 SU. Job `182022356.gadi-pbs` used hosts `gadi-cpu-spr-0628` and `-0629`, 104 ranks each. Both runtime archives, the OpenFOAM archive, the source input files, and the `simpleFoam` binary passed SHA-256 checks; `simpleFoam.ldd` resolved private `libmpi.so.40`.

Evidence SHA-256: `coefficient.dat` `46c73697147fafcb45837a38b34ea87e205075caddb11c359a25748a32f978c7`; `simpleFoam.log` `931ccb0e98f3f89fd29276b2083e7c478309de500500ddb517931fbe384f8b10`; `rank-host-map.txt` `e54bbfcf578ec399df4d4d750a18815e81d113c0267b24a96c8d77481d2127ef`.

The submitted script is `builds/build-scripts/gadi-gcc162-ompi5010/run_scaling_2n_scotch_v1.pbs` at commit `f00872ffaa88394177d8048b6d480331f8a7e4e9`, SHA-256 `89a789fa1fcf58ac4566f16b29becbc851d14e3719c90d1ba2b731588f670b04`. No second 2N submission or automatic repeat occurred.
