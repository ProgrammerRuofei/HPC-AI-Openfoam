# Gadi ICX 2025 and 2026 hierarchical (26 8 2)

The user requested and approved one four-node run of each ICX version, in order (2025.3.2 then 2026.2), after the exact proposed differences were shown. Failed jobs are not automatically resubmitted; the second run follows validation of the first. The two new scripts derive from their own completed Scotch templates and change decomposition to hierarchical (26 8 2) plus unique job names, output paths and assertions. Both passed local bash -n and no-index whitespace checks.

Scripts:
- builds/build-scripts/gadi-icx20253-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs, SHA-256 7de64433111d24258bf043f98e642b3b371c49f9714cd0c480723e1c79afef99.
- builds/build-scripts/gadi-icx20262-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs, SHA-256 cc57228f75a969e208245719df5ec94730ce7f8d1db84bc13a1531fe6cf4316b.

Each request: pm78/normalsr, four Sapphire Rapids nodes, 416 CPUs/ranks (104/node), 760 GB memory, 100 GB JOBFS, one-hour limit, 832 SU maximum reservation per job. Source mesh, solver, schemes, solution, steps and rank mapping are unchanged. ICX 2025 and 2026 retain different effective communication controls from their successful Scotch templates, so between-version timing is a stack comparison, not a compiler-only effect. At pre-submit read-only check, pm78 had 10.20 KSU available, zero reserved and 157.49K/202K scratch inodes used.

Next: commit only these scripts and records on isolated codex/gadi-gcc162-build, push GitHub/Gadi, fast-forward the Gadi execution checkout and check commit/script hashes, then submit ICX 2025 once to a unique stdout. Verify terminal PBS state and all raw evidence before considering the already approved ICX 2026 submission. Preserve all original jobs and unrelated files.

## ICX 2025 submission

The four reviewed files were committed as d048f311cca0128a9ca38d1bfe89318fb2621c0c and pushed to GitHub/Gadi isolated branches. The Gadi execution checkout was at that commit; remote script hashes matched the local values above, both scripts passed remote bash -n, remote checkout was clean, and both independent stdout paths were absent before submission.

The exact one-time command from the Gadi execution checkout was:
/opt/pbs/default/bin/qsub builds/build-scripts/gadi-icx20253-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs

It returned 182562739.gadi-pbs. Initial qstat showed Q in normalsr-exec, 416 CPUs, 760 GB memory, 100 GB JOBFS, one-hour walltime. Its independent stdout is:
/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_hierarchical_26x8x2_v1.pbs.out

Expected job-keyed raw evidence is:
/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/baseline-4n-hierarchical-26x8x2/182562739.gadi-pbs/evidence/

PBS terminal status, pass marker, scientific checks, step time, Cd and actual SU are pending. The ICX 2026 job has not been submitted. Do not resubmit an uncertain qsub result or automatically retry a failed four-node job.

## ICX 2025 completed and validated

`182562739.gadi-pbs` finished with PBS `job_state=F`, `Exit_status=0`, walltime `00:13:14`, and NCI receipt `183.50` SU. Its own `exit-status.txt` says `script_exit_rc=0`; `run.log` ends with `ICX20253_OMPI5010_OF2512_HIERARCHICAL_26X8X2_4N_PASS`. The original `decomposition.txt` records 416 subdomains and hierarchical `(26 8 2)`. `rank-host-map.txt` has 104 ranks on each of `gadi-cpu-spr-0234` through `-0237`. The seven case-input checks, GCC/MPI/OpenFOAM archive checks, simpleFoam binary check, and private `libmpi.so.40` resolution all appear in the job log. `10_decomposePar.log`, `20_renumberMesh.log`, `30_potentialFoam.log`, `40_applyBoundaryLayer.log`, and `simpleFoam.log` each end normally; the solver reached `Time = 150` and `End`.

Original result lines: `Average wall-clock time per time step = 2.040001329684563`; `final_Cd=2.8772995935173329e-01`. The `coefficient.dat` row at time 150 agrees. `10_decomposePar.log` reports 3,882,476 processor faces, maximum 157,057 cells/rank (0.00145% above mean), and maximum 61,085 faces between processors. These are partition measurements, not a direct MPI-wait profile.

Raw remote evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/baseline-4n-hierarchical-26x8x2/182562739.gadi-pbs/evidence/`; independent PBS stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_hierarchical_26x8x2_v1.pbs.out`. These remain unmodified on Gadi. The original logs, not the status code alone, support the result. ICX 2026.2 remains unsubmitted at this point.

## ICX 2026.2 one-time submission

The reviewed ICX 2025 result files were committed as `1b4040e90c4fa642a92252d796d8488b08727596`, pushed to the existing GitHub and Gadi isolated branches, and the Gadi execution checkout reported `Already up to date` after `git pull --ff-only` from the Gadi control repository. Its HEAD matched that commit, the worktree was clean, and the ICX 2026.2 PBS script passed `bash -n` with local and remote SHA-256 `cc57228f75a969e208245719df5ec94730ce7f8d1db84bc13a1531fe6cf4316b`. The independent stdout path did not exist before submission.

The exact one-time command from `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo` was:
`/opt/pbs/default/bin/qsub builds/build-scripts/gadi-icx20262-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs`.
It returned **`182564097.gadi-pbs`**. Initial `qstat -f` showed `Q` in `normalsr-exec`, 416 CPUs and one-hour requested walltime. This is the second and final user-approved four-node submission; no automatic repeat is authorized.

Independent stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/run_baseline_4n_hierarchical_26x8x2_v1.pbs.out`.
Expected job-keyed evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/baseline-4n-hierarchical-26x8x2/182564097.gadi-pbs/evidence/`.
Terminal PBS status, solver evidence, coded step time, Cd and actual SU are pending.

## ICX 2026.2 completed result

`182564097.gadi-pbs` finished `job_state=F`, `Exit_status=0`, PBS walltime `00:16:40`, and **231.11 SU**. The job-keyed marker is `ICX20262_OMPI5010_UCX118_OF2512_HIERARCHICAL_26X8X2_4N_PASS`; `exit-status.txt` says `script_exit_rc=0`. The four SPR hosts each mapped 104 ranks; the fixed scientific input hashes and source/binary checks are retained. All four preparation logs and `simpleFoam.log` end normally; the latter reaches `Time = 150` and `End`.

Original measured result: **2.078723972046979 s/step**, final **Cd 0.28773188557326351**. This is 0.038722642 s/step slower than the ICX 2025.3.2 hierarchical `(26 8 2)` run (2.040001329684563 s/step). The two builds retained their respective successful Scotch templates and differ in communication/collective settings, so this is a stack comparison, not a compiler-only estimate. The 31 retained raw files, including PBS stdout, were pulled read-only and locally SHA-256 matched to fresh remote hashes under `planning/evidence/gadi-pbs-script-snapshot/logs/182564097.gadi-pbs/` in the current local repository; remote originals remain unchanged.
