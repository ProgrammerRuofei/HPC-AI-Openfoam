# Manual Inspection Errors

## ASPIRE2A baseline v2 — MPI/process termination during renumberMesh

- **Status:** `OPEN`
- **Recorded:** 2026-08-30
- **Workflow:** `experiments/aspire2a-baseline/run_baseline_fixed_v2.pbs`
- **Attempt / PBS job:** `4n512_baseline_fixed_v2` / `15811806.pbs101`
- **Scope:** Four nodes, 512 MPI ranks, OpenFOAM v2512 baseline workflow repair; no optimisation setting was changed.

### Observed error

The pre-run environment validation passed, `restore0Dir -processor` completed,
and `renumberMesh` launched across four allocated nodes. The `renumberMesh`
stage log completed its OpenFOAM timing section but ended with:

```text
x1001c2s1b1n0.hostmgmt2001.cm.asp2a.nscc.sg: rank 100 died from signal 7
```

PBS historical status was `F` with `Exit_status = 143`, 68 seconds wall time,
and approximately 2:44:12 CPU time. `potentialFoam`, `applyBoundaryLayer`,
and `simpleFoam` did not start; no solver timing exists.

### Evidence

- PBS output: `/home/project/59000020/openfoam-isc26/results/of2512_4n512_baseline_fixed_v2.out`
- Stage log: `/home/users/industry/ai-hpc/apacsc20/scratch/openfoam-isc26/cases/occDrivAerStaticMesh-v2512/logFiles/20_renumberMesh.4n512_baseline_fixed_v2.log`
- Scheduler history: `qstat -xf 15811806.pbs101`

### Confirmed facts

- `WM_PROJECT_DIR` was set to the OpenFOAM v2512 installation.
- `RunFunctions` existed and was sourced before `set -u`.
- `restore0Dir` resolved as a shell function and completed successfully.
- `simpleFoam` resolved as an executable.
- The case directory and 512 processor directories existed.
- The candidate preserved the existing module, PBS allocation, MPI launcher,
  ranks, binding, decomposition, mesh, and solver commands.

### Unresolved questions

- Why rank 100 received signal 7 after the `renumberMesh` stage reported `End`.
- Whether the PBS exit 143 was a consequence of the rank failure, launcher
  behavior, scheduler action, or another platform condition.
- Whether the failure is reproducible under the unchanged baseline workflow.

### Required user decision

Authorize a bounded, read-only diagnosis of the MPI/PBS failure, or explicitly
authorize a narrowly scoped retry/fix. No retry or performance optimisation is
authorized by this record.

### Authorized read-only diagnosis — 2026-08-30

The user authorized bounded read-only diagnosis after this record was opened.
The following evidence was inspected without modifying remote state:

- `qstat -xf 15811806.pbs101` confirmed PBS `Exit_status = 143`, 68 seconds
  wall time, and the same four-node allocation.
- The complete `renumberMesh` log contains no `FOAM FATAL`, explicit MPI error,
  NaN, or floating-point exception. `trapFpe` is an informational OpenFOAM
  startup line. The final sequence is normal `ExecutionTime`, `ClockTime`,
  `End`, `Finalising parallel run`, then rank 100 signal 7.
- No extra job-ID diagnostic file was present in the accessible home/project
  paths. The PALS runtime directory referenced by the log had already been
  removed by the time of inspection.

**Diagnosis result:** the failure is confirmed to occur during or immediately
after PALS/MPI parallel-run finalisation, but the available evidence does not
establish whether its cause is a rank-local fault, launcher/runtime behavior,
or scheduler/platform termination. Status remains `OPEN`; no retry or patch
was performed.

### Authorized unchanged-configuration retry — 2026-08-30

The user explicitly authorized one bounded retry with all OpenFOAM, compiler,
MPI, node/rank, binding, decomposition, case, and command settings unchanged.
`run_baseline_fixed_v2_retry1.pbs` differed from v2 only in its PBS job name,
PBS output name, and `RUN_TAG`; local/remote syntax checks and upload checksum
verification passed.

- **PBS job:** `15812450.pbs101`
- **Final PBS state:** `F`, `Exit_status = 135`, 58 seconds wall time.
- **Failure marker:** after `renumberMesh` printed `End` and `Finalising
  parallel run`, `x1001c6s4b0n1.hostmgmt2001.cm.asp2a.nscc.sg: rank 185 died
  from signal 7`.
- **Not reached:** `potentialFoam`, `applyBoundaryLayer`, and `simpleFoam`.

This reproduces the same stage/finalisation failure seen in v2, so the failure
is **REPRODUCIBLE** at stage level. It varies from v2 rank 100/node
`x1001c2s1b1n0` to retry rank 185/node `x1001c6s4b0n1`; therefore its
rank/node manifestation is **NON-DETERMINISTIC / PLATFORM-RUNTIME SUSPECT**.
Status remains `OPEN`. No further retry or configuration change was made.

### Authorized MPI/PALS/PBS runtime diagnosis — 2026-08-30

Bounded read-only runtime inspection found:

- Both signal-7 nodes (`x1001c2s1b1n0` for v2 and `x1001c6s4b0n1` for
  retry-1) were queryable through PBS and reported `job-busy`, with normal
  advertised 128 CPU / approximately 440 GiB-memory allocations. Neither was
  marked offline or down at inspection time.
- `/scratch` had 3.2 PiB available (67% used) and `/data` had 1.5 PiB
  available (73% used); inode usage was 32% and 41%, respectively. No
  capacity exhaustion is evidenced. The site quota query was only partially
  permitted and cannot establish every quota type.
- No job-specific PALS/PBS diagnostic file was accessible after completion.
- **Important repeat-control limitation:** `renumberMesh -overwrite` changed
  the processor mesh during v2. The retry's `Before renumbering` band/profile
  already matched v2's `After renumbering` values. Therefore retry-1 repeated
  the same script, module, allocation, launcher, and commands, but it was not
  a strictly identical initial mesh-state repeat.

The repeated failure still establishes a recurring parallel-finalisation
problem in this workflow, but it cannot alone prove an invariant failure of an
identical initial case state. Platform support would need PBS/PALS server-side
records to determine the rank signal-7 cause.

## Gadi HPCToolkit timer preflight stalled before GCC/Scotch solver

- **Status:** `AUTHORIZED_FOR_DIAGNOSIS`
- **Recorded:** 2026-10-19
- **Workflow:** `builds/build-scripts/gadi-gcc162-ompi5010/profile_baseline_4n_scotch_v1.pbs`
- **Attempt / PBS job:** unscored 4N profile / `181520909.gadi-pbs`
- **Scope:** Gadi `normalsr`, four Sapphire Rapids nodes, 416 ranks; fixed
  GCC 16.2.0/Open MPI 5.0.10/OpenFOAM v2512/Scotch scientific case.

### Observed error and evidence

The source and archive hashes, private MPI linkage, Scotch decomposition,
four-host 104-rank mapping, `renumberMesh`, `potentialFoam`, and
`applyBoundaryLayer` all passed. The subsequent
`hpcrun -e REALTIME@f20 /bin/sleep 1` preflight left an empty log for over
15 minutes. `profile-events.txt` and `simpleFoam.log` were never created.
The user approved cancelling the non-progressing job. PBS reported `F`,
`Exit_status=271` (SIGTERM), 26:04 walltime, and 361.46 SU. Original evidence
is in `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-scotch/181520909.gadi-pbs/evidence/`; the
PBS resource summary is in the job's unique stdout under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/`.

### Suspected cause and unresolved questions

The installed HPCToolkit 2021.05.15 `hpcrun --help` says `@f` frequency
notation is for Linux perf events, whereas `CPUTIME` and `REALTIME` are
timer events with numeric periods. This makes `REALTIME@f20` a likely
configuration error. HPCToolkit also documents that REALTIME sampling can
disrupt programs that do not handle interrupted syscalls; the test target
was `/bin/sleep`. Neither mechanism has been isolated by the old job's empty
log, so the internal hang cause remains unconfirmed. A previous two-rank
`CPUTIME@f20` trial completed; that does not validate REALTIME or the full
solver profile.

### Authorized next diagnosis

The user approved one new low-cost, unscored diagnostic after reviewing its
proposed diff: one Gadi SPR node, four CPUs, six-minute PBS cap (0.8 SU at
2 SU/core-hour), with six independent HPCToolkit timer/program combinations,
each constrained by `timeout -k 2s 8s`. The script is
`builds/build-scripts/gadi-gcc162-ompi5010/diagnose_hpctoolkit_timers_1n_v1.pbs`.
It reproduces the same archived runtime environment, writes unique logs, and
does not run OpenFOAM or authorize another four-node profile. Update this
case after the diagnostic returns; preserve both jobs' original evidence.
