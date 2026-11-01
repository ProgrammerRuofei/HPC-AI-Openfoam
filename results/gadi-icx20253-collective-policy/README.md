# 182829851.gadi-pbs — collective-policy smoke passed

Checked 2026-11-01 client date (Asia/Singapore); PBS server receipt dated
2026-11-02 is preserved verbatim. PBS F/Exit0,58seconds,0.16SU,SPR0248.
ICX2025.3.2/privateOpenMPI5.0.10/OpenFOAMv2512,Scotch pitzDaily_fused,
5ranks per arm,20steps each,default then no-HCOLL. 16GB/20GBJOBFS/10min.
All39 original files verified against remote SHA256; plus qstat-xf receipt.
See sources.tsv and SHA256SUMS; original names and bytes preserved.
Remote evidence root:
/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/collective-policy-smoke-v1/182829851.gadi-pbs/evidence
Stdout source is recorded in sources.tsv. No missing files in this job evidence inventory.

Both Time1..20/End/finalization, blockMesh/decomposePar End, identical input
hashes, five rank receipts per arm, sum10 and unique markers independently
checked locally. Default solver Enabled components: basic,hcoll,libnbc,self,tuned;
no-HCOLL: basic,libnbc,self,tuned. Enabled does not prove operation ownership
or algorithm. Both MPI probes report /usr/lib64/libucp.so.0 v1.21.0; probe
receipts are not direct evidence of the solver's loaded UCP version.
Module declarations ucx1.18.1/ucc1.4.4 unchanged; no UCX preload.

Verbose diagnostic times: default0.003530716684210526/no-HCOLL0.003591257368421052
s/step. These tiny tutorial timings are not performance evidence for the 65M
case. No DrivAer Cd exists for this tutorial; mark not applicable.
Script SHA5f964f4939ae5885d84d232813d254a1784c5fd1fff49ff4d6b4d490166c4ac4.
No binary rebuild or official-science modification.

[Original archive](../../planning/evidence/gadi-pbs-script-snapshot/logs/182829851.gadi-pbs/README.md)
