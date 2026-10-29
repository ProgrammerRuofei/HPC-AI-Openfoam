# Gadi ICX 2025.3.2 Scotch one-time verification

The user approved one exact-science, same-build four-node repeat after review of the proposed script differences. `181399707.gadi-pbs` remains the only earlier valid ICX 2025.3.2 Scotch result (1.976664843872483 s/step, Cd 0.29187617440389690, PBS Exit 0, 228.80 SU per original PBS receipt). `181402435.gadi-pbs` was cancelled at Exit 271 and is not a valid repeat. `182562739.gadi-pbs` uses hierarchical (26 8 2), not Scotch.

## Approved script and submission

The new script `builds/build-scripts/gadi-icx20253-ompi5010/run_baseline_4n_scotch_verify_v2.pbs` differs from the successful Scotch script only in the PBS job name, unique stdout and `verification=one_time_repeat` provenance field. Its SHA-256 is `d7a34f9acceb6fc74011623ff89bcadb86106f26a997ccf04c3a9bd17c477efc`. Science input, OpenFOAM/MPI archives, launcher, decomposition, ranks and 150-step controls are unchanged. Local `bash -n` and diff review passed.

The isolated branch commit `f5e303a425c8e167d093e1e3bcfa52db7c1fc543` was pushed to existing GitHub and Gadi remotes. The Gadi isolated execution checkout `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo` matched that commit, was clean, and had the same script hash; `bash -n` passed there and the unique stdout was absent before submission. The main control checkout's unrelated untracked files were left untouched.

Exact one-time submission from the isolated execution checkout:
`/opt/pbs/default/bin/qsub builds/build-scripts/gadi-icx20253-ompi5010/run_baseline_4n_scotch_verify_v2.pbs`

It returned **`182564679.gadi-pbs`**. Initial `qstat -f` showed Q in `normalsr-exec`, project pm78, 416 CPUs, 760 GB memory, 100 GB JOBFS and 01:00:00 requested walltime. The maximum request is 832 SU; expected charge from the previous run is approximately 229 SU, with the actual value pending the PBS receipt.

Independent stdout: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010/submit-logs/run_baseline_4n_scotch_verify_v2.pbs.out`.
Expected job-keyed evidence: `/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20253-ompi5010-of2512/baseline-4n-scotch/182564679.gadi-pbs/evidence/`.

## Pending validation

Check terminal PBS Exit_status; pass marker and script exit status; four SPR hosts each with 104 ranks; source, archive and binary hashes; Scotch `decomposePar` and all preparation-stage `End` markers; `simpleFoam` Time=150, End and coded seconds/step; `coefficient.dat` Cd; and actual per-job SU. Preserve raw logs and use the job-keyed archive workflow. Do not submit another four-node run automatically. Historical jobs did not record UCP's runtime version, collective selection or per-rank CPU affinity; this repeat retains the performance conditions and does not claim to close those evidence gaps.
