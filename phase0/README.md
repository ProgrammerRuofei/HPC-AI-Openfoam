# Gadi Phase 0 baseline repeat — preparation candidate

## Project status

- **GADI CLUSTER ADAPTER: READY**
- **GADI PHASE 0 BASELINE REPEAT: PREPARATION REQUIRED**

## Intended fresh work area (not created yet)

```
/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902
```

The historical source remains read-only for this workflow:

```
/scratch/pm78/kj7183/openfoam_cpu/case/occDrivAerStaticMesh
```

Before `qsub`, create only the empty `submit-logs` directory below; PBS opens
its `-o` file before the script begins.  This does not create a case or alter
historical evidence:

```
/scratch/pm78/kj7183/openfoam_cpu/phase0-baseline-repeat-20260902/submit-logs
```

The candidate PBS job refuses to run if the fresh `case` directory already
exists.  It makes the case and its evidence directory on a compute node only
after `qsub` is explicitly authorized.

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

## Phase 0A provenance captured (read-only on 2026-09-02)

- GCC and G++: `8.5.0 20210514 (Red Hat 8.5.0-28)`
- `WM_COMPILER=Gcc`
- `WM_OPTIONS=linux64GccDPInt32Opt`
- `WM_MPLIB=SYSTEMOPENMPI`
- MPI: `Open MPI 4.1.7`
- OpenFOAM build: module `OpenFOAM/2512`, `WM_PROJECT_VERSION=v2512`,
  `WM_PROJECT_DIR=/apps/OpenFOAM/2512`
- CPU: Intel(R) Xeon(R) Platinum 8268 CPU @ 2.90GHz; 2 sockets × 24 cores,
  one hardware thread per core = 48 physical cores/node.

The historical PBS script SHA-256 is
`c92003460300d5aa5f0ca6ccf7f68052c47454650bf87fcb40a6ef5b22172756`.
The candidate is deliberately built from that script's PBS request and
`Allrun.gadi` protocol; its local snapshot is
[historical_drivaer_4n.pbs](historical_drivaer_4n.pbs).

## Required read-only validation before `qsub`

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

The local candidate is [phase0_baseline_repeat_4n.pbs](phase0_baseline_repeat_4n.pbs).
