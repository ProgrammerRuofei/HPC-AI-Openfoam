# Gadi four-node PMPI timing diagnostic — 2026-10-21 SGT

## Authorization and completed preflight

The user approved **one** four-node C-only PMPI diagnostic after reviewing
the proposed diff. This approval does not include a repeat job. The earlier
one-node PMPI v2 smoke `181705417.gadi-pbs` passed PBS exit 0, two-rank UCX
probe, five-rank Scotch tutorial, and exact reconciliation of 10-second
per-rank counters with full-run counters. Its 64.767-second nonzero-rank
barrier occurred during tutorial startup and is not scientific bottleneck
evidence.

The reviewed diagnostic uses the same GCC 16.2.0, private Open MPI 5.0.10,
`ucx/1.18.1`, `ucc/1.4.4`, OpenFOAM v2512 and real Scotch as the validated
baseline. The case is the hash-checked ~65M-cell `occDrivAerStaticMesh` with
unchanged mesh, `simpleFoam`, `fvSchemes`, `fvSolution` and 150 steps. It
requests Gadi `normalsr`, four Sapphire Rapids nodes, 416 CPUs and MPI ranks
(104 per node), 760 GB memory, 100 GB JOBFS, and 30 minutes; the requested
ceiling is about 416 SU at the established rate. The solver timeout is 900
seconds. Timing from this instrumented run is diagnostic, not a competition
score. Reports remain in node-local JOBFS until four validated archives are
saved to scratch, conserving its nearly exhausted inode allocation.

Local shell syntax, source/helper SHA-256 constants, diff whitespace, and a
104-rank synthetic archive-helper test passed. Commit
`66b229dc2ab8ada70f713f0df9ee6404c3fca51e` containing the PBS script and
two node helpers was pushed to both isolated GitHub and Gadi branches. The
Gadi branch ref matched this commit. Materialized immutable submission files
passed SHA-256 and `bash -n`:

| File | SHA-256 |
| --- | --- |
| `profile_baseline_4n_pmpi_v1.submitted.pbs` | `95eb5c470a3ade1b709cb35c89d143d1d51b7bfa9a2205e26240db6e1e59dc90` |
| `stage_4n_pmpi_build_node_v1.submitted.sh` | `5b783998c458ec9b9e1c60ccc1fb3965e98e0e3bb477416ac143794f9b38231f` |
| `stage_4n_pmpi_archive_node_v1.submitted.sh` | `e63e0351542edeaf73e4254d6c25be9874ab72b02475d003eb95f644f29189e6` |
| Existing `pmpi_timing_v2.submitted.c` | `b3e8f31868cce92284048b896d6339fc0b01d0b8b900eef3e28409207790ccd0` |

Before submission `nci_account -P pm78` showed about 6.06 KSU available,
0 reserved, and 199.95K of 202K scratch inodes used. The Gadi control
checkout remained on `main`; its unrelated untracked experiment files were
preserved. The approved branch ref and immutable copies supplied this job.

## PBS submission and pending result

One non-interactive command submitted the immutable script:

```sh
ssh -o BatchMode=yes gadi-comp '/opt/pbs/default/bin/qsub /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_pmpi_v1.submitted.pbs'
```

It returned **`181868687.gadi-pbs`**. Initial `qstat -f` showed `Q` with
416 CPUs and a 30-minute request. No resubmission was made. Independent PBS
stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_pmpi_v1.pbs.out`.
Job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-pmpi/181868687.gadi-pbs/evidence/`,
with four rank-report archives in the sibling `pmpi-raw/` directory.

Next check PBS terminal state and `Exit_status`, four SPR hosts with 104
ranks each, full preparation and solver `End` at `Time = 150`, final Cd
0.27–0.30, profiler pass marker, 416 summary/bucket pairs, archive SHA-256,
per-step time, and actual SU. Separate startup from solver windows before
interpreting MPI call durations; those durations include waiting and do not
equal network-transfer time. Preserve all failure evidence, and do not
automatically repeat a four-node job.

## First attempt stopped before preparation

After the user requested a status check, the existing `gadi-comp` control
socket had expired. The user restored it; the renewed non-interactive check
returned `Master running`. PBS then reported `181868687.gadi-pbs` in state
`F` with `Exit_status=1` and two seconds of walltime. The independent PBS
stdout contains the accounting receipt but no script log. It reports
**0.46 SU**, 10.25 MB memory used, no JOBFS use, and four allocated SPR
nodes. The job-keyed evidence directory was not created, so the failure
occurred before `mkdir -p "$EVIDENCE"`; no preparation chain, MPI program,
`simpleFoam`, Cd, or profiling report ran.

The first failing preflight is the test for the two existing node helpers.
PBS `Variable_List` records `PBS_O_WORKDIR=/home/397/kj7183` because the
absolute-path `qsub` was invoked from the remote home directory. The script
therefore looked for
`/home/397/kj7183/builds/build-scripts/gadi-gcc162-ompi5010/stage_4n_runtime_node.sh`
and its processor helper. Read-only checks returned absent for both home
paths and present for the runtime helper in
`/scratch/pm78/kj7183/openfoam_cpu/control-repo/`. This explains the silent
`test -f` exit before logging. The original PBS stdout and job ID are
preserved; this is a submission-working-directory error, not evidence about
PMPI compatibility or the scientific solver.

Proposed correction: make the two established helper paths independent of
`PBS_O_WORKDIR` by resolving them from the confirmed Gadi control checkout,
and submit a new immutable script from that checkout. A new four-node job
requires a separately reviewed diff and explicit user approval. Do not
resubmit `181868687.gadi-pbs` or reuse its stdout/evidence path.

## Approved v2 retry submitted once

The user separately approved one corrected four-node attempt after seeing
the exact helper-path diff and the approximately 416 SU request ceiling.
`profile_baseline_4n_pmpi_v2.pbs` replaces the two `$PBS_O_WORKDIR` helper
paths with the confirmed absolute Gadi control-repo paths. It uses unique
v2 job, stdout, scratch and JOBFS paths. The science input, compiler/MPI,
four SPR nodes × 104 ranks, Scotch, 150 steps, memory, JOBFS and 30-minute
request are unchanged. The v2 script passed local `bash -n`, exact source
and helper SHA-256 checks, and an assertion that no other script content
changed from v1. Commit `d5c4bf26c3fd6dfba16746c555071440b75b4d2b` was
pushed to the isolated GitHub and Gadi branches.

Remote read-only preflight confirmed the Gadi branch ref, that the old node
helpers in the control checkout exactly matched the branch copies, the
existing immutable PMPI source and helper hashes, 6.06 KSU available, and
unused v2 output paths. Gadi materialized the v2 PBS script from that ref;
SHA-256 was
`2927da8270bacc31b998b4bfce3d6b739a0041633ae3a0d3ed26b820d70b606e`,
and remote `bash -n` passed.

One command submitted it **from inside the control checkout**:

```sh
ssh -o BatchMode=yes gadi-comp 'cd /scratch/pm78/kj7183/openfoam_cpu/control-repo && /opt/pbs/default/bin/qsub /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_pmpi_v2.submitted.pbs'
```

The command returned **`181908113.gadi-pbs`**. Initial `qstat -f` showed Q,
416 CPUs, 30 minutes, and `PBS_O_WORKDIR` correctly set to the control
checkout. Independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/profile_baseline_4n_pmpi_v2.pbs.out`;
job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/profile-4n-pmpi-v2/181908113.gadi-pbs/evidence/`.
Actual exit status, profiler reports, Cd and SU are pending. No further
four-node retry is authorized.
