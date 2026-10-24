# Intel MPI 2021.19 two-node OFI diagnostic

| Job | Intended test | Observed first failure | Walltime | SU | OFI conclusion |
|---|---|---|---:|---:|---|
| `182194827.gadi-pbs` | Two `normalsr` SPR nodes, 208 allocated CPUs, one intended Intel MPI rank per node; ICX 2026.2 / Intel MPI 2021.19 private runtime | Both `mpirun -n 2 -ppn 1 hostname` processes ran on `gadi-cpu-spr-0685`; the allocated second node was `0686` | 00:00:51 | 5.89 | Inconclusive: script stopped before `MPI_Init` |

Both node-local runtime stages passed. The archived stack contains a
private libfabric 2.6 library, but `fi_info` was not available on PATH.
The scheduler/launcher placement assertion prevented the MPI transfer
probe from running. Original stdout and evidence paths are documented
in `progress/2026-10-25-gadi-impi202119-2n-ofi-probe.md`.
