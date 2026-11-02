# Rank/NUMA four-node v2 authorized retry

User approved one resubmission after the topology receipt failure182932939. Required startup reading and Git-state checks completed in current session; main and isolated unrelated dirty contents preserved. Full v2 local diff displayed and validated, then installed in isolated branch.

Only topology receipt collection/output diagnostics and new attempt paths changed; same ICX2025.3.2/privateOpenMPI5.0.10/OpenFOAMv2512/Scotch/fixed65M,4SPR×104ranks,control then candidate150steps each,bothcorebound,21within-node/socket rank moves.760GBRAM/400GBJOBFS/1h,max832SU;465–500SU planning estimate. Prior35.13SU failed attempt retained separately. No extra retry authorized.

Three new scripts have bash-n PASS; embeddedPython AST/hash checks PASS; mocked receipt tests cover valid, empty, wronghost/model, commandfailure and existing-file preservation. Remote verification and unique submission pending. Monitor only this retry when submitted; successful completion requires full original pair acceptance and raw-file SHA archival.

## Submitted once — 182939454.gadi-pbs

User-approved single v2 retry submitted by `qsub experiments/gadi-icx20253-rank-numa/run_rank_numa_pair_4n_v2.pbs` from the existing remote isolated checkout. Returned ID182939454.gadi-pbs; no duplicate qsub. Script commit a04f44a895b771bca0c70aaeb61744ab330454c8; PBS SHA601e73fe815561997173f2a409aa82140790a23acc174889c1191414beba4e8c. Three script SHA values and remote bash-n passed; remote HEAD equals local. GitHub/Gadi synchronization completed.

Pre-submit nci_account -P pm78:6.02KSU available, scratch661.74GiB/1TiB and180.51K/202Kinodes. Supplementary `lquota -P pm78` was rejected as unsupported syntax; storage figures are from nci_account, not lquota. New stdout absent before submission. Planned incremental scratch<=25GiB/<6000inodes fits observed headroom; no old evidence/grid deletion.

Stdout:/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_rank_numa_pair_4n_v2.pbs.out
Job root:/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-pair-4n-v2/182939454.gadi-pbs/
Top evidence/pair.log and exit-status; control/evidence and candidate/evidence. Actual SU,solversteps,Cd,seconds/step pending. Same4SPR416ranks,150stepsperarm,1hour832SUceiling. Monitor only this job; no further retry authorization.
