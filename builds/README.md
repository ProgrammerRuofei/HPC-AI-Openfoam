# Builds — compiler and MPI toolchain stacks

How each candidate software stack is **produced**. No performance claim lives
here: a build that succeeds proves only that a binary exists.

| Path | Contents |
| --- | --- |
| [`build-scripts/`](build-scripts/) | One directory per candidate stack (C1/C2/C3, S1/S2/S3, A1) plus the shared `common/` build workflow |
| `source/` | Placeholder for source trees |
| `extra-packages/` | Placeholder for approved extra packages |

The current candidate is **C1 = ICC Classic 2021.10.0 + OpenMPI 4.1.7 +
OpenFOAM v2512**, in
[`build-scripts/c1-icc2021-openmpi417/`](build-scripts/c1-icc2021-openmpi417/).
It has passed build, archive, and runtime-smoke validation; its 65M benchmark
is still `PENDING`.

Build outcomes for every stack are indexed in
[`../results/experiment-index.md`](../results/experiment-index.md); the build
failures and what they taught are in
[`../results/hpc-lessons.md`](../results/hpc-lessons.md) (L5, L6, L7).

> **Do not move files in this directory.** Each `build_<id>.pbs` runs
> `exec bash builds/build-scripts/<id>/build_<id>.sh` by repository-relative
> path, and each `build_<id>.sh` reaches `../common/` relative to its own
> location.
