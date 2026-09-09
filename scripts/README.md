# Scripts — reusable harnesses

Harnesses that are not tied to a single compiler stack. Stack-specific build
and benchmark scripts live in [`../builds/build-scripts/`](../builds/build-scripts/);
official baseline scripts live in [`../official-gadi-spr/`](../official-gadi-spr/).

| Path | Purpose | Status |
| --- | --- | --- |
| `compiler-screening/benchmark_candidate_4n.pbs` | Generic 4-node candidate benchmark, parameterised via `qsub -v` | Untracked; **has known defects** — see below |
| `compiler-screening/smoke_candidate.pbs` | Generic small-case smoke test | Untracked; same defects |
| `compiler-screening/stage_candidate_runtime_node.sh` | Per-node runtime staging via `pbsdsh` | Untracked |

> **Known defects in the generic harness.** It uses `${PBS_NNODES:?}`, a Torque
> variable that Gadi's PBS Pro does not define (lesson L8), and it extracts the
> runtime archive one directory level too high. The C1 work therefore uses a
> dedicated, corrected harness in
> `../builds/build-scripts/c1-icc2021-openmpi417/`. Fix or retire these before
> reusing them for C2/C3.

`outputs/` holds raw probe evidence.

> **Do not move these files.** The PBS scripts invoke
> `scripts/compiler-screening/stage_candidate_runtime_node.sh` by
> repository-relative path.
