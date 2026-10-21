# Gadi SPR GCC 16.2 / Open MPI 5.0.10 candidate

Status: **GCC 16.2, Open MPI 5.0.10, real Scotch and OpenFOAM v2512
passed cross-job validation and two complete four-node, 416-rank,
150-step runs.** See
`results/gadi-gcc162-ompi5010-scotch/run-registry.md` for the full
configuration and measurements, and
`progress/2026-10-16-gadi-ompi5010-gcc16-failure-retry.md` for job IDs,
failures, fixes, evidence and SU.

This candidate targets `normalsr` (Sapphire Rapids, 104 physical cores/node).
The staged work produced private GCC 16.2.0, Open MPI 5.0.10 and
OpenFOAM v2512 archives. The 416-rank Scotch candidate has two validated
full-case measurements. It is the current validated candidate; the
compiler, MPI and decomposition changes have not been isolated in a
one-factor comparison.

## Stage 1: GCC 16.2.0

- Source input: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/gcc-16.2.0.tar.xz`.
- Official source SHA-512: `c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1`.
- Bootstrap compiler: Gadi module `gcc/15.1.0`; build only C and C++ with
  `--disable-bootstrap --disable-multilib --disable-nls`.
- PBS: one `normalsr` node, 104 CPUs, 400 GB RAM, 150 GB jobfs, six-hour limit.
- Build and install inside `$PBS_JOBFS`; retain a single tar archive in scratch
  to avoid exhausting the project's inode quota.
- Build `181342083.gadi-pbs` finished with `Exit_status=0`, GCC/G++ 16.2.0,
  `GCC162_BUILD_ARCHIVE_PASS`, and a verified SHA-256 archive. It used 38.42 SU.
- Relocation job `181344224.gadi-pbs` finished with `Exit_status=0` in a new
  `$PBS_JOBFS`: C and C++17 compile/run passed, and `ldd` resolved
  `libstdc++.so.6` from the relocated GCC prefix. It used 0.02 SU. An initial
  hash transcription failure, `181344115.gadi-pbs`, is retained as evidence.

The two upstream source archives have been downloaded locally to
`/private/tmp/gadi-toolchain-sources/` and verified against publisher hashes:

| Archive | Publisher hash | Local verification |
| --- | --- | --- |
| `gcc-16.2.0.tar.xz` | SHA-512 `c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1` | PASS |
| `openmpi-5.0.10.tar.gz` | SHA-256 `5692cc80554a7117c99eaa725d35100edd8bbf73423a5e265ff867979192df7d` | PASS |

The current `pm78` scratch allocation has 195.21K of 202K inodes used. Do not
unpack GCC or Open MPI installations onto scratch. The retained archive is
immutable and a repeated attempt must use a new job-specific filename.

## Remaining gates

1. Run and verify the upstream-patched Open MPI build retry: `Exit_status=0`,
   UCX 1.18.1, UCC 1.4.4, PBS TM, two-rank MPI smoke, archive/hash and SU.
2. Validate the Open MPI archive after relocation in a separate PBS job.
3. Build OpenFOAM v2512 against that exact MPI and verify `ldd`/wrapper paths.
4. Before the full 4-node/416-rank/150-step Scotch run, compare its script
   against the current build instructions and successful Gadi runs. Validate
   Cd and repeatability before labelling the candidate the team's best build.

No previous hierarchical benchmark is scheduled for repetition. The team's
valid site-build result `178149002.gadi-pbs` (2.139565 s/step) is the initial
absolute reference, with the caveat that the first candidate changes several
factors at once.

## Open MPI 5.0.10 GCC 16 build failure and repair

Build `181344373.gadi-pbs` finished with `Exit_status=2` after 10:45 and
charged 11.47 SU. The first relevant compiler error was
`mca_part_persist_start: inlining failed ... max-inline-insns-single limit reached`
in `ompi/mca/part/persist/part_persist.h`. The original output remains in
`submit-logs/build_ompi5010.pbs.out` and
`evidence/181344373.gadi-pbs/build_ompi5010.log`. This exact GCC 16 /
Open MPI 5.0.10 failure is tracked upstream in
[open-mpi/ompi#13847](https://github.com/open-mpi/ompi/issues/13847).
The retry script applies the one-line upstream fix from
[commit aa024ac](https://github.com/open-mpi/ompi/commit/aa024ac73d624611cfe3af6f541b5d28dedf07bb)
to a checksum-verified source copy within the new job's `$PBS_JOBFS`; it
removes `__opal_attribute_always_inline__` only from `mca_part_persist_start`.
This changes Open MPI's build input, not OpenFOAM or its scientific workload.
The retry has a distinct PBS stdout path; evidence and archives are named by
new job ID.

Build `181344546.gadi-pbs` used 11.36 SU and passed the first fix, then
failed in unused OpenSHMEM initialization. The v3 script adds
`--disable-oshmem` per Open MPI documentation. See the progress record for
the first error, preserved logs, and job IDs.

Build `181345046.gadi-pbs` used 12.32 SU. The install and version/UCX/UCC
checks passed; the `prte_info --param ras tm` command was invalid. The v4
script uses the documented plain `prte_info` probe and retains an archive
before acceptance smoke tests. See the progress record.

Build `181346004.gadi-pbs` used 13.30 SU and retained a SHA-256-verified
Open MPI archive. The installed PRRTE reported `ras: pbs` and `plm: tm`;
the script's obsolete `ras: tm` expectation caused `Exit_status=1` before
the MPI smoke. The archive requires fresh-job and cross-node validation.

Relocation job `181346158.gadi-pbs` cost 0.04 SU. The archive and version
checks passed, but `plm: tm` was absent after relocation. The archived
plugin exists; the v2 diagnostic checks its dynamic dependencies and PRRTE
failed-component report before any cross-node job.

The diagnostic cost 0.04 SU. Its plugin `ldd` resolved all libraries, while
PRRTE/PMIx error output still referenced the old build-job prefix. The
next smoke sets `OPAL_PREFIX`, `PMIX_PREFIX`, and `PRTE_PREFIX` together.

Job `181346315.gadi-pbs` passed in 18 s / 0.04 SU, including GCC/MPI
versions, UCX/UCC, PBS RAS/TM, relocated `libmpi`, and both local ranks.
The two-node smoke next checks PBS launch and UCX transport between distinct
SPR hosts before building the OpenFOAM candidate.

Job `181346473.gadi-pbs` used 1.96 SU and stopped after staging the first
node because `pbsdsh` output bypassed the parent's `tee`. The v2 scripts
write and verify unique per-node marker files before MPI launch.

Job `181346532.gadi-pbs` used 2.31 SU and again stopped before MPI.
`pbsdsh -n 1` selects the second task slot on the first node, not the
second node, so the no-overwrite gate rejected duplicate staging. The
v3 PBS script uses slots 0 and 104 and verifies host mapping against
`PBS_NODEFILE` before launch. Original evidence is retained.

Job `181350909.gadi-pbs` passed (`Exit_status=0`, 36 s, 4.16 SU): both
SPR nodes staged pinned archives, PBS RAS/TM components were present,
`libmpi.so.40` resolved from the relocated runtime, and two UCX MPI ranks
ran on distinct hosts. `OMPI5010_RELOCATION_2N_PASS` marks this stack ready
for the OpenFOAM v2512 build. See the progress record and retained raw logs.

## Stage 2: OpenFOAM v2512 build candidate

`build_openfoam_v2512.pbs` uses a Gadi `normalsr` SPR node with 48 CPUs,
190 GB memory, 100 GB JOBFS, and a four-hour limit. This bounds the
worst-case queue charge at about 384 SU at 2 SU per core-hour; the prior
C1 OpenFOAM build completed in 1:26:52 and used 97.5 GB memory and 5.01 GB
JOBFS, but its timing is not a prediction for GCC 16. The exact GCC/MPI
archives are SHA-256 checked and unpacked only into this job's JOBFS.

The shared build helper retains its previous site-Open-MPI behavior when
private-prefix variables are unset. For this candidate it exports the
three relocation prefixes, uses the archived GCC wrappers, checks
`simpleFoam` against relocated `libmpi.so.40`, and packages a full
OpenFOAM/ThirdParty runtime (including `META-INFO` and source needed for
codeStream) with a verified SHA-256. It verifies authoritative and staged
`OPENFOAM_SOURCE_ID_V2` before build and does not change mesh or solver
source. The initial GCC candidate uses stock `WM_COMPILE_OPTION=Opt`
(`-O3`) and no additional vector-width flags. A fresh-job run check is
required before a four-node benchmark.

The first OpenFOAM build `181351226.gadi-pbs` exited 0 in 56:38 for
90.61 SU and produced a verified full runtime archive with the private
MPI-linked `simpleFoam`. ThirdParty's optional Scotch and ADIOS2 builds
reported errors despite `Allwmake` returning success. A fresh-job
`pitzDaily_fused` smoke with Scotch decomposition is required before this
archive can be considered a four-node candidate. The tutorial smoke is
not an official competition result and preserves the 65M case untouched.

The fresh-job smoke `181359431.gadi-pbs` (0.12 SU) confirmed that Scotch
decomposition reaches only the dummy stub. The original build's Scotch 6.1.0
compile fails under GCC 16's C23 default. `build_openfoam_v2512_scotch_v2.pbs`
uses `-std=gnu17` for the copied Scotch makefile in JOBFS, requires real
Scotch and scotchDecomp libraries, and writes a new job-ID-keyed archive.
The original archive and smoke evidence remain available. The corrected
archive still needs a fresh-job tutorial smoke before any four-node run.

The corrected build `181360543.gadi-pbs` passed with real Scotch and
scotchDecomp libraries, private MPI-linked `simpleFoam`, source identity,
and a verified full archive in 55:57 for 89.52 SU. The archive hash is
`64cd075a385938f0c9ac0c478066349e5bb198f5fa8cd80cc3ed61fb12286281`.
`smoke_openfoam_v2512_v4.pbs` pins this artifact for an independent
five-rank Scotch tutorial validation.

The fresh-job v4 smoke `181366491.gadi-pbs` passed Scotch decomposition,
private MPI-linked five-rank `simpleFoam`, coded timing, and normal parallel
completion in 51 seconds for 0.14 SU. The next low-cost v5 smoke tests
processor directories on JOBFS reached through symlinks in a shared
scratch case, matching the planned four-node layout while keeping inode
usage below the remaining project allocation.

The v5 symlink-layout smoke `181368402.gadi-pbs` passed in 49 seconds
(about 0.13 SU): real Scotch decomposition, five-rank private-MPI
`simpleFoam`, coded timing, and normal completion. This validates the
layout on one node. `run_baseline_4n_scotch_v1.pbs` and its two
`stage_4n_*_node.sh` helpers extend it to four SPR nodes. They pin the
accepted archives and source hashes, keep 104 processor directories per
node in JOBFS, check all 416 rank-to-host placements, and retain full-chain
logs and Cd in a job-ID-keyed scratch evidence directory. The four-node
job itself is needed to validate cross-node file access and benchmark time.

The first four-node job `181368883.gadi-pbs` passed the full chain and
150-step solver: 1.991194389 s/step, Cd 0.2918759493, 226.26 SU.
Its same-build repeat `181371071.gadi-pbs` also passed: 1.988625920
s/step, the same final Cd, 230.19 SU. Each used four SPR nodes with
104 ranks/node. See `results/gadi-gcc162-ompi5010-scotch/run-registry.md`
for the exact software, MPI placement, decomposition, scientific case,
and comparison to the older site-module baseline.

The approved one-node runtime diagnostic `181520734.gadi-pbs` passed in
44 seconds (`Exit_status=0`). Its two ranks, using the same pinned archives
and module/OpenFOAM environment, actually loaded `/usr/lib64/libucp.so.0`
reporting UCX 1.21.0, SHA256
`c5f993ab980f2bc736fe34cfb933acd6fb4d767444f6d64c3326766908277abc`.
UCC 1.4.4 was linked but its Open MPI collective component was disabled by
default and disqualified at runtime. HPCToolkit 2021 produced two-rank
sampling files, with a non-fatal DSO mapping warning. The old scored jobs
recorded the system `libucp` path but neither its version nor UCC selection;
their exact historical effective UCX version must remain unknown. See
`progress/2026-10-19-gadi-baseline-runtime-evidence-profile.md`.

The approved `profile_baseline_4n_scotch_v1.pbs` is a diagnostic copy of the
validated 4N Scotch script. It keeps the same pinned stack and scientific
inputs, runs 416 ranks for 150 steps, and samples only eight solver ranks
with HPCToolkit. The request is capped at 40 minutes/554.67 SU; its sampled
solver time is not a new scored result. `stage_4n_hpctoolkit_node.sh` packages
each node's measurement files into one scratch archive before local
`hpcprof` analysis. See the linked progress report for provenance and result.

Profile attempt `181520909.gadi-pbs` was cancelled with the user's
authorization after its HPCToolkit `REALTIME@f20` one-second preflight made
no progress for over 15 minutes. PBS final status was `Exit_status=271`
(`SIGTERM`), 26:04 walltime, **361.46 SU**. All four nodes had 104 ranks;
Scotch and the three MPI preparation applications ended normally. The
solver and sampling database never started, so no profile or scored result
exists. The original `realtime-preflight.log` is empty and preserved under
the job-keyed evidence directory. See the 2026-10-19 progress report for
the evidence boundary; another four-node run requires separate approval.

The bounded one-node timer diagnosis `181521525.gadi-pbs` completed in one
minute for **0.13 SU**. Both `REALTIME@f20` and `REALTIME@50000` timed out
after eight seconds when profiling `/bin/sleep 1`; both completed on a
CPU-active `seq` command. CPUTIME on `sleep` also completed. This isolates
the four-node stall to the REALTIME-on-sleep preflight rather than the
`@f20` spelling alone. The job did not run OpenFOAM. Its six-row matrix and
raw measurement archive are under the job-keyed evidence directory; a new
solver profile remains subject to separate review and approval.

Tutorial smoke `181358016.gadi-pbs` used 0.01 SU and stopped before
unpacking because its functionObject SHA-256 literal was truncated. It
is not a Scotch result. The v2 script pins the full verified hash and
uses new stdout/evidence paths; the original failure output is retained.

Tutorial smoke v2 `181358755.gadi-pbs` used 0.11 SU. It passed all
archive and binary hashes but ran `ldd` before sourcing the runtime's
`etc/bashrc`, so OpenFOAM libraries were unresolved. This is a probe
ordering error, not a Scotch result. v3 activates the runtime before
linkage inspection; original evidence is retained.

A separately approved, non-scored five-rank tutorial smoke is prepared in
`smoke_hpctoolkit_openfoam_1n_v1.pbs`. It profiles `simpleFoam` with
`CPUTIME@50000`, has a 120-second solver timeout and ten-minute PBS limit,
and validates solver completion plus raw samples for every rank. Its unique
output paths preserve the earlier HPCToolkit failure evidence.

The approved CPUTIME OpenFOAM tutorial smoke `181585812.gadi-pbs` passed
PBS `Exit_status=0`, Scotch decomposition, five-rank `simpleFoam` through
20 steps and `End`, with nonzero rank-specific `.hpcrun` samples. It used
one SPR node, 5 CPUs, 1:10 walltime and 0.19 SU. The raw profile archive
and solver log are preserved under the job-keyed evidence directory; see
`progress/2026-10-19-gadi-baseline-runtime-evidence-profile.md`. The short
tutorial is not a representative scientific profile or competition score.

One separately approved follow-up is
`postprocess_hpctoolkit_smoke_1n_v1.pbs`. It analyzes only the preserved
five-rank measurement archive on one SPR node (2 CPUs, ten minutes, at most
0.67 SU). Bounded `hpcstruct` and `hpcprof` reconstruct the old JOBFS
load-map prefix against hash-checked runtime archives. The test establishes
whether the samples can yield a usable function/source database before any
new four-node profiling request. It is not a solver run or scored repeat.

Postprocessing `181623287.gadi-pbs` passed (`Exit_status=0`) in 1:25 for
**0.15 SU**. Hash-checked runtime and archived samples produced a verified
HPCToolkit database (SHA-256
`89ea21f309e94bde6636d6731966c882311fba314446c7e7cbfc299f0178bfe5`).
The database names OpenFOAM and MPI procedures but contains no OpenFOAM
source-file paths; source-line attribution is not established. BFD/DWARF
warnings were nonfatal. See the 2026-10-19 progress report for raw paths
and the boundary on interpreting the short tutorial profile.

The separately approved four-node raw diagnostic is
`profile_baseline_4n_scotch_v2.pbs` with
`stage_4n_hpctoolkit_node_v2.sh`. It keeps the pinned GCC 16.2/Open MPI
5.0.10/OpenFOAM v2512 Scotch 416-rank, 150-step case, samples two ranks per
SPR node with `CPUTIME@50000`, and saves only raw profiles. The solver has a
15-minute timeout; the PBS request has a 30-minute ceiling (416 SU maximum).
Commit `52f94a5` was pushed to GitHub and Gadi after explicit approval.
The single submission returned `181627666.gadi-pbs` and finished with PBS
`Exit_status=0`, raw-profile pass marker, all 150 steps, and four verified
node archives. It used 16:43 and **231.80 SU**; instrumented diagnostic
timing was 1.988370329 s/step and Cd 0.2918759493.
Treat this as a non-scored diagnostic; no repeat or profile parsing job is
included in its approval. See the 2026-10-19 progress report for exact
submission, archive hashes, and the evidence boundary.

The later, separately approved `postprocess_hpctoolkit_4n_v1.pbs` analyzed
those raw profiles on one SPR node with two CPUs, without running the solver.
Job `181629095.gadi-pbs` passed (`Exit_status=0`) in 1:26 for **0.15 SU**.
Its hash-checked database (`e904bb217c341b326c3d4ea1b2639748fd21851506dc54304bc1f2dd714ade60`)
and module/procedure tables are under the job-keyed evidence path in the
2026-10-19 progress report. The largest sampled CPU hotspots are Gauss-Seidel
smoothing, `lduMatrix` operations, and `memmove`; HCOLL and MPI/UCX progress
also appear. See the results registry for percentages and interpretation
limits. No new 416-rank run was submitted.


The first mpiP 3.6 smoke `181635700.gadi-pbs` failed in wrapper
generation because Gadi `/bin/python` is a blocking shim (0.14 SU); no MPI
probe or solver ran. `build_smoke_mpip36_1n_v2.pbs` uses `/bin/python3` for
configure/make and has a unique stdout. See the 2026-10-19 progress report.


The one approved v2 mpiP smoke `181691060.gadi-pbs` exited 2 in 0:53
(about 0.15 SU by requested CPUs and walltime). Python wrapper generation
passed; generated `MPI_Pready_list` has a `const int *` argument that
conflicts with the pinned Open MPI 5.0.10 header's `int *`. The shared
mpiP library and MPI/OpenFOAM probes were not reached. Raw evidence is
retained; see the progress report. No further mpiP run was submitted.


The separately approved v3 mpiP smoke `181694279.gadi-pbs` exited 2
after 0:56 (about 0.16 SU by allocated CPUs and walltime). Disabling
partitioned wrappers resolved the `MPI_Pready_list` compile conflict;
`mpiP-wrappers.c` compiled. The next fatal error was mpiP's required
`fortran_vars.f` include of `mpif-config.h`, absent because this private
Open MPI was configured with `--disable-mpi-fortran`. No MPI probe or
solver ran. Raw evidence is preserved; see the progress report.


`pmpi_timing.c` and `smoke_pmpi_timing_1n_v1.pbs` are a C-only
alternative to mpiP for the same private Open MPI. The small smoke
measures 14 selected MPI call types on a two-rank probe and five-rank
Scotch tutorial, with per-rank CSV output. MPI call duration includes
waiting and progress and is not a direct measurement of network
transfer time. It is not a scored case or permission for a four-node run.


C-only PMPI timing smoke `181704658.gadi-pbs` passed (`Exit_status=0`):
private MPI linkage, two-rank UCX probe, five-rank Scotch tutorial through
20 steps, seven per-rank CSVs and SHA-256-verified profiler library.
PBS walltime was 1:57 on five cores, or about 0.33 SU by the established
rate; the per-job charge was not separately visible in rounded account
output. Tutorial rank 0 compiled the coded function object for about
64 seconds while ranks 1–4 waited in one `MPI_Barrier`. This is startup
waiting, not scientific solver or network timing. See the progress report
for exact evidence.


Windowed PMPI v2 smoke `181705417.gadi-pbs` was submitted once from
commit `2e95834` and passed with PBS `Exit_status=0` in 1:59 on five
CPUs (about 0.33 SU estimated from allocation). It adds 10-second
per-rank call windows and verifies exact reconciliation with full-run
counters on the same two-rank probe and five-rank, 20-step Scotch tutorial.
See the 2026-10-19 progress report for source/script SHA-256 and evidence
paths. The two-rank UCX probe and five-rank
20-step Scotch tutorial passed, and every ten-second call bucket reconciled
exactly with its per-rank total. The profiler library SHA-256 was
`dbe725d1ee8e07746ff18d0179ef4f02b24962cc0c3311a8aecb22bef1e88b79`.
The first bucket contains a 64.767-second startup barrier on ranks 1–4;
this is not the scientific solver's MPI fraction. See the progress report.
The exact NCI per-job debit was not available from rounded account output.

The separately approved `profile_baseline_4n_pmpi_v1.pbs` and two node
helpers preserve the validated 65M-cell, 416-rank, 150-step Scotch setup
while timing 14 C MPI call types in 10-second windows. They build the
hash-pinned interposer on each node's JOBFS and archive 104 rank reports
per node into four scratch files. This is a diagnostic, not a scored run.
Commit `66b229d` was pushed to isolated GitHub and Gadi branches after
local review; one submission returned `181868687.gadi-pbs` (initially Q).
The 30-minute, 416-core request has an approximately 416 SU ceiling.
See `progress/2026-10-21-gadi-pmpi-4n-diagnostic.md` for hashes, exact
paths, and completion criteria. No automatic repeat is authorized.

The first attempt `181868687.gadi-pbs` actually finished with PBS
`Exit_status=1` after two seconds and **0.46 SU**, before creating the
job-keyed evidence directory. `PBS_O_WORKDIR` was the remote home because
the absolute-path `qsub` ran there; the preflight looked for existing node
helpers under home rather than the Gadi control checkout. Read-only path
checks confirmed this first failure. No solver/profile result was produced.
The original PBS stdout is preserved. A corrected four-node retry requires
a new reviewed script, unique paths, and user approval.

The user approved one corrected v2 attempt. Its only functional change is
to resolve the two existing node helpers from the confirmed absolute Gadi
control checkout; it also uses unique v2 outputs. Script commit `d5c4bf2`
and SHA-256 are recorded in the 2026-10-21 progress report. Gadi accepted
one job, `181908113.gadi-pbs`, with the correct
`PBS_O_WORKDIR=/scratch/pm78/kj7183/openfoam_cpu/control-repo`. It passed
with PBS exit 0, four nodes × 104 ranks, 150 steps, Cd
0.29187594927465327, diagnostic 1.993566906751678 s/step, and 246.83 SU.
The complete PMPI reports and job evidence are preserved. The 416-rank
surface/Waitall table and exact rank-neighbor face table were extracted
without a new PBS job; see `results/gadi-gcc162-ompi5010-scotch/`.

The user separately approved one low-cost PMPI peer-counter smoke. The new
`pmpi_peer_counter_v1.c` retains the v2 timing report and adds in-memory
per-world-peer call and requested-payload counters for Isend, Irecv, Send,
Recv, and both sides of Sendrecv. Other communicators and unresolved world
peers remain separate. It writes peer CSVs only at finalize. The companion
`smoke_pmpi_peer_counter_1n_v1.pbs` requests one SPR node, five CPUs and
15 minutes (2.5 SU requested ceiling), and checks a deterministic two-rank
probe plus two profiled and two unprofiled five-rank, 20-step Scotch tutorial
runs. It records solver step time and launcher walltime overhead. This is
not a scored or four-node diagnostic. The reviewed source/script were
submitted once as `181921800.gadi-pbs` (initial state Q); its final result
will be recorded in `progress/2026-10-22-gadi-pmpi-peer-counter.md`.
