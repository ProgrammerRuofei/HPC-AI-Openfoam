# Experiments — ASPIRE2A (NSCC Singapore)

This directory holds the **ASPIRE2A** line of work. It is a different cluster
from Gadi and its results must never be mixed with Gadi results.

**Status: blocked.** Single-node runs succeed; every multi-node run dies with
`signal 7` after the solver has already finished. See lesson L9 in
[`../results/hpc-lessons.md`](../results/hpc-lessons.md).

| Directory | Contents |
| --- | --- |
| [`aspire2a-baseline/`](aspire2a-baseline/) | The 4-node / 512-rank baseline, its copied source evidence, and the workflow-repair candidates |
| [`aspire2a-diagnosis/`](aspire2a-diagnosis/) | Controlled T1/T2/T4 tests isolating node count from rank count |
| `_template/` | Blank structure only — never submit its placeholder script |

Gadi work does **not** live here: official runs are in
[`../official-gadi-spr/`](../official-gadi-spr/), controlled repeats in
[`../phase0/`](../phase0/), and compiler builds in
[`../builds/build-scripts/`](../builds/build-scripts/).

Every run is indexed in [`../results/experiment-index.md`](../results/experiment-index.md).
