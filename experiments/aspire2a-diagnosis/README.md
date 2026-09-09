# ASPIRE2A multi-node diagnosis runs

Controlled tests isolating the ASPIRE2A (NSCC Singapore) multi-node failure.
**Status: `FAILED` / blocked.** These are not optimisation experiments and
produce no performance result.

## The failure

Every multi-node run dies with `signal 7` (SIGBUS) **after** OpenFOAM has
printed `End` and `Finalising parallel run`. The solver completes; the process
group dies during teardown. No OpenFOAM fatal error, NaN, or explicit MPI error
appears in any log.

## What the tests establish

| Test | Allocation | Setup script | Run script | Outcome |
| --- | --- | --- | --- | --- |
| T1 | 1 node × 128 ranks | `setup_t0_t1_128*.pbs` | `run_t1_128*.pbs` | `PASS` |
| T4 | 2 nodes × 64 ranks | `setup_t4_128_2n_v1.pbs` | `run_t4_128_2n_v1.pbs` | `signal 7` after `End` |
| T2 | 2 nodes × 128 ranks | `setup_t2_256_v1.pbs` | `run_t2_256_v1.pbs` | `signal 7` after `End` |

T1 and T4 use the **same total rank count** (128) and differ only in node
count. T1 passes and T4 fails, so the failing variable is **node count, not
rank count**. The failing rank and node vary between runs.

Classification: `MULTI-NODE / INTER-NODE PALS-MPI RUNTIME SUSPECT`.

## Related material

- Four-node baseline and its repair attempts: [`../aspire2a-baseline/`](../aspire2a-baseline/)
- Open error record: [`../../MANUAL_INSPECTION_ERROR.md`](../../MANUAL_INSPECTION_ERROR.md)
- Support request draft with full evidence paths: [`../../planning/aspire2a-nscc-support-draft.md`](../../planning/aspire2a-nscc-support-draft.md)
- Lesson L9: [`../../results/hpc-lessons.md`](../../results/hpc-lessons.md)
- Planned isolation build (A1, private source): `builds/build-scripts/a1-gcc112-craympich-private/`

## Current blocker

The documented persistent SSH master accepts the control check, but no command
channel returns — including `exit 0`. No new ASPIRE2A job can be submitted
until that is restored.
