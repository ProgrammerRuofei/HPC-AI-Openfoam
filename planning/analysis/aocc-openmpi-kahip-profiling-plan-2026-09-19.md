# AOCC 5.0 / Open MPI 5.0.10 / KaHIP baseline: profiling plan

**Date:** 2026-09-19. **Scope:** read-only local and remote inspection only.
No PBS job was submitted, no file was modified on ASPIRE2A, no build ran, and
`fast-performance-screening-2026-09-17.md` and the independent Codex QA report
were not edited. This is a new, separate local report. All local git changes
from other work (`MANUAL_INSPECTION_ERROR.md`, `workflow/00-General-SSH-Rules.md`,
`workflow/gadi-cluster-config.md`, the Cray PALS probe commits and progress
notes) were left untouched; `git status` was checked first, per
`workflow/01-Git-Sync-Policy.md`, and nothing unrelated was staged or altered.

**Objective for this task:** determine where the accepted AOCC/Open MPI/KaHIP
baseline spends time, in support of the teammate's baseline-selection
storyline — not to build or screen Intel MPI, and not to resume compiler/MPI
comparison work.

---

## 1. Confirmed baseline fingerprint

Every field below was independently re-verified in this session (not copied
from an earlier revision without checking), against retained evidence and one
live remote read. Source is marked per row.

| Field | Value | Source / how verified |
| --- | --- | --- |
| OpenFOAM | v2512, `_87ed40d256-20251219` | retained solver log header (prior session) |
| Case | `occDrivAerStaticMesh`, 65,334,765 cells | retained `decomposePar` log, this job |
| Compiler | AOCC 5.0 (`WM_COMPILER=Amd`) | job's own `.o`: `WM_COMPILER=Amd WM_MPLIB=SYSTEMOPENMPI WM_COMPILE_OPTION=Opt` |
| MPI | Open MPI 5.0.10-gcc11 | `mpirun=/app/apps/openmpi/5.0.10-gcc11/bin/mpirun` in the job's own `.o` |
| Decomposition | KaHIP, `config=fast`, `imbalance=0.01` | job's own `decomposePar` log: `kahipDecomp : config=fast imbalance=0.01` |
| Resources | 4 nodes x 128 ranks = 512 ranks | `#PBS -l select=4:ncpus=128:mpiprocs=128:mem=400gb`, retained PBS script |
| Binding | `--bind-to core --map-by ppr:128:node:PE=1` | retained PBS script `MPI_ARGS`, and the job's own printed `PAR=` line |
| Build variant | stock `Opt`, not PGO | `WM_COMPILE_OPTION=Opt`; platform `linux64AmdDPInt32Opt` |
| **PBS job ID** | **`20092999.pbs101`** | recovered from the job's own `.o`: `PAR=mpirun --hostfile /var/spool/pbs/aux/20092999.pbs101 ...` — this is a genuine, independently-recovered confirmation of the job ID stated in the task, not an assumption |
| Compute node (this job) | `x1002c1s5b0n1` | job's own `.o`, `DrivAer start host=...` |
| Attempt / case name | `occdrivaer_4node_aocc_kahip_pin_v1` | job's own `.o` |
| **Result (uninstrumented)** | **2.869256832046979 s/step** | job's own `.o`: `AVG_WALL_PER_STEP=2.869256832046979` — matches the task's stated value exactly |
| Cd(150) | 0.280044 | job's own `.o`, `coefficient.dat` tail, column 2 at `Time=150` |
| `simpleFoam` SHA-256 | `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f` | **re-measured live** on ASPIRE2A this session (`sha256sum .../platforms/linux64AmdDPInt32Opt/bin/simpleFoam`) — matches the task's stated value exactly, and confirms the shared binary is still unchanged today despite ongoing teammate PGO work on the same tree |
| `libmpi` resolution | `/app/apps/openmpi/5.0.10-gcc11/lib/libmpi.so.40` | job's own `.o`, `ldd`-style resolution line printed by the harness |
| `libfabric` resolution | team scratch build, `.../ext/libfabric/lib/libfabric.so.1` | job's own `.o` |
| Module list | `aocc/5.0`, `gcc/11.2.0`, `openmpi/5.0.10-gcc11` | retained PBS script |
| `fvSolution` iteration caps | `p`: GAMG, maxIter 12 (+ coarsest PCG minIter=maxIter=35); `U`: smoothSolver maxIter 15; `k`/`omega`: smoothSolver maxIter 8 | read directly, prior session, unchanged case template |
| Solver phase timing (`time`, from the job's `.e`) | decomposePar 3m59.2s real; renumberMesh 0m37.4s real; potentialFoam 0m19.7s real; applyBoundaryLayer 0m12.6s real; **simpleFoam 8m6.8s real, 998m17.9s user, 15m34.5s sys** | job's own `.e` file, read this session — see §1.1 |

### 1.1 A free, but ambiguous, signal already sitting in the retained `.e` file

The job's `.e` file captures bash's `time` output around every parallel phase.
For the timed `simpleFoam` phase:

```text
real    8m6.751s
user    998m17.904s
sys     15m34.518s
```

`(user+sys)/real = 60832.4s / 486.751s ~= 125.0` "rank-equivalents" of
continuous CPU activity.

This number is genuinely informative but **its meaning depends on a fact this
session could not resolve from existing evidence**: whether bash's `time`
builtin, measuring `wait4()`/`getrusage(RUSAGE_CHILDREN)` on the *local
shell's direct children*, captured CPU time from all 512 ranks across 4 nodes,
or only from the subset of ranks co-located on the node that ran the PBS
script's shell (up to 128 ranks). Open MPI 5.0.10 here was built
`--with-pbs` (confirmed via `ompi_info`, §4), meaning remote ranks are most
likely spawned through PRTE daemons started via the PBS Task Manager API on
the other 3 nodes — processes that are not, in the general case, direct OS
children of the launching bash shell, and therefore plausibly **outside**
what `time` can see.

| If `time` captured... | Then 125 rank-equivalents means | Implied reading |
| --- | --- | --- |
| all 512 ranks | ~24.4% average CPU occupancy across the whole job | Ranks spend ~75% of wall time not executing instructions — strong (but not yet attributed) evidence of large aggregate wait time |
| only the ~128 co-located ranks | ~97.6% CPU occupancy on the launch node | The launch node's ranks are almost continuously busy; this observation would say nothing about the other 3 nodes |

**This is presented as an open question, not a conclusion.** It is not used
to answer H1 or H5 below. Resolving it is cheap (a `ps -eo pid,ppid,comm
--forest` snapshot on all 4 nodes during a future run, or documentation of
PRTE's PBS/TM launch behavior) and is folded into the future 4-node design
(§9) rather than claimed here as an existing result.

### 1.2 KaHIP partition: this job's own decomposition, verified deterministic against a sibling run

The task warned that "inter-node face" numbers from earlier analysis depend
on an unverified rank-to-node mapping, and that KaHIP determinism was an open
risk. Both points were checked directly against **this job's own**
`decomposePar` log (`.../cases/occdrivaer-occdrivaer_4node_aocc_kahip_pin_v1/logFiles/10_decomposePar.log`,
fetched fresh this session), not assumed from a different job.

**Determinism check.** This job's decompose log was diffed byte-for-byte
against the previously-analysed *unbound* KaHIP run (`kahip_v1.1`, a
different PBS submission, same mesh, same `config=fast imbalance=0.01`, same
512 ranks). The only differences are the log header's timestamp, hostname,
PID, case path, and the KaHIP solver's own wall-clock line (`80.17 s` vs
`80.13 s` — ordinary run-to-run timing noise for identical work). **Every
per-processor cell count, face count, neighbour list, and patch count is
byte-identical between the two independent decompositions.** For this exact
mesh, rank count, and KaHIP config, decomposition is empirically
deterministic across at least two independent invocations. This is a small
sample (n=2) and is not claimed to generalise to other configurations, but it
does mean the partition-topology numbers below are valid specifically **for
job 20092999**, not borrowed from a different job's possibly-different
partition.

| Metric (job 20092999's own partition) | Value |
| --- | --- |
| Cells per rank: min / mean / max | 114,134 / 127,606.96 / 128,882 |
| Cell imbalance (max/mean) | 1.00999 (KaHIP's own 1% budget, fully used) |
| Distinct processor-interface faces (edge cut) | 2,786,035 |
| Processor faces per rank: mean / max | 10,882.95 / 21,408 |
| Communicating rank pairs | 2,757 |
| Neighbours per rank: mean / max | 10.77 / 37 |
| Inter-node faces (assuming rank r on node r div 128) | 213,435 (7.66% of the cut) — **conditional on the rank-to-node mapping being correct; not yet measured for this job** |

The inter-node split remains conditional, exactly as the task flagged: it
assumes Open MPI's `--map-by ppr:128:node:PE=1` places rank *r* on node
*r* div 128, which has never been measured for this baseline. §9 makes
capturing the actual mapping a first-class, mandatory step of any future
profiled run — not an assumption to keep carrying forward.

---

## 2. Evidence from the failed Forge probe (context, not repeated)

Recorded in full in `fast-performance-screening-2026-09-17.md` Revision 8
(not edited by this report). Summary for context only:

- Job `23486768.pbs101`, `arm-forge/25.0.2`, `perf-report`.
- Trivial `mpirun -np 128 hostname` wrapped in `perf-report`: the underlying
  MPI launch succeeded completely (all 128 ranks returned the correct
  hostname); `perf-report` itself exited 1, produced no `.txt`/`.html`
  report, and its own log shows `Thread -1 exited` after a license wait that
  did resolve (not a license-server-reachability failure).
- Step B (a short `simpleFoam` run under `perf-report`) was never attempted;
  the probe script's own `STEP_A_FAILED` gate stopped it correctly.
- **This failure is specific to the Linaro/Arm Forge runtime-attach
  mechanism on this compute node. It is not evidence that profiling in
  general is impossible here**, and it is not repeated in this task. No
  other Forge version, flag, or launch mode was tried, per the prior
  explicit instruction to stop and report on failure.

This probe is **not** resubmitted, and the previously-prepared 4-node
`perf-report` profiling script is **not** used — both per this task's explicit
constraints.

---

## 3. Profiler candidate table

Every "module avail" / `ompi_info` / `ldd` / `which` check below was run live
on ASPIRE2A this session (login node unless stated). Per the task's explicit
instruction, login-node presence is never treated as compute-node proof; each
row's "compute-node usability" column reflects only what has actually been
demonstrated, which for every row except Forge (demonstrated to fail) is
**not yet demonstrated either way**.

| Candidate | PMPI/LD_PRELOAD? | Relink needed? | Recompile needed? | Supports OMPI 5.0.10? | Per-rank data? | P2P vs collectives vs wait? | HW counters? | Overhead (typical) | Output size @512 ranks | License? | Compute-node usability shown? | Would the profiled binary differ from the baseline? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **mpiP** | yes (LD_PRELOAD, PMPI) | no | no | n/a — **not installed anywhere on ASPIRE2A** (`module -t avail mpip`/`mpiP`: no match; `command -v mpiP` empty in the retained `probe_phase8_tools_v1.o` compute-node probe, §3.1) | yes | P2P + collectives, not fine-grained wait | no | low-moderate | small (text summary) | no (open source) | **N/A — absent as software, not a compute-node question** | no, if it existed |
| **IPM** | yes (LD_PRELOAD, PMPI) | no | no | n/a — **not installed anywhere on ASPIRE2A** (`module -t avail ipm`: no match; `command -v ipm` empty in the retained compute-node probe) | yes | P2P + collectives (aggregate), limited wait detail | some (via PAPI, if linked) | low | ~500 KB XML per rank-set in last year's Iris runs (illustrative only, different system, not a projection — see §10) | no | **N/A — absent as software** | no, if it existed |
| **Score-P / Scalasca / Extrae / TAU** | varies (some PMPI, some need recompiled instrumentation) | typically yes for full instrumentation | typically yes | unknown — moot | yes | yes, detailed | yes (via PAPI) | moderate-high | large (trace-based) | no (mostly open source) | **N/A — none installed** (`module -t avail scorep/scalasca/extrae/tau`: no match, checked live) | **yes, in general** for full instrumentation modes |
| **Cray perftools / CrayPat (`pat_build`)** | no — post-link binary patcher | **yes, confirmed** | no | its own MPI layer | yes | yes | yes | moderate | moderate-large | no | **Confirmed to REQUIRE relink**: `pat_build` refused the existing unmodified `simpleFoam` with `ERROR: Missing required ELF section '.note.link'` (found earlier this session investigating the same binary) — the tool itself states the fix is to rebuild with the `perftools` module loaded | **yes** — disqualified by the "do not change the baseline binary" constraint without separate authorization |
| **Linaro/Arm Forge (`perf-report`/`map`)** | no (dynamic attach) | no | no | yes, launches fine | intended, not reached | intended, not reached | intended, not reached | intended, not reached | intended, not reached | yes | **Confirmed to FAIL** (§2) | no, if it worked |
| **PAPI (library, `papi/6.0.0.14`)** | no | n/a | **yes, to use directly** (its API must be called from source) | n/a | yes if driven | no (counters only, not MPI-aware) | **yes — this is its purpose** | low | small | no | present as a module; no front-end to drive it without source changes or one of the (absent) tools above | **yes**, if called from source |
| **Linux `perf` (perf_events)** | no (execs and traces the child, no preload needed) | no | no | agnostic to MPI implementation | yes, per-process | no MPI-level breakdown; gives CPU/cache/stall counters and call-graph samples | **yes — CPU/cache/memory/NUMA** | low-moderate (`perf stat`); moderate (`perf record`) | small (`stat`); moderate (`record`) | no | **not found in login-node PATH at all** (`which perf` empty, `perf --version`: command not found); no module either; compute-node reality genuinely unknown — HPE Cray EX systems sometimes ship a leaner login-node OS image than the compute-node image, so absence here is a weaker signal than Forge's case, but it is still unconfirmed | no |
| **Open MPI MCA verbosity** (`pml_base_verbose`, `btl_base_verbose`, `coll_base_verbose`) | no (built into `libmpi`) | no | no | yes (native) | yes, per-rank stderr lines | **transport/algorithm selection only — not a timing profiler** (explicit user instruction) | no | very low | small (log lines) | no | effectively guaranteed to work — it is the same binary and MPI stack already proven to run | **no** |
| **MPI Tools Interface (`MPI_T`)** | no, but driving it needs a small caller | no | **yes — a new, separate, non-OpenFOAM harness must call `MPI_T_*`** | yes, native to OMPI 5.x | yes | depends on exposed PVARs (OMPI exposes some PML/coll counters) | no | very low | small | no | untested; `ompi_info -a` (static, login-node only) can enumerate available PVARs at zero cost, but *driving* live per-rank collection during the real solve needs a new harness | the harness itself is new code, but it does not touch `simpleFoam`; still counts as "build something" under this task's scope, so **out of scope for the 1-node probe** below |
| **Nsight Systems / VTune / other GPU or Intel-specific tracers** | — | — | — | — | — | — | — | — | — | — | `nsys`/`ncu`: no module; VTune (`vtune`): no module, and the retained `probe_phase8_tools_v1.o` (§3.1) shows `aps`/`vtune` absent from PATH even after loading `intel-oneapi/2025.1.3` and sourcing `setvars.sh` on a compute node | **Architecturally not applicable** — these ASPIRE2A `normal`-queue nodes are dual-socket AMD EPYC 7713 (Milan), CPU-only; no GPU accelerator module is relevant to this job |

### 3.1 The existing `probe_phase8_tools.pbs` result — read, not repeated

Per the task's explicit instruction, this existing probe and its retained
output were read this session rather than re-run.

- Script: `scripts/probe_phase8_tools.pbs` (1 node, 4 cpus, 16 GB, 20 min
  walltime; loads `intel-oneapi/2025.1.3`, sources its `setvars.sh`, then
  checks `aps`, `vtune`, `ipm`, `mpiP` via `command -v`, then a bounded
  `find` under the oneAPI tree, then a completion marker).
- Retained output `scripts/outputs/probe_phase8_tools_v1.o`: ran on compute
  node `x1002c...` under queue `qdev`; loaded `intel-oneapi/2025.1.3`
  successfully; **`APS=`, `VTUNE=`, `IPM=`, `MPIP=` all printed empty** — none
  of the four are on `PATH` after the standard oneAPI environment setup.
- The output file (516 bytes, 16 lines, byte-count verified) **stops right
  after `MPIP=`**; the script's own completion marker
  (`PROBE_PHASE8_TOOLS_DONE`) never appears, and the retained `.e` file is
  empty (no PBS walltime-kill message). The most likely explanation is a
  latent bug in the script itself: it runs `set -eo pipefail`, and its final
  step is an unguarded `find ... -type f | head -20` — if more than 20
  matching files exist under the searched oneAPI tree, `head` closes the
  pipe early, `find` receives `SIGPIPE`, and under `pipefail` that non-zero
  status trips `set -e`, silently terminating the script before the
  completion echo. **This is noted as a finding for the record, not fixed or
  resubmitted here** — it is an existing shared script, out of this task's
  scope to modify or rerun.
- **Net result usable for this report:** VTune/APS and IPM/mpiP are
  confirmed absent from `PATH` on an ASPIRE2A compute node under the
  Intel oneAPI environment, independent of the OpenMPI/AOCC baseline stack
  entirely. This corroborates, from a second independent probe, the same
  `module avail` absence found on the login node.

---

## 4. Selected next profiling method, and why

**No currently-installed, no-relink, no-recompile profiler has been
demonstrated to work against the exact baseline binary on an ASPIRE2A
compute node.** This is stated plainly, as the task requires, rather than
implied. Working through the preferred decision order:

1. **mpiP / IPM** — closed, not by incompatibility but by **absence**: `module
   avail` (login node) and the retained `probe_phase8_tools_v1.o` (compute
   node) agree that neither exists on this system in any form.
2. **A sampling/counter method that does not relink** — the only real
   candidate is Linux `perf`. It is not installed as a module and not present
   in the login node's `PATH`. This is a genuinely weaker starting position
   than Forge had (Forge was confirmed present and versioned on the login
   node before failing on the compute node); `perf`'s compute-node status is
   simply unknown. It remains the least-bad candidate for a probe because
   every other option in categories 1 and 3 is either absent as software or
   requires a relink, and `perf` is sometimes shipped only in a compute
   node's OS image on HPE Cray EX systems even when absent from the
   login-node image.
3. **Score-P / Scalasca / Extrae / TAU** — closed, absent as software
   (`module avail`, checked live, no matches).
4. **Direct OpenFOAM-side instrumentation** — out of scope for this task by
   both the user's explicit instruction and `AGENTS.md`'s application
   boundaries (source changes need separate approval and would no longer be
   the exact scored baseline).

**Decision: prepare, but do not submit, a minimal 1-node probe for Linux
`perf`.** Bundle into the same probe a zero-risk, guaranteed-to-work
secondary check — Open MPI MCA verbosity — since it costs nothing extra and
answers part of H4 (transport/placement diagnostics) regardless of whether
`perf` works. If the `perf` probe also fails, §4.1 states the resulting
position clearly rather than proposing a fifth workaround.

### 4.1 If `perf` also fails

If this probe fails, the honest state of the project is: **no viable
external profiler currently exists for the unmodified AOCC/Open MPI/KaHIP
baseline on ASPIRE2A.** The only remaining paths would be (a) a controlled,
separately-authorized Cray perftools relink with explicit before/after binary
identity bookkeeping and validation that the relinked binary's behaviour and
timing are not materially different from the scored baseline, (b) contacting
NSCC support about Forge's compute-node attach failure or about `perf`
availability policy — the Forge failure mode (license resolved, MPI launch
succeeded, only the sampling thread died) looks like exactly the kind of
issue vendor/site support could plausibly resolve, or (c) the last-resort,
explicitly out-of-scope-today direct OpenFOAM-side instrumentation route.
None of these is proposed for execution now.

---

## 5. Exact information this method can and cannot measure

### `perf stat` (counting mode, if it works)

**Can measure**, per rank/process (when run as `mpirun ... perf stat --
simpleFoam -parallel`, one `perf` instance per rank):
- Wall clock, task-clock, CPU utilisation
- Instructions, cycles, IPC
- Cache references/misses (L1/LLC, counter-set-dependent)
- Branch predictions
- Context switches, CPU migrations
- With `--per-node`/`-M` extensions where supported: memory bandwidth
  proxies via uncore counters (hardware- and permission-dependent, not
  guaranteed)

**Cannot measure directly:**
- MPI call classification (`perf` has no concept of "this stall was an
  `MPI_Waitall`" — it only sees the process spending time in a syscall or a
  spin loop). Attributing a `perf`-observed stall specifically to MPI wait
  requires either `perf record` with call-graph sampling landing inside
  `libmpi`/`libopen-pal` frames (approximate, sampling-based) or corroboration
  from a second source (e.g. the MCA-verbosity transport log, or elapsed-time
  bracketing around collectives if the source were instrumented — out of
  scope).
- Collectives vs point-to-point split (no MPI semantic awareness at all).
- Message counts or bytes transferred.
- Rank-to-rank communication topology.

### `perf record` (sampling mode, if it works)

Adds approximate call-graph attribution (which functions, including
`libmpi`/`libopen-pal` symbols if not stripped, were executing when each
sample landed) at the cost of higher overhead and much larger output
(`perf.data` per rank, potentially significant at 512 ranks — sampling rate
must be kept low and reported explicitly if used).

### Open MPI MCA verbosity (bundled diagnostic, not the primary profiler)

**Can measure:** which BTL/PML/collective algorithm Open MPI actually
selected at runtime (e.g. confirms UCX vs. TCP vs. vader/self, matching the
concern the senior team's slide raised about a silent TCP fallback on a
different Gadi build). **Cannot measure:** any timing breakdown at all — it
is a selection log, not a profiler, exactly as the task specifies.

---

## 6. Minimal 1-node probe design

Two independent trivial checks, run in the same tiny job, each gated
separately, neither touching OpenFOAM:

**Step A — Linux `perf` existence and basic function.**
`which perf`, `perf --version`, then (only if both succeed)
`perf stat -e task-clock,cycles,instructions,cache-misses -- sleep 2` on a
single compute-node process (no MPI at all yet). Gate: `STEP_A_OK` only if a
parseable `perf stat` report is produced; `STEP_A_FAILED` otherwise, and the
probe stops — no attempt to wrap an `mpirun` command with `perf` if the
trivial single-process case does not even work.

**Step B — `perf` wrapping a trivial MPI command (only if Step A passed).**
`mpirun --hostfile "$PBS_NODEFILE" -np 8 perf stat -- hostname`, on the same
1 node. Confirms `perf` survives being invoked once per rank under Open
MPI's launcher, not just standalone. Gate: `STEP_B_OK` only if 8 valid `perf
stat` reports appear (one per rank) and all 8 `hostname` outputs are correct;
`STEP_B_FAILED` otherwise, probe stops. **No OpenFOAM workload runs in this
job regardless of Step B's outcome** — that is reserved for the future 4-node
design (§9), which needs separate authorization in any case.

**Step C — Open MPI MCA verbosity (independent of A/B, always attempted).**
`mpirun --hostfile "$PBS_NODEFILE" -np 8 --mca pml_base_verbose 10 --mca
btl_base_verbose 10 -- hostname`, capturing the selection log. This is
expected to succeed regardless of Step A/B's outcome, since it exercises
only functionality already proven to work in this session (Open MPI 5.0.10
launching successfully was directly observed in the Forge probe's Step A).

### 6.1 Why this is the smallest viable design

- 1 node, 8 ranks maximum, no more than a few minutes of actual runtime.
- Every step is gated; a failure stops the job rather than cascading into a
  wasted larger step.
- Nothing is built, no `Allwmake`, no `Pstream` build, no Intel MPI.
- No existing PBS output, case, report, or build product is touched; see
  §7.3 for the exact new, unique names used.
- The full tool log is preserved and read in full (not `tail`-ed only) when
  reporting results back, matching the lesson learned from under-reading the
  Forge probe's `stepA.log` earlier this session.

---

## 7. Complete proposed local diff (probe script) — NOT SUBMITTED

This is a new standalone file. It does not modify `run_occdrivaer.sh` (which
gained PGO-related changes very recently under active teammate use — checked
again this session) or any other shared script. It writes to new, unique
output paths only.

### 7.1 New file: `scripts/probe_perf_1n_v1.pbs`

```bash
#!/bin/bash
#PBS -N probe_perf1n
#PBS -P 59000020
#PBS -q normal
#PBS -l select=1:ncpus=8:mem=16gb
#PBS -l walltime=00:15:00
#PBS -o outputs/probe_perf_1n_v1.o
#PBS -e outputs/probe_perf_1n_v1.e

# Read-only compute-node availability probe for Linux perf (perf_events),
# plus an independent, guaranteed-to-work Open MPI MCA-verbosity check.
# Does not build, relink, or run any OpenFOAM workload. Does not touch
# run_occdrivaer.sh or any existing case/output/build product.
#
# Gated: STEP_A (perf, single process) -> STEP_B (perf under mpirun) ->
# STEP_C (MCA verbosity, independent of A/B). Stops at the first failed
# gate in the A/B chain; STEP_C always runs since it exercises only
# already-proven Open MPI functionality.

set -eo pipefail
cd "$PBS_O_WORKDIR"
mkdir -p outputs
PROBE_DIR="outputs/probe_perf_1n_v1_${PBS_JOBID%%.*}"
mkdir -p "${PROBE_DIR}"

module purge
module load aocc/5.0
module load gcc/11.2.0
module load openmpi/5.0.10-gcc11
export PATH="/app/apps/aocc/5.0/bin:${PATH}"

echo "=== module list ==="
module list -t 2>&1
echo "=== host / kernel ==="
hostname
uname -r
echo "=== perf_event_paranoid (compute node; login node was 2) ==="
cat /proc/sys/kernel/perf_event_paranoid 2>&1 || echo "not readable"

echo
echo "=== STEP A: perf existence and single-process function ==="
set +e
PERF_PATH="$(command -v perf)"
echo "perf path: ${PERF_PATH:-<not found>}"
if [[ -z "${PERF_PATH}" ]]; then
    echo "PROBE_RESULT=STEP_A_FAILED — perf not on PATH on this compute node."
    set -e
    exit 0
fi
perf --version > "${PROBE_DIR}/stepA_version.log" 2>&1
cat "${PROBE_DIR}/stepA_version.log"

perf stat -e task-clock,cycles,instructions,cache-misses \
    -- sleep 2 > "${PROBE_DIR}/stepA_stat.log" 2>&1
STEPA_RC=$?
set -e
echo "perf stat exit code: ${STEPA_RC}"
echo "--- full stepA_stat.log (not tailed) ---"
cat "${PROBE_DIR}/stepA_stat.log"

if [[ "${STEPA_RC}" -ne 0 ]] || ! grep -qE "task-clock" "${PROBE_DIR}/stepA_stat.log"; then
    echo "PROBE_RESULT=STEP_A_FAILED — perf ran but produced no parseable counters."
    exit 0
fi
echo "PROBE_RESULT=STEP_A_OK"

echo
echo "=== STEP B: perf wrapping a trivial MPI command (8 ranks, 1 node) ==="
set +e
mpirun --hostfile "${PBS_NODEFILE}" -np 8 -x PATH -x LD_LIBRARY_PATH \
    perf stat -e task-clock,cycles,instructions -- hostname \
    > "${PROBE_DIR}/stepB.log" 2>&1
STEPB_RC=$?
set -e
echo "mpirun+perf exit code: ${STEPB_RC}"
echo "--- full stepB.log (not tailed) ---"
cat "${PROBE_DIR}/stepB.log"

N_HOST_LINES="$(grep -cE '^x[0-9]' "${PROBE_DIR}/stepB.log" || true)"
N_PERF_BLOCKS="$(grep -cE 'task-clock' "${PROBE_DIR}/stepB.log" || true)"
echo "hostname lines seen: ${N_HOST_LINES} (expect 8)"
echo "perf counter blocks seen: ${N_PERF_BLOCKS} (expect 8)"

if [[ "${STEPB_RC}" -ne 0 || "${N_HOST_LINES}" -lt 8 || "${N_PERF_BLOCKS}" -lt 8 ]]; then
    echo "PROBE_RESULT=STEP_B_FAILED"
else
    echo "PROBE_RESULT=STEP_B_OK"
fi

echo
echo "=== STEP C: Open MPI MCA verbosity (independent diagnostic, always run) ==="
set +e
mpirun --hostfile "${PBS_NODEFILE}" -np 8 -x PATH -x LD_LIBRARY_PATH \
    --mca pml_base_verbose 10 --mca btl_base_verbose 10 \
    -- hostname > "${PROBE_DIR}/stepC_mca.log" 2>&1
STEPC_RC=$?
set -e
echo "MCA-verbose mpirun exit code: ${STEPC_RC}"
echo "--- full stepC_mca.log (not tailed) ---"
cat "${PROBE_DIR}/stepC_mca.log"
if [[ "${STEPC_RC}" -eq 0 ]]; then
    echo "PROBE_RESULT=STEP_C_OK"
else
    echo "PROBE_RESULT=STEP_C_FAILED"
fi

echo
echo "PROBE_COMPLETE — see ${PROBE_DIR}/ for full per-step logs."
```

### 7.2 Why the script is structured this way

- `set -eo pipefail` at the top, but every fallible external command that
  should *not* abort the whole job is explicitly wrapped in `set +e` / `set
  -e` pairs with its own captured exit code — avoiding the exact
  `pipefail`-induced silent-truncation bug diagnosed in `probe_phase8_tools.pbs`
  (§3.1). No unguarded pipe to `head` anywhere in this script.
- Every tool log is written to its own file under a unique, job-ID-suffixed
  directory and `cat`-ed in full when reporting, not `tail`-ed — applying the
  lesson from under-reading the Forge probe's `stepA.log` on the first pass
  earlier this session.
- Step C runs unconditionally (its own `set +e` block) regardless of Step
  A/B's outcome, so a `perf`-not-found result still yields the MCA-verbosity
  evidence.

### 7.3 File-safety checklist against this task's constraints

| Constraint | How satisfied |
| --- | --- |
| New standalone filename, based on latest shared runner conventions | `scripts/probe_perf_1n_v1.pbs` — new name, no collision checked against `scripts/outputs/` (none exists) |
| Unique job/stdout/stderr/case/profiler-output names | `#PBS -N probe_perf1n` (new), `outputs/probe_perf_1n_v1.{o,e}` (new), `outputs/probe_perf_1n_v1_${PBS_JOBID}/` (new, job-ID-suffixed so a rerun cannot collide either) |
| No overwrite of existing evidence | No existing path is written to; the probe creates only new files |
| `run_occdrivaer.sh` not edited | Not referenced at all — this probe never touches OpenFOAM |
| No `Allwmake`, no `Pstream` build, no Intel MPI | None appear anywhere in this script |
| No remote file modified, no PBS submitted | This script exists only locally in this session; **not uploaded, not submitted** |

---

## 8. Explicit success and stop criteria

| Outcome | Criterion | Action |
| --- | --- | --- |
| Full success | `STEP_A_OK`, `STEP_B_OK`, `STEP_C_OK` all present | `perf` is usable at least at 1-node scale under Open MPI 5.0.10; proceed to design (not yet submit) the future 4-node profile of §9 using `perf stat` per rank |
| Partial success | `STEP_A_OK`, `STEP_B_OK`, but `STEP_C_FAILED` | Unexpected — Step C exercises already-proven functionality; stop and diagnose the MCA-verbosity flags specifically before anything else, since this would indicate this session's understanding of the baseline's own MPI stack is wrong somewhere |
| Partial success | `STEP_A_OK` but `STEP_B_FAILED` | `perf` works standalone but not under `mpirun`; report exactly which of exit-code/hostname-count/perf-block-count failed; do not proceed to a 4-node design until this is understood, since the 4-node design depends on `perf` surviving under the launcher |
| Failure | `STEP_A_FAILED` | `perf` is not usable here at all. Stop. Report per §4.1: no currently-installed no-relink profiler exists for this baseline. Do not try another tool in the same job or a follow-up job without a new explicit decision. |
| Any PBS-level failure (job held, walltime exceeded, `Exit_status != 0` on the wrapper itself) | — | Read the full `.o`/`.e`, diagnose, report; do not resubmit without showing the diagnosis first, matching this session's handling of the Forge probe |

---

## 9. Future 4-node profile design (described only, not submitted)

Contingent on §6-8 succeeding. Exact configuration, unchanged from the
confirmed fingerprint in §1:

- AOCC 5.0, Open MPI 5.0.10, KaHIP `config=fast imbalance=0.01`, 4 nodes x
  128 = 512 ranks, `--bind-to core --map-by ppr:128:node:PE=1`, stock `Opt`.
- **Screening window first.** A fresh case run to 40 steps (not 150),
  matching the methodology already accepted elsewhere in this project for
  screening versus scored validation, before any profiled 150-step run is
  considered. Steps 20-40 as the stabilized comparison window if a
  contemporaneous unprofiled control confirms the window is still
  representative for this partition (it was for the KaHIP-vs-hierarchical
  pair checked previously, to within 0.07% of the 150-step ratio; this
  should be re-checked for the profiled-vs-unprofiled pair specifically, not
  assumed).
- **Baseline binary hash gate**, before running: `sha256sum` of
  `linux64AmdDPInt32Opt/bin/simpleFoam` must equal
  `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f` (§1),
  re-checked at submission time since the shared tree changes under active
  teammate PGO work.
- **Input and partition identity checks:** `sha256sum` of the mesh/case
  input files (as already practiced elsewhere in this project), and a fresh
  `decomposePar` invocation's log diffed against job 20092999's own log
  (§1.2) to confirm the partition is the same one being profiled — not
  assumed identical just because the KaHIP config string matches.
- **Actual rank-to-host-to-core/NUMA mapping capture**, resolving §1.1's
  open ambiguity and the conditional inter-node numbers of §1.2: e.g. each
  rank prints `hostname`, `sched_getcpu()`/`/proc/self/status`
  `Cpus_allowed_list`, and NUMA node, gathered centrally before the timed
  run — cheap, and directly answers H4.
- **Profiler overhead measurement against a contemporaneous unprofiled
  control**, in the same allocation where practical (an A-B or A-B-B-A
  structure, consistent with the paired-screen methodology already used
  elsewhere in this project), so the profiler's own perturbation is
  quantified rather than assumed negligible.
- **Per-rank distributions**, not just aggregates: CPU-busy time, and
  (if `perf` supports it at this scale) cache-miss rate, reported as
  min/mean/max/sd across the 512 ranks — directly testing H3 (are a few
  ranks the outliers).
- **Point-to-point versus collective/reduction time**: `perf`-alone cannot
  supply this (§5); if Step B/C evidence from the 1-node probe shows MCA
  verbosity gives usable per-call information, or if a documented,
  zero-relink way to read Open MPI's built-in `MPI_T` PML/coll PVARs without
  a new harness is found (not yet demonstrated — see the candidate table's
  MPI_T row), fold that in; otherwise state plainly that this split remains
  unmeasured and is the strongest argument for revisiting Forge (via NSCC
  support) or a scoped Cray perftools relink later.
- **Message counts and bytes transferred**: not obtainable from `perf`
  alone; would need mpiP/IPM (absent) or MCA-level accounting if it exists
  for this build (to be checked from `ompi_info -a` output, at zero cost,
  before claiming this is unobtainable).
- **Top MPI call sites**: only if `perf record` call-graph sampling resolves
  symbols inside `libmpi`/`libopen-pal` (to be confirmed, not assumed, since
  it depends on whether the installed Open MPI build retains symbols).
- **CPU/cache/memory/NUMA counters**: exactly the `perf stat`/`perf record`
  output of §5, per rank.
- **Cd, residual, and solver-iteration checks**: identical acceptance gates
  already used throughout this project (`End` marker, no `NaN`, Cd within
  the official 0.28-0.29 band, `fvSolution` iteration caps unchanged —
  confirmed once already for this exact case in §1).
- **Clear separation between profiled timing and official uninstrumented
  timing**: the profiled run's own `Average wall-clock time per time step`
  is reported as a *profiled-arm* number, explicitly labelled as such and
  never substituted for the retained 2.869256832046979 s/step
  uninstrumented result; the overhead measurement above quantifies the gap
  rather than ignoring it.

### 9.1 Which hypotheses this design can and cannot resolve, honestly

| Hypothesis | Resolvable with `perf` alone? |
| --- | --- |
| H1 (is MPI material?) | Only indirectly — `perf`'s CPU-busy fraction per rank, contrasted with wall time, bounds *non-computation* time, but cannot itself prove that gap is MPI rather than, e.g., a page fault or an I/O stall. Corroboration needed. |
| H2 (p2p vs collectives) | **No** — not measurable from `perf` alone (§5); needs mpiP/IPM/MPI_T/Forge, none currently working. |
| H3 (outlier ranks) | **Yes** — per-rank CPU-busy and cache-miss distributions directly test this. |
| H4 (actual placement) | **Yes** — the mapping capture step directly answers this; independent of whether `perf` itself works. |
| H5 (compute/memory/cache/NUMA-bound) | **Yes, this is `perf`'s strength** — cycles, IPC, cache-miss rates, and (if uncore counters are accessible) memory-bandwidth proxies are exactly what `perf stat`/`perf record` are for. |
| H6 (rank placement/affinity effects) | Partially — the mapping capture (H4) plus per-rank counters (H3/H5) together give strong circumstantial evidence, not a controlled experiment isolating affinity as the sole variable. |
| H7 (KaHIP processor-interface communication) | Only via correlation with the partition-topology numbers already computed in §1.2/earlier revisions (e.g. do the highest-interface-face ranks show the lowest CPU-busy fraction) — suggestive, not a direct MPI-time measurement. |

H2 in particular is **not answerable by the currently-viable toolchain**.
This should be stated to the teammate plainly rather than implied to be
covered.

---

## 10. Slide-ready profiling outputs we expect to obtain

If §6-9 succeed as designed:

- A bar or table of **per-rank CPU-busy fraction** across all 512 ranks
  (min/median/max/sd), directly testing H3.
- A **scatter or correlation plot** of per-rank CPU-busy fraction (or
  cache-miss rate) against that rank's KaHIP processor-interface face count
  (from §1.2's partition data) — a slide-ready visual argument for or against
  H7, clearly labelled as correlational.
- A **rank-to-node/core map** (H4), likely a simple table or heatmap showing
  whether the assumed 4-contiguous-blocks-of-128 placement held.
- **Aggregate cycles/IPC/cache-miss-rate** for the profiled run, positioned
  against the memory-bandwidth context already on record elsewhere in this
  project (Gadi node-level bandwidth figures) — but **only as this system's
  own measured numbers**, never substituting last year's or another
  cluster's percentages, per the task's explicit instruction.
- A clearly two-column table: **profiled-arm timing vs. the retained
  uninstrumented 2.869256832046979 s/step**, with the measured overhead
  stated as a percentage, so nobody mistakes the profiled number for the
  scored one.

**Illustrative-only reference points** (last year's artifacts, a different
system, a different mesh scale, presented only to size what "an IPM/VTune
report looks like," not as evidence about the current baseline): last year's
IPM XML reports were approximately 500-570 KB each; the retained VTune
output directory totals approximately 1.7 MB. These numbers say nothing
about what a working profiler on ASPIRE2A would produce at 512 ranks; a
genuinely new size estimate should replace this once (if) a working tool is
found.

---

## 11. Remaining risks and unknowns

| # | Risk / unknown | Status |
| --- | --- | --- |
| P1 | `perf` may not exist on ASPIRE2A compute nodes at all (absent even from the login-node `PATH`, a weaker starting position than Forge had) | Open — the exact question §6's probe answers |
| P2 | Even if `perf` works, **H2 (p2p vs collectives) has no currently-viable measurement path** | Open, stated plainly rather than glossed over |
| P3 | The `.e` file's `real`/`user`/`sys` ambiguity (§1.1) is unresolved and must not be used to answer H1/H5 until the cross-node process-tree question is settled | Open, folded into the future 4-node design |
| P4 | KaHIP determinism was checked for only n=2 independent decompositions of this exact mesh/config/rank-count; it is not established for any other configuration, and a future profiled run must still re-verify partition identity rather than assume it (§9) | Partially resolved, bounded scope |
| P5 | The inter-node face split (§1.2) remains conditional on an unverified rank-to-node mapping; not to be presented as measured until §9's mapping-capture step runs | Open, explicitly flagged, not carried forward as fact |
| P6 | `probe_phase8_tools.pbs`'s own likely `pipefail`/`SIGPIPE` bug (§3.1) means its `find` results (which tool files, if any, exist elsewhere in the oneAPI tree under non-standard names) were never actually seen; the `command -v` results are still valid and sufficient for this report's conclusions, but the `find` half of that probe never ran to completion | Noted for the record; not fixed or rerun in this task |
| P7 | Whether Open MPI 5.0.10's `MPI_T` PVAR set (native, zero-relink) could supply *any* p2p/collective split without a new harness program has not been checked via `ompi_info -a` (a zero-cost, login-node-only check that was not performed this session due to scope/time) | Open — a candidate cheap follow-up, explicitly not pursued here since it does not change this report's recommended next action |
| P8 | If `perf` fails, the Forge failure mode (license resolved, launch succeeded, sampling thread died) looks plausibly support-fixable; contacting NSCC has not been attempted and is outside this task's scope | Open, noted as a possible future path in §4.1 |
| P9 | Overhead of `perf stat`/`perf record` at full 512-rank scale is assumed low-to-moderate based on general knowledge of the tool, not measured on this system; §9 requires measuring it against a contemporaneous control rather than assuming a textbook figure | Open, designed to be resolved as part of §9, not before |

---

## Stop point

This report and the complete local diff in §7 are presented for review. No
PBS job was submitted, no OpenFOAM ran, nothing was built, and no remote file
was modified. The next authorized action, if approved, is submission of
exactly the single 1-node probe in §7.1 — nothing larger, and no alternate
tool substituted without a new explicit decision if it fails.

---

# Addendum — 2026-09-19: mpiP build plan (user decision: build mpiP from source)

The user was asked to disambiguate "rebuild the profiler" among three
materially different options (build mpiP from source; build IPM from source;
relink `simpleFoam` against Cray perftools) and chose **mpiP from source**.
This addendum is the complete, evidence-checked build plan. Everything below
is still **read-only reconnaissance and local planning** — no file was
downloaded, no job was submitted, nothing was built. `git status` was
rechecked before writing this addendum; nothing outside this one file
changed.

## 12. Why mpiP over IPM, given the user's constraint

Both are absent from ASPIRE2A as installed software (§3) and both are
PMPI/LD_PRELOAD-based, so neither requires relinking `simpleFoam`. mpiP was
selected by the user; it is also the smaller, simpler build (fewer
dependencies — no `libxml2` requirement, unlike IPM's XML report generation),
which lowers the risk of this being yet another tool that "builds but doesn't
actually attach," matching this project's repeated experience.

## 13. Source identification — verified live, not assumed

The obvious guessed URL was wrong and is recorded here as a caution against
assuming without checking, consistent with this project's practice:

| Attempted | Result |
| --- | --- |
| `https://github.com/LLNL/mpiP/releases/download/3.5/mpiP-3.5.tar.gz` (guessed capitalisation) | **HTTP 404** |
| `https://api.github.com/repos/LLNL/mpiP/releases/latest` (GitHub API, authoritative) | `tag_name: 3.5`, asset `mpip-3.5.tgz`, `browser_download_url: https://github.com/llnl/mpiP/releases/download/3.5/mpip-3.5.tgz` (lowercase `mpip`) |
| `https://github.com/llnl/mpiP/releases/download/3.5/mpip-3.5.tgz` (corrected) | **HTTP 200**, `content-type: application/octet-stream`, **`content-length: 336942`** (via the redirect to `release-assets.githubusercontent.com`) |

**Confirmed source for this plan:**

- URL: `https://github.com/llnl/mpiP/releases/download/3.5/mpip-3.5.tgz`
- Size: **336,942 bytes** (~329 KiB)
- This is the official LLNL GitHub release asset for mpiP 3.5, the current
  latest tagged release (checked against the repo's tag list: `3.5`,
  `3.4.1`, ...).

This download has not happened. Per the safety rules governing this session,
downloading any file requires the user to see the filename, source, and size
and approve it — stated here explicitly rather than assumed covered by "build
mpiP."

## 14. Dependency and environment check — all live on ASPIRE2A this session

| Dependency | Status | Evidence |
| --- | --- | --- |
| C compiler + MPI wrapper | `mpicc` from `openmpi/5.0.10-gcc11`, wraps `/opt/cray/pe/gcc/11.2.0/bin/gcc`, links `-L/app/apps/openmpi/5.0.10-gcc11/lib ... -lmpi` | `mpicc -show`, run live |
| Target MPI library match | Confirmed: this is the exact `libmpi.so.40` the baseline uses | same `.so` path as recorded in job 20092999's own `.o` (§1) |
| **PMPI weak-symbol aliasing in `libmpi.so.40`** | **Confirmed present** — `MPI_Send`/`PMPI_Send` and 6 other common calls (`Isend`, `Irecv`, `Wait`, `Waitall`, `Allreduce`, `Bcast`, `Barrier`) all show `W MPI_*` aliasing `T PMPI_*` at identical addresses | `nm -D`, run live this session — see §11 discussion above; this is the load-bearing fact that makes LD_PRELOAD viable at all |
| `bfd.h` (symbol resolution) | Present, `/usr/include/bfd.h`; package `binutils-devel-2.30-128.el8_10.x86_64` confirmed installed | `find`, `rpm -q`, run live |
| `libbfd` (linkable) | Present, bare linkable name `/usr/lib64/libbfd.so` (not just a versioned `.so`) | `find -iname libbfd.so*` |
| `libunwind` (stack unwinding, optional) | **Runtime library present** (`libunwind-1.3.1-3.el8.x86_64`), **headers absent** (`libunwind-devel` confirmed not installed) | `rpm -q libunwind-devel` -> "not installed"; `find /usr/include -iname libunwind.h` -> no match |
| `autoconf`/`automake`/`libtool`/`make` | All present in `PATH` | `command -v`, run live |
| Outbound internet, login node | Confirmed (`github.com` HTTP 200, no proxy needed) | `curl`, run live |
| Outbound internet, compute node | **Not checked and not assumed** — this project's repeated lesson (Cray MPICH, Forge) is that login-node facts do not transfer to compute nodes. The build design below avoids ever needing compute-node internet, sidestepping the question entirely rather than testing it. | design choice, §15 |

**Consequence:** mpiP will be built **without libunwind support** (headers
absent), using its fallback stack-walking mode (glibc `backtrace()`), **with**
`libbfd` symbol resolution (both pieces present). This is a standard,
supported mpiP configuration, not a degraded one — it trades slightly less
robust stack unwinding through heavily inlined/optimised frames for zero
added dependency risk. If call-site resolution from this configuration turns
out to be too coarse once real output is seen, building `libunwind-devel`
from source is a possible follow-up, not attempted now.

## 15. Two-phase plan: fetch (login node) then build (compute node)

The compute-node build never touches the network. This is deliberate: it
removes the untested "does the compute node have internet" variable from the
critical path entirely, rather than probing it.

### Phase 1 — fetch and verify (login node only, no PBS job, no SU)

```sh
mkdir -p ~/scratch/tools
cd ~/scratch/tools
curl -sSL -o mpip-3.5.tgz \
  "https://github.com/llnl/mpiP/releases/download/3.5/mpip-3.5.tgz"
sha256sum mpip-3.5.tgz | tee mpip-3.5.tgz.sha256
wc -c mpip-3.5.tgz   # expect 336942
tar tzf mpip-3.5.tgz | head -20   # inspect archive contents before extracting
tar xzf mpip-3.5.tgz
```

`~/scratch/tools/` is a **new** directory, entirely separate from
`~/scratch/openfoam-v2512/` — zero chance of colliding with the OpenFOAM
build tree, the shared `run_occdrivaer.sh`, or the teammate's in-flight PGO
build. The SHA-256 is recorded for provenance and so a future re-fetch can be
verified against it.

**This phase is not executed yet.** It requires the explicit download
approval noted in §13.

### 16. New file: `scripts/build_mpip_1n_v1.pbs` (compute-node build, NOT SUBMITTED)

```bash
#!/bin/bash
#PBS -N build_mpip
#PBS -P 59000020
#PBS -q normal
#PBS -l select=1:ncpus=4:mem=8gb
#PBS -l walltime=00:20:00
#PBS -o outputs/build_mpip_1n_v1.o
#PBS -e outputs/build_mpip_1n_v1.e

# Builds mpiP 3.5 from the already-fetched, already-verified source at
# ~/scratch/tools/mpiP-3.5 (Phase 1, login node, separate approval).
# Installs to ~/scratch/tools/mpiP-install (new, isolated prefix).
#
# Does NOT touch ~/scratch/openfoam-v2512/ at all: no OpenFOAM module is
# loaded, no simpleFoam binary is read or written, no shared script is
# referenced. This is a standalone, independent build of a small diagnostic
# library. Deliberately does not use the compute node's network: the source
# was fetched once, on the login node, in Phase 1.

set -eo pipefail
cd "$PBS_O_WORKDIR"
mkdir -p outputs

SRC=~/scratch/tools/mpiP-3.5
PREFIX=~/scratch/tools/mpiP-install
if [[ ! -d "${SRC}" ]]; then
    echo "REFUSING: ${SRC} does not exist. Run Phase 1 (login-node fetch) first." >&2
    exit 1
fi
if [[ -d "${PREFIX}" ]]; then
    echo "REFUSING: ${PREFIX} already exists. Not overwriting a prior build attempt." >&2
    echo "Remove it explicitly first if a clean rebuild is wanted." >&2
    exit 1
fi

module purge
module load gcc/11.2.0
module load openmpi/5.0.10-gcc11
echo "=== module list ==="
module list -t 2>&1
echo "=== mpicc resolution (must match the baseline's own libmpi.so.40) ==="
mpicc -show

cd "${SRC}"
echo "=== configure ==="
# No --with-libunwind: headers are confirmed absent (§14); mpiP falls back
# to backtrace()-based stack walking. --with-bfd points at the confirmed
# system binutils-devel install.
./configure \
    --prefix="${PREFIX}" \
    CC=mpicc \
    --with-bfd=/usr \
    2>&1 | tee "${PBS_O_WORKDIR}/outputs/build_mpip_1n_v1_configure.log"

echo "=== make (full log preserved, not tailed) ==="
make 2>&1 | tee "${PBS_O_WORKDIR}/outputs/build_mpip_1n_v1_make.log"

echo "=== make install ==="
make install 2>&1 | tee "${PBS_O_WORKDIR}/outputs/build_mpip_1n_v1_install.log"

echo "=== what actually got produced (do not assume static vs shared) ==="
find "${PREFIX}" -iname "libmpiP*" -exec ls -la {} \;
echo
echo "=== library type check ==="
for f in "${PREFIX}"/lib/libmpiP.*; do
    [[ -e "$f" ]] || continue
    echo "-- $f"
    file "$f"
done

if [[ -f "${PREFIX}/lib/libmpiP.so" ]]; then
    echo "BUILD_RESULT=SHARED_LIB_PRODUCED — LD_PRELOAD usage plan (Sec. 17) applies directly."
elif [[ -f "${PREFIX}/lib/libmpiP.a" ]]; then
    echo "BUILD_RESULT=STATIC_LIB_ONLY — LD_PRELOAD is not applicable to a static archive."
    echo "Using mpiP would then require adding '-L${PREFIX}/lib -lmpiP -lbfd' to"
    echo "simpleFoam's final link step -- a small, but real, change to the scored"
    echo "binary's link line, needing the same before/after identity bookkeeping"
    echo "already used for other build variants in this project, and separate"
    echo "explicit authorization before attempting."
else
    echo "BUILD_RESULT=NO_LIBRARY_PRODUCED — build did not succeed; see the full make log."
fi
echo "BUILD_MPIP_DONE"
```

### 16.1 File-safety checklist

| Constraint | How satisfied |
| --- | --- |
| New standalone filename | `scripts/build_mpip_1n_v1.pbs` — new, no collision |
| Does not touch `run_occdrivaer.sh` or the OpenFOAM tree | Never loads an OpenFOAM/AOCC module, never reads/writes anything under `~/scratch/openfoam-v2512/` |
| No `Allwmake`, no `Pstream` build, no Intel MPI | None present |
| Unique output/install paths, no overwrite | `~/scratch/tools/mpiP-install` — refuses to run if it already exists; `outputs/build_mpip_1n_v1.{o,e}` plus three separMPI-named `.log` files, none colliding with any existing path |
| No remote file modified yet, no PBS submitted | Local file only in this session |

## 17. Planned usage once (if) the build succeeds — LD_PRELOAD, baseline binary untouched

Contingent on `BUILD_RESULT=SHARED_LIB_PRODUCED`. This is the payoff of the
whole approach: **the scored `simpleFoam` binary (hash
`7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f`) is never
touched.** Profiling would be invoked as:

```sh
export LD_PRELOAD=~/scratch/tools/mpiP-install/lib/libmpiP.so
export MPIP="-t 10.0 -k 2"   # mpiP's own runtime options: report top costs, capture 2 stack levels
mpirun --hostfile "$PBS_NODEFILE" -np <N> --bind-to core --map-by ppr:128:node:PE=1 \
    -x LD_PRELOAD -x MPIP \
    simpleFoam -parallel
```

exactly the same launcher and binding flags as the accepted baseline (§1),
with `LD_PRELOAD`/`MPIP` added to the exported-variable list already present
in the harness's own `XENV` construction. mpiP writes one text report
(`*.mpiP`) per job at MPI_Finalize, aggregating per-callsite MPI time across
all ranks plus per-rank breakdowns — this is planned, not executed, and
would itself need the same 1-node-then-4-node, binary-hash-gated, unique-
output-name discipline as every other probe in this project before any
150-step or 4-node run is considered.

## 18. Updated candidate-table entry (mpiP), given this session's new evidence

The §3 table entry for mpiP already correctly showed "LD_PRELOAD: yes,
relink needed: no." This addendum adds what was not yet known when that table
was written:

- **PMPI weak-aliasing confirmed present** in the exact target `libmpi.so.40`
  (§14) — the single fact that determines whether LD_PRELOAD can work at all
  here. This was previously an assumption implicit in listing mpiP as a
  PMPI/LD_PRELOAD tool; it is now a checked fact specific to this system.
- **Exact, verified source location and size** (§13), replacing "not
  installed, would need to be built" with a concrete, checked plan.
- **Compute-node internet dependency eliminated by design** (§15) rather
  than left as an untested risk like the Forge/Cray-MPICH cases.
- **New, still-open risk:** whether mpiP 3.5's build actually emits a shared
  `.so` (needed for LD_PRELOAD) or only a static `.a` (which would require a
  small link-line change to `simpleFoam`, reopening the "binary differs from
  baseline" question, just far less invasively than a full CrayPat relink).
  This is not assumed either way; the build script's own output (§16) is
  designed to determine it and state the consequence explicitly rather than
  proceed on a guess.

## 19. Stop point (addendum)

Nothing beyond read-only checks has been executed. Two explicit approvals are
needed before any remote state changes, and they are **separable** — the
user may approve one without the other:

1. **Phase 1 (§15):** download `mpip-3.5.tgz` (336,942 bytes) from
   `https://github.com/llnl/mpiP/releases/download/3.5/mpip-3.5.tgz` to
   `~/scratch/tools/` on the ASPIRE2A login node, and extract it. No SU cost,
   no PBS job.
2. **Phase 2 (§16):** submit `scripts/build_mpip_1n_v1.pbs` (1 node, 4 cpus,
   20 min requested walltime) to build it. Small SU cost. Requires Phase 1 to
   have completed first (the script itself checks and refuses otherwise).

Neither has been done. Waiting for explicit approval before either.

### 15.1 Phase 1 outcome — executed, verified

Executed on the ASPIRE2A login node this session, with explicit user approval
for this step only (Phase 2 not yet approved).

```text
curl -sSL -o mpip-3.5.tgz "https://github.com/llnl/mpiP/releases/download/3.5/mpip-3.5.tgz"
wc -c mpip-3.5.tgz            -> 336942 (matches the pre-download HEAD check exactly)
sha256sum mpip-3.5.tgz        -> e366843d53fa016fb03903e51c8aac901aa5155edabe64698a8d6fa618a03bbd
tar tzf mpip-3.5.tgz | head   -> standard mpiP-3.5/ autotools tree, inspected before extraction
tar xzf mpip-3.5.tgz
```

Result: `~/scratch/tools/mpip-3.5.tgz`, `~/scratch/tools/mpip-3.5.tgz.sha256`,
and the extracted `~/scratch/tools/mpiP-3.5/` tree (top-level contents match
a standard mpiP 3.5 source distribution: `configure`, `configure.ac`,
`mpiP-API.c`, `mpiPi.c`, etc.). This matches the `SRC` path already assumed
by `scripts/build_mpip_1n_v1.pbs` (§16) exactly, so no path adjustment is
needed before Phase 2 can run.

**Phase 2 (the compute-node build job) has not been submitted** — it
requires a separate explicit approval per §19.

### 16.2 Phase 2 outcome — three attempts, root causes diagnosed, v3 succeeded

All three attempts preserved as separate evidence (`v1`/`v2`/`v3`, no
overwrite). Each failure was fully diagnosed from its own logs before the
next attempt, not guessed.

| Attempt | Job | Exit | Outcome |
| --- | --- | --- | --- |
| v1 | `24026650.pbs101` | 1 | `configure: error: Python is required to build mpiP.` — the source's `make-wrappers.py` needs a bare `python`; only `python3` was on `PATH`. Also used a wrong flag name, `--with-bfd` (harmless "unrecognized option" warning, not the actual failure). |
| v2 | `24028140.pbs101` | 77 (autoconf's standard "compiler cannot link" code) | `module load python/3.11.7-gcc11` fixed the Python check, but its own dependency chain silently swapped `PATH` from `gcc/11.2.0` to `gcc/11.4.0-nscc` (a `module` conflict/prereq, not something this session requested). The *actual* root cause, found in `config.log`'s real linker output, was unrelated to gcc at all: `libmpi.so`'s `DT_NEEDED` on `libfabric.so.1` was unresolved, because the mpiP build never set the `LD_LIBRARY_PATH` every other AOCC/Open MPI job script in this project already sets for the team's own scratch `libfabric` build. |
| **v3** | **`24029346.pbs101`** | **0** | **Success.** Added the same `LD_LIBRARY_PATH` (`~/scratch/openfoam-v2512/ext/libfabric/lib`) every existing job script uses; corrected `--with-binutils-dir=/usr` (the real flag name); kept `--disable-libunwind`. A defensive `module load gcc/11.2.0` reload was also added but was rejected by the module system's own hard conflict rule (`ERROR:150: Module 'gcc/11.2.0' conflicts with... 'gcc/11.4.0-nscc'`) — harmless, since `mpicc` uses its own hardcoded absolute compiler path regardless of `PATH`, confirmed by `mpicc -show` throughout. |

**Result:** `~/scratch/tools/mpiP-install/lib/libmpiP.so`, 914,816 bytes,
"ELF 64-bit LSB shared object... dynamically linked, with debug_info, not
stripped". `BUILD_RESULT=SHARED_LIB_PRODUCED` — the best-case outcome
identified in §16: LD_PRELOAD is directly usable, `simpleFoam` remains
byte-identical to the recorded baseline hash, no relink of anything in the
scored path is needed.

**Post-build verification, this session:**

- `nm -D libmpiP.so`: `MPI_Send`, `MPI_Isend`, `MPI_Allreduce`,
  `MPI_Waitall`, `MPI_Init`, `MPI_Finalize` all confirmed **`T` (strong)**,
  matching the weak/strong pairing already confirmed in `libmpi.so.40` (§14)
  — LD_PRELOAD interposition will engage correctly.
- `ldd libmpiP.so`: resolves `libmpi.so.40` to the exact same
  `/app/apps/openmpi/5.0.10-gcc11/lib/libmpi.so.40` as the baseline.
  **Caveat:** this `ldd` was run on the login node without the job's own
  `LD_LIBRARY_PATH` override active, and in that environment `libfabric.so.1`
  resolved to the system/Cray copy (`/opt/cray/libfabric/1.22.0/lib64/`)
  rather than the team's scratch build the baseline actually uses. Any future
  profiled run must export the same `LD_LIBRARY_PATH` every existing
  AOCC/Open MPI job script uses, to guarantee identical `libfabric` linkage
  to the baseline, not just identical `libmpi`.

**Known limitation, not fixed in v3:** `checking bfd.h usability... no` /
`checking bfd.h presence... no` despite `bfd.h` existing on disk and
`--with-binutils-dir=/usr` being passed — the configure-time compile+link
test against `bfd.h`/`libbfd` failed for a reason not yet diagnosed (a
plausible cause is a missing `-liberty`/`libiberty` dependency that `libbfd`
itself often requires, or a `bfd.h` macro-ordering requirement specific to
this binutils version — not confirmed). Configuration summary:
`Address to Source Lookup: none`. **Consequence:** mpiP's reports will show
raw return addresses rather than resolved function names/source lines for
MPI call sites. This does **not** block the primary hypotheses (H1, H3, H5,
H7 in §9.1 all depend on aggregate and per-rank MPI-time data, not symbol
resolution); it only weakens the "top MPI call sites" richness under H2. Not
pursued as a v4 fix without a separate decision, since it is not blocking.

### 16.3 Updated stop point

The mpiP build itself is complete and verified. **Using it — even a 1-node
LD_PRELOAD sanity check against a trivial MPI program, let alone against
`simpleFoam` — has not been done and is not authorized by anything in this
addendum.** That is the natural next step and needs its own explicit
decision, following the same gated, evidence-first pattern used throughout
this session.

### 20. LD_PRELOAD sanity check — succeeded (verdict corrected from the probe script's own false-negative gate)

Two attempts, both preserved:

| Attempt | Job | Exit | Outcome |
| --- | --- | --- | --- |
| v1 | `24049669.pbs101` | 0 (wrapper), but `STEP_B_FAILED` internally | The compiled `1-hot-potato` control run itself failed with a standard PRRTE "not enough slots" error, because the PBS resource request `select=1:ncpus=8:mem=16gb` omitted `mpiprocs=8` — a plain PBS-spec bug in this probe script, unrelated to mpiP, MPI, or the baseline. Every other working script in this project includes `mpiprocs=`; this one did not. |
| **v2** | **`24050747.pbs101`** | **0**, and genuinely **all three steps succeeded** | Fixed by adding `mpiprocs=8`. |

**v2 evidence, read in full (not tailed):**

- STEP A (compile mpiP's own `testing/1-hot-potato.c`, a real ring
  `MPI_Send`/`MPI_Recv` exchange): OK.
- STEP B (control run, no `LD_PRELOAD`): all 8 ranks completed the ring
  exchange correctly and printed `Finished normally`.
- STEP C (`LD_PRELOAD=libmpiP.so`, `MPIP="-k 2"`): all 8 ranks again
  completed correctly, output identical in substance to the control, **plus**
  mpiP's own startup/shutdown banners appeared
  (`mpiP: mpiP V3.5.0 (Build Sep 19 2026/21:29:34)`,
  `mpiP: Storing mpiP output in [./1-hot-potato.8.347155.1.mpiP]`) —
  these only print if mpiP's own wrapped `MPI_Init`/`MPI_Finalize` actually
  executed, directly confirming interposition engaged.

**A real, complete mpiP report was produced** (quoted in full in this
session's transcript; preserved at
`outputs/probe_mpip_ldpreload_1n_v2_24050747/1-hot-potato.8.347155.1.mpiP` on
ASPIRE2A), containing:

- A per-task `AppTime` / `MPITime` / `MPI%` table (task `*` aggregate:
  70.99% MPI time for this artificial ring-exchange test — not a baseline
  number, just proof the mechanism computes and reports this exact
  quantity, which is precisely what H1 needs against the real baseline).
- 16 correctly-identified callsites (8 ranks x `Send` + `Recv`), each with
  real per-rank timing (`Callsite Time statistics`) and per-rank message-size
  data (`Callsite Message Sent statistics`, correctly showing 4 bytes per
  `MPI_Send` of a single `float`).

**Correction to this probe's own design:** the script's final validation
gate searched the report text for the literal strings `MPI_Send`/`MPI_Recv`
and reported `STEP_C_FAILED` when it found none — this is a bug in the
probe's own grep pattern, not a real failure. mpiP's report format lists
call types with the `MPI_` prefix stripped (`Send`, `Recv` in the `Call` /
`MPI_Call` columns), which the script did not account for. **Manually
reviewing the full, preserved report output shows the interception,
correctness, and content were all genuinely successful.** This is recorded
here as the correct verdict, superseding the probe's own printed
`PROBE_RESULT=STEP_C_FAILED` line.

### 21. Updated status: mpiP is a verified-working profiler for this baseline

- Built from source (§16.2), linked against the exact baseline `libmpi.so.40`.
- `simpleFoam` remains byte-identical to `7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f`
  throughout — nothing in the scored path was touched.
- LD_PRELOAD interception independently confirmed against mpiP's own
  official point-to-point test, with a full, readable report produced,
  showing exactly the per-rank MPI-time-fraction and per-callsite timing
  data needed for H1, H3, and (via Send/Recv separation) part of H2.
- **Not yet done, and not authorized by anything above:** running mpiP
  against `simpleFoam` itself, at 1 node or 4 nodes. That is the natural next
  step and needs its own explicit decision, following §9's design (baseline
  binary hash gate, partition/input identity checks, profiler-overhead
  measurement against a contemporaneous unprofiled control, etc.) adapted to
  use `LD_PRELOAD=libmpiP.so` in place of the still-unresolved Forge/`perf`
  routes.

### 22. Two free follow-ups, done while the 1-node simpleFoam probe was running

Both read-only, zero SU, performed on the ASPIRE2A login node while job
`24450837.pbs101` (§20's next step, 1-node real `simpleFoam` under mpiP) was
still queued/running.

**P6 (bfd.h detection failure, §16.2) — root cause found.** The v3 build's
own `config.log` (from job `24029346.pbs101`, which ran on compute node
`x1001c5s5b1n1`) shows the actual compiler invocation and error:

```text
configure:5252: mpicc -c -g -O2  -I/usr/include conftest.c >&5
conftest.c:59:10: fatal error: bfd.h: No such file or directory
```

`-I/usr/include` is present and correct, yet the file is reported missing —
despite `/usr/include/bfd.h` (263,351 bytes, from `binutils-devel-2.30-128.el8_10.x86_64`)
being confirmed present **on the login node**. `df -T /usr/include` on the
login node reports filesystem type **`overlay`** — a per-node container-style
image, not a shared network filesystem. **This is the same "login-node
software visibility does not prove compute-node reality" pattern this
project has hit twice before** (Cray MPICH/libfabric, Linaro Forge's sampling
thread): `binutils-devel` most likely is not installed in the compute node's
own local OS image, even though it is on the login node's. This was
diagnosed entirely from the already-completed v3 build's own retained log —
no new job was needed to reach this conclusion. Not pursued further (no v4
build attempted) without a separate decision; it remains a non-blocking gap
per §16.2 (only degrades call-site symbol resolution, not the core per-rank/
per-call-type timing data already confirmed working in §20).

**P7 (MPI_T PVARs) — investigated, inconclusive from read-only tools alone.**
`ompi_info --help` has no dedicated MPI_T/PVAR/CVAR listing mode, and
`ompi_info --param all all --level 9` (searched broadly) shows zero matches
for `MPI_T`. This is expected, not a negative result about MPI_T itself:
`ompi_info` reflects **MCA parameters** (build/runtime tunables), a related
but distinct concept from MPI_T **performance variables**, which are only
enumerable by calling `MPI_T_init_thread()` / `MPI_T_pvar_get_num()` from a
running program. Determining whether this Open MPI 5.0.10 build actually
exposes useful PML/collective PVARs would require compiling and running a
small dedicated harness — a new build+run step, out of scope for read-only
"free" work and not pursued without its own decision. **Status: still open,
not ruled out, not confirmed.**

### 23. 4-node profiled-baseline design, prepared as a local diff (NOT SUBMITTED)

Prepared while waiting on §20's 1-node result, so it is ready for review
immediately once that result is in, rather than designed from scratch
afterward. This adapts §9's design (originally written for Forge/`perf`) to
use the now-verified `LD_PRELOAD=libmpiP.so` mechanism instead.

```bash
#!/bin/bash
#PBS -N probe_mpipof4
#PBS -P 59000020
#PBS -q normal
#PBS -l select=4:ncpus=128:mpiprocs=128:mem=400gb
#PBS -l place=scatter
#PBS -l walltime=01:00:00
#PBS -o outputs/probe_mpip_simplefoam_4n_v1.o
#PBS -e outputs/probe_mpip_simplefoam_4n_v1.e

# Profile the ACCEPTED baseline (AOCC 5.0 / Open MPI 5.0.10 / KaHIP /
# 4x128=512 / bound --bind-to core --map-by ppr:128:node:PE=1 / stock Opt,
# job 20092999, 2.869256832046979 s/step) with mpiP via LD_PRELOAD.
# NOT SUBMITTED -- contingent on the 1-node result (probe_mpip_simplefoam_1n_v1)
# succeeding first, per this project's established one-node-before-four-node
# discipline.
#
# Unlike the 1-node probe, this run performs a FRESH decomposePar (KaHIP
# config=fast/imbalance=0.01 was independently confirmed deterministic for
# this exact mesh/rank-count across 2 prior invocations -- Sec 1.2 -- but
# each new profiled run still re-verifies its own partition rather than
# assuming it, per that same section's caution). Screening window: 40 steps,
# not the full 150, per Sec 9's methodology; steps 20-40 as the stabilized
# comparison window, with a contemporaneous unprofiled control run in the
# SAME allocation (A-B structure) to measure profiler overhead directly
# rather than assume it negligible.

set -eo pipefail
cd "$PBS_O_WORKDIR"
mkdir -p outputs
PROBE_DIR="${PBS_O_WORKDIR}/outputs/probe_mpip_simplefoam_4n_v1_${PBS_JOBID%%.*}"
mkdir -p "${PROBE_DIR}"

module purge
module load aocc/5.0
module load gcc/11.2.0
module load openmpi/5.0.10-gcc11
export PATH="/app/apps/aocc/5.0/bin:${PATH}"
export OMPI_CC=clang OMPI_CXX=clang++ OMPI_FC=flang

FABRIC_LIB="${HOME}/scratch/openfoam-v2512/ext/libfabric/lib/libfabric.so.1"
[[ -e "${FABRIC_LIB}" ]] || { echo "Missing scratch libfabric" >&2; exit 1; }
export FOAM_EXTRA_LD_LIBRARY_PATH="$(dirname "${FABRIC_LIB}")"
export LD_LIBRARY_PATH="${FOAM_EXTRA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"
export FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"

MPIP_LIB="${HOME}/scratch/tools/mpiP-install/lib/libmpiP.so"
[[ -e "${MPIP_LIB}" ]] || { echo "Missing libmpiP.so" >&2; exit 1; }

# ---- baseline binary hash gate --------------------------------------------
EXPECT_SHA=7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f
ACTUAL_SHA="$(sha256sum "${FOAM_INST_DIR}/OpenFOAM-v2512/platforms/linux64AmdDPInt32Opt/bin/simpleFoam" | cut -d' ' -f1)"
[[ "${ACTUAL_SHA}" == "${EXPECT_SHA}" ]] || { echo "REFUSING: binary hash mismatch (${ACTUAL_SHA})" >&2; exit 1; }

cd "${FOAM_INST_DIR}/OpenFOAM-v2512"
set +eu
source etc/bashrc WM_COMPILER=Amd WM_MPLIB=SYSTEMOPENMPI WM_COMPILE_OPTION=Opt WM_LABEL_SIZE=32
set -eu
export LD_LIBRARY_PATH="${FOAM_EXTRA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"

NCORES=512
XENV="-x PATH -x LD_LIBRARY_PATH -x HOME"
while IFS= read -r v; do XENV="${XENV} -x ${v}"; done < <(env | awk -F= '/^(WM_|FOAM_|LLVM_|GCOV_)/ {print $1}' | sort -u)
PAR="mpirun --hostfile ${PBS_NODEFILE} -np ${NCORES} ${XENV} --bind-to core --map-by ppr:128:node:PE=1"

run_arm () {   # $1=label $2=extra mpirun -x flags $3=env prefix (e.g. "LD_PRELOAD=...")
    local label="$1" xflags="$2"
    local CASE="${PROBE_DIR}/case-${label}"
    rm -rf "${CASE}"; mkdir -p "${CASE}"
    TEMPLATE="${FOAM_INST_DIR}/cases/occDrivAerStaticMesh-template"
    cp -a "$(readlink -f "${TEMPLATE}")/." "${CASE}/"
    rm -rf "${CASE}"/processor*
    cd "${CASE}"
    foamDictionary -entry nCores -set 512 system/include/caseDefinition
    foamDictionary -entry decompositionMethod -set kahip system/include/caseDefinition
    foamDictionary -entry endTime -set 40 system/controlDict.noWrite
    cp system/controlDict.noWrite system/controlDict
    cp system/fvSolution.fixedIter system/fvSolution
    mkdir -p logFiles
    time decomposePar -constant > logFiles/10_decomposePar.log 2>&1
    sha256sum logFiles/10_decomposePar.log
    restore0Dir -processor
    time ${PAR} renumberMesh -constant -overwrite -parallel > logFiles/20_renumberMesh.log 2>&1
    time ${PAR} potentialFoam -initialiseUBCs -parallel > logFiles/30_potentialFoam.log 2>&1
    time ${PAR} applyBoundaryLayer -ybl 0.0450244 -parallel > logFiles/40_applyBoundaryLayer.log 2>&1
    SFLOG="logFiles/50_simpleFoam.${label}.log"
    STAMPS="${PROBE_DIR}/${label}.stepstamps.txt"
    T0=$(python3 -c 'import time;print(repr(time.monotonic()))')
    eval "${3:-}" stdbuf -oL ${PAR} ${xflags} simpleFoam -parallel 2>&1 \
        | stdbuf -oL tee "${SFLOG}" \
        | python3 -u -c 'import sys,time
for l in sys.stdin:
    if l.startswith("Time = "): sys.stdout.write("%.9f %s" % (time.monotonic(), l))' > "${STAMPS}"
    T1=$(python3 -c 'import time;print(repr(time.monotonic()))')
    grep -q '^End' "${SFLOG}" || { echo "REFUSING: ${label} has no End marker" >&2; exit 1; }
    grep -Eiq 'nan' "${SFLOG}" && { echo "REFUSING: NaN in ${label}" >&2; exit 1; }
    python3 - "${STAMPS}" "${label}" <<'PY'
import sys
stamps, label = sys.argv[1], sys.argv[2]
ts={}
for l in open(stamps):
    a,b=l.split(None,1); ts[int(b.split('=')[1])]=float(a)
steps=sorted(ts)
win=[ts[s]-ts[s-1] for s in steps if 20<=s<=40 and (s-1) in ts]
print(f"{label}: window(20-40) mean s/step = {sum(win)/len(win):.6f}  n={len(win)}")
PY
    cd "${PBS_O_WORKDIR}"
}

echo "=== ARM A: unprofiled control ==="
run_arm "ctrlA" "" ""
echo "=== ARM B: mpiP LD_PRELOAD ==="
run_arm "mpipB" "-x LD_PRELOAD -x MPIP" "LD_PRELOAD=${MPIP_LIB} MPIP=-k\ 3"
echo "=== ARM C: mpiP LD_PRELOAD (repeat) ==="
run_arm "mpipC" "-x LD_PRELOAD -x MPIP" "LD_PRELOAD=${MPIP_LIB} MPIP=-k\ 3"
echo "=== ARM D: unprofiled control (repeat, A-B-B-A structure) ==="
run_arm "ctrlD" "" ""

echo "=== mpiP reports ==="
find "${PROBE_DIR}" -iname "*.mpiP" -exec echo {} \; -exec cat {} \;
```

**Not yet reviewed line-by-line against the same rigor as the submitted
scripts** (e.g. the `eval "${3:-}" ...` env-prefix construction for
LD_PRELOAD needs verification it correctly propagates through `stdbuf`/`tee`/
the python timestamper without shell-quoting surprises; the partition-hash
capture is present but not yet cross-checked against Sec 1.2's determinism
finding for THIS run specifically). **Presented here as prepared groundwork
only** — it must be re-reviewed, and the 1-node result must succeed, before
any approval decision.

### 24. First real simpleFoam profile — job 24450837.pbs101, 1 node / 128 ranks / 10 steps

Success. Both arms reached `End`, no `NaN`, both completed 10 real steps.
Reused the pristine 1-node KaHIP case per §16 of the original probe design
(no `decomposePar`/`renumberMesh`/`potentialFoam`/`applyBoundaryLayer`
needed — `processor*/0/` independently confirmed still genuine t=0, per
§1.1's `writeInterval=100000` finding). Binary hash confirmed
`7846a125...` before running.

**Finding: OpenFOAM's own `Average wall-clock time per time step` line does
not print for short runs.** Neither the control nor the LD_PRELOAD log
contains it at all (`grep` confirmed zero matches in both). Root cause,
found by comparing against a retained 40-step reference log
(`50_simpleFoam.2026-09-13_05-14-56.log`): this line is the output of
OpenFOAM's `wallClockTimeStatistics` function object, printed **once, at
the very end**, alongside `Number of measured time steps = 39` and a
standard-deviation/confidence-interval report — not a per-step running
average. A 10-step screening window does not reach whatever the function
object's internal minimum is. **This reinforces, from direct evidence
rather than just the earlier methodological argument (Sec 10), why the
project's steps-20-40-delta approach is the right one for short screening
runs** — the built-in summary line simply is not available at screening
scale.

**Manual step-timing comparison** (mean `ExecutionTime` delta, steps 2-10,
since the built-in average was unavailable):

| Arm | Mean ExecutionTime delta (s/step) |
| --- | ---: |
| Control (no LD_PRELOAD) | 13.2211 |
| LD_PRELOAD (mpiP) | 13.4333 |
| **Profiler overhead** | **+1.61%** |

Low, consistent with mpiP being a lightweight PMPI-interposition wrapper
rather than a full tracer. This is a 1-node/10-step number, not a
prediction for the 4-node/512-rank scored configuration — overhead must be
re-measured there, per §9/§23's contemporaneous-control design, not assumed
to carry over.

**mpiP report** (`case-preload/simpleFoam.128.744952.1.mpiP`, 9.4 MB,
`-k 3` stack depth):

- Aggregate row across all 128 ranks: **`AppTime` 1.94e4 s, `MPITime` 2.77e3
  s, `MPI% = 14.28`** for this 10-step/1-node window. A real, tool-reported
  number bearing on H1 — not the scored baseline's number, but direct
  confirmation the instrument produces exactly this quantity against the
  real solver.
- **21,924 distinct callsites** resolved (vs. 16 in the earlier toy test) —
  proportionate to a real 128-rank OpenFOAM solve.
- **Callsite frequency by call type** (site count, not time-weighted —
  see caveat below):

  | Call | Sites |
  | --- | ---: |
  | `Allreduce` | 6,912 |
  | `Waitall` | 3,584 |
  | `Allgather` | 1,792 |
  | `Isend` | 1,664 |
  | `Irecv` | 1,664 |
  | `Bcast` | 1,536 |
  | `Test` | 896 |
  | `Send` | 254 |
  | `Recv` | 128 |

  `Allreduce` dominates by callsite count, consistent with GAMG's
  per-V-cycle residual/dot-product reductions — matching the expectation
  stated when this probe was designed. `Isend`/`Irecv` at matched counts
  (1,664 each) are consistent with non-blocking halo exchange, with
  `Waitall` completing them.
- **Caveat, stated plainly:** the report's own "Aggregate Time (top twenty)"
  table ranks individual **callsites** by their own total time, and every
  one of its top-20 entries happens to be `Bcast` (each ~6.33 ms, count 26).
  This does **not** mean `Bcast` dominates total MPI time overall — it
  means a handful of specific Bcast call sites are individually expensive
  relative to other *individual* sites, which is a different question from
  "which call type consumes the most aggregate time across all 21,924
  sites." Answering that properly requires summing the `Mean x Count`
  column across every site grouped by name, not just reading the top-20
  list — not completed in this session (the report is 9.4 MB; this was a
  1-node sanity check, not the analysis pass) and explicitly **not**
  claimed here. The `Aggregate Sent Message Size` table separately confirms
  substantial point-to-point traffic (`Isend`, top site: 183,600 messages,
  6.86e8 bytes total over the 10-step window) — real evidence for H7-style
  correlation work once the actual 4-node/512-rank partition is profiled.

### 25. Status: ready for the reviewed 4-node profile, pending its own approval

The 1-node real-`simpleFoam` gate (this project's established
one-node-before-four-node discipline) has passed. The §23 4-node script was
drafted as groundwork but explicitly flagged as **not yet re-reviewed at the
same rigor as submitted scripts**. Before that script can be proposed for
submission, it needs: (a) a careful re-check of the `LD_PRELOAD` env-prefix
propagation through `stdbuf`/`tee`/the python timestamper (this session's
1-node script used a simpler, already-proven `VAR=val ${PAR} -x VAR ...`
form directly, without stdbuf/tee/timestamping — the 4-node draft's added
complexity for the steps-20-40 window has not been tested at any scale yet
and should probably be simplified to match what is actually proven to work),
and (b) proper time-weighted call-type aggregation tooling prepared in
advance, so the 4-node run's much larger report doesn't hit the same
top-20-is-misleading trap this session just diagnosed.

### 26. The real 4-node profile — job 24490441.pbs101 (v3), success

Two prior attempts before this one, both preserved as evidence and both
diagnosed from first principles (no guessing):

| Attempt | Job | Exit | Outcome |
| --- | --- | --- | --- |
| v1 | `24457466.pbs101` | 1 | ARM A (control) succeeded and gave the first-ever 40-step reference (`Average wall-clock time per time step = 2.857141668897436`, within 0.42% of the scored 2.869256832046979). ARM B failed silently: `foamDictionary`, called immediately after ARM A's heavy 512-rank run finished, produced a 0-byte `controlDict.noWrite` (plausible transient filesystem contention), and `set -e` exited the script with zero diagnostic output. |
| v2 | (never submitted) | — | Fixed by adding post-`foamDictionary` verification + one retry with a fresh template copy, and clearing stale `logFiles/` inherited from the copied template. Upload itself then failed independently (`scp: write remote: Failure`) due to a **19 GB home-filesystem quota overflow** — v1's two full 512-processor case copies (`case-control` + `case-preload`) had been written under `PBS_O_WORKDIR` (the 50 GB home quota), not scratch (100 TB). Diagnosed via `myquota` (initially misleadingly stale at 249 MB, later correctly showing 52.00 G / 50.00 G) and a direct write-failure test. The 19 GB was deleted with explicit user approval; the fix (this section) relocates `PROBE_DIR` to `~/scratch/openfoam-v2512/cases/`. |
| **v3** | **`24490441.pbs101`** | **0**, both arms OK | Success. Walltime used: 17m22s of the 40m requested. |

**Both arms used job 20092999's own already-decomposed KaHIP partition**
(verified via the `10_decomposePar.log` sha256 printed at the top of the
job's own output: `d0f5eac5...`), not a freshly re-decomposed one — this is
the actual scored partition, not merely an equivalent one.

**Correctness.** Both arms reached `End`, no `NaN`, and — notably —
**identical Cd(40) in both arms: `0.28004`** (to displayed precision), also
matching the original 150-step run's Cd almost exactly, consistent with
this case's Cd converging early and remaining stable. `prep_case`'s new v2
verification printed `controlDict 21641 bytes, endTime=40 confirmed` for
both arms — the fix worked as designed.

**OpenFOAM's own built-in statistic, available this time (40 steps is
enough):**

| Arm | `Average wall-clock time per time step` |
| --- | ---: |
| Control (no LD_PRELOAD) | 2.855959348641025 |
| Reference: scored baseline (150 steps, job 20092999) | 2.869256832046979 |

0.46% apart — the same small, expected direction of difference already
characterised in earlier revisions (per-step cost drifts slightly upward
over a longer run). This *is* effectively a second, independent measurement
of the accepted baseline configuration, and it lands within noise of the
original.

**Manual step-time comparison (mean `ExecutionTime` delta, steps 2-40):**

| Arm | s/step |
| --- | ---: |
| Control | 2.8277 |
| LD_PRELOAD (mpiP) | 3.1244 |
| **Profiler overhead** | **+10.49%** |

**This is a materially different overhead than the 1-node test's +1.61%.**
mpiP's own instrumentation cost does not stay flat as rank count grows from
128 to 512 — plausibly the single-collector-rank gather-and-write step at
`MPI_Finalize` (the report header shows `Collector Rank: 0`, one rank
gathering everyone's statistics) and/or the callsite-tracking bookkeeping
itself scale worse than linearly with rank count. **Consequence: the
`26.64%` MPI-time figure below must not be read as "eliminating all MPI
communication would save 26.64% of wall time"** — it is measured on a run
that is itself ~10.5% slower than the clean baseline due to the measuring
tool. It is valid evidence for the *proportional breakdown* and for
*relative* comparisons (which call types dominate, which ranks are
outliers), not for an absolute wall-clock saving estimate.

**mpiP report** (`case-preload/simpleFoam.512.3360713.1.mpiP`, 37.45 MB,
`-k 3`):

- Aggregate row across all 512 ranks: **`AppTime` 7.07e4 s, `MPITime`
  1.88e4 s, `MPI% = 26.64`** for this 40-step/4-node/512-rank window.
  Materially higher than the 1-node test's 14.28% — expected, since 1-node
  communication is entirely intra-node (shared memory, fast), while 4-node
  communication is partly inter-node (crosses the network, slower) for the
  fraction of KaHIP's partition boundary that lands between nodes.
- **Call-type frequency (site count)**, and its relationship to the 1-node
  test's numbers:

  | Call | 4-node sites | 1-node sites | Ratio |
  | --- | ---: | ---: | ---: |
  | `Allreduce` | 27,648 | 6,912 | 4.00x |
  | `Waitall` | 14,336 | 3,584 | 4.00x |
  | `Allgather` | 7,168 | 1,792 | 4.00x |
  | `Isend` | 6,656 | 1,664 | 4.00x |
  | `Irecv` | 6,656 | 1,664 | 4.00x |
  | `Bcast` | 5,632 | 1,536 | 3.67x |
  | `Test` | 3,584 | 896 | 4.00x |
  | `Send` | 1,022 | 254 | 4.02x |

  Most call types scale almost exactly 4x with the rank count (512/128=4),
  as expected since the same OpenFOAM source code runs regardless of scale;
  `Bcast`'s slightly sub-4x ratio is noted but not explained further here.
  `Allreduce` again dominates by a wide margin, consistent with GAMG's
  per-V-cycle global reductions — the same pattern held at both 1-node and
  4-node scale, now confirmed on the actual scored configuration.
- Full call-type-weighted-by-time aggregation (as opposed to site count)
  was not performed in this session, for the same reason noted at 1-node
  scale (the report is large — 37 MB here — and this remains future
  analysis work, not completed ad hoc).

### 27. Status

The accepted 4-node baseline has now been profiled successfully, on its own
actual partition, with correctness confirmed (Cd, `End`, no `NaN`) and a
credible, tool-reported MPI-time fraction (26.64%, with an explicitly
quantified +10.49% measurement overhead caveat). This directly answers H1
(MPI is a non-trivial, double-digit fraction of the baseline) and gives
strong site-count evidence toward H2 (Allreduce-type collectives dominate
by call frequency, though not yet confirmed by time-weighted aggregation).
H3 (outlier ranks) and H7 (correlation with KaHIP partition topology) are
answerable from the existing per-rank/per-callsite data in this report but
were not analysed further in this session.

### 28. scotch profile — job 24600615.pbs101, success, first cross-decomposition comparison

Same proven v3 methodology, `TEMPLATE` pointed at
`occdrivaer-occdrivaer_4node_aocc_scotch_v1` instead of the KaHIP case.
Walltime used: 24m35s of 40m requested. Both arms `ARM_A_OK`/`ARM_B_OK`,
`prep_case` verification passed for both, no `NaN`.

**Correctness.** Cd(40) identical between arms: `0.28405` — matches the
archived scotch Cd from the original partition-topology table (§19 of the
other report) to 5 decimal places.

**Timing:**

| | KaHIP (§26) | scotch |
| --- | ---: | ---: |
| Control `Average wall-clock time per time step` | 2.855959 | 2.899848 |
| Manual control mean, steps 2-40 | 2.8277 | 2.8744 |
| Manual LD_PRELOAD mean, steps 2-40 | 3.1244 | 3.3390 |
| **Profiler overhead** | **+10.49%** | **+16.16%** |

**mpiP's own measurement overhead is not a fixed percentage** — it was
higher for scotch than for KaHIP. A plausible driver is scotch's higher
inter-node communication volume itself increasing the cost of mpiP's own
per-call interception, but this is not confirmed here. **Consequence,
stated again because it matters every time:** overhead numbers from one
configuration must not be assumed to transfer to another; each profiled
arm needs its own contemporaneous control, which both these runs correctly
have.

**The MPI-time comparison this section exists for:**

| | KaHIP | scotch | Ratio |
| --- | ---: | ---: | ---: |
| Aggregate MPI% (mpiP, this session's measurement) | 26.64% | **29.80%** | 1.12x |
| Inter-node face fraction (partition topology, § earlier report) | 7.66% | 11.52% | 1.50x |

**The direction matches the partition-topology prediction: scotch, with a
higher inter-node face fraction, shows a higher measured MPI-time
percentage than KaHIP.** The magnitude of the increase is smaller
proportionally (+12% relative in measured MPI time vs +50% relative in
inter-node face fraction) — expected, since MPI time reflects the full
communication picture (intra-node included, which is cheap and identical in
relative structure) not just the inter-node fraction alone, and since
`Allreduce`/`Waitall`/collective costs are not purely determined by the
inter-node edge count. This is the first actual *measured* (not just
geometrically inferred) evidence in this project that decomposition quality
causally affects MPI time in the predicted direction.

**Call-type frequency (site count): identical to KaHIP's**, both 27,648
`Allreduce`, 14,336 `Waitall`, etc. This is expected and itself an
informative negative result: call-site counts are a property of the
**solver's own code structure** (same `fvSolution`, same iteration caps,
same 512 ranks, same 40 steps) — they do not change with the partition
shape. What differs between KaHIP and scotch is the **cost per call**, not
the **number of calls**, consistent with the same underlying algorithm
running on a differently-shaped communication graph.

### 29. Status

Two of three planned decomposition profiles are done (KaHIP, scotch).
Hierarchical `(8 8 8)` was deliberately deferred at the user's request in
favour of first checking whether the teammate had tried alternative `(x y
z)` ratios at 512-rank scale — confirmed this session: **no**, every
4-node hierarchical run in the shared experiment tree still uses only
`(8 8 8)`, and no hierarchical-related script has been touched since
2026-09-15. The earlier finding that `(8 8 8)` routes the most expensive
cutting axis (z) through every node boundary (fast-performance-screening
Sec 17.4) remains untested against any alternative ratio, by either this
project's own agents or the teammate, at the scale that matters.

### 30. hierarchical (16 4 2) profile — job 24722196.pbs101, success — a clean control experiment

1-node, 128 ranks, official 40-step window (not a 10-step sanity check).
Reuses the archived `occdrivaer_1node_aocc_hier1642_v1` case. Both arms
`STEP_A_OK`/`STEP_B_OK`, `Cd(40)` identical between arms (`0.43867`),
matching the rules' expected ~0.43 band exactly.

**Correctness / reproducibility.** Control arm's built-in
`Average wall-clock time per time step = 13.42643364315385`, within 0.14%
of the archived value (13.445) from a different, earlier run — normal
run-to-run variance, and a clean independent reconfirmation with full
provenance (binary hash, Cd) that the earlier archival number wasn't a
fluke.

**Profiler overhead: +0.88%** — much lower than either 4-node profile
(KaHIP +10.49%, scotch +16.16%), and close to the *other* 1-node test's
+1.61% (the original KaHIP 1-node sanity check, job 24450837.pbs101).
**This is now two independent data points at 128 ranks (≈1-2% overhead) and
two at 512 ranks (≈10-16% overhead) — reinforcing that mpiP's own
measurement cost scales with rank count, not with decomposition method.**

**The key number — and an important scale caveat before using it:**

| Configuration | Ranks | Aggregate MPI% (mpiP) |
| --- | ---: | ---: |
| hierarchical (16 4 2), 1-node | 128 | **10.37%** |
| KaHIP, 1-node (job 24450837.pbs101, §24) | 128 | 14.28% |
| KaHIP, 4-node (job 24490441.pbs101, §26) | 512 | 26.64% |
| scotch, 4-node (job 24600615.pbs101, §28) | 512 | 29.80% |

**Do not read this table as "hierarchical beats KaHIP."** The hierarchical
number is at 1-node scale; KaHIP and scotch's headline numbers are at
4-node scale. Comparing across rows requires comparing at the *same* rank
count. The valid same-scale comparison is the top two rows only:
**at 1-node, the best hierarchical split (10.37%) shows LOWER measured MPI
time than KaHIP (14.28%)** — and their wall-clock times are correspondingly
close: hierarchical(16,4,2) 13.426 s/step vs the archived best 1-node KaHIP
13.333 s/step, a 0.7% gap, nowhere near the 16.68% gap seen at 4-node.

**This is not a contradiction of the project's central finding — it is a
clean confirmation of its mechanism.** At 1-node, there is no possible
inter-node (cross-machine, network) communication at all -- everything is
intra-node shared memory. If the KaHIP-vs-hierarchical gap were caused by
something generic about partition quality (e.g. plain cell/face imbalance,
or intrinsic algorithm cost), it should show up at 1-node too. It does not:
at 1-node the two methods are nearly tied. **The gap only opens up at
4-node, exactly where the mechanism this project has argued for --
inter-node communication surface -- can actually operate.** This 1-node
result functions as an unplanned but genuine control experiment for the
whole causal story, and it passed.

### 31. Updated action-order recommendation

Given §29-30, the hierarchical-tuning search is now well-supported as
closed: `(16 4 2)` is confirmed the best 1-node split found (both by
partition topology, §17 of the earlier revision, and now by direct
solve+profile), the decompose-only sweep found nothing better, and this
1-node result actively supports rather than undermines the KaHIP storyline
by isolating where the KaHIP advantage actually comes from (inter-node
traffic specifically, not partition quality in general). Per the official
rules ("Decomposition: try this first... Profile communication on the
4-node scored configuration... MPI profiling and analysis are strongly
recommended"), the primary submission storyline should be: baseline
hierarchical -> partition-topology analysis identifying inter-node
communication as the likely cause -> switch to KaHIP, measured 16.68%
4-node improvement -> mpiP profiling on the actual scored configuration
confirms the mechanism (26.64% vs scotch's 29.80%, tracking the inter-node
face fraction) -> this 1-node control result confirms the effect is
specifically inter-node, not a general partition-quality artifact. The
hierarchical-tuning search is a one-paragraph supporting footnote:
"(16 4 2) is confirmed the best available hierarchical split; even so, at
4-node scale it remains slower than KaHIP because the deficit is inherently
about inter-node placement, which no same-family tuning can fix."

### 32. 4-node hierarchical decompose-only sweep — job 24861072.pbs101, hypothesis refuted again

Same methodology as the 1-node sweep (§29-30), scaled to 512 ranks. Five
candidates chosen to satisfy `nx*ny` being an exact multiple of 128 (this
session's node-boundary-alignment reasoning, presented to the user before
submission). Walltime used: 21m24s of 150m requested. All 5 candidates
succeeded (`decomposePar exit code: 0` for each), none skipped or failed.

| Candidate | `pf_sum` | Distinct interface faces (`pf_sum/2`) | vs `(8 8 8)` = 5,679,671 |
| --- | ---: | ---: | ---: |
| **(8 8 8)** [existing, only prior 4-node hierarchical] | 11,359,342 | **5,679,671** | baseline |
| (32 8 2) | 12,757,059 | 6,378,530 (see caveat) | +12.3% |
| (16 8 4) | 12,918,354 | 6,459,177 | +13.7% |
| (32 4 4) | 13,152,216 | 6,576,108 (see caveat) | +15.8% |
| (16 16 2) | 14,065,443 | 7,032,722 (see caveat) | +23.8% |
| (8 16 4) | 15,299,997 | 7,649,999 (see caveat) | +34.7% |

**Data-quality caveat.** Three of five candidates' `pf_sum` values are odd
numbers, which should be structurally impossible if every processor
interface face is counted exactly twice (once per side), as verified
earlier in this project (§7's symmetry check on the KaHIP/hierarchical
4-node logs, and re-confirmed for the 1-node sweep). The exact cause was
not investigated in this session (does not change the conclusion below,
since every candidate is worse than `(8 8 8)` by 12%+, far outside any
parity-rounding effect) but should be resolved before quoting these exact
figures externally.

**Every single candidate is worse than the only decomposition already
tested.** This is the second independent refutation this session of a
geometrically-motivated hypothesis about hierarchical tuning (the first
being the 1-node "push more cuts onto the long axis" idea, §30). The
"node-boundary alignment" mechanism proposed before this sweep was real
(verified via the `nx*ny` divisibility check) but evidently not the
dominant factor.

**A more likely explanation, in hindsight.** `(8 8 8)` is the unique
*uniform* factorization of 512 into three equal factors among all
candidates tested (all 5 new ones have ratios far from 1:1:1, e.g.
`(32 4 4)` is 8:1:1). Minimizing total cut surface for a fixed number of
same-volume pieces favors keeping each piece close to cube-shaped, which
for a mesh whose overall bounding box is not extremely anisotropic favors
splits close to equal on all three axes. The node-boundary-alignment
mechanism appears to be a real but secondary effect, dominated by this
cube-shape effect. This mirrors the 1-node finding in reverse: at 1-node,
mild anisotropy `(16 4 2)` beat the more uniform `(8 8 2)`/`(8 4 4)`, but
pushing to extreme anisotropy `(32 4 1)` etc. made things much worse --
consistent with there being a shape optimum that is neither perfectly
uniform nor arbitrarily stretched, and `(8 8 8)` at 512-rank scale appears
to sit very close to it.

**Conclusion: the hierarchical-tuning search is closed at both scales.**
`(8 8 8)` remains the best 4-node hierarchical split found, `(16 4 2)`
the best 1-node one (§30), and two independent, differently-motivated
search attempts at 4-node scale (plus one at 1-node) found nothing better.
Per §31's plan, this becomes a one-paragraph supporting footnote; no
further SU should go toward hierarchical parameter search.

## 33. Returning to the main storyline: the one missing measurement

KaHIP (§26) and scotch (§28) have both been profiled with mpiP at the
actual scored 4-node/512-rank scale. Hierarchical `(8 8 8)` -- the
configuration the whole comparison exists to explain -- has **not**. Its
inter-node face fraction (36.07%, more than triple scotch's 11.52% and
nearly 5x KaHIP's 7.66%) is known from partition topology alone; its
actual measured MPI% is not. Completing this profile gives the cleanest
possible evidence for the submission's central claim: three decompositions
at the identical scale, identical rank count, identical binary, identical
40-step window, with both partition-topology and directly-measured MPI-time
evidence in hand for all three.

## 34. hierarchical(8,8,8) profile — job 24870034.pbs101, success — the trio is complete

Same proven v3 methodology, `TEMPLATE` pointed at
`occdrivaer_4node_aocc_hier888_v1`. Long queue wait due to `node_pool`
contention in `q5` (~96 minutes from submission at 14:19:56 to start at
15:59:57 — the SSH ControlMaster connection also expired once during the
wait and needed re-establishing; unrelated to the job itself). Once
running, walltime used: 34m36s of the 40m requested. Both arms
`ARM_A_OK`/`ARM_B_OK`, `prep_case` verification passed for both
(`controlDict 21641 bytes, endTime=40 confirmed`), no `NaN`.

**Correctness.** Cd(40) identical between arms: `0.29843` (to displayed
precision) — matches this session's earlier-recorded Cd(150)=0.29843 for
this same decomposition almost exactly, consistent with the early-
convergence pattern already established for KaHIP in §26 ("this case's Cd
converging early and remaining stable"). This reconfirms, rather than
newly discovers, the pre-existing mild concern: hierarchical(8,8,8)'s Cd
sits at ~0.298 at both 40 and 150 steps, slightly above the official
~0.28-0.29 band, while KaHIP (0.28004) and scotch (0.28405) both sit
within/closer to it. This is orthogonal to the timing/MPI% findings below
and does not affect them.

**Timing:**

| | KaHIP (§26) | scotch (§28) | hierarchical(8,8,8) |
| --- | ---: | ---: | ---: |
| Control `Average wall-clock time per time step` | 2.855959 | 2.899848 | **3.455052** |
| Manual control mean, steps 2-40 | 2.8277 | 2.8744 | 3.3138 |
| Manual LD_PRELOAD mean, steps 2-40 | 3.1244 | 3.3390 | 3.4628 |
| Profiler overhead | +10.49% | +16.16% | **+4.50%** |

hierarchical(8,8,8) is genuinely the slowest of the three at this scale,
by a wide margin — **+21.0%** slower than KaHIP and **+19.1%** slower than
scotch on the official per-step statistic (control arm, no profiler
running). The profiler overhead itself is lowest for this config (+4.50%,
vs scotch's +16.16%) — confirming yet again (per §28's note) that mpiP's
own overhead is not a fixed cost and does not track the underlying
communication cost in a simple way; it should never be assumed to
transfer between configurations.

**The completed three-way MPI-time comparison:**

| | KaHIP | scotch | hierarchical(8,8,8) |
| --- | ---: | ---: | ---: |
| Aggregate MPI% (mpiP, this session) | 26.64% | 29.80% | **37.08%** |
| Inter-node face fraction (partition topology) | 7.66% | 11.52% | **36.07%** |
| Control avg wall-clock/step | 2.855959 | 2.899848 | **3.455052** |

All three metrics now agree, in the same order, across all three
decompositions: **KaHIP < scotch < hierarchical(8,8,8)**, for inter-node
face fraction, measured MPI%, and directly measured wall-clock time per
step. This is no longer an inference from partition topology alone (as it
was through §25) — it is now a directly measured, monotonic, three-point
relationship between how much of a decomposition's boundary crosses a
node edge and how slow the resulting run actually is. This is the
strongest available evidence for the submission's central causal claim.

**Call-type frequency (site count): identical to KaHIP and scotch**, all
three configurations show exactly 27,648 `Allreduce`, 14,336 `Waitall`,
7,168 `Allgather`, 6,656 `Isend`/`Irecv` each, 5,632 `Bcast`, 3,584
`Test`, 1,022 `Send`, etc. This is now confirmed across THREE
decompositions (not just two): call-site counts are fixed by the solver's
own code structure (same `fvSolution`, same iteration caps, same 512
ranks, same 40 steps), completely independent of partition shape. Only
the *time* spent per call differs.

### 35. Status — the mpiP profiling storyline is complete

All three planned 4-node/512-rank decomposition profiles are done: KaHIP
(§26), scotch (§28), hierarchical(8,8,8) (§34). Combined with the 1-node
control experiment (§30) that isolated the effect as specifically
inter-node, this project now has:

1. A working, from-source-built profiler (mpiP) verified against the
   actual competition binary with zero modification to it.
2. Direct, measured evidence (not just topology inference) that
   inter-node communication fraction predicts both mpiP-measured MPI% and
   actual wall-clock time per step, monotonically, across three
   independently-designed decompositions.
3. A control experiment (1-node) confirming the mechanism is specifically
   about inter-node placement, not a general partition-quality artifact.
4. A closed, negative-but-informative search of the hierarchical-tuning
   parameter space at both scales (§30, §32), supporting the decision to
   not pursue further hierarchical tuning.

Per §31's plan, this is now sufficient to write up the primary submission
storyline. Remaining optional work (not required for the storyline to be
complete): time-weighted callsite aggregation (as opposed to site-count
only) for KaHIP/scotch/hierarchical, per-rank outlier analysis, and the
H3/H7 hypotheses noted in §27 as answerable-but-not-yet-analysed from the
existing report data.
