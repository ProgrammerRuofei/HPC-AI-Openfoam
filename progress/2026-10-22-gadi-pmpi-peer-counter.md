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

Local syntax and diff review, commit/push, immutable remote materialization,
PBS submission, final exit and actual SU remain to be recorded below. A
four-node peer-counter diagnostic requires a separate decision after this
overhead and coverage evidence is reviewed.
