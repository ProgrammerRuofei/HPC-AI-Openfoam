# Gadi Phase 0 baseline repeat — successful independent reproduction

## Project status

- **GADI CLUSTER ADAPTER: READY FOR DOCUMENTED PHASE 0 REPEATABILITY RUNS**
- **PHASE 0 INITIAL REPEAT: PASS** — PBS job `178063948.gadi-pbs`, 2026-09-03.

## Fresh work area used by Phase 0

```
/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902
```

The historical source remains read-only for this workflow:

```
/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh
```

Before the approved submission, only the empty `submit-logs` directory was
created. PBS opens its `-o` file before the script begins; the fresh case and
evidence directory were then created by the job on allocated compute nodes.

```
/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/submit-logs
```

The candidate PBS job refuses to run if the fresh `case` directory already
exists. It preserved the historical source case as read-only.

## Fresh-copy protocol

The candidate copies exactly `0.orig`, `constant`, `system`, and `Allrun.gadi`
from the source case. The historical `Allrun.gadi` resets `0` from `0.orig`,
uses `controlDict.noWrite`, preserves `fvSolution.fixedIter`, then performs a
fresh `decomposePar` into its own work area before the unchanged solver launch.
It deliberately does **not** copy source `0`, numerical time directories,
`logFiles`, `postProcessing`, `dynamicCode`, or `processor*` directories.
`constant/polyMesh` is retained as part of `constant`, so the source mesh is
preserved.

Before submission, confirm that `0` is the historical baseline's intended
initial condition and that the historical `drivaer_4n.pbs` has no additional
required case files outside these three directories.  Do not submit until
the provenance fields and the comparison against that script are filled in.

## Invariants requested for Phase 0

- Gadi / NCI, project `pm78`
- OpenFOAM.com `v2512`
- 4 nodes, 48 MPI ranks per node, 192 ranks total
- `hierarchical`, `n (16 6 2)`
- SIMPLE target: 150 iterations (must be verified in copied `controlDict`)
- unchanged launcher: `mpirun -np "$PBS_NCPUS" simpleFoam -parallel`
- no explicit CPU binding or MPI performance options

## Phase 0 provenance

- GCC and G++: `8.5.0 20210514 (Red Hat 8.5.0-28)`
- `WM_COMPILER=Gcc`
- `WM_OPTIONS=linux64GccDPInt32Opt`
- `WM_MPLIB=SYSTEMOPENMPI`
- MPI: `Open MPI 4.1.7`
- OpenFOAM build: module `OpenFOAM/2512`, `WM_PROJECT_VERSION=v2512`,
  `WM_PROJECT_DIR=/apps/OpenFOAM/2512`
- **Compute-node CPU:** Intel(R) Xeon(R) Platinum **8274** CPU @ 3.20GHz;
  2 sockets × 24 physical cores = 48 physical cores/node; SMT = 2. This
  compute-node observation supersedes the earlier login-node 8268 observation.

The historical PBS script SHA-256 is
`c92003460300d5aa5f0ca6ccf7f68052c47454650bf87fcb40a6ef5b22172756`.
The candidate is deliberately built from that script's PBS request and
`Allrun.gadi` protocol; its local snapshot is
[historical_drivaer_4n.pbs](historical_drivaer_4n.pbs).

## Validation completed before `qsub`

1. Read the source `drivaer_4n.pbs` and exact source dictionary locations.
2. Record `gcc --version`, `g++ --version`, `WM_COMPILER`, `WM_OPTIONS`,
   `WM_MPLIB`, `mpirun --version`, the OpenFOAM build/version, and the CPU
   topology under the loaded OpenFOAM/2512 environment.
3. Confirm source metadata/checksums are unchanged before versus after the
   candidate preparation (the candidate itself does no remote write).
4. Confirm the copied `decomposeParDict` has `method hierarchical` and
   `numberOfSubdomains 192` with `n (16 6 2)`; confirm the workload has a
   150-iteration target.
5. Run `bash -n` on the final script and review `diff -u` against the
   historical script.

The executed candidate is [phase0_baseline_repeat_4n.pbs](phase0_baseline_repeat_4n.pbs),
from Git commit `21c4c48` in the Gadi control clone
`/scratch/pm78/kj7183/openfoam_cpu/control-repo`.

## Phase 0 consolidation

### 1. Objective

Validate that an independent fresh-case workflow can reproduce the documented
four-node Gadi baseline configuration. Phase 0 is a reproducibility validation,
not an optimisation experiment.

### 2. Controlled configuration

- OpenFOAM.com v2512; GCC 8.5.0; Open MPI 4.1.7.
- Four nodes, 48 MPI ranks/node, 192 ranks total, and one OpenMP thread/rank.
- 150 SIMPLE iterations; hierarchical decomposition `n (16 6 2)`.
- Historical `Allrun.gadi` pipeline and `mpirun -np "$PBS_NCPUS" simpleFoam -parallel`.
- No newly introduced binding, MPI tuning, decomposition, solver, or numerical change.

### 3. Hardware and software provenance

The job ran on `gadi-cpu-clx-1096`, `gadi-cpu-clx-1105`,
`gadi-cpu-clx-1106`, and `gadi-cpu-clx-1115`. Each reported Xeon Platinum
8274 @ 3.20 GHz, two sockets, 24 physical cores/socket, and SMT = 2. The
loaded module environment was `openmpi/4.1.7` and `OpenFOAM/2512`.

### 4. Fresh-case isolation

The job copied only `0.orig`, `constant`, `system`, and `Allrun.gadi` from the
immutable historical source. It excluded prior `0`, time directories,
`logFiles`, `postProcessing`, `dynamicCode`, and all `processor*` directories.
It recorded checksums for the copied launcher and dictionaries.

### 5. Validation checks

The preflight confirmed four allocated nodes, 192 ranks, OpenFOAM v2512,
GCC/Open MPI versions, `nCores 192`, `nHierarchical (16 6 2)`, `endTime 150`,
fixed-iteration `fvSolution`, the mesh, and the executable launcher. The
solver reached `Time = 150`, followed by `End` and `Finalising parallel run`;
PBS reported `Exit_status = 0`.

### 6. Result

| Metric | Phase 0 measurement |
| --- | ---: |
| Solver ClockTime | 802 s |
| Solver ExecutionTime | 781.85 s |
| Mean measured timestep wall time | 5.1367 s/step |
| Measured timesteps | 149 |
| PBS walltime | 17m54s |
| Peak memory | 230.13 GB |

### 7. Historical comparison

The documented historical four-node reference is ClockTime 787 s,
ExecutionTime 776.52 s, and mean measured timestep time 5.174129850805368
s/step. Phase 0 ClockTime is 15 s (about 1.9%) higher, while its mean measured
timestep time is slightly lower.

### 8. Interpretation

Phase 0 is a **PASS**: the isolated workflow reproduced the required
configuration and completed the fixed workload. The single 802 s result is a
measurement, not evidence of a regression or an optimisation conclusion.

### 9. Limitations

One repeat cannot estimate run-to-run variance or establish a controlled
baseline median. The official scientific acceptance criteria remain to be
recorded separately; this validation confirms the fixed-step workflow and its
normal completion markers.

### 10. Next step — repeatability

Prepare two further independent fresh-case repeats before any profiling or
optimisation comparison. Retain every individual measurement and use their
controlled-run median, not the fastest run, as the future comparison baseline.

## Evidence

- PBS output: `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/submit-logs/drivaer_p0r_4n.pbs.out`
- Solver log: `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/case/logFiles/50_simpleFoam.178063948.gadi-pbs.log`
- Provenance and copied checksums: `/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/evidence/phase0-baseline-repeat-20260902-4n-192r.178063948.gadi-pbs/`
