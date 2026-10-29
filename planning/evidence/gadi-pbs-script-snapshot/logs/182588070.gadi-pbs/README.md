# 182588070.gadi-pbs — ICX binding preflight

Raw evidence fetched read-only on 2026-10-30 through verified BatchMode SCP.
444 remote original files (443 evidence files plus PBS stdout) matched SHA-256;
qstat-xf.txt is a separate captured scheduler command receipt. Original names,
subdirectories and bytes retained. No scientific solver ran; Cd and s/step N/A.

## Identity and validation

Script commit 2b71932034f54ad9c6007aecb81c37f49a7200f2; P0 SHA256
3be58d39a4d7a55f27569250e2c756f9045c4795037ab1edeea40d83e712c9a4.
ICX 2025.3.2 / private Open MPI 5.0.10 / GCC 16.2 runtime, ucx/1.18.1 and
ucc/1.4.4 modules. One normalsr SPR 8470Q host gadi-cpu-spr-0381,
104 allocated CPUs, 16GB memory, 20GB JOBFS, 10-minute request.
PBS F / Exit 0, script_exit_rc=0, unique PASS; walltime23seconds, actual1.33SU.

Default/core each have104 complete rank receipts. Default:13 allowed physical
cores per rank,13ranks per NUMA domain. Core:104 unique physical cores,
onecore per rank within that rank's original default mask. can_run_binding=true.
Optional fill/span mapping probes both completed and each has104 receipts;
no performance benefit is established by this topology observation.

Dual-rank MPI_Init/Allreduce sum1 passed. Both ranks reported actual UCP
/usr/lib64/libucp.so.0 version1.21.0. Collective log records HCOLL enabled and
UCC unavailable/disqualified on relevant communicator selections. This2-rank
probe does not establish104-rank or416-rank solver collective selection.
Core/CPU affinity is not actual memory-page placement.

## Source paths and hashes

All original per-file remote paths and SHA-256 are in [sources.tsv](sources.tsv).
All local raw-file hashes including captured PBS state are in [SHA256SUMS](SHA256SUMS).
Remote evidence root:
/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/binding-numa-preflight-v1/182588070.gadi-pbs/evidence/.
PBS stdout:
/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_binding_numa_1n_v1.pbs.out.

Missing files: none among the443-file retained evidence inventory and PBS
stdout. simpleFoam.log/coefficient.dat are intentionally absent: this is an
allocation/runtime probe. Historical runtime and future solver choices remain
outside this job's evidence.
