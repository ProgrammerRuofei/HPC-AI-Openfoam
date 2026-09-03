# Official Gadi Sapphire Rapids run registry

| Run ID | Date | Commit | PBS Job | Queue | Nodes | CPU | Ranks | Ranks/node | Decomposition | Compiler / MPI | Official avg wall-clock/step | ClockTime | Cd | Exit | Validity | Notes |
| --- | --- | --- | --- | --- | ---: | --- | ---: | ---: | --- | --- | ---: | ---: | ---: | ---: | --- | --- |
| hardware-probe | 2026-09-03 | `8d9d2e1` | `178141693.gadi-pbs` | normalsr | 1 | Xeon Platinum 8470Q SPR | 0 | 0 | — | GCC / OpenMPI 4.1.7 | — | — | — | 0 | valid probe | 2×52 physical cores, 8 NUMA, 503 GiB; site OpenFOAM v2512. |
| baseline-4n-attempt-1 | 2026-09-03 | `85277f1` | `178142339.gadi-pbs` | normalsr | 4 | Xeon Platinum 8470Q SPR | 416 | 104 | hierarchical (16 13 2) | GCC / OpenMPI 4.1.7 | — | — | — | — | **never ran** | PBS refused the reservation: `Could not reserve allocation from project`. 2 h request needed 1664 SU against 332.89 SU available; concurrent compiler-screening builds held 1.92 KSU reserved. Cancelled and resubmitted with a 1:15 walltime. |
