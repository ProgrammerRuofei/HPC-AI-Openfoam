# ASPIRE2A Scotch A/B/C: zero-SU time, Cd and topology audit

Date: 2026-10-25 (Asia/Singapore). Read-only analysis of the nine retained
4-node/512-rank/150-step runs, jobs `25909583`, `25909584`, `25909585`.
No job, build, file transfer, remote write or scheduler change was performed.
The earlier [completion check](2026-10-25-aspire2a-scotch-abc-evidence.md)
established log completeness, fresh 150-row coefficients and build/input
identity. This note inspects their time progression, numerical signals and
rank-to-node partition topology. `A` = plain Scotch; `B` = `domains (4 8 16)`
with `domainWeights (1 1 1)`; `C` = the same domains with `(1 1 0.01)`.

## Time progression

The solver's scored metric equals the mean of steps 2–150. `ClockTime` is
printed to integer seconds at each step, so the per-step jump counts below
are approximate diagnostics, not a replacement for the precise solver metric.

| Block / job | Arm | Solver s/step | Clock s/step, steps 2–50 / 51–100 / 101–150 | Clock jumps ≥10 s | Largest jumps (step: seconds) | Median jump |
| --- | --- | ---: | --- | ---: | --- | ---: |
| 1 / `25909583` | A | 2.929377 | 2.939 / 2.920 / 2.940 | 0 | — | 3 s |
| 1 | B | 3.030054 | 2.878 / 3.000 / 3.200 | 1 | 123:15 | 3 s |
| 1 | C | 3.201184 | 2.898 / 3.560 / 3.140 | 2 | 78:32; 113:10 | 3 s |
| 2 / `25909584` | A | 3.166639 | 3.000 / 3.200 / 3.300 | 2 | 67:12; 133:10 | 3 s |
| 2 | B | 2.912308 | 2.898 / 2.920 / 2.920 | 0 | — | 3 s |
| 2 | C | 3.086675 | 2.898 / 3.340 / 3.020 | 1 | 89:17 | 3 s |
| 3 / `25909585` | A | 5.565019 | 4.612 / 5.920 / 6.140 | 16 | 57:54; 146:53; 150:44 | 3 s |
| 3 | B | 4.918194 | 6.796 / 3.980 / 4.020 | 9 | 33:75; 34:65; 126:29 | 3 s |
| 3 | C | 4.113459 | 3.204 / 4.840 / 4.280 | 8 | 68:38; 108:35; 142:30 | 3 s |

Even in block 3, median step-to-step `ClockTime` is 3 s. Its mean is driven
up by intermittent large jumps. At A step 146, `ExecutionTime` grows by about
2.9 s while `ClockTime` grows 53 s. Such gaps show elapsed-time stalls relative
to the logged execution counter; they do **not** identify network, OS
scheduling, storage, competing jobs, or hardware as the cause. The block-3
physical nodes differ from blocks 1–2, but cabinet placement is only a
hypothesis. The three arms in a block ran sequentially, so even sharing one
allocation does not guarantee the same transient conditions. The alternate
fastest arm across blocks is not reproducible evidence that A, B or C wins.
All three saved PBS stderr files are empty and each stdout ends in
`SCOTCH_ABC_PASS`. They record the same libfabric file hash
`4959baaffd662...`; grep found no explicit fabric/timeout error explaining
the stalls. The SSH host-key messages in PBS stdout concern compute-node
connections and are not evidence of a network performance fault.

## Cd and residuals

Each arm has an identical Cd trajectory across its three blocks at all saved
steps, not merely at the four checkpoints below. The exact per-arm partitions
and cell counts also recur across blocks. The strong timing variation therefore
does not accompany a changed numerical result within the same arm.
The full `coefficient.dat` files match byte-for-byte across the three blocks
within each arm (SHA-256 prefixes: A `4d83382c`, B `788e7ca0`, C `17450474`).

| Arm | Cd(40) | Cd(80) | Cd(120) | Cd(150) | Mean pressure final residual, steps 100–150 | Mean absolute global continuity error, steps 100–150 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 0.435469 | 0.336759 | 0.300376 | 0.284051 | 1.53e-7 | 6.53e-8 |
| B | 0.439104 | 0.332007 | 0.292017 | **0.274010** | 1.37e-7 | 5.28e-8 |
| C | 0.431943 | 0.338476 | 0.291453 | 0.288551 | 1.75e-7 | 9.10e-8 |

B's lower Cd is reproducible and accompanies a different partition-dependent
trajectory. Its reported pressure/continuity residuals are finite and similar
in scale to A/C; these summaries do not establish a numerical failure. The
competition reference is approximately 0.28–0.29 at 150 steps, but the cited
rules do not impose a hard 0.29 or 0.28 cutoff; the project's broader local
gate is 0.27–0.30. Consequently B is **correctness review pending**, not
automatically disqualified, and not a performance winner on the basis of its
single fast block. Review the full Cd/residual trajectory against reference
examples with the team before using B as an accepted result.

## Rank mapping and partition topology

Each block's `rank-affinity.csv` contains 512 rank records, four actual hosts
with 128 ranks each, and eight distinct allowed CPU masks per host. Each
host/mask combination is shared by 16 ranks. The request had no explicit
per-core binding. These saved masks describe allowed CPU sets at capture time;
they do not prove identical execution conditions or later CPU placement.

The rank-to-host mapping verifies that consecutive rank groups of 128 occupy
one host in **these three blocks**. Using the original rank-pair face listings,
counting each pair once, gives:

Saved per-rank `partition-boundary.sha256` manifests are byte-identical across
the three blocks for each arm (manifest SHA-256 prefixes: A `3682dbf1`,
B `0226d1d5`, C `ee8b64e2`). This confirms the captured processor-boundary
files did not change between repeats of a given arm.

| Arm | Distinct cut faces | Distinct cross-node faces | Cross-node rank pairs | Max cells / mean cells | Max interface faces on one rank |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 2,927,022 | 337,324 | 450 | 1.010721 | 22,214 |
| B | 2,958,587 | 279,728 | 376 | 1.012507 | 21,142 |
| C | 3,033,594 | 271,614 | 377 | 1.010548 | 22,829 |

All three partitions are well balanced by cell count. C has **more total
processor-interface faces** than A, while its mapped cross-node faces are
**65,710 fewer**. This supports a topology-shift hypothesis, not a measured
network-byte or timing benefit. The partition and cross-node counts are the
same in all three blocks, while timing varies widely; topology alone cannot
explain block-3 slowdowns.

## Decision from existing evidence

1. Do not claim weighted Scotch is reproducibly faster than plain Scotch.
   Retain the originally submitted C observation (2.905191 s/step,
   Cd 0.288551) as a valid single-run record, with repeatability unresolved.
2. B remains a control that separates domain structure from weighting; its
   Cd needs scientific review, not a categorical pass/fail from an informal
   narrow band.
3. Before another A/C allocation, investigate available site records for
   block-3 node health, contention or fabric events and consider a run design
   that balances order within an allocation. The present logs alone do not
   establish root cause, so no new PBS job is justified yet.

## Evidence and exact remote commands

Remote roots, one per block:

`/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-abc-full-b{1,2,3}-v1-{25909583,25909584,25909585}/`

For each arm, inspected `evidence/logs/50_simpleFoam.log`,
`evidence/coefficient.dat`, `evidence/logs/10_decomposePar.log`; for each
block, inspected `evidence/nodes.txt` and `evidence/rank-affinity.csv`.
Prior completion/status, saved input hashes and PBS paths are in the linked
completion check.

All remote reads used the documented `aspire2a-comp` direct `sshpass -f` SSH
form in `workflow/00-General-SSH-Rules.md` with one password prompt, strict
known-host checking, bounded timeouts, no control socket, and `ssh -T`.
The local password-file checks used metadata only (owner, regular/non-symlink,
mode 600, nonempty; parent owner/mode 700); no credential contents were read.
Exact remote commands passed to that form, in order:

```text
hostname
bash -s  # read-only for-loop over the three retained roots: sed nodes/rank-affinity, grep/tail solver and decomposition logs
bash -s  # read-only grep/head of block-3 solver and coefficient files
bash -s  # read-only grep of coefficient header and decomposePar layout
sed -n "47,65p" .../scotch-abc-full-b1-v1-25909583/A_plain/evidence/logs/10_decomposePar.log
python3 -  # stdin-only parser: 9 saved logs, coefficient files, 3 rank maps and decomposePar rank-pair listings; prints derived summaries, no writes
python3 -  # stdin-only parser: 9 solver logs and 3 rank-affinity maps; prints jump/median/mask summaries, no writes
python3 -  # stdin-only parser: block-1 decomposePar logs; prints cell balance and max per-rank interface
bash -s  # read-only loop: sha256sum of each arm's retained coefficient.dat, cut to digest
bash -s  # read-only loop: sha256sum of each arm's retained partition-boundary.sha256 manifest, cut to digest
bash -s  # read-only for-loop: ls PBS stdout/stderr and grep diagnostic strings from retained stdout
```

There were no scheduler commands, no remote state changes, and no local
source/run-script changes. The only local edit for this audit is this report.
The SSH alias/user/host, project root and PBS system remain confirmed as in
`workflow/00-General-SSH-Rules.md`; no unknown adapter field was inferred.
