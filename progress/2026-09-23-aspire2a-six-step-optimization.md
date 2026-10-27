# ASPIRE2A six-step optimisation tracker

## Status

| Step | Scope | Status |
| --- | --- | --- |
| 1 | Repair Cd provenance; archive and aggregate mpiP; rank/partition analysis | **COMPLETE** |
| 2 | Clean bound KaHIP repeatability controls with full mapping | **COMPLETE** — v5 job `25523028`, A/A steady-window difference 0.0505% |
| 3 | Clean AOCC/Open MPI/KaHIP control-profile-control with mpiP | PLANNED |
| 4 | Profile-directed KaHIP/decomposition/Open MPI screening | PLANNED |
| 5 | Controlled AOCC versus GCC comparison | PLANNED |
| 6 | 150-step validation and final 1/2/4-node scaling | PLANNED |

## Step 1 outcome

- The retained profile `coefficient.dat` files are stale inherited 150-step
  files and cannot validate profile Cd(40).
- Time-weighted parsing is complete. Allreduce is about half of measured MPI
  time; Waitall rises from 28.25% for KaHIP to 34.41% for hierarchical.
- The raw reports confirm four blocks of 128 ranks on four hosts, validating
  the prior cross-node face counts for these jobs.
- Old runs lack core/NUMA affinity evidence; Step 2 must record it.
- Local evidence and report:
  `planning/evidence/aspire2a-mpip-4n512-2026-09-23/` and
  `planning/analysis/aspire2a-step1-mpip-evidence-2026-09-23.md`.

## Stop point

The reviewed v1 script was committed as
`8082264290a66ec49fad3e2f3a5bd5bd39420fd3`, synchronized to the ASPIRE2A
control checkout and submitted exactly once as `25381367.pbs101`. It finished
in two seconds with `Exit_status=1`, zero CPU time and empty stdout/stderr.
PBS recorded `PBS_O_WORKDIR=/data/projects/59000020/openfoam-isc26/control-repo`;
the script required string equality with the equivalent
`/home/project/59000020/openfoam-isc26/control-repo`, so it exited at that
preflight before creating the run root, loading modules or invoking OpenFOAM.

The v1 output files are retained. The reviewed v2 changes only the
job/output/run names and compares canonical paths with `readlink -f`. It was
committed as `7fa1d0a6bb011af010bb49588aa80802dd9cb81b`, synchronized through
the control repository, and submitted exactly once as `25395779.pbs101`.

The canonical path gate passed and v2 created the isolated run root
`$HOME/scratch/openfoam-v2512/cases/step2-clean-repeatability-v2-25395779`.
PBS allocated four nodes and 512 CPUs, but the script exited after three
seconds with `Exit_status=1`, `cput=00:00:01`, and `Stageout_status=1`.
The retained `evidence/run.log` reaches the AOCC 5.0, GCC 11.2.0 and Open MPI
5.0.10 module record, then stops. No `executables.txt`, case input files,
decomposition log, processor directories, solver log or coefficient output
was produced. In the reviewed script, the only failing command between the
module record and `executables.txt` is the readability gate for
`$HOME/scratch/openfoam-v2512/ext/libfabric/lib/libfabric.so.1`. Therefore v2
failed at that private libfabric preflight before sourcing OpenFOAM or running
`decomposePar`, `mpirun`, or any OpenFOAM executable.

No automatic retry was made. Step 2 remains incomplete. Any next retry needs
a newly reviewed local diff and explicit approval.

## Step 2 v3 local preparation

A local, unsubmitted v3 proposal is available at
`experiments/aspire2a-six-step/step2_clean_repeatability_v3.pbs`. It preserves
the v2 workload, resources, toolchain, binding and two-arm A/A design. Its
runtime-only changes are:

- absolute, unique v3 PBS stdout/stderr paths under the control repository;
- direct shared-scratch candidates for the retained baseline libfabric;
- a mandatory SHA256 gate against the archived working-library digest
  `4959baaffd6620659f9878693faba31bd3ac7c382a0e576a9e1816653873407f`;
- recorded library path, realpath, digest and `ldd`; and
- a gate that `simpleFoam` resolves `libfabric.so.1` to the selected verified
  file before any MPI launcher or OpenFOAM command can run.

`bash -n` passes and the v2/v3 PBS resource directives match. The v3 file has
been committed as `a109433d2acb488a4c0acbc1c608725b7c582598`, synchronized,
and submitted exactly once as `25481476.pbs101` after explicit approval.

The job queued for about eleven minutes, then ran for three seconds and ended
with `Exit_status=1` and one CPU-second. Absolute stdout/stderr paths worked.
The job verified the direct shared-scratch baseline libfabric, including the
expected digest
`4959baaffd6620659f9878693faba31bd3ac7c382a0e576a9e1816653873407f`,
and recorded the resulting `LD_LIBRARY_PATH`. It then stopped before creating
`executables.txt`. The empty case directory and absence of launcher,
decomposition and solver evidence establish that no MPI or OpenFOAM command
ran.

The script sequence narrows the new failure to the OpenFOAM environment and
binary-preflight block between the successful libfabric record and creation
of `executables.txt`. `cd "$OF_DIR"` would normally emit an error if it failed,
but the retained combined log ends silently. A nonzero return while sourcing
`etc/bashrc` under global `set -e` is the leading explanation, but failure
while sourcing `RunFunctions` or the silent `test -x "$SIMPLEFOAM"` gate is
not excluded by the existing evidence. The next harness revision should
record each of these checkpoints separately, capture the bashrc return code,
and validate `WM_PROJECT_DIR`, `FOAM_APPBIN`, required commands and linkage
explicitly. This is a harness diagnosis, not a performance result.

No automatic retry was made. Step 2 remains incomplete; another local diff
and explicit approval are required before any further remote action.

## Step 2 v4 local preparation

The unsubmitted local proposal
`experiments/aspire2a-six-step/step2_clean_repeatability_v4.pbs` retains the
v3 resources and complete A/A experiment. It uses unique v4 job, output and
run-root names, disables `errexit` only while sourcing `etc/bashrc` and
`RunFunctions`, records both return codes, and then replaces implicit source
status assumptions with explicit environment, function, executable and
linkage gates. Named checkpoints make any further preflight failure directly
visible. `bash -n` passes and the v3/v4 PBS project, queue, select, placement
and walltime directives are identical. V4 has not been committed,
synchronized or submitted.

V4 was subsequently approved, committed as
`729e5f2b17594b7e48ae475cbcd7d0770d54e9cb`, synchronized and submitted once
as `25489653.pbs101`. It queued for about 30 minutes, then ran for four seconds
with one CPU-second and `Exit_status=1`. The checkpoint evidence establishes:

- libfabric and the OpenFOAM tree passed;
- `etc/bashrc` completed with `bashrc_rc=0`;
- all explicit OpenFOAM environment-variable gates passed; and
- sourcing `RunFunctions` stopped at line 29 because
  `FOAM_LD_LIBRARY_PATH` was unbound while global nounset was enabled.

No MPI launcher or OpenFOAM executable ran. A local v5 proposal now keeps
nounset disabled after sourcing the OpenFOAM environment, while retaining
errexit, pipefail and the explicit environment/linkage gates. V5 otherwise
changes only unique job/output/run-root names. `bash -n` passes, its resource
directives match v4. It was approved, committed as
`635e94159da9db2a62c26fa835a6049f6533aa9a`, synchronized and submitted once
as `25523028.pbs101`. The job is queued for four nodes with scheduler comment
`Insufficient amount of resource: node_pool`; it has not started. A five-minute
read-only thread heartbeat named `Monitor ASPIRE2A v5` now reports only a
meaningful state change or final evidence. It must not submit, cancel or retry
jobs or modify remote files.

## Step 2 v5 outcome

Job `25523028.pbs101` started at 2026-09-24 01:58:24, completed in 12:48 and
finished with `Exit_status=0`. Both identical 40-step arms passed. Their
steps-20-40 mean ExecutionTime increments are 2.827619048 and 2.829047619
s/step, a **0.0505%** difference relative to the pair mean. The built-in
full-run lines are 2.855659040 and 2.861398735 s/step.

Both fresh coefficient files contain exactly steps 1-40, have Cd(40)
0.43471632678608485 and are byte-identical. Solver iteration, residual and
continuity records are also identical. The 512-row affinity manifest confirms
four hosts, 128 ranks and 128 unique physical cores per host, with NUMA nodes
0-7 represented. Each core binding mask contains both SMT siblings.

The fresh KaHIP partition reproduces 65,334,765 cells, 2,786,035 distinct
processor-interface faces, maximum 21,408 processor faces/rank and maximum
cells/mean 1.009992. Step 2 passes the <=1% repeatability gate. No v6 retry is
needed. The full local report is
`planning/analysis/aspire2a-step2-repeatability-2026-09-24.md`; raw and derived
evidence is under
`planning/evidence/aspire2a-step2-repeatability-25523028/`.
