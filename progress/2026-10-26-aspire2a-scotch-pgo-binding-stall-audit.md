# ASPIRE2A weighted Scotch PGO × binding timing audit (2026-10-26)

Read-only follow-up on PBS jobs `25970245.pbs101` and `25970246.pbs101`.
No job was submitted, changed or cancelled; no remote file was modified.
Each block ran the same weighted Scotch partition (`domains (4 8 16)`,
`domainWeights (1 1 0.01)`) with 4 nodes, 512 ranks, 150 SIMPLE steps and
AOCC 5.0/Open MPI 5.0.10. `O` denotes stock Opt, `P` the existing PgoUse
build; `default` and `core` denote the two launcher binding policies. Block 1
ran O_default → O_core → P_core → P_default; block 2 reversed that order.

## Verified outcomes

Both PBS jobs finished with exit status 0; both runner exit-status files say
`script_exit_rc=0`. All eight solver logs have exactly 150 `Time =` entries,
normal arm completion, and a fresh coefficient file with Cd(150) = 0.288551.
Each arm's affinity file contains 512 ranks, 128 on each of four hosts.

| Block | Arm | Official mean, s/step | Median recorded step, s | Steps ≥10 s | Largest single step, s | ClockTime increase across steps 2–150, s | ExecutionTime increase, s |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | O_default | 10.298689 | 2.905 | 17 | 550.840 (step 64) | 1534 | 430.43 |
| 1 | O_core | 7.025161 | 2.900 | 15 | 164.535 (step 143) | 1047 | 428.94 |
| 1 | P_default | 4.294532 | 2.901 | 10 | 57.794 (step 35) | 640 | 429.36 |
| 1 | P_core | 5.960658 | 2.897 | 14 | 61.818 (step 22) | 888 | 434.26 |
| 2 | O_default | 4.090865 | 2.910 | 6 | 55.337 (step 6) | 609 | 430.59 |
| 2 | O_core | 4.277891 | 2.900 | 8 | 37.526 (step 78) | 637 | 433.06 |
| 2 | P_default | 7.991659 | 2.905 | 17 | 115.367 (step 84) | 1191 | 438.63 |
| 2 | P_core | 6.482215 | 2.897 | 12 | 96.799 (step 98) | 965 | 428.39 |

The solver records 149 per-step wall times (steps 2–150); its official mean
is retained above. The per-step median is a **diagnostic only**, not a
replacement score. The eight medians cluster at 2.897–2.910 s, whereas the
official means range from 4.091 to 10.299 s. In block 1 O_default, the 17
steps at or above 10 s contribute about 1,092 s above its 2.905 s median;
that accounts for nearly all of its roughly 1,101 s excess over a 149-step
median-rate run. Its step 64 records 550.840 s of wall time while the
`ExecutionTime` counter advances about 2.9 s. Block 2 P_default likewise has
17 long steps, including consecutive step 82–84 ClockTime jumps of about
96, 105 and 116 s. The sampled solver iterations at those steps remain normal
(`Ux/Uy/Uz` 15, `p` 12). These intermittent elapsed-time stalls explain the
large variation in the scored means; the logs do not identify their physical
cause.

The actual node sets differ between blocks:

- Block 1: `x1001c5s6b1n0`, `x1001c5s6b1n1`, `x1001c5s7b0n0`,
  `x1001c5s7b1n1`.
- Block 2: `x1002c1s3b1n0`, `x1002c1s3b1n1`, `x1002c1s4b0n0`,
  `x1002c1s4b0n1`.

In both blocks, default placement has eight distinct captured allowed CPU
masks per host; each mask is shared by 16 ranks. The core-binding arm has 128
distinct captured masks per host. Thus the affinity intervention took effect
as recorded, but the masks alone do not explain the sporadic stalls. The two
PBS stderr files are empty and both stdout files end in
`SCOTCH_PGO_BINDING_PASS`. No explicit timeout, fabric error or OOM message
was found. Compute-node SSH host-key warnings in stdout are connection setup
messages, not proof of a fabric performance fault. The PBS historical records
were no longer returned by `qstat -x` at this audit; retained job-keyed logs
and scratch files supplied the result evidence.

## Interpretation and next decision

Do not claim a PGO or core-binding speedup from these two blocks. The paired
differences reverse direction between blocks, while per-step medians are
almost identical. Filtering out slow steps may help diagnose the anomaly,
but must not replace the official full 150-step average in a performance
claim. The same type of sporadic wall-clock jumps was observed in the earlier
Scotch A/B/C study, so blind repetition is unlikely to settle the much smaller
plain-vs-weighted Scotch question.

The next useful action is a site-health inquiry using these job IDs, node
sets and the 2026-10-25 06:49–10:01 SGT run window, asking whether those
nodes or the fabric had recorded events/contention. If no site explanation is
available, design any later repeat with contemporaneous controls, balanced
run order and a predeclared way to flag stalled runs; retain every full
official score and correctness result. New PBS work requires separate review
and authorization.

## Evidence and read-only commands

Scratch roots:

- `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-pgo-binding-b1-v1-25970245/`
- `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/scotch-pgo-binding-b2-v1-25970246/`

Per arm: `evidence/logs/50_simpleFoam.log`, `evidence/coefficient.dat`,
`evidence/avg-step.txt`, `evidence/cd150.txt`, `evidence/rank-affinity.csv`.
Per block: `evidence/nodes.txt`, `evidence/run.log`,
`evidence/exit-status.txt`. PBS stdout/stderr are under
`/home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-scotch-pgo-binding/outputs/`.

Used the documented direct `aspire2a-comp` SSH form with a metadata-checked
local password file and strict existing host-key checking. Remote commands
were read-only: `qstat -x -f` for both IDs; `grep`, `head`, `tail`, `stat`,
`cat` of retained logs and node/affinity records; and inline `python3 -c`
parsers that iterated the eight saved solver logs and affinity CSV files,
printing step deltas, upper-tail statistics and per-host rank/mask counts.
No parser wrote a file. Current project adapter `TBD` fields are unchanged.
