# Rank/NUMA memory-headroom retry v2

User explicitly approved one64GB retry including isolated GitHub/Gadi sync and archival. Startup rules already read in active session; latest result and Git state checked, existing master confirmed. All unrelated dirty files preserved.

Exact approved diff installed as new v2 PBS; SHA74a325010a6f0800860928faf9e7f5b1166131acb190f95a53e83c254e73c655, bash -n passed. Only RAM16->64GB and new attempt paths/names changed.104CPU/10min/20GBJOBFS unchanged,max34.67SU. C/helper/map unchanged. v1 F/Exit137/1.62SU preserved; candidate validity unknown.

Next: verify quota/unique output, sync and hash, submit exactly once, record returned ID. No automatic retry or four-node job; monitor stays off.

## Submitted once — 182929980.gadi-pbs

2026-11-02 18:42:57 Gadi time; initial qstat -xf stateQ. PBS confirms1node104ncpus/104mpiprocs,64GB RAM,20GBJOBFS,00:10:00. ActualSU and result pending;34.67SU ceiling. No auto retry/four-node job/monitor.

Script commit f439ed4eccae2c3beaf0fab8a15bc23d6ff6caa0 synchronized GitHub/Gadi; remote ff-only and SHA74a325010a6f0800860928faf9e7f5b1166131acb190f95a53e83c254e73c655 verified. Original v1/source/helper/CSV hashes unchanged. Quota before submission6.05KSU available,661.74GiB/1TiB scratch,179069/202000inodes. New stdout absent.

Stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_rank_numa_1n_v2.pbs.out
Evidence: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v2/182929980.gadi-pbs/evidence/

Exact scheduler commands through existing ssh -o BatchMode=yes -o ConnectTimeout=10 gadi-comp: `qsub experiments/gadi-icx20253-rank-numa/preflight_rank_numa_1n_v2.pbs` (once), `qstat -xf 182929980.gadi-pbs`. Execution checkout /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo; synchronized with `git pull --ff-only /scratch/pm78/kj7183/openfoam_cpu/control-repo codex/gadi-gcc162-build`. Readonly nci_account -P pm78/lquota/status/hash and bash-n checks completed. Remote changes only approved Git synchronization and PBS job submission.

Next requested check: inspect182929980 only; verify Exit/PASS/624rank receipts/actualUCP/pre-postMPI masks and3/6/10/2 permutations, archive original files and SU. Failure stops further submissions.
