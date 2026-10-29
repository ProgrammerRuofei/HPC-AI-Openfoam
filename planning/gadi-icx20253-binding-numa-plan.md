# Gadi ICX 2025.3.2: core binding, rank order and NUMA experiment plan

Date: 2026-10-30, Asia/Singapore. Requested scope: prepare a detailed plan and
progress its execution over approximately two hours. PBS queue time is not
predictable; two hours is a work window, not authorization for unlimited SU.
The first concrete execution batch below needs approval after its script diff
is displayed, as required by AGENTS.md. Later four-node choices depend on the
measurements and require their own reviewed diff. No new PBS job has yet been
submitted for this plan.

## 1. Purpose and evidence

Use ICX 2025.3.2 / private Open MPI 5.0.10 / OpenFOAM.com v2512 / Scotch as
the working candidate. Its two four-node observations are 1.976664844 and
1.975253477 s/step, mean 1.975959161, final Cd 0.291876174. The second run's
raw evidence is at `planning/evidence/gadi-pbs-script-snapshot/logs/182564679.gadi-pbs/`;
the first raw receipt is not independently archived in the current main checkout.
The ICX 2026 runtime-policy screening result 182575342 is 1.994094357 s/step;
the final raw-log pull and complete independent validation remain outstanding.
Compiler-only attribution is not established.

The GCC one-node binding jobs 182017873/182019151 used the same host and
science, with 104 ranks and 40 steps. Default allowed each rank to move inside
a 13-core NUMA region; core binding produced 104 distinct physical-core masks.
Times were 8.373520290 / 8.346359078 s/step, only 0.32437% apart. The current
ICX four-node host map does not establish its actual core binding. Do not
assume its default policy is identical to the earlier GCC observation.

## 2. What the three controls mean

* **Core binding:** constrain each MPI process to one physical core. This can
  reduce migration and cache disruption, but can also remove useful scheduler
  flexibility. One physical core may expose two SMT CPU IDs; verify socket/core
  identity rather than asserting a one-element Linux CPU mask. It does not
  enable additional vector instructions or guarantee a performance gain.
* **Rank order / CPU placement:** choose which numbered mesh partition runs on
  which core and NUMA domain. All cores can be occupied in two experiments,
  while the neighboring partitions occupy different physical locations.
* **NUMA memory policy:** choose where pages are allocated. CPU binding does
  not by itself prove page placement. Linux normally prefers local allocation;
  explicit local allocation can be equivalent to the default. Page location
  is not a measurement of memory bandwidth or remote-memory stall time.

Treat these as separate tests. Keep the chosen runtime policy throughout:
load intel-compiler-llvm/2025.3.2, ucx/1.18.1, ucc/1.4.4; private Open MPI;
UCX PML; no forced UCX preload or changed HCOLL/UCC collective parameters.
Reject an unexpected injected LD_PRELOAD or OMPI_MCA_coll rather than silently
turning this into another communication-policy experiment. Loaded modules,
ldd and MPI_Init runtime probes have different evidential strength; preserve
all and label any unmeasured 104/416-rank selection as unknown.

## 3. Fixed identity and outputs

Use the existing ICX archive from build 181392981, SHA-256
`a832416d47a1a26cc2a02ef0c69eb09dbf142043d619ed22ece37d96b029dfcd`, and
simpleFoam SHA-256 `7cc4af8c576eba1e97ba16a767fca5843293c391b71a3904a596b3981d2913e4`.
Private MPI archive SHA-256 is
`8ac121e4f64eb329dc33cd2cc8229dc9f655064a757cbcaa36af962b21619fc6`;
GCC runtime archive SHA-256 is
`1149c0d97412ae3741cc18d60f233cdd3dd5e33bc92c55c59db2dd8cf535b714`.
Copy source science only into this job's private JOBFS. Keep the fixed
65,334,765-cell mesh, simpleFoam source, fvSchemes and fvSolution. Retain
no additional permanent full input copy. Hash source mesh files, compare
the actual private copy, and retain science/configuration manifests.

Every arm retains: PBS receipt, job/script identity, binary/archive hashes,
module and MPI receipts, topology, rank/node/core/NUMA map, preparation logs,
full simpleFoam.log, coefficient.dat, coded s/step, solver iterations, Cd,
exit/PASS and actual SU. Preserve raw files by job ID under
`planning/evidence/gadi-pbs-script-snapshot/logs/<job-id>.gadi-pbs/`, with
separate `default/` and `core/` folders, original bytes, SHA-256 and README.
Update the job index, experiment README, results and progress together.
Per-job SU cannot be allocated exactly to each arm; retain whole-job actual
charge and label any time-proportional allocation as an estimate.

## 4. First execution batch: placement probe and paired binding screen

### P0: one-node placement/runtime preflight

One normalsr SPR node, 104 allocated cores, 16 GB memory, 20 GB JOBFS,
10-minute ceiling: **34.67 SU maximum**. No OpenFOAM solve.

1. Verify archives, ICX/MPI versions, PBS allocation and SPR topology.
2. Compare default `--map-by ppr:104:node` with the same command plus
   `--bind-to core`. Record 104 separate JSON affinity receipts per policy.
3. Check unique ranks, one host, 104 distinct physical cores for core mode,
   no core sharing, and that each core assignment is within that rank's
   default allowed-core set. If both masks are already identical, skip the
   expensive binding comparison. If placement also changes, stop and revise
   the claim/design before interpreting it as binding alone.
4. As optional topology observations in this same allocation, try
   `--map-by ppr:13:numa --rank-by fill --bind-to core` and `--rank-by span`
   only if the observed topology is eight 13-core NUMA domains. Verify actual
   map differences; unsupported syntax/placement blocks this later direction,
   not an otherwise valid default/core preflight. A launch that hangs stops
   the probe; do not continue with a possibly surviving MPI job.
5. Run a bounded two-rank MPI_Init/Allreduce probe, record the private MPI
   and actual loaded UCP path/version plus collective verbose evidence.
   This validates the probe's runtime, not the 104/416-rank solver selection.

### B1/B2: two same-node paired blocks, AB then BA

Each PBS job requests one normalsr SPR node, 104 cores, 190 GB memory,
100 GB JOBFS, 40 minutes, **138.67 SU maximum**. Both arms use 104-way Scotch,
40 steps, the same binaries/runtime and complete preparation chain.

* B1 order: A = default, then B = core.
* B2 order: B = core, then A = default.
* Different blocks may receive different hosts. Compare B/A within each
  host block first; do not treat absolute times from different hosts as paired.
* Each arm starts from a fresh private case, never a previous solver's state.
  Keep both cases in JOBFS until PBS disposal; no deletion of old scratch
  evidence. The previous two-arm job 182509859 used 39.8 GB JOBFS and
  22:48 / 79.04 SU. It reported memory use at 190 GB, so any memory failure
  in the ICX screen stops the affected batch; do not automatically raise memory.
* Perform the default/core map comparison again on each allocated host before
  the large case is copied or solved. Save a per-rank receipt immediately
  before exec of the actual solver; this is pre-exec affinity, not proof that
  an MPI component cannot change affinity after MPI_Init.
* B2 runs only after B1 has completed its evidence/correctness checks. These
  two blocks are planned replication, not permission for additional repeats.

First-batch total ceiling: **312.00 SU**, 90 minutes of requested allocation
time if serial. Historical cost suggests roughly 160 SU plus the probe, but
this is an estimate, not an ICX measurement. Queue delays can extend beyond
the two-hour work window. No further job is submitted merely to fill time.

### Acceptance and decision

Require PBS Exit 0 plus markers, both full preparation chains, exactly 40
solver Time entries and End, finite positive step times, finite Cd, input
hashes and consistent 104-rank decomposition geometry. The observed 40-step
Cd range 0.42–0.45 is a local plausibility check, not an official tolerance.
Investigate any Cd trajectory or iteration-count change; do not select a fast
but scientifically different arm. Exact Cd equality is useful evidence but
not assumed as a universal floating-point requirement. The proposed pair parser
uses maximum absolute paired Cd difference <= 1e-8 as a conservative promotion
gate; exceeding it triggers inspection, not a claim of competition failure.

For block i calculate `delta_i = 100 * (t_Ai - t_Bi) / t_Ai` and report both
paired effects, not only pooled minima. Two agreeing blocks are encouraging
but not a confidence interval. A 0.3% effect remains inconclusive unless
supported by repeatability and a clear physical-placement change. As a
practical decision rule, a consistent effect around 1% or greater merits a
four-node confirmation; this is a budgeting choice, not statistical proof.
Opposite signs or effects comparable to observed within-policy variation
stop promotion. Do not reject all four-node placement hypotheses solely
because a one-node result is null: the cross-node problem is different.

## 5. Rank ordering / NUMA CPU placement: separate follow-up

Use the P0 topology and actual maps before choosing commands. Candidate M0/M1
are `ppr:13:numa` with `--rank-by fill` / `--rank-by span`, both core bound.
First require the same set of 104 occupied physical cores and 13 ranks per
NUMA domain, while rank-to-core association actually differs. If this release
produces identical maps or cannot honor the request, skip redundant solves.
If an explicit rankfile is needed, generate it from verified hwloc logical
indices, not from guessed Linux CPU numbers; preflight the resulting mapping.

Compare M0/M1 in paired AB/BA blocks, 104 ranks and 40 steps, using the same
correctness checks and cost ceilings as B1/B2. Derive for each mapping the
number of partition faces crossing NUMA domains/sockets from the actual
rank-neighbor list. Rank numbering need not follow geometric proximity.
Associate time changes with these data cautiously; MPI waits also include
load imbalance. This is a separately reviewed batch after B1/B2, not an
automatic addition to the initial 312-SU ceiling.

For a four-node extension preserve each host's original block of 104 ranks
when testing within-node order. A global rank-by option may also redistribute
ranks among hosts; inspect the complete 416-row map before execution. Study
cross-node reordering as a separate experiment if it changes host membership.

## 6. NUMA memory placement: diagnose before forcing a policy

After selecting an explicit CPU placement, take sparse diagnostic samples
from representative ranks across the eight NUMA domains using available
`numastat -p` or `/proc/<pid>/numa_maps`. Read only these job-owned processes;
do not scan other jobs. Measure anonymous-page locality and memory policy,
and retain the rank/core map. Sampling is diagnostic and outside scored runs;
page counts alone cannot prove bandwidth saturation or stalls.

Only then consider one memory-policy comparison with CPU/rank placement held
fixed: default versus local allocation if they actually differ, or default
versus interleave if there is a concrete bandwidth/locality hypothesis.
Interleave may increase remote access and regress. Avoid hard `membind` to
one domain without capacity evidence because it can trigger local exhaustion.
For this later stage, first budget one 104-core/10-minute preflight (34.67 SU
maximum) to verify the selected CPU map, `numactl` availability, effective
memory-policy inheritance and small-allocation page placement. A small buffer
is only a tool check, not a model of the 65M case. Then propose one 104-core,
40-step diagnostic of the real case with sparse page-placement receipts
(20-minute/69.33-SU ceiling, 190 GB memory, 100 GB JOBFS), followed only if
justified by two uninstrumented AB/BA memory-policy pairs (2 x 138.67 SU).
This optional stage totals at most 381.33 SU and needs a separate exact diff
and approval; it is not included in the current batch. If tools are missing,
page locality is already appropriate, or policies are equivalent, omit the
corresponding solve rather than spend SU on a redundant treatment.

No global kernel NUMA-balancing, transparent-hugepage or shared-node settings
are changed. Missing tools are recorded; no package installation is implied.

## 7. Four-node confirmation and profile

After screening, propose a single specific policy against the selected ICX
2025/Scotch control. Use four normalsr SPR hosts, 104 ranks/host, 416 total,
150 steps, complete preparation chain, and the same binary/input/runtime.
One-hour ceiling = 832 SU per run; prior ICX default runs cost 228.80 and
228.34 SU. Current evidence predicts no reliable optimized-run cost.
Show the actual four-node diff and get approval before submission. For effects
near 1%, a contemporary paired control is preferable to relying only on old
scores; any extra control/repetition must be explicitly budgeted and approved.

CPU and PMPI diagnostics are separate runs. Continue the existing ICX CPU
then PMPI plan; compare named CPU costs, steady Waitall/Allreduce distributions,
calls and rank surfaces. Exclude startup Barrier from steady PMPI estimates.
Do not equate CPU sample percentages to wall-time fractions, or MPI waiting
to network-transfer time. A binding benefit must be demonstrated by an
uninstrumented run; diagnostic timings are not scored results.

## 8. Failure handling and stop conditions

| Failure | First action | Repair / resume boundary |
|---|---|---|
| SSH/authentication timeout or rejection | Preserve local work; no auth retry | User restores verified control connection; no PBS outcome inferred |
| Unknown qsub outcome | Read queue and unique stdout/evidence | Never resubmit until the original submission is resolved |
| Syntax, path, output-name or parser defect | Save first error, ID and raw files | Local narrow fix, syntax/parser tests, new attempt path; reviewed diff/sync before retry |
| Unsupported map/rank option | Save actual command and launcher error | Change only reviewed topology proposal; no oversubscribe/overload fallback |
| Core map not 104 unique physical cores | Stop before solver | Diagnose topology/cpuset/rank map; do not silently bind multiple ranks to one core |
| Missing optional NUMA tool | Record unavailable | Continue checks that do not depend on it; no installation |
| MPI hang/initialization fault | Bounded timeout, retain logs | Stop affected job path; diagnose libraries/launcher; no expensive automatic retry |
| PBS memory/time/storage limit | Retain receipts and partial logs | Re-estimate resources and seek approval; do not enlarge automatically |
| Invalid Cd, altered input/hash, incomplete End | Mark invalid and preserve | Investigate; do not tune physics or loosen correctness to make a pass |
| No consistent speedup | Report null/inconclusive result | Stop promotion; no automatic search through many flags |

Local deterministic documentation/parser repairs may proceed within this
request. New remote-affecting patches still follow the repository diff gate;
this plan does not grant an unlimited retry or four-node submission budget.

## 9. Execution and storage checklist

Before approved submission: existing control connection and transfer form;
current quota and active jobs; isolated branch only; reviewed explicit file
list; syntax/helper validation; GitHub/Gadi synchronization and ff-only/hash
checks; unique output paths. At the 2026-10-30 read-only check, pm78 had
8.76 KSU available, 527.80 GiB of 1 TiB scratch and 161.33K of 202K inodes.
This is a snapshot, not a reservation. Record exact values again before use.

Keep the existing verified source and runtime archives as master copies.
New permanent scratch consists of evidence only (planning allowance <1 GiB
and <5,000 inodes for the first batch, to be measured; do not confuse this
allowance with observed output size). Temporary cases/runtime consume only
their allocated JOBFS; no persistent duplicate mesh or results overwrite.
If exact free space/inodes cannot be verified, stop the relevant submission.

## References

* `results/gadi-gcc162-ompi5010-scotch/binding-1n-40step.md`
* `planning/evidence/gadi-pbs-script-snapshot/logs/182509859.gadi-pbs/`
* `planning/gadi-icx20253-scotch-profile-plan.md`
* `progress/2026-10-29-gadi-icx-gcc-profiling-phase0.md`
* [Open MPI 5.0.10 placement/binding/rankfile documentation](https://docs.open-mpi.org/en/v5.0.10/man-openmpi/man1/mpirun.1.html)
* [Linux NUMA memory policy](https://kernel.org/doc/html/v5.15/admin-guide/mm/numa_memory_policy.html)

## Approval received 2026-10-30

User explicitly approved the first three-job batch, maximum 312 SU, including isolated-branch commit/synchronization, sequential gated submission and raw evidence retrieval. No further approval is needed for these unchanged reviewed jobs. Failures stop progression; additional jobs remain excluded.
