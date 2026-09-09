# Build script variants

One directory per candidate stack. Each contains its README, PBS and shell
scripts, and an `outputs/` directory.

| ID | Stack | Status |
| --- | --- | --- |
| [`c1-icc2021-openmpi417/`](c1-icc2021-openmpi417/) | ICC Classic 2021.10.0 + OpenMPI 4.1.7 | Build `PASS`; runtime smoke `PASS`; 65M screening `VALID` (`178570241`, 2.66% slower than GCC) |
| [`c2-icx2025-openmpi417/`](c2-icx2025-openmpi417/) | ICX 2025.1.1 + OpenMPI 4.1.7 | `FAILED UNDER EARLIER BUILD PATH` — not retested after `bc45f06` |
| [`c3-icx2023-openmpi417/`](c3-icx2023-openmpi417/) | ICX 2023.2.0 + OpenMPI 4.1.7 | `FAILED UNDER EARLIER BUILD PATH` — not retested after `bc45f06` |
| [`s1-icc2021-impi2021/`](s1-icc2021-impi2021/) | ICC 2021.10 + Intel MPI 2021.10 | `FAILED` — deferred at OpenFOAM environment integration (lesson L2) |
| [`s2-icx2023-impi2021/`](s2-icx2023-impi2021/) | ICX 2023.2.0 + Intel MPI | `PENDING` — out of scope while S1 is blocked |
| [`s3-icx2025-impi2021/`](s3-icx2025-impi2021/) | ICX 2025.1.1 + Intel MPI | `PENDING` — out of scope while S1 is blocked |
| `a1-gcc112-craympich-private/` | GCC 11.2 + Cray MPICH, private source (ASPIRE2A) | `PENDING` — scripts untracked |
| `common/` | Shared build workflow used by the C-series | — |

`C` = OpenMPI candidates on Gadi. `S` = Intel MPI candidates on Gadi.
`A` = ASPIRE2A. The numeric suffix is the compiler/MPI version pair.

Full provenance per stack: [`../../results/experiment-index.md`](../../results/experiment-index.md).
