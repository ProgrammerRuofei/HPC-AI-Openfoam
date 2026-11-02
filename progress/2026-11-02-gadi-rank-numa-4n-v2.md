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

## Completion observed; immutable archival in progress

2026-11-02 17:44 Singapore heartbeat: PBS F/Exit0,2051s,474.01SU; both arms and pair V2_PASS. Remote summary control1.984055637966442/candidate1.984123309966443s/step,finalCd both0.29187617440389690,maxCdtrajectorydifference0. Preliminary values await independent local validation; no performance win established.

A single collector is running: /private/tmp/collect_ranknuma_182939454.py, exec session21688. Unique staging /private/tmp/archive-182939454-bw6wzna1 (path also in /private/tmp/collect-182939454-stage.txt). Remote manifest lists3447originals,36transfergroups,<=104/group,4parallel,600sec/group; two compiled MPI probe executables explicitly excluded. No case/processor archive copied. Do not start a duplicate transfer; check session/collection.json and SHA verified files first. Validator prepared at /private/tmp/validate_ranknuma_182939454.py; run against complete staging then archive unchanged into job-keyed local directory, update results/indices/progress, commit only related files, push/ff-only/hash and delete monitor. New PMPI script commit2010d33 from another task is already in the branch; preserve it and unrelated dirty files.

## V2 completed — 182939454.gadi-pbs

F/Exit0, botharms/pair PASS and independent local acceptance PASS. SPR0261–0264,4×104ranks,ICX2025.3.2/privateOpenMPI5.0.10/OpenFOAMv2512/Scotch/fixed65,334,765cells. Same explicit corebinding;21rank moveswithinoriginalnode/socket. Each150steps andcompletepreparation/End/finalization. Control **1.984055637966442s/step**, candidate **1.984123309966443s/step**; finalCd both **0.2918761744038969**, fulltrajectorydifference0. Runtime probesbothUCP1.21.0 at/usr/lib64/libucp.so.0;HCOLL selection appears inbothprobeverbose logs,notproof ofevery solvercollective. ModulesUCX1.18.1/UCC1.4.4.

Actual **474.01SU**,2051s;recordonceperpair. Candidate0.0034107914%slower; singleorderedpair showsno usefulspeedup,notreproducible regression. CPUmaskdoesnotprove memorypage locality. 3447originals+qstatSHAverified,3328rankJSON independentlychecked. [Raw local logs](../planning/evidence/gadi-pbs-script-snapshot/logs/182939454.gadi-pbs/README.md). No newjob/retry.

All originals retrieved read-only with verified SCP into fresh staging, archived with unchanged bytes/SHA. No scientific files changed. Prior v1failedreceipt resolved byv2four-node topology pass; noadditionalrerunauthorized. Finish bysyncing onlyrelatedresultsandrawlogs,verifyremotehashanddeletecompletedmonitor.

## Transfer recovery and independent acceptance — final local check

The original collector stopped after the SSH interruption. Resume session 49317 completed in a new staging directory, `/private/tmp/archive-182939454-resume-1gkl2w93`, reusing 2307 SHA-matched files and retrieving only 1140 missing or incomplete files. Both staging directories remain intact.

The local validator passed all 3448 manifest hashes (3447 original files plus the PBS query capture), all 3328 rank JSON receipts, both 150-step solver chains, the fixed partition/input checks, and the identical Cd trajectories. The three success markers each occur exactly once in their respective logs. The previously incomplete archival is now complete. Git synchronization is the remaining administrative step; no further PBS work is authorized.

## Synchronization verified; monitor closed

Archive/result commit `76024ca4f1942a477e41789c1b26bb0a2144fefc` is present on GitHub and the existing Gadi branch. The execution checkout is clean; `git pull --ff-only /scratch/pm78/kj7183/openfoam_cpu/control-repo codex/gadi-gcc162-build` returned Already up to date. Remote `sha256sum --quiet -c SHA256SUMS` passed all 3448 entries; result CSV, manifest and independent-validation JSON hashes also match locally.

The completed `gadi-rank-numa-v2-monitor` automation was deleted successfully. No new PBS job, cancellation, runtime change, or scientific-input change occurred. Unrelated collective-policy changes and other untracked files remain untouched. There is no remaining action for this monitor.
