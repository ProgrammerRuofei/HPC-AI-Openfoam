# Experiments — experiment-specific harnesses

One directory per experimental line. These are **experiment harnesses**, not
authoritative scored ones: nothing produced here may be quoted as an official
competition result.

| Directory | Platform | Contents |
| --- | --- | --- |
| [`gadi-4n-decomp/`](gadi-4n-decomp/) | **Gadi** `normalsr` Sapphire Rapids | Controlled 4-node / 416-rank **decomposition screening** A/B: hierarchical `(16 13 2)` versus `(26 8 2)` |
| [`aspire2a-baseline/`](aspire2a-baseline/) | ASPIRE2A (NSCC) | The 4-node / 512-rank baseline, its copied source evidence, and the workflow-repair candidates |
| [`aspire2a-diagnosis/`](aspire2a-diagnosis/) | ASPIRE2A (NSCC) | Controlled T1/T2/T4 tests isolating node count from rank count |
| `_template/` | — | Blank structure only — never submit its placeholder script |

## The three tiers, and why they are separate

- **`official-gadi-spr/`** — the *authoritative* official/scored harnesses. Only
  results produced there may be called `OFFICIAL`. See
  [`../official-gadi-spr/`](../official-gadi-spr/).
- **`experiments/gadi-4n-decomp/`** — Gadi decomposition screening. It
  deliberately mirrors the official chain and semantics so its two arms can be
  compared scientifically against each other, and its baseline arm can be
  sanity-checked against the official result. Its output is
  **`DECOMPOSITION SCREENING`**, never `OFFICIAL`.
- **`experiments/aspire2a-*`** — the ASPIRE2A line, a **different cluster**
  whose results must never be mixed with Gadi results. **Status: blocked** —
  single-node runs succeed, every multi-node run dies with `signal 7` after the
  solver has already finished. See lesson L9 in
  [`../results/hpc-lessons.md`](../results/hpc-lessons.md).

Other Gadi work lives elsewhere: controlled reproducibility repeats in
[`../phase0/`](../phase0/), compiler/MPI builds in
[`../builds/build-scripts/`](../builds/build-scripts/).

Every run is indexed in [`../results/experiment-index.md`](../results/experiment-index.md).
