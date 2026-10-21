# Gadi PMPI peer-counter diagnostic — 2026-10-22 SGT

## Preserved four-node evidence, no new SU

The successful `181908113.gadi-pbs` profile used GCC 16.2.0, private Open MPI
5.0.10, loaded UCX 1.18.1/UCC 1.4.4 modules, OpenFOAM v2512, Scotch, four
`normalsr` Sapphire Rapids nodes (104 ranks per node), the unchanged ~65M-cell
`occDrivAerStaticMesh`, and 150 steps. PBS exit was 0, Cd was
0.29187594927465327, diagnostic timing was 1.993566906751678 s/step, and
accounted usage was 246.83 SU. PMPI call durations include waiting and are
not direct network-transfer times. The dynamically loaded `libucp.so.0` in
the saved `ldd` output points to `/usr/lib64`; its version was not recorded
by the old job and must not be inferred from the module list.

The saved `10_decomposePar.log` contains each rank's cell count and shared
faces with every neighboring rank. The four checksummed PMPI archives provide
416 full and 416 bucketed timing reports; `rank-host-map.txt` provides the
four host assignments. A read-only extraction produced:

- `results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-ranks.csv` (416 ranks);
- `results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-rank-edges.csv`
  (2,307 symmetric rank-pair boundaries);
- `results/gadi-gcc162-ompi5010-scotch/pmpi-181908113-analysis.md`.

Neighbor-face sums match every rank's logged processor-face total. Cells/rank
have CV 0.73%, processor faces CV 29.87%. The 206 ranks with at least one
cross-node face averaged 21.398 s of steady `MPI_Waitall`, versus 17.365 s
for the other 210 ranks; rank 112 had the highest Waitall (32.613 s) despite
zero direct cross-node faces. This does not isolate network cost or prove
causality. No four-node rerun is needed to reconstruct the rank-neighbor
surface graph.

## Approved one-node counter smoke

The user explicitly approved one small diagnostic after the proposed source
and PBS changes were described. It does not authorize a new four-node job.
`pmpi_peer_counter_v1.c` extends the validated C-only v2 interposer. In-memory
per-peer counters record successful sends and posted receives, their requested
payload bytes, and datatype-size errors. World peers, non-world communicator
traffic, and unresolved world peers are kept distinct. Requested receive bytes
are buffer capacity, not necessarily actual delivered bytes. No wrapper writes
to disk; reports are emitted at `MPI_Finalize`.

`smoke_pmpi_peer_counter_1n_v1.pbs` requests one `normalsr` SPR node, five
CPUs, 16 GB memory, 20 GB JOBFS, and 15 minutes (at most about 2.5 SU at the
established accounting rate). It reuses SHA-pinned GCC/MPI/OpenFOAM archives.
The two-rank UCX probe checks deterministic Isend/Irecv/Send/Recv/Sendrecv
counts and requested bytes, including a duplicate communicator. Four separate
five-rank, 20-step Scotch tutorial solves (U1/P1/U2/P2) check report
completeness, source linkage, and profiled versus unprofiled solver-step and
launcher walltime ratios. The result is diagnostic, not competition-scored.

Local mock-header C syntax, Bash syntax, embedded Python syntax, source hash,
and staged whitespace review passed. Commit
`aa96fad0253ed191fb7fe809af5f195d6f545612` was pushed to both the
GitHub and Gadi `codex/gadi-gcc162-build` branch refs and checked with
`git ls-remote`. Local Git could not refresh its remote-tracking refs because
the shared primary checkout's `.git` refs are read-only to this worktree;
this did not affect either remote branch, and both refs were verified.

The Gadi control checkout remained on `main`. Immutable source and PBS copies
were materialized from the approved branch commit under the confirmed scratch
submit-logs directory, without overwriting existing files. Their hashes are:

| Submitted file | SHA-256 |
| --- | --- |
| `pmpi_peer_counter_v1.submitted.c` | `ae997a4b1c51884b0954470ebf7ffb62b254741a86d1e4c0b9f1f3ca6feaa974` |
| `smoke_pmpi_peer_counter_1n_v1.submitted.pbs` | `22d9a10fe45d78352492727c053703a4fd369d7366d3ead5ca7bf01d0355797c` |

Gadi `sha256sum -c` and `bash -n` passed. The independent PBS stdout path
was confirmed unused. One non-interactive `qsub` from the Gadi control
checkout returned **`181921800.gadi-pbs`**; initial `qstat -f` showed `Q`,
5 CPUs and 15 minutes. The stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/smoke_pmpi_peer_counter_1n_v1.pbs.out`;
job-keyed evidence is under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/pmpi-peer-v1-smoke.181921800.gadi-pbs/`.

## Terminal result and first real failure

`/opt/pbs/default/bin/qstat -xf 181921800.gadi-pbs` reported state F,
`Exit_status=1`, and 3:13 walltime. The independent PBS stdout accounting
receipt reports **0.54 SU**, 5 CPUs and 10.82 GB used memory. The job ran on
`gadi-cpu-spr-0503`. The two-rank UCX probe passed exact per-peer and
requested-byte assertions, including duplicated-communicator traffic.
All four five-rank, 20-step Scotch tutorial solves reached normal `End`,
each with a final coded wall-clock statistic. Both instrumented solves wrote
all five summary, 10-second bucket and peer CSV files, with zero datatype
size errors. The two instrumented solves had exactly matching point-to-point
counts and requested payload bytes: 45,904 Isend and 45,904 Irecv calls,
15,716,080 requested bytes in each direction, plus four Send and four Recv
calls (288 requested bytes in each direction). Their full PMPI summary counts
agree exactly with the peer-counter aggregate counts.

The script correctly stopped at the **first coverage failure**: every one of
those 91,816 point-to-point calls per instrumented tutorial run was on a
non-`MPI_COMM_WORLD` communicator. The initial v1 design intentionally
aggregates such traffic as `other_comm` and therefore cannot identify the
remote world rank for the OpenFOAM solver. The assertion was:
`('P1', {'world': 0, 'other_comm': 91816,
'unresolved_world_peer': 0})`. This is an instrumentation-scope failure,
not a solver, MPI launch, Scotch, or scientific-correctness failure. The
original job ID, stdout, run log and reports remain preserved; the failed
attempt must not be relabelled PASS or resubmitted unchanged.

Read-only inspection of the authoritative v2512 source at
`/apps/OpenFOAM/2512/src/Pstream/mpi/UPstream.C` explains this observation:
the default `noInitialCommDup_` is false, and the base communicator is built
with `MPI_Comm_dup(MPI_COMM_WORLD, &mpiNewComm)` (around lines 274 and 809).
Passing `-mpi-no-comm-dup` merely to make v1 count peers would change the
runtime communication setup being diagnosed. A translation cache is the
appropriate instrumentation fix.

For preliminary overhead context, unprofiled tutorial solver-step times were
0.0039799504 and 0.0037713692 s/step; instrumented times were 0.0040656167
and 0.0040816411 s/step, a mean ratio of **1.05108**. This 20-step tutorial
is too short to establish four-node overhead. Launcher walltime was about
6.7 s unprofiled versus about 66.1 s instrumented (ratio **9.85466**),
dominated by startup and dynamicCode compilation in each copied case; the
reason for the extra startup time is not yet isolated. The script exited
before writing its overhead summary, so these ratios were computed read-only
from the preserved TSV and solver logs.

Next: design and locally validate a communicator-to-world-rank translation
cache, using MPI group translation once per communicator rather than per
message; preserve separate accounting for intercommunicators, unmappable
ranks, and wildcard receives. Then show the concrete v2 source/PBS diff and
obtain approval for any distinct low-cost retry under `AGENTS.md`. Only a
passing, low-overhead small test can justify proposing a separately approved
four-node diagnostic. No extra job has been submitted.
