# ASPIRE2A six-step optimisation — Step 1 evidence report

Date: 2026-09-23  
Status: **STEP 1 COMPLETE**  
Scope: existing files and read-only remote inspection only; no PBS submission,
OpenFOAM run, build, or remote modification.

## 1. Evidence archived locally

The three raw 4-node/512-rank mpiP reports, paired control/profile solver logs,
original decomposition logs and inherited coefficient files are retained under
[`planning/evidence/aspire2a-mpip-4n512-2026-09-23/`](../evidence/aspire2a-mpip-4n512-2026-09-23/).

Raw mpiP SHA256:

| Method | Job | Report SHA256 |
| --- | --- | --- |
| KaHIP | `24490441.pbs101` | `e13539a1eff56230fadfcb68ae26f86b486831040df408bb2cb5a7ea13f0373e` |
| Scotch | `24600615.pbs101` | `6b01fdcf0d18b9f52871140773effdff9bb77a9dbd45ccb8e44014e38cf00fb3` |
| hierarchical `(8 8 8)` | `24870034.pbs101` | `602a5243f6b4b84d5d1a0acd3c9b3dd69c4bcbd3d70057fa7f476f1c7be` |

The local parser is
[`analyze_mpip_reports.py`](../evidence/aspire2a-mpip-4n512-2026-09-23/analyze_mpip_reports.py).
Its reconstructed call-time totals match the sum of mpiP's 512 rank totals to
within 0.01% for every method, providing an internal validation of the parser.

## 2. Cd provenance: resolved as stale inherited evidence

All six `case-control`/`case-preload` coefficient paths point to files with the
original September 14 timestamps, 150 numeric rows and `Time=1..150`:

| Method | File mtime | Rows | SHA256 |
| --- | --- | ---: | --- |
| KaHIP | `2026-09-14 04:45:03 +0800` | 150 | `8e9b543c1f8780c154a86e9790d6d7e17e2770b4fe409f6df89b3e561d3bfda7` |
| Scotch | `2026-09-14 03:55:59 +0800` | 150 | `4d83382cf56b8c27ad6f7ab116ce90451ed01aa48650858b5a1210eca2dfecf0` |
| hierarchical | `2026-09-14 03:49:38 +0800` | 150 | `0ae4fd4aeaf601465e96d0a18859abf47d1f6e9cc76dbeec0dd7f3a9aeb02582` |

The profile jobs ran on September 20–21 and their solver logs reached only
step 40. The coefficient files were not updated during those jobs. Their
control and preload copies are byte-identical because both inherited the same
completed template file.

**Correction:** values `0.28004`, `0.28405` and `0.29843` cited as profile
Cd(40) are actually inherited original-run Cd(150) values. They do not validate
profile correctness and must not appear on slides as profile Cd(40).

The live solver logs remain valid evidence that both arms reached `Time = 40`,
completed normally and produced finite solver output. The wall-clock and mpiP
measurements remain usable as diagnostic timing evidence, with the already
measured profiler-overhead caveat. A clean rerun is needed to establish Cd
trajectory equivalence.

## 3. Time-weighted MPI call aggregation

| Method | Reconstructed MPI time | Collective | Wait/test | Point-to-point | Other |
| --- | ---: | ---: | ---: | ---: | ---: |
| KaHIP | 18,836.4 s | 57.62% | 31.77% | 9.59% | 1.02% |
| Scotch | 22,499.2 s | 57.18% | 33.58% | 8.43% | 0.81% |
| hierarchical | 28,900.7 s | 55.34% | 36.83% | 7.26% | 0.57% |

Top individual calls:

| Method | Allreduce | Share | Waitall | Share |
| --- | ---: | ---: | ---: | ---: |
| KaHIP | 9,645.2 s | 51.20% | 5,322.0 s | 28.25% |
| Scotch | 11,650.9 s | 51.78% | 6,856.2 s | 30.47% |
| hierarchical | 13,798.9 s | 47.75% | 9,944.4 s | 34.41% |

Relative to KaHIP:

- Scotch adds 3,662.8 aggregate MPI seconds; additional Allreduce + Waitall
  account for 96.6% of that increase.
- Hierarchical adds 10,064.3 aggregate MPI seconds; additional Allreduce +
  Waitall account for 87.2% of that increase.

This supports an Allreduce algorithm screen, but it also shows that collective
tuning alone cannot address the whole problem. Waitall growth is the strongest
partition-sensitive signal.

## 4. Per-rank distribution

| Method | Median MPI time/rank | p90 | p95 | p99 | Maximum |
| --- | ---: | ---: | ---: | ---: | ---: |
| KaHIP | 36.25 s | 42.10 | 43.75 | 47.26 | 54.60 |
| Scotch | 43.60 s | 48.79 | 50.15 | 52.48 | 53.60 |
| hierarchical | 56.10 s | 66.20 | 69.65 | 74.97 | 79.60 |

mpiP records the exact rank-to-host assignment. All runs used four hosts with
128 consecutive ranks per host, so the earlier `floor(rank/128)` cross-node
calculation is now verified for these profile jobs. The reports do not record
core or NUMA affinity; those fields remain unknown for the old runs.

## 5. Partition topology joined to actual host assignment

| Method | Distinct processor-interface faces | Distinct cross-node faces |
| --- | ---: | ---: |
| KaHIP | 2,786,035 | 213,435 |
| Scotch | 2,927,022 | 337,324 |
| hierarchical | 5,679,671 | 2,048,418 |

Across methods, higher cross-node surface, mpiP fraction and wall time preserve
the same ordering: KaHIP < Scotch < hierarchical.

Within a single method, the per-rank correlations are weak and sometimes
negative. This is expected for synchronization timing: ranks with less work
can accumulate more MPI wait while the slow rank computes or communicates.
Consequently, per-rank `MPITime` is not a direct per-rank work measurement.
The useful signal is the distribution tail and the cross-method aggregate,
not a claim that the rank with the most interface faces must have the highest
recorded MPI time.

## 6. Decision for the next steps

Step 1 changes the next experiment decision in two ways:

1. **Step 2 must repair the correctness harness.** Fresh cases must start with
   no `postProcessing`, and the job must prove that the resulting coefficient
   file was created during the current allocation, has exactly steps 1–40 and
   differs from the inherited 150-row files.
2. **Both partition and collective work remain justified.** KaHIP parameter
   screening targets Waitall and communication-surface cost. The later MPI
   screen should prioritize one verified Allreduce setting because Allreduce
   alone accounts for roughly half of measured MPI time.

The next compute experiment is Step 2: two identical bound KaHIP 40-step
controls in one 4-node allocation, with mpiP disabled, fresh Cd output and an
actual rank/core/NUMA manifest. A complete local PBS diff must be reviewed
before remote synchronization or submission.

## 7. Remote actions performed

Read-only operations only:

- listed the three known profile directories and their retained files;
- inspected `controlDict`, solver logs, numeric time directories, timestamps
  and coefficient files;
- copied the three raw mpiP reports, six solver logs, coefficient files and
  three original `decomposePar` logs to the local evidence directory using
  `scp -p`;
- did not alter any remote file or scheduler state.

No `qsub`, `qdel`, OpenFOAM executable, build command or remote write command
was issued.

