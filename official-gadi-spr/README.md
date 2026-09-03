# Official Gadi Sapphire Rapids workflow

This directory contains the official 2026 APAC OpenFOAM workflow for Gadi
`normalsr` (Intel Xeon Platinum 8470Q Sapphire Rapids) using the site
OpenFOAM v2512 module.  It is intentionally separate from the earlier
Cascade Lake workflow-validation runs.

`official_baseline_4n.pbs` is the first controlled official baseline.  It
uses four 104-physical-core nodes, one MPI rank per physical core (416 ranks
total), and hierarchical decomposition `(16 13 2)`.  This is a simple
hardware-topology-aligned baseline, not an optimisation claim.  The script
uses the full official preparation chain and only changes the permitted
decomposition entries in the fresh case copy.

Gadi accepts aggregate resource directives, so the four-node request is
`ncpus=416` and `mem=760GB`: the latter is the exact aggregate of the
reviewed 190 GiB per-node allocation.  The job verifies four allocated nodes
at runtime and its PBS metadata is checked before the result is accepted.

The primary result is `Average wall-clock time per time step` emitted by
`simpleFoam`; `ClockTime` and other timings are secondary evidence.  Run
records belong in `results/official-gadi-spr/run-registry.md`.

## Scaling points

`official_baseline_1n.pbs`, `official_baseline_2n.pbs` and
`official_baseline_4n.pbs` cover the three mandated points. All three use the
identical six-step preparation chain and change only what the rules require per
point: the node count, the iteration count (40/80/150) and the decomposition.

`416 = 2^5 x 13`, `208 = 2^4 x 13` and `104 = 2^3 x 13`, so 13 is a **forced**
factor of any hierarchical decomposition at every point. The three scripts
therefore hold `y = 13` and `z = 2` fixed and scale only the streamwise
dimension, which keeps node count the single moving variable across the series:

| Nodes | Ranks | Ranks/node | Decomposition | Iterations | Walltime |
| ---: | ---: | ---: | --- | ---: | --- |
| 1 | 104 | 104 | `(4 13 2)` | 40 | 01:30:00 |
| 2 | 208 | 104 | `(8 13 2)` | 80 | 01:15:00 |
| 4 | 416 | 104 | `(16 13 2)` | 150 | 01:15:00 |

Requested walltime is a budget variable, not free headroom: PBS reserves against
the *requested* time while billing uses *actual* elapsed time, so an oversized
request can make a job unschedulable without saving anything.

## Gates and extraction

- `validate_official_baselines.sh` - static compliance gate for all three scripts.
  Run it before every `qsub`. It is negative-tested: it rejects a changed `-ybl`,
  a missing chain step, a wrong queue, an explicit `select=`, a dropped
  `fvSolution` check, a wrong iteration count, a decomposition whose product does
  not equal the rank count, a removed Cd-evidence trap, and lost fresh-case
  isolation.
- `extract_official_metrics.sh <evidence-dir> <endTime>` - pulls the primary
  metric, verifies the chain and completion, reports secondary timings, and
  checks Cd against the official per-point range (~0.43 / ~0.34 / 0.28-0.29).

Each `#PBS -o` path must exist before submission:

```
mkdir -p /scratch/pm78/kj7183/openfoam_cpu/official-gadi-spr/baseline-{1n,2n,4n}/submit-logs
```
