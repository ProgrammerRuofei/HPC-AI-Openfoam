# 182939454.gadi-pbs — four-node rank/NUMA paired screening v2

PBS **F / Exit0**, pair and both-arm PASS, independently verified against original logs and all rank receipts. Actual **474.01 SU**, walltime **00:34:11**. Start2026-11-02 17:08:34 Singapore; PBS completion17:43:07. V1 failure182932939 (35.13SU) remains separate; two attempts together509.14SU.

## Configuration and result

| Item | Control | Candidate |
|---|---|---|
|Compiler / MPI|ICX2025.3.2 / privateOpenMPI5.0.10|same binaries and archives|
|Application / science|OpenFOAMv2512, occDrivAerStaticMesh,65,334,765cells,fixed source/fvSchemes/fvSolution|same input hashes|
|Decomposition|Scotch,416partitions|identical partition geometry hash|
|Nodes / ranks|SPR0261–0264,Intel8470Q,104ranks/node,416total|same allocation|
|Binding|explicit rankfile,one physicalcore/rank,13ranks/NUMA|same;21rankpositions moved3/6/10/2,original node/socket preserved|
|Steps|150,Time1..150,End,normal finalization|150,Time1..150,End,normal finalization|
|Mean seconds/step|1.984055637966442|1.984123309966443|
|Final Cd|0.2918761744038969|0.2918761744038969|
|Full Cd trajectory|150points|identical; maxabsdiff0|

Candidate is **0.0034107914% slower** (0.000067672s/step difference). This single control-then-candidate pair provides no evidence of a useful speedup; do not call this tiny difference a reproducible regression or conclude all NUMA/rank-placement options are ineffective. No timings from instrumented runs are mixed into this pair.

Modules declared UCX1.18.1/UCC1.4.4. Both416-rank probes actually loaded **/usr/lib64/libucp.so.0**, version **1.21.0**, and verbose logs contain HCOLL selected/enabled at priority90. These statements concern the probes, not proof of every simpleFoam collective. UCC library presence is not UCC-selection proof. CPU masks are pre-exec receipts; they do not locate solver memory pages or measure CPU migrations.

## Raw evidence and provenance

3447 original files plus `qstat-xf.txt` are present with SHA verification. `sources.tsv` maps every original local relative filename to its exact remote path and SHA; `SHA256SUMS` covers originals and qstat, `remote-sha256.txt` retains remote hash output. Original names/bytes and `control/`, `candidate/`, top-level `evidence/` preserved. Only two compiled MPI probe executables are excluded; see `excluded.txt`. No logs excluded. Scientific case/processor data remain at remote jobroot; retrieval did not duplicate mastermesh.

Remote jobroot: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-pair-4n-v2/182939454.gadi-pbs/
Independent stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_rank_numa_pair_4n_v2.pbs.out

PBS script SHA601e73fe815561997173f2a409aa82140790a23acc174889c1191414beba4e8c; submission script commit a04f44a895b771bca0c70aaeb61744ab330454c8. Source dictionaries/archive/simpleFoam SHA checks passed, exact values retained in run.log/expected-source/expected-scripts. Five mastermesh hashes match betweenarms and aftereachsolve. Partition SHA **6c3d197ff7f601a68ed937fe736b99f9e2c280392cd802a3895a250b46c724b5** matches botharms and the candidate design graph.

## Independent acceptance

See `independent-validation.json` and `validate_local.py`. Eacharm has1664rankJSON (416 each baseline/placement/solver-affinity/mpi-runtime),416unique worldranks,fourhosts×104,104unique physicalcores/host,13ranks/NUMA. Candidate masks match the pinned map,3/6/10/2changed,originalnode/socket preserved. MPI pre/post masks agree,Allreduce86320 andring correct. Botharms have allfour preparationlogs End and150step solver End/finalization. Cd0.27–0.30 and pairdiff<=1e-8 are predeclared diagnostic gates, not official competition hardlimits.

Allocation416CPU/760GBRAM/400GBJOBFS/1hour,max832SU. Actualmemory341.75GB,JOBFS42.24GB fromPBSreceipt. Total SU recorded once for the pair, not charged to eacharm. No retries or further experiments submitted. Monitor to be closed after result synchronization.
