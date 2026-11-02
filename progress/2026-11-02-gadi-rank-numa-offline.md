# ICX Scotch rank/NUMA ordering — offline candidate and preflight proposal

Startup workflow/AGENTS/APPLICATION already read in this conversation; latest
collective result and both main/isolated Git states rechecked. Preserved all
existing changes. This turn local analysis only, no cluster access or PBS.

User approved proceeding in order: rank/NUMA placement, evidence-based MPI
collective parameters, then build flags. Completed the first 0-SU analysis.

Primary raw graph182830268 default decomposePar, SHA verified; exact2307-edge
identity with GCC PMPI181908113 derived graph. P0182588070 topology/core104
receipts SHA checked; four-node182637290 binding text confirms historical
rank%104 logicalcore template. Template must be rechecked on new allocation.

Candidate keeps everyrank's node/socket,13ranks/NUMA,104/node; only21rank slots
change. Cross-nodefaces300065 andcross-socket164284 unchanged. Within-node
cross-NUMA716379 ->700355 (-2.2368%); maximumNUMAcells2054052 unchanged.
This is a proxy, not speedup or bytes; no global optimum claim. Both future
arms core-bound for control, not an assertion corebinding improves speed.

Files: planning/analysis/gadi-icx-rank-numa-order-2026-11-02/{README.md,
analyze.py,summary.json,input-provenance.json,swaps.json,
candidate-analysis-only.csv,numa-loads.csv}.
No runnable rankfile generated. Reproducible local search and independent
edge recount passed. Raw archives untouched.

Review patch only: planning/reviews/gadi-icx-rank-numa-preflight-2026-11-02/.
One proposed1node104CPU/16GB/20GBJOBFS/10min,34.67SU maximum; no solver.
Six short104-rank launches:baseline,rankfilecontrol,4candidateblocks.
NewMPIprobe records pre/postMPI_Init masks,Allreduce5356,ring,actualUCP;
helper derives current hwloclogicalcores and validates expectedslotmapping.
Localbash/Python/syntheticpositive&negativechecks passed; Cnotcompiled.

Exact diff ready, pending specific approval under AGENTS. No runtime scripts
installed, commit/push/remoteaccess/submission/monitor this turn. No4node,
NUMAmemorypolicy,extra retry orOpenFOAMbuild authorized by this proposal.
Existing collective job182830268 remains PBSExit1 due pairedCd gate; no
retroactive reclassification. Remaining2199raw smallfiles still remote.

Next after approval: implement exacthashpatch in existing isolatedworktree,
local validation, read-onlyconnection/quota andunique-outputchecks, approved
GitHub/Gadisync/ff-only/SHA, submitonepreflight. RecordreturnedID immediately;
unknownqsub outcome neverrepeated. Failurepreserveandstop. Completion archive
logs/SHA/results andreport; decide on4node separately.

## Approval and implementation

2026-11-02: user approved this one preflight. Installed the four exact reviewed files in isolated branch; all SHA256 values match. Existing unrelated changes preserved. Submission pending validation and remote checks.

## Single submission — 182926714.gadi-pbs

User approval implemented exactly, runtime file hashes unchanged. Commit dc7f25906ad1043de106c02ccef23279f4da1457 pushed to existing GitHub/Gadi isolated branch; execution checkout ff-only and all four SHA256 checks passed. bash -n / Python AST passed locally; remote bash -n passed. No OpenFOAM or live MPI execution outside PBS.

Submitted once at 2026-11-02 18:12:25 Gadi time; qstat -xf shows Q, 1 node / 104 ncpus+mpiprocs, 16GB, 20GB JOBFS, 00:10:00. Maximum34.67 SU. No actual SU or correctness result yet.

Readonly pre-submit checks: existing master running; nci_account -P pm78 reports6.06KSU available, lquota661.74GiB/1TiB and178941/202000inodes. Planned incremental evidence<20MiB/<800inodes. Unique stdout absent before qsub; remote tracked worktree clean.

Exact remote commands (all through ssh -o BatchMode=yes -o ConnectTimeout=10 gadi-comp):
- hostname; nci_account -P pm78; lquota; test ! -e <stdout>; git -C <execution-checkout> status --short; git -C <execution-checkout> rev-parse HEAD
- cd <execution-checkout> && git pull --ff-only /scratch/pm78/kj7183/openfoam_cpu/control-repo codex/gadi-gcc162-build
- bash -n experiments/gadi-icx20253-rank-numa/preflight_rank_numa_1n_v1.pbs
- cd experiments/gadi-icx20253-rank-numa && sha256sum -c ../../planning/reviews/gadi-icx-rank-numa-preflight-2026-11-02/SHA256SUMS
- after exact HEAD and absent stdout gates: qsub experiments/gadi-icx20253-rank-numa/preflight_rank_numa_1n_v1.pbs
- qstat -xf 182926714.gadi-pbs

Execution checkout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo.
Stdout: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/preflight_rank_numa_1n_v1.pbs.out
Evidence: /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/rank-numa-preflight-v1/182926714.gadi-pbs/evidence/

Remote changes limited to approved isolated Git sync and one PBS submission. Main and unrelated dirty files preserved. No monitor created; no retry or four-node job. On next requested check, inspect this ID, validate all six launches and archive original files/SHA/README. Live compatibility and actual cost remain pending, not assumed.
