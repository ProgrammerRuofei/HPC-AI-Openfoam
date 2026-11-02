# 182929980.gadi-pbs — complete original logs and independent validation

**PBS F / Exit0; uniquePASS and independent local validation PASS.**
ICX2025.3.2, private Open MPI5.0.10, single normalsr SPR8470Q host gadi-cpu-spr-0686;104ranks,64GBRAM/20GBJOBFS/10min request.48sec,**2.77SU**;PBS memory20.89GB,JOBFS1.94GB. MPI-only: no solver steps/Cd/scored time.

Six launches,104rankJSON each,624 total. Baseline/control/four candidate blocks on same physical node,104distinct cores,13ranks/NUMA,pre/postMPI_Init masks equal,sum5356/ring valid. Control changed0;candidate blocks3/6/10/2. All624 records report actual UCP `/usr/lib64/libucp.so.0`,version1.21.0. Modules UCX1.18.1/UCC1.4.4 are declarations, not actual-selection proof. Preflight did not capture collective selection. No MR registration failures in any launch;104 unused-UCX-environment warnings per launch retained.

655 original produced files (654 evidence including624rankJSON + stdout) copied byte-for-byte and checked against remoteSHA256. qstat.txt is exact captured scheduler stdout. No missing produced files. See [every source path](sources.tsv), [each local raw file SHA256](SHA256SUMS), [remote hashes](remote-sha256.txt), [independent validation](independent-validation.json), [validator](validate_local.py). Generated manifests/validation are not original cluster logs.

Sources:
- `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v2/182929980.gadi-pbs/evidence/`
- `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_rank_numa_1n_v2.pbs.out`

Read-only remote commands: qstat -xf182929980; in evidence `find . -type f -exec sha256sum {} +`; sha256sum independentstdout. Transfer `scp -p -o BatchMode=yes` exact files in bounded directory groups to unique local staging, at most4concurrent groups. No remote mutation from retrieval.

This validates one-node launch and placement compatibility, not four-node speedup or actual solver memory-page residence. Original v1 memory failure remains in its separate archive.
