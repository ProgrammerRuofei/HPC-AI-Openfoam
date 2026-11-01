# ICX 2025 collective-policy preflight review

Date: 2026-11-01, Asia/Singapore. Review only; no executable installed,
remote access, Git synchronization, compilation or PBS submission this turn.

## Evidence and scope

User approved progressing in order: collective policy, rank placement,
NUMA memory policy, then build flags. The next concrete action is one
small compatibility job; a four-node performance experiment is a separate gate.

The four-node binding pair 182637290 completed both 150-step arms:
default 1.982912342221477 versus core 1.985228038577181 s/step,
Cd 0.2918761744038969 in both, identical partition and Cd trajectory,
PBS receipt Exit 0, 464.76 SU total. This did not demonstrate core-binding
benefit. It did not measure physical memory-page placement.

Local P0 job 182588070 `mpi-runtime.log` lines 211 and 238 show HCOLL
Enabled for the two-rank probe; rank-0 receipt reports UCP 1.21.0 at
`/usr/lib64/libucp.so.0`. Neither proves selection in the 416-rank solver.
The module names ucx/1.18.1 and ucc/1.4.4 are not effective-library evidence.

## Exact proposed change

[Full script diff](proposed-script.patch) derives a new script from the
successful ICX 2025 tutorial smoke, leaving the old script untouched.
The new path would be
`experiments/gadi-icx20253-collective-policy/smoke_collective_policy_1n_v1.pbs`.
Archive, simpleFoam binary and timing-function SHA values remain unchanged.

Within one allocation, stage the same runtime once and create two fresh
pitzDaily_fused cases. Run default first, then exclude HCOLL. Each arm has
a 5-rank MPI Allreduce correctness/runtime probe and a 5-rank, 20-step
Scotch tutorial. Both use the same `ppr:5:node` mapping and default binding.
Only treatment adds `--mca coll '^hcoll'`; no UCX preload/version change,
UCC enable, forced tuned algorithm, compiler rebuild or 65M case change.
Both add `coll_base_verbose=30` and `--report-bindings` for diagnostics.

The small MPI probe is compiled with the existing private MPI wrapper and ICX
inside PBS. It reports actual probe UCP path/version after MPI_Init and checks
the sum of ranks is 10. The solver's own verbose log is independently saved
to identify enabled collective components. An Enabled component does not
identify every collective's algorithm or prove exclusive ownership.

## Resources and storage

- One normalsr node, 5 CPUs/ranks, 16 GB RAM, 20 GB JOBFS, 10-minute ceiling.
- CPU-based planning ceiling: 5 × 2 × 10/60 = **1.67 SU**. Check current
  allocation and scheduler limits before submission; no quota read this turn.
- One runtime extraction plus two tiny tutorials in JOBFS. Existing smoke
  used 12 GB; request 20 GB leaves margin, not a measured future peak.
- Persistent output planning allowance <100 MiB / <500 inodes, verify actual
  usage. No permanent duplicate of the 65M mesh, no cleanup or overwrite.
- Proposed stdout suffix `smoke_collective_policy_1n_v1.pbs.out` must be absent.
  Evidence root: existing ICX OF root / `collective-policy-smoke-v1/<job>/evidence`.

## Acceptance and evidence

Require PBS Exit 0, both arm markers and final unique PASS, genuine private MPI
link, pinned archives/binary, five probe receipts per arm, Allreduce sum=10,
normal probe finalization, no incompatible-UCP warning, identical tutorial
dictionary/input hashes, real Scotch, blockMesh/decomposePar End, exact solver
Time 1..20, End/finalization and finite positive coded time. Save all original
logs, submitted PBS, module list, ompi_info, launcher strings, bindings,
component-selection lines and compatibility-summary.json; archive by job ID
with per-file SHA and sources, actual SU and index/results/progress updates.

No HCOLL Enabled line may occur in the excluded solver arm. If the default arm
also has no HCOLL Enabled evidence, mark the intended contrast unestablished;
do not promote to four-node work automatically. Identify fallback components
from raw logs rather than assuming tuned. Missing/ambiguous component evidence
is a diagnostic limitation, not permission to silently change MPI settings.

This tutorial has no DrivAer Cd check. It cannot establish 65M correctness,
cross-node compatibility, 416-rank collective selection or performance gain.
Verbose tutorial timing is diagnostic only. Actual UCP receipts belong to the
probe, not the solver; do not use them to rewrite historical runtime claims.

## Local review and authorization gate

Proposed shell passed bash -n via stdin; embedded Python passed AST parsing.
The C probe is adapted from successful P0; it has not been compiled locally
or remotely. No executable script installed. Validation/hash receipt is
[validation.txt](validation.txt). Runtime paths, current storage/inodes and
remote Git/script hashes must be verified after approval and before qsub.

Requested approval covers implementation of this reviewed diff, only related
files committed to `codex/gadi-gcc162-build`, push to existing
`git@github.com:ProgrammerRuofei/HPC-AI-Openfoam.git` and Gadi transport,
remote ff-only and hashes, one PBS submission, read-only bounded checks and
verified SCP archival. No four-node run, automatic repeat, new monitor,
NUMA run or build-flag change is included. Failure preserves evidence and
stops the batch; unknown qsub outcome must never be resubmitted.

## Subsequent gates, in order

1. Inspect this result. If useful, design contemporary four-node default versus
   no-HCOLL comparison, no CPU/PMPI instrumentation or verbose solver logging
   in timed runs. Same nodes, same 416 ranks/150 steps, pinned science and default
   binding. Runtime/selection evidence is a separate diagnostic launch whose
   scope must be reported accurately. Show diff and approve the exact budget;
   recent two-arm job cost 464.76 SU, one-hour pair ceiling approximately 832 SU.
   Extra repeats are not implicitly approved. No expected gain is asserted.
2. Fix the selected collective policy; review an offline within-node permutation
   using the saved neighbor graph, preserving each node's rank set and 104-rank
   capacity. Validate mapping before one separately approved performance pair.
3. With CPU/rank mapping fixed, first inspect actual page distribution; select
   one distinct memory policy only if there is a concrete contrast to test.
   Allowed CPU/memory masks do not establish page residency. No blanket
   interleave-all or hard-coded shared NUMA node for every rank.
4. Audit existing build flags and CPU evidence before choosing one ISA/vector
   treatment. Build cost, compatible smoke, numerical validation and matched
   performance controls require a new reviewed proposal. No fast-math sweep.

## Sources

- [P0 probe log](../../evidence/gadi-pbs-script-snapshot/logs/182588070.gadi-pbs/mpi-runtime.log)
- [Four-node binding raw archive](../../evidence/gadi-pbs-script-snapshot/logs/182637290.gadi-pbs/README.md)
- [Open MPI 5 collective selection and tuned scope](https://docs.open-mpi.org/en/v5.0.x/tuning-apps/coll-tuned.html)
- [Existing rank/topology options](../../gadi-scotch-topology-rank-options-2026-10-30.md)
