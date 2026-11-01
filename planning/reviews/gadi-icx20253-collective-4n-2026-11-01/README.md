# Four-node collective comparison, one pair

Latest user instruction: “查看结果然后继续下一步 不用停下来问我”. This authorizes
continuing the previously described next controlled collective experiment
without another approval pause. It supersedes the previous review's pending
approval gate for this next pair only; no unlimited search/repeats or monitor.
Concrete [diff](proposed-scripts.patch) shown before synchronization/submission.

ICX2025.3.2/privateOpenMPI5.0.10/OpenFOAMv2512,Scotch,4normalsrSPR nodes,
104ranks/node,416total,150steps per arm,default then no-HCOLL. Same default
CPU binding,exact input/partition hashes. All preparation stages run default
collectives in both arms, isolating the treatment to simpleFoam and its
separate diagnostic probe. Only treatment adds --mca coll '^hcoll'.
No UCX preload,version change,UCC enable,forced algorithm or build flags.
Two fresh independent cases/runtimes; no original evidence overwritten.

Before each arm's decomposition, a separate416rank MPI_Init/Allreduce probe
checks four104rank hosts, sum86320,probe UCP path/version parity and HCOLL
component enabled/excluded.120second timeout. Compile only this tiny probe
using the existing toolchain inside PBS. Actual solver run has no collective
verbose,CPU orPMPI sampling. Pre-exec affinity receipts retained; compare all
rank host/localrank/core/NUMA/cpumask/memory-allowed masks exactly. Actual memory
pages and post-MPI affinity remain unmeasured. Probe selection is not proof
of the actual solver's per-operation component/algorithm.

Require PBSExit0,botharm/finalPASS,source/runtime/binarySHA,ScotchandfourprepEnd,
Time1..150/End/finalization,finitecodedtime,finalCd and fulltrajectory,
partition/inputidentity,416rankmappingandaffinityparity. Cd0.27–0.30 and
trajectory maxdiff<=1e-8 are existing diagnostic gates,not claimed official
hard criteria; on disagreement preserve output and investigate,not loosen.

Resources:416CPU/760GB/400GBtotalJOBFS/onehour,832SU ceiling. Planning actual
465–500SU based on completed binding pair464.76SU; not a guarantee. JOBFS
100GiB/node,50GiBfree quota guard before each arm. Same two-arm staging as
successful182637290. New persistent planning allowance<=20GiB/<6000inodes,
including ~2500 affinity/probe receipts. Recheckquota immediatelybefore submit.
Fixed65Mmastermeshreferenced andhashed,no permanent duplicateinput.

Bashsyntax,embeddedPythonAST,manifestSHA,unchangedscientific/stagingblock,
no corebinding/no verbose in timedsolver checked. Comparator tests:matching
416ranks accepted;wrongmask/missingrank rejected. Probeparser acceptedvalid
416worldsum;rejectedwrongsum. C differs from successfulsmoke onlyexpectedsize/sum.
No assumption of speedup. Singleorderedpair cannot eliminate order/noise.
No additionalrepeat,four-nodevariant,NUMA orbuildjobautomaticallyafterthis.
Monitor stays off. Originalsmoke39filesarchived before promotion.
