# Four-node rank/NUMA pair — approved implementation

User explicitly approved exact520line diff, one paired PBS run, isolated GitHub/Gadi sync, original-log archival and renewed monitor. Startup workflow already read in active session; latest progress/Git state/master rechecked. Preserved main and unrelated dirtychanges.

Installed5files exactly matching approvedSHA;bash-n/Python/embeddedPython AST PASS. Prior synthetic416rank4host tests passed, liveprobe will run in job before scientificchain. Cprobe only, noOpenFOAM rebuild.

4SPR104ranks/node,416total,ICX2025.3.2/privateOpenMPI5.0.10/Scotch/fixed65M,control thencandidate each150steps,corebound both.21rankpositions change;node/socket/partition fixed.760GBRAM/400GBJOBFS/1h,max832SU. No extra retry orBA authorized. Next: quota/uniqueoutput checks,commit/sync/hash,one qsub andrecordID; resume5minmonitor.

## Single submission — 182932939.gadi-pbs

Submitted once2026-11-02 19:12:30 Gadi scheduler time (16:12:30 Asia/Singapore). Initialqstat stateQ. PBS confirms4nodes,104CPU/ranks each,416total,760GB RAM/400GBJOBFS/1h;832SU request ceiling. ActualSU/results pending.

Script commit b9f656a670016646ca4ca572b2326d9cf725182c; PBS SHA78b5926b750bb2b5532538e3ad92cf50f2e89792ca52c42ecd148361eff1446d. Fivefile manifests verified locally/remotely,remote bash-npassed. ExistingGitHub/Gadi branch synced andremoteff-only checked. Before submissionquota6.05KSUavailable,scratch661.74GiB/1TiB,180435/202000inodes;newstdoutabsent. No source/oldoutputs/mainchanges.

Exactqsub: `qsub experiments/gadi-icx20253-rank-numa/run_rank_numa_pair_4n_v1.pbs` from /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo; then`qstat -xf 182932939.gadi-pbs`. AllSSH viaexistingmaster/BatchMode/ConnectTimeout10. Remoteff-only from /scratch/pm78/kj7183/openfoam_cpu/control-repo codex/gadi-gcc162-build.

Stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_rank_numa_pair_4n_v1.pbs.out
Root: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-pair-4n-v1/182932939.gadi-pbs/
Topreceipt: evidence/; arms: control/evidence/ and candidate/evidence/.

User approved resumed5minute monitoring. NormalQ/Rsilent;finishindependentlyvalidateboth150stepchains,geometries,input/binaryhash,placementandruntimeproof,Cd/seconds/SU; archiveoriginals. Diagnosefailurewithoutautomaticretry. No extrafournode/BA/flagsauthorized.

## 182932939.gadi-pbs — failed topology receipt, 2026-11-02

F / Exit1, 00:02:32, **35.13 actual SU**; SPR0201–0204, 4×104 requested ranks, 416 total. ICX2025.3.2 / private OpenMPI5.0.10 / OpenFOAMv2512 / Scotch. Planned control then candidate, each150steps; neither reached solver. No seconds/step or Cd.

Four runtime staging receipts and source-dictionary/archive/binary SHA checks passed. `control/evidence/lscpu-0.txt` is empty while PBS stdout contains lscpu output. The first identified failing gate is the required model grep following the pbsdsh stdout redirection (arm script lines106–107); no ERR trace is available. Failure is in topology evidence collection, before baseline rank mapping, MPI probe, decomposition or candidate. Runtime UCP version / collective selection are unknown; module names and ldd do not establish them.

24 original files plus qstat captured, SHA verified, no originals excluded or overwritten. [Raw local logs](../planning/evidence/gadi-pbs-script-snapshot/logs/182932939.gadi-pbs/README.md). Preserve failure; no automatic retry. Proposed repair is node-side receipt writing with nonempty/model checks and explicit error-stage logging, followed by local tests and a complete new-version diff for approval. No run-script change applied.

Connection restored by user; `ssh -O check gadi-comp` reported master pid60987. Read-only `qstat -xf 182932939.gadi-pbs`, stdout, find/wc/cat and SHA inspections; verified `scp -p -o BatchMode=yes` to a fresh temporary directory, then immutable local archival. No qsub/qdel or remote data modification. Main and unrelated collective dirty files preserved. Automation gadi-rank-numa was deleted after confirming this attempt had finished. Next action: review a complete topology-receipt v2 repair proposal and approve a new attempt before execution.
