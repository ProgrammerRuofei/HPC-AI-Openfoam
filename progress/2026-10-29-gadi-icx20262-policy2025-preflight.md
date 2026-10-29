# ICX 2026.2 / Open MPI 5.0.10 unpreloaded runtime-policy preflight

The user approved one low-cost runtime preflight only. A new four-node run remains unapproved. This diagnostic approximates the successful ICX 2025.3.2 Scotch job's launch policy; it cannot recover the older job's unrecorded actual UCX version or selected collective.

The reviewed script `builds/build-scripts/gadi-icx20262-ompi5010/preflight_policy2025_2n_v1.pbs` derives from the successful two-node UCX 1.18.1 preflight. It retains the same hash-pinned private GCC/Open MPI 5.0.10 archives and two SPR nodes with one MPI rank each. It removes the site UCX preload, allows HCOLL by removing `coll ^hcoll`, and saves actual UCP path/version after MPI_Init, collective verbose output, CPU binding and cross-node Allreduce result. Its unique stdout and job-keyed evidence paths prevent overwriting existing results. Requested maximum: 208 allocated CPUs × 10 min × 2 SU/core-hour = 69.33 SU; the prior two-node preflight completed in 36 seconds at about 4.16 SU.

The gate is PBS Exit 0, unique pass marker, two distinct hosts, private MPI link, both MPI ranks with nonmissing UCP path/version, cross-node Allreduce sum 1, no UCP API incompatibility warning, and recorded collective/binding evidence. The two-rank collective selection does not prove the choice at 416 ranks. No OpenFOAM solver or 65M scientific case runs in this preflight; a prior five-rank ICX 2026 OpenFOAM smoke under the unpreloaded/system-UCX policy passed (`182469604.gadi-pbs`). If this preflight fails, do not submit the high-cost four-node screening job.

## Submission

The script passed `bash -n`, the reviewed diff and `git diff --check`. Script SHA-256: `98a2d814a6f403bc4e68f9e48d2224f00808d13d5e10ed54265122fcfd22055a`; commit `faca03a9cf342a5f02196238e40579652a62df48`. The isolated GitHub and Gadi branches were pushed; the active Gadi worktree fast-forward check was up to date, its script hash matched, and the unique stdout path was absent. Exactly one `/opt/pbs/default/bin/qsub builds/build-scripts/gadi-icx20262-ompi5010/preflight_policy2025_2n_v1.pbs` returned `182573253.gadi-pbs`. Initial PBS status `Q` in `normalsr-exec`, 208 requested CPUs and 10-minute walltime. Independent stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/preflight_policy2025_2n_v1.pbs.out`; job-keyed evidence will be `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/policy2025-2n.182573253.gadi-pbs/`. Terminal result and SU pending. No four-node job was submitted.

## First attempt outcome and reviewed correction

`182573253.gadi-pbs` ended `job_state=F`, `Exit_status=1`, PBS walltime
`00:00:35`, actual **4.04 SU**. The two MPI ranks ran on distinct SPR hosts
`gadi-cpu-spr-0700` and `gadi-cpu-spr-0718`; each reported `size=2`,
`sum=1`, loaded `/usr/lib64/libucp.so.0` and UCP self-reported version
`1.21.0`. MPI_COMM_WORLD collective verbose output selected `hcoll` at
priority 90 on both ranks. This is a two-rank observation, not evidence of
the selection at 416 ranks. No `UCP API version is incompatible` warning was
found. The job did **not** print the final PASS marker.

The first failing script check was the anchored `grep` for a complete
`POLICY2025_CROSS_NODE` line. Collective verbose writes interleaved with
rank stdout, yielding lines beginning with fragments such as
`[gadi-cpu-sprPOLICY2025_CROSS_NODE...`; the MPI program and `mpirun` had
already returned successfully. The original job-keyed evidence and stdout
remain unchanged. The first attempt is therefore a **failed acceptance
script**, not a successful preflight or proof that cross-node MPI failed.

Reviewed v2 script `builds/build-scripts/gadi-icx20262-ompi5010/
preflight_policy2025_2n_v2.pbs` writes one separate receipt per rank to the
shared evidence directory, then checks those files. It keeps verbose MPI
output as independent evidence and uses distinct stdout and job-keyed paths.
Allocation and runtime policy are unchanged. Local `bash -n` and
`git diff --no-index --check` passed. Script SHA-256:
`d81cb6fe04a3d279a67f43d8ee2c9bc6406c75a83ba1d45d8ca7d2bc3b91f2aa`.
The user approved this correction and one new two-node submission.

## Approved v2 submission

The user approved the v2 correction and one retry. Commit
`c4ab7773dd7b7e8c66166fb5141db8c8a9928584` was pushed to the existing
GitHub and Gadi isolated branches. The Gadi execution checkout fast-forward
check was up to date and clean; `bash -n` and the v2 SHA-256 matched the local
script. The new stdout path was absent. `nci_account -P pm78` showed 9.02 KSU
available, zero reserved, and scratch 512.48 GiB / 160.69K inodes used.
Exactly one `qsub` of `preflight_policy2025_2n_v2.pbs` returned
**`182574797.gadi-pbs`**. Initial `qstat -f` showed `Q` in `normalsr-exec`,
208 CPUs and a 10-minute limit. Its independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/preflight_policy2025_2n_v2.pbs.out`; job-keyed evidence is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/policy2025-2n-v2.182574797.gadi-pbs/`.
Final result and actual SU pending. No four-node job was submitted.

## v2 final result

`182574797.gadi-pbs` finished `job_state=F`, `Exit_status=0`, PBS walltime
`00:00:36`, and **4.16 actual SU**. The unique
`ICX20262_OMPI5010_POLICY2025_2N_PASS` marker and `script_exit_rc=0` are
present. Ranks 0 and 1 ran on different SPR nodes (`0663`, `0669`), each
reported `size=2`, `sum=1`, actual loaded `/usr/lib64/libucp.so.0`, and UCP
self-reported `1.21.0`. `mpi-smoke.ldd` resolved the private
`openmpi-5.0.10/lib/libmpi.so.40`. Two rank receipts passed the saved
`rank-receipts.sha256` manifest. Verbose MPI_COMM_WORLD selection showed
`hcoll` priority 90 on both ranks; no `UCP API version is incompatible`
warning appeared. This is a two-rank runtime-compatibility result, not a
416-rank collective selection or OpenFOAM performance result.

Original PBS stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/preflight_policy2025_2n_v2.pbs.out`.
Job-keyed raw evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/policy2025-2n-v2.182574797.gadi-pbs/`.
No four-node job has been submitted under this runtime-policy study.
