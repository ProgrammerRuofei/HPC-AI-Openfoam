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

- **Status:** `USER_ACTION_REQUIRED` — low-cost cause isolation complete;
  any further OpenFOAM profile requires new review and approval.
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

### One-node timer diagnosis outcome — 2026-10-19

The single approved PBS job `181521525.gadi-pbs` ended `F`,
`Exit_status=0`, 1:00 walltime, **0.13 SU** on SPR node `0562`. The script
verified the same GCC, MPI and OpenFOAM archive SHA256 values and private
MPI linkage, then completed all six bounded tests:

| Target | Timer specification | Exit | Elapsed |
| --- | --- | ---: | ---: |
| `sleep 1` | `CPUTIME@f20` | 0 | 2 s |
| `sleep 1` | `CPUTIME@50000` | 0 | 1 s |
| `sleep 1` | `REALTIME@f20` | 124 (timeout) | 8 s |
| `sleep 1` | `REALTIME@50000` | 124 (timeout) | 8 s |
| bounded CPU-active `seq` | `REALTIME@f20` | 0 | 1 s |
| bounded CPU-active `seq` | `REALTIME@50000` | 0 | 1 s |

Both REALTIME spellings timed out only with `sleep`, whereas the same
profiler and environment completed on `seq`. This isolates the operational
stall to REALTIME profiling of the sleeping preflight target. The installed
help still documents numeric microsecond periods for timer sources, so a
future script should use `@50000`; the matrix rules out the `@f20` spelling
as a sufficient explanation of this hang. The internal interrupted-syscall
mechanism is plausible from HPCToolkit documentation but was not directly
traced. Original logs, status matrix, and measurement tar are preserved at
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/evidence/hpctoolkit-timer-diag.181521525.gadi-pbs/`.

No further four-node run was submitted. A future profile needs a separately
reviewed script without the REALTIME-on-sleep preflight, bounded startup,
and a small OpenFOAM sampling smoke before requesting 416 ranks.

## Gadi ICX 2026.2/Open MPI 5.0.10 UCX 1.18.1 path gate

- **Status:** `USER_ACTION_REQUIRED` — loader cause unresolved; no retry approved.
- **Recorded:** 2026-10-29
- **Workflow:** `builds/build-scripts/gadi-icx20262-ompi5010/smoke_openfoam_v2512_ucx118_v1.pbs`
- **Attempt / PBS job:** UCX 1.18.1 path-gated tutorial / `182508155.gadi-pbs`
- **Scope:** Gadi `normalsr`, one Sapphire Rapids node, 5 CPUs, 20-minute
  request; ICX 2026.2, private Open MPI 5.0.10, OpenFOAM v2512, site UCX
  1.18.1/UCC 1.4.4 modules. No fixed 65M case was run.

### Observed failure and retained evidence

PBS ended `F`, `Exit_status=1`, 1:00 walltime, 0.17 SU on
`gadi-cpu-spr-0215`. The job-keyed `exit-status.txt` also reports 1. Archive
SHA checks and toolchain version checks passed. `simpleFoam.ldd` found the
private MPI and site UCC, but found `libucp.so.0`, `libucs.so.0`,
`libucm.so.0` and `libuct.so.0` under `/usr/lib64` despite an explicit
post-environment `LD_LIBRARY_PATH` entry for `/apps/ucx/1.18.1/lib`
following the private MPI directory and preceding the prior library path.
The first failing command was the `grep` gate requiring `libucp.so.0` to
resolve under that site path. The MPI-initialized probe, Scotch decomposition
and solver did not start, so there is no runtime UCX version or solver timing
from this attempt. The prior successful smoke `182469604.gadi-pbs` did run
and reported system UCX 1.21.0 after MPI initialization.

Original job-keyed evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/smoke-ucx118.182508155.gadi-pbs/`.
Independent PBS stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/smoke_openfoam_v2512_ucx118_v1.pbs.out`.
Scheduler evidence: `qstat -xf 182508155.gadi-pbs`.

### Suspected cause and next decision

The loader cause is unconfirmed. Possible mechanisms include RPATH/RUNPATH
in the private MPI or another dependency, or library search behavior after
the environment has been assembled. A bounded diagnostic would capture the
final library path, relevant ELF dynamic tags and loader search trace before
another solver run. Such a diagnostic, any path/launcher change and any retry
require a separate reviewed scope. Do not treat the path-gate failure as an
OpenFOAM or UCX 1.18.1 runtime failure.

### Authorized bounded diagnosis — 2026-10-29

The user subsequently authorized automatic low-cost diagnostic and repair
attempts until the UCX path is verified, then a four-node submission after
the small verification succeeds. The first diagnosis is
`builds/build-scripts/gadi-icx20262-ompi5010/diagnose_ucx_loader_1n_v1.pbs`:
one `normalsr` node, two CPUs and ten-minute cap. It records the final
library path, ELF tags, `ldd`, bounded loader tracing and a two-rank UCP
version probe. The four-node job must not be submitted on diagnostic-script
completion alone; the actual runtime path/version and tutorial solver must
pass first. Each new attempt keeps unique output and preserved evidence.

### Resolution update — 2026-10-29

The user's subsequent authorization superseded the earlier
`USER_ACTION_REQUIRED` status for bounded low-cost diagnosis. Diagnostic
`182508262.gadi-pbs` failed before its MPI probe because archived `mpicc`
still referenced vanished JOBFS GCC; preserved ELF evidence showed private
MPI `DT_RPATH` placed `/usr/lib64` ahead of site UCX. Diagnostic
`182508303.gadi-pbs` passed with explicit site UCX preload and both ranks
reported UCP 1.18.1. Five-rank tutorial `182508353.gadi-pbs` passed but
reported a UCP >=1.19 warning while HCOLL was selected. Excluding HCOLL in
the distinct tutorial `182508439.gadi-pbs` removed that warning while
Scotch, solver `End` and coded timing all passed. Two-node communication
preflight `182508496.gadi-pbs` passed across two SPR hosts with one rank
each, UCP 1.18.1 on both and a completed `MPI_Allreduce`. All original
job-keyed evidence and stdout paths remain intact; no failed output was
overwritten. The four-node candidate uses the verified preload and excludes
HCOLL. UCC 1.4.4 is available but its runtime collective selection is not
claimed.

## Gadi binding4n182590339 JOBFS failure — OPEN

Track2 resource allocation/peak-storage error;no automatic repair authorized.

## Result inspected — 182590339.gadi-pbs: incomplete pair, JOBFS limit

PBS F / Exit_status271,SIGTERM,walltime00:17:27 (1047s),posted actual241.97SU
for the entire job. One normalsr allocation,4 Sapphire Rapids8470Q hosts
0514,0515,0516,0526;each104 CPUs/ranks,total416. ICX2025.3.2/private
OpenMPI5.0.10/OpenFOAMv2512/Scotch,unchanged65,334,765-cell occDrivAerStaticMesh.
UCX1.18.1/UCC1.4.4 are declared modules only;actual solver UCP version,
UCC/HCOLL selection remain unmeasured. No UCX preload or collective override.

Default arm completed all four preparation stages and Time1..150/End/finalization.
Coded149-step mean1.985561463114094s/step (first step excluded),Cd at150
0.29187617440389690,ExecutionTime302.06s/ClockTime308s.416rank mapping,
source/actualmesh checks,archive/binary checks and default PASS present.
Pre-exec solver masks allow13physicalcores perrank;not post-MPI affinity or
memory residency. The separate416rank core probe had unique cores within
corresponding default masks. Core arm stopped during runtime staging after
its node0 receipt;no decomposition or solver log,Cd,step-time,corePASS or
pairPASS/summary. Therefore this is not a valid completed binding comparison.
Default completed-arm data are retained as partial-job evidence,not a successful
paired result or a core-binding benefit.

Authoritative PBS stdout: `Job 182590339.gadi-pbs killed due to exceeding jobfs quota. Quota: 25.0GB, Used: 26.53GB, Host: gadi-cpu-spr-0514`.
PBS select gives4nodes eachjobfs26843545600bytes:100GB total is25GB/node.
The first arm's JOBFS files remained while the second unpacked a separate runtime.
The pre-submit capacity estimate failed to budget simultaneous per-node peak;
this is a workflow resource-planning error,not a demonstrated MPI/solver defect.
Retained pair_exit_rc=0 and core script_exit_rc=0 contradict PBS termination and
must never override it. Signal-aware failure reporting needs review separately.

1256 original evidence/stdout files retrieved with remote/local SHA agreement;
44 remaining rank receipts are listed in missing-files.tsv. qstat -xf was
read remotely and showed F/271,but its full raw stdout was not captured locally
before SSH expired;the archived PBS stdout independently records Exit271 andSU.
Original names/bytes and evidence/default/core paths
preserved;README,SHA256SUMS,sources.tsv and remote inventory retained. Missing
expected outputs were never produced:core solve/preparation,core coefficients,
pair-summary and pairPASS. The first bulk SCP pull reached its600-second local transfer bound;1091 verified originals were recovered from preserved staging and a remaining-only pull recovered165 more files before the master connection broke.
Stopped remote operations at SSH failure,no automatic authentication retry.
Full independent affinity validation is deferred until the44 missing receipts arrive.
No archived originals overwritten;no remote file
modified,no repair/retry/newPBS submission ormonitor restart.

Next proposed remedy requires a new reviewed diff and approval:calculate per-node
peak from both arms,then choose adequate per-node JOBFS or reuse the immutable
runtime across arms while preserving independent cases and all evidence;correct
signal status capture. Do not delete existing evidence or reuse this job ID.
