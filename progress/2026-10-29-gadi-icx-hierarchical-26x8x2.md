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
