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
