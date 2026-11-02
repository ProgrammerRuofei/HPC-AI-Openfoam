# Proposed one-attempt memory-headroom retry (not installed/submitted)

Observed job182926714 F/Exit137/1.62SU: scheduler memory kill at16GB during baseline104-rank initialization.104 probe RSS values alone total16.180843GiB. The earlier P0 only ran a2-rank MPI communication probe, so its16GB success did not establish104-rank MPI memory sufficiency.

Propose64GB rather than changing MPI,UCX,HCOLL or rankcount: preserves the experiment and adds initialization headroom.64GB is below the existing104-core SPR node allocation's190GB used by other jobs.104cores/10minutes retains34.67SU CPU-time ceiling; check scheduler allocation before treating it as exact charge.20GBJOBFS unchanged (v1 used1.94GB). No large scientific input. Expected scratch<20MiB/<800inodes; check availablequota before submission.

[Full diff](proposed-scripts.patch) is a new v2 file relative to retained v1. Only mem16->64GB and unique job/stdout/root/JOBFS/PASS names change. C,Python,CSV byte-identical; six launches/45s timeouts remain. bash -n of proposed content passed. New script SHA256: `74a325010a6f0800860928faf9e7f5b1166131acb190f95a53e83c254e73c655`.

Require PBSExit0,624correct rankJSON,104uniquecores,Allreduce5356/ring,pre/postMPI affinity,UCPreports,expected3/6/10/2permutations,acceptance.json and uniquePASS. Check whether MRregistration errors recur; more memory does not guarantee their absence. If failure remains, stop and inspect; no automatic extra retry or four-node job.

Approval requested: implement this exact diff, validate, synchronize existing isolated GitHub/Gadi branch, submit one v2 preflight, retrieve and archive original evidence/results. No4node solve. AGENTS requires shown diff and approval; workflow05 treats resource/MPI failures asTrack2. Prior approval was one v1 only.

## Approval received

2026-11-02: user explicitly approved one64GB preflight retry, branch synchronization and result archival. Exact reviewed v2 SHA validated; v1 and its original logs retained. No further retry or four-node solve authorized.
