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

## Cray PALS one-node probe v1 — compute-node libfabric unresolved

- **Status:** `USER_ACTION_REQUIRED`
- **Recorded:** 2026-09-17
- **Workflow:** `scripts/probe_cray_pals_1n_v1.pbs`
- **Attempt / PBS job:** `probe_cray_pals_1n_v1` / `22693051.pbs101`
- **Scope:** One node, two planned PALS ranks, Cray MPICH 8.1.15 `ofi/gnu/9.1` library-resolution and launcher availability probe; no OpenFOAM run.

### Observed error and evidence

PBS history reports state `F`, `Exit_status = 2`, two seconds wall time, and
compute node `x1002c0s5b1n0`. The stdout file
`/home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v1.o`
shows `libfabric.so.1 => not found` in `ldd` of the selected
`libmpi.so`; the stderr file with suffix `.e` says `Unresolved Cray MPICH
dependency`. The script exited at its preflight guard before `mpiexec` or
`hostname` ran. No evidence about PALS startup or MPI initialization was
obtained.

Read-only `module show libfabric/1.22.0` identifies
`/opt/cray/libfabric/1.22.0/lib64` as a path it prepends to
`LD_LIBRARY_PATH`. The v1 script loaded `cray-pals/1.1.6` but not
`libfabric/1.22.0`; `module show cray-pals/1.1.6` adds only PALS paths. This
supports a missing runtime-library-path diagnosis for the preflight failure.
It does not establish that loading libfabric will make PALS or MPI work.

### Proposed fix and required decision

For a new attempt, add `module load libfabric/1.22.0` before the `ldd` check,
retain the same Cray MPICH variant, and use new PBS output names. Review a
local diff and obtain explicit approval for the module change, resource/job
submission, commit and synchronization before retrying. Preserve v1 output.
No patch or retry has been made.

### Authorized v2 attempt — 2026-09-17

The user approved exactly one v2 retry after reviewing the complete local
v1-to-v2 diff. The v2 script adds `libfabric/1.22.0`, records modules, runtime
paths and available version information, and requires all `libmpi.so`
dependencies plus a readable resolved `libfabric.so.1` before launching two
`hostname` ranks. PBS resources match v1. Local commit
`877695ada738819b8540d99140a068e6604688ae` contains only the new script;
remote commit and script SHA256 were verified. PBS job `22803616.pbs101` was
submitted once and is queued in `qdev` at the first check. **Outcome pending.**
No build, OpenFOAM run, four-node experiment, cancellation, or additional
retry was performed.

### v2 outcome — preflight failed; stop

PBS history for `22803616.pbs101` reports state `F`, `Exit_status = 2`, two
seconds wall time, and compute node `x1002c5s7b0n1`. The v2 stderr contains
`libfabric(4):ERROR:105: Unable to locate a modulefile for
'libfabric/1.22.0'`, followed by `Unresolved Cray MPICH dependency`.
`module list` in stdout contains only `aocc/5.0`, `gcc/11.2.0`, and
`cray-pals/1.1.6`; `LD_LIBRARY_PATH` lacks the Cray libfabric directory, and
`ldd` still reports `libfabric.so.1 => not found`. The preflight guard exited
before either `mpiexec --version` or `mpiexec hostname`. The login-node
modulefile observed earlier was not resolvable in this compute-node job;
whether the library itself is mounted and usable there remains unknown.

Raw evidence is preserved at
`/home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v2.{o,e}`.
No further module combination, patch, build, or PBS retry was attempted.
Status remains `USER_ACTION_REQUIRED`; a new approach requires a separate
decision and authorization. The one approved retry has been consumed.

### Authorized v3 attempt — compute-node library absent; stop

After the user reviewed and confirmed the complete v2-to-v3 local diff, the
v3 script was committed as `7d226e4bd7a26fecb4eb98038f5e2e15905d2e94`,
synced to the approved control checkout, and submitted once as PBS job
`22815643.pbs101`. Its SHA256 matched locally and remotely:
`92261d86bffd8e56d391d87544e47d60063286cab45e6275c6a692fd9ca20a77`.
The v1/v2 output files were present before submission; the v3 output names
were unused.

PBS history reports `F`, `Exit_status = 2`, three seconds wall time, and compute
node `x1001c7s7b0n1`. The v3 stdout records:

```text
--- compute-node libfabric.so.1 ---
ls: cannot access '/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1': No such file or directory
```

Stderr says `Cray libfabric library missing or unreadable` at that path. The
preflight exited before prepending `LD_LIBRARY_PATH`, inspecting `libmpi.so`
with `ldd`, querying versions, or launching `mpiexec hostname`. The
login-node `/opt/cray/libfabric/1.22.0/lib64` path is therefore not available
as a readable library path on this allocated compute node. This does not
establish what libfabric versions, if any, are available elsewhere on compute
nodes. PALS launch and MPI initialization remain untested.

Raw output is preserved at
`/home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v3.{o,e}`.
Status remains `USER_ACTION_REQUIRED`. No further probe, alternate path,
module combination, build, OpenFOAM run, or four-node job is authorized by
this result.
