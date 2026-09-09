# HPC lessons register

Failures worth keeping. Each entry records what happened, the *mechanism*, and
the rule it produced. In HPC a failure that explains scheduler, compiler, or
MPI behaviour is more valuable than another duplicate success — none of these
are deleted just because they are old or embarrassing.

Some lessons are **historical**: they describe behaviour observed at a
particular time and are not necessarily the current active configuration. Each
entry says which it is.

---

## L1 — Requested walltime reserves service units; actual runtime bills them

**Status:** historical observation, permanently applicable rule.
**Where observed:** Gadi, project `pm78`, 2026-09-03.

A compiler-build job requested **8 hours** of walltime on 48 `normal` cores.
It actually ran ~24 minutes and was billed **38.61 SU**. But PBS reserves
against the *requested* walltime, so the 8-hour request held roughly **768 SU**
of the project's grant for as long as it was queued or running.

The consequence was not theoretical. Official 4N baseline attempt 1
(`178142339.gadi-pbs`) was queued with the comment
`Could not reserve allocation from project`, which looked like grant
exhaustion. It was not: the reservation held by a **concurrent build job** was
blocking it. PBS scheduled the baseline at 20:28:15 as soon as that build
released its reservation.

Two separate errors followed from misreading this:

1. The queue comment was read as a permanent block; the job was cancelled by
   operator error about 2 minutes into a *running* allocation, losing ~45 SU.
2. The grant was believed exhausted. It was not — the 2.05 KSU shown as
   `Reserved` was a pending hold that later reconciled to Used 2.12 KSU,
   Reserved 0, **Avail 1.88 KSU**.

**Rules produced:**
- Requested walltime is a **budget variable**, not free headroom. Size it from
  measured runtime plus a defensible margin.
- Never run a long-walltime build concurrently with a scored `normalsr` run.
- A queue comment is a *snapshot*, not a terminal state. Do not cancel a
  running job on the strength of one.
- Before concluding "no SU left", check `Reserved` separately from `Used`.

Related: the walltime-budget paragraph in
[`official-gadi-spr/README.md`](../official-gadi-spr/README.md); the correction
record in [`planning/competition-progress.md`](../planning/competition-progress.md);
attempt 1 in [`official-gadi-spr/run-registry.md`](official-gadi-spr/run-registry.md).

## L2 — OpenFOAM's `etc/bashrc` resets `WM_MPLIB=INTELMPI` to `SYSTEMOPENMPI`

**Status:** historical blocker for the Intel MPI (S-series) candidates. It is
**not** a current active configuration — C1/C2/C3 use `SYSTEMOPENMPI`
deliberately and are unaffected.
**Where observed:** Gadi, S1 build attempt 4, `178138805.gadi-pbs`.

Exporting `WM_MPLIB=INTELMPI` *before* sourcing `etc/bashrc` does not survive:
the script resets it to `SYSTEMOPENMPI`. `etc/config.sh/mpi:130-136` then takes
the Open MPI code path and issues

```
mpicc --showme:link
```

`--showme:link` is an **Open MPI-specific** wrapper flag. Handed to Intel MPI's
`mpicc`, it is forwarded to ICC, which rejects it. The build fails before any
OpenFOAM or ThirdParty compilation starts.

A second, independent problem surfaced in the same attempt: the authoritative
`/apps/OpenFOAM/2512` tree has no `META-INFO/api-info`, so
`etc/config.sh/setup:30` cannot set `FOAM_API`.

**Rules produced:**
- Pass MPI/compiler selection as **command-line arguments** to `etc/bashrc`
  (`. etc/bashrc WM_COMPILER=Icc WM_MPLIB=SYSTEMOPENMPI WM_COMPILE_OPTION=Opt`),
  not as pre-exported environment variables.
- This is an **environment-integration** failure. It is not evidence that ICC
  or Intel MPI is incompatible with OpenFOAM, and must not be recorded as one.
- The `META-INFO/api-info` overlay is created only in ephemeral job storage,
  after the staged source has passed its identity check, and is separately
  hash-verified (`d03cf08c...`).

Related: [`s1-autonomous-debug-summary.md`](s1-autonomous-debug-summary.md)
attempt 4; the `WM_MPLIB` notes in the S1/S2/S3 build READMEs.

## L3 — `restore0Dir` is a shell function, not a binary

**Status:** fixed; applies to any script driving the official chain.
**Where observed:** official 4N attempt 2 `178147674.gadi-pbs` (exit 127), and
earlier on ASPIRE2A.

Five of the six official chain steps are executables. `restore0Dir` is a
function defined in `$WM_PROJECT_DIR/bin/tools/RunFunctions`. A script that
never sources `RunFunctions` fails with `restore0Dir: command not found` —
*after* `decomposePar` has already spent ~4.5 minutes writing 416 processor
directories.

Sourcing it naively fails too: under `set -u`, `RunFunctions` trips on
`FOAM_LD_LIBRARY_PATH`. Lift `nounset` for the source only, then restore it.

**Rule:** a gate that checks whether a command *string* is present in a script
does not prove the command will *resolve*. Check resolution
(`type restore0Dir`), not spelling.

## L4 — Every `-parallel` step needs `mpirun`, not just the solver

**Status:** fixed.
**Where observed:** official 4N attempt 3 `178148324.gadi-pbs` (exit 134).

Only `simpleFoam` was launched under `mpirun`; `renumberMesh`,
`potentialFoam`, and `applyBoundaryLayer` ran bare. `renumberMesh` aborted with
`FOAM FATAL ERROR: attempt to run parallel on 1 processor` (`UPstream.C:369`).

The case-supplied `Allrun` is explicit: `decomposePar` is serial, `restore0Dir`
is a function, and **all four** `-parallel` steps run under `mpirun -np
$nProcs`.

**Rule:** reproduce the case's own launcher pattern exactly. Both L3 and L4
were inherited from the original chain and both were invisible to a
string-matching gate.

## L5 — `wmake` must build its own tools before any library

**Status:** fixed in `builds/build-scripts/common/build_openfoam_v2512_openmpi.sh`.
**Where observed:** C1 build attempt 2 `178141482.gadi-pbs`.

ThirdParty compiled cleanly under ICC — SCOTCH, boost, and CGAL all finished —
then the build stopped with:

```
make: .../platforms/tools/linux64Icc/wmkdepend: Command not found
```

`wmkdepend` is wmake's own dependency generator and is installed to the
**compiler-specific** `platforms/tools/${WM_ARCH}${WM_COMPILER}`. The site tree
ships only `linux64Gcc`. Switching to ICC therefore requires rebuilding the
wmake toolchain first.

It was missed because a normal OpenFOAM distribution has a top-level `Allwmake`
sequencing `wmake/src` → `src` → `applications`. The site installation has
**no top-level `Allwmake`**, so the scripts drove the steps by hand and
reproduced only the last two.

**Rule:** run `wmake/src/Allmake` first and assert the matching `wmkdepend` is
executable *before* starting the libraries, so this fails in seconds instead of
24 minutes deep as a confusing `make` error.

## L6 — ICC Classic 2021.10 needs two source compatibility patches

**Status:** fixed; both patches are staged job-locally, never written back to
the authoritative source.
**Where observed:** C1 build attempts 3 and 4.

1. `178163598` — ICC did not expose the C++17 aligned-new declarations
   `ListPolicy` requires; corrected with a feature-macro workaround.
2. `178166039` — with that fixed, ICC propagated the `const` value-parameter
   declaration of `CircularBuffer::toGlobal`, producing non-modifiable-lvalue
   errors.

**Rule:** an old compiler failing on modern C++ is a *portability* result, not
a performance result. Patch the staged copy, hash it, and keep the
authoritative source untouched.

## L7 — PBS runs a spool copy of your script

**Status:** fixed.
**Where observed:** S1 attempts 1 and 2 (`178136462`, `178137625`).

Two distinct failures, both exit 127 in about 1 second:

1. The `#PBS -o` **parent directory did not exist**, so the job produced no
   output at all — no log, no evidence, nothing to debug.
2. PBS executed the script from `/local/spool/pbs/mom_priv/jobs/`, so
   `BASH_SOURCE[0]` could not find its sibling shell script in the repository.

**Rules:**
- Create the `#PBS -o` directory before every `qsub`. A job that cannot write
  its output is a job you cannot diagnose.
- Resolve repository files from `${PBS_O_WORKDIR}`, never from `BASH_SOURCE`.

## L8 — `PBS_NNODES` does not exist on Gadi

**Status:** live defect in `scripts/compiler-screening/*.pbs`; avoided in the
C1-specific harness.

`PBS_NNODES` is a **Torque** variable. Gadi runs **PBS Pro**, which does not
define it, so `${PBS_NNODES:?}` aborts the job at the first line that uses it.

**Rule:** derive the node count from `PBS_NODEFILE`
(`sort -u "$PBS_NODEFILE" | wc -l`) and then verify it independently from what
the launched tasks actually report.

## L9 — ASPIRE2A multi-node teardown dies with `signal 7`

**Status:** `OPEN`. See [`MANUAL_INSPECTION_ERROR.md`](../MANUAL_INSPECTION_ERROR.md).

Every ASPIRE2A multi-node run fails with `signal 7` (SIGBUS) **after** OpenFOAM
prints `End` and `Finalising parallel run` — the solver finishes, then teardown
kills it. `15811806.pbs101`: rank 100 died, exit 143, 68 s wall.

T1 (1 node × 128 ranks) passes; T4 (2 nodes × 64 ranks) fails at the **same
total rank count**. The variable is therefore node count, not rank count, and
the failing rank and node vary between runs.

Classification: `MULTI-NODE / INTER-NODE PALS-MPI RUNTIME SUSPECT`. No OpenFOAM
fatal error, NaN, or explicit MPI error was found.

**Rule:** a failure *after* `End` is a runtime/teardown problem, not a
numerical one. Do not chase the physics.

## L10 — A passing validation gate is not a performance result

**Status:** permanent classification rule.

C1 has passed build validation, an archive-integrity check, and a 5-rank
runtime smoke test. None of those produce a timing, and none of them make a
later C1 run official. The chain is:

```
build PASS → archive PASS → smoke PASS → SCREENING benchmark → OFFICIAL run
```

Each arrow is a separate authorisation with separate evidence requirements.
Official status additionally requires the `normalsr` queue and official rules.

## L11 — A job submitted from an untracked script has no commit provenance

**Status:** live gap. Applies to C1 jobs `178252413` and `178254935`.

The C1 runtime-archive repair (`178252413.gadi-pbs`) and the final runtime
smoke (`178254935.gadi-pbs`) both passed. Neither can cite a Git commit,
because the scripts that produced them —
`repair_c1_runtime_archive_v2.pbs` and `smoke_c1_icc2021_openmpi417.pbs` —
were **untracked** in the Gadi clone when they were submitted. They are still
uncommitted on the Mac.

The results are real and their completion tokens are valid. What is missing is
the ability to prove *which exact script text* produced them, which is the
whole point of recording a commit alongside a job ID.

**Rules produced:**
- Commit a script **before** submitting the job that runs it. `git status` on
  the cluster clone should be empty except for documented runtime artifacts.
- A run record with a job ID but no commit is incomplete provenance. Record the
  gap explicitly rather than leaving the commit column blank and hoping nobody
  notices.
- This is exactly the failure mode
  [`workflow/01-Git-Sync-Policy.md`](../workflow/01-Git-Sync-Policy.md) exists
  to prevent: reviewed changes must reach the cluster **through Git**, not by
  appearing there untracked.

Related: the same habit produced the Mac/Gadi history split recorded in
[`progress/2026-09-09-repo-organisation-and-git-state.md`](../progress/2026-09-09-repo-organisation-and-git-state.md).
