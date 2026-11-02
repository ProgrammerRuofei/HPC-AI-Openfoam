# Optimisation Plans

## Current baseline

The current controlled Gadi reference configuration is OpenFOAM v2512,
GCC 8.5.0, Open MPI 4.1.7, four nodes / 192 MPI ranks, hierarchical
decomposition `(16 6 2)`, and 150 SIMPLE iterations.  The four valid
controlled measurements are ClockTime 802, 1045, 793, and 790 s.  The
representative performance is their median, **797.5 s**, rather than the
fastest single run.  R2 is correctness-valid and remains part of the dataset;
its sustained solver-time slowdown is unexplained by the captured evidence.

This Gadi baseline does not establish an ASPIRE2A baseline.

## Optimization directions

| Direction | Analysis ID/file | Analysis date | Scope | Status | Main finding | Suggested follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| GCC/Open MPI Phase 0 repeatability | `phase0/README.md` | 2026-09-03 | R1–R4 four-node control | Closed; no causal diagnosis | Three runs are tightly grouped; R2 is a valid sustained slowdown; all-run CV is about 14.6% because R2 is retained. | Freeze configuration; screen toolchain stacks one variable at a time. |
| Compiler/toolchain stack screening | This plan | 2026-09-03 | Not started | Await explicit execution approval | Repository evidence proves only GCC 8.5.0 + Open MPI 4.1.7 + OpenFOAM/2512 control. | Read-only module discovery, then build and screen candidates. |
| ICX/GCC Scotch PMPI | [gadi-icx-gcc-pmpi-2026-11-02](analysis/gadi-icx-gcc-pmpi-2026-11-02/README.md) | 2026-11-02 | 181908113 vs 182940799, 4 SPR nodes / 416 ranks / 150 steps | Diagnostic analysis complete | Same partition and per-rank call counts; ICX Waitall lower, Allreduce not improved. Runtime/placement gaps prevent compiler-only attribution. | Review CPU profile evidence; any new diagnostic requires separate approval. |

## Next direction

### Compiler/toolchain screening design — not authorised to execute

The unit under test is a complete stack: compiler implementation/version and
flags; OpenFOAM build configuration; MPI implementation/version and compiler
compatibility; linked runtime libraries; executable checksum; module list;
launcher; binding; decomposition; and case checksum.  No candidate compiler
or MPI stack is currently proven available from the repository.  The only
proven stack is the frozen GCC 8.5.0 / Open MPI 4.1.7 / OpenFOAM v2512 control.

Before choosing candidates, run these **read-only** Gadi commands under a
separately authorised discovery scope:

```bash
module -t avail gcc 2>&1
module -t avail openmpi 2>&1
module -t avail OpenFOAM 2>&1
module show OpenFOAM/2512
module show gcc/<candidate-version>
module show openmpi/<candidate-version>
module purge; module load gcc/<candidate-version> openmpi/<candidate-version>
command -v gcc g++ mpirun; gcc --version; g++ --version; mpirun --version
```

For any proposed OpenFOAM executable, additionally record `ldd <simpleFoam>`
and `sha256sum <simpleFoam>` before running it.  A module name from an
unrelated legacy Neko note is not candidate-availability evidence.

**Stage 1 — fast screening.** Build/verify one immutable executable per
available stack, then run one full 4-node, 192-rank, endTime-150 case per
candidate.  Derive every PBS script from the frozen R4 control; change only
the stack-specific module/build/executable identity fields.  Suggested stable
names are `toolchain-<compiler>-<version>-<mpi>-<version>-v1`, run tag
`tc-<stack>-screen-4n-192r-v1`, and separate `submit-logs`, `evidence`, and
fresh case roots.  Use a comparison table containing all provenance fields,
correctness markers, ClockTime, ExecutionTime, timestep statistics, PBS
walltime/memory, and raw paths.

No fixed percentage threshold is justified by only four repeats.  A single
candidate becomes worth repeating only if its ClockTime is below the best
observed normal-looking control (790 s), rather than merely below the all-run
median, because the all-valid median includes R2's documented anomaly.  This
is a gate for Stage 2, not an acceptance claim.

**Stage 2 — finalists.** Repeat only the strongest valid candidate stack(s)
enough times to compare medians and distributions against the frozen control.
Do not accept an improvement based on one best run; retain every run, preserve
the workload checksum, and reject invalid or clearly slower stacks.  Do not
change compiler flags, MPI, binding, decomposition, and numerical settings in
the same experiment.

### Profiling roadmap — after a repeated winning toolchain only

Profiling is not authorised until a winning stack has been selected and
repeated as a new compiler-optimised baseline.  Ask questions in this order:

1. computation versus MPI communication/waiting;
2. rank/load imbalance;
3. dominant CPU hotspots;
4. memory/NUMA limitation;
5. material I/O time.

Use the lightest available tool that answers the next unanswered question.
Availability of mpiP, Arm MAP, HPCToolkit, and Intel VTune/Advisor is not
established; discover candidates read-only before proposing use.  Potential
evidence-to-action mapping is: MPI/wait → binding, placement, MPI runtime, or
decomposition; imbalance → decomposition; CPU hotspots → compiler code
generation; memory/NUMA → affinity/locality; I/O → I/O investigation.  Each
subsequent experiment changes one primary variable and compares repeated
measurements against the frozen compiler-optimised baseline.
