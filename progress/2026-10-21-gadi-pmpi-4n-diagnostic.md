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
