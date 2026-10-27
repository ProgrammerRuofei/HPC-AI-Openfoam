# Hierarchical `(16 8 4)` stock Opt comparison

ASPIRE2A PBS job `25906053.pbs101` completed on 2026-10-22. The job used the pinned OpenFOAM v2512 DrivAer case, AOCC 5.0 / Open MPI 5.0.10 stock Opt build, 4 nodes, 512 ranks, `ppr:128:node` without explicit binding, and 150 `simpleFoam` steps. The only computational setting changed from the `(32 16 1)` stock Opt control job `25826705.pbs101` was the hierarchical XYZ decomposition.

| Evidence | Value |
| --- | --- |
| PBS final state and exit | `F`, `Exit_status = 0` |
| Script exit | `script_exit_rc=0` |
| Solver step markers | 150, ending at `Time = 150` |
| Average wall-clock time per step | **3.291327721919464 s** |
| Fresh coefficient rows | 150, first = 1, last = 150 |
| Cd(150) | **0.27356125421800065** |
| `simpleFoam` SHA-256 | `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f` |

The coefficient file modification time was 2026-10-22 06:42:39 +08, during this job. This confirms fresh output, but the final Cd is below the approximate 0.28–0.29 reference used in earlier reviews; examine the entire Cd and residual trajectory before making a scientific-validity claim. The matched `(32 16 1)` run recorded 3.064002462691275 s/step and Cd(150) 0.29002205478189458, so `(16 8 4)` did not become the faster hierarchical candidate.

Remote evidence root: `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-v2512/cases/hier1684-opt-4n-v1-25906053/`. Its `evidence/logs/50_simpleFoam_A0.log`, `case/postProcessing/forceCoeffsAll/0/coefficient.dat`, `evidence/provenance.txt`, `evidence/simpleFoam.sha256`, and `evidence/exit-status.txt` are the primary artifacts. PBS stdout/stderr remain under `/home/project/59000020/openfoam-isc26/control-repo/experiments/aspire2a-hier1684-opt-4n/outputs/`.

No retry, patch, or further optimisation decision is implied by this record.
