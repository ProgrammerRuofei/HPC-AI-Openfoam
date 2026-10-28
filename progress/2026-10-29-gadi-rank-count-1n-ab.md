# Gadi GCC16.2 Scotch 104/96-rank same-node comparison

Date: 2026-10-29 (Asia/Singapore). The user approved one single-node
104/96-rank A/B PBS experiment after reviewing its proposed remote-script
diff. No two- or four-node follow-up or automatic repeat was approved.

The completed GCC16.2/Open MPI5.0.10/OpenFOAM v2512 Scotch 104-rank,
40-step reference is `182017873.gadi-pbs`, 8.373520290307694 s/step,
Cd 0.43806006706848422 and 40.50 SPR SU. The purpose of this paired
experiment is to measure 104 and 96 ranks sequentially on one SPR host
with unchanged source case, archive hashes, default binding and full
Allrun-equivalent chain. See
`experiments/gadi-rank-count/README.md` for the exact controls.

Local `bash -n`, pinned-hash comparison to the validated one-node script,
and static chain checks passed. The script and README were committed as
`3dc32da6c938ee1a8e87b8eb0c859b34cad5ffe3` and pushed to the
isolated GitHub and Gadi branches. On Gadi the existing branch checkout
had that same HEAD, passed `bash -n`, and matched script SHA-256
`dccc848a9f9f65c7dc219f6faf816f72385b41446ea3d5d067b412a1292745e8`.
The existing main checkout and unrelated untracked files were left alone.

After checking that the unique PBS stdout path did not exist, this exact
remote command was run once from the Gadi branch checkout:

```sh
cd /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo
/opt/pbs/default/bin/qsub experiments/gadi-rank-count/run_rankcount_1n_40step_ab_v1.pbs
```

PBS returned **`182509859.gadi-pbs`**. The first `qstat -f` showed
`Q`, `normalsr-exec`, 104 CPUs, 100 GB JOBFS and 00:40:00 walltime.
The request ceiling was about 138.67 SPR SU; the final NCI receipt charged
**79.04 SPR SU** for 00:22:48 walltime.
PBS stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_rankcount_1n_40step_ab_v1.pbs.out`.
Job-keyed evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/rank-count-1n-40step/182509859.gadi-pbs/evidence/`.

Final audit: PBS `job_state=F`, `Exit_status=0`; the job log records both
arm-level PASS markers and `GCC162_OMPI5010_SCOTCH_1N_40STEP_104_96_AB_PASS`.
The same SPR host (`gadi-cpu-spr-0002.gadi.nci.org.au`) supplied all 104
and 96 affinity records. Both case-input SHA-256 manifests are identical.
Each arm completed Scotch decomposition, renumberMesh, potentialFoam,
applyBoundaryLayer and simpleFoam, reaching `Time = 40` and `End`.
The 104-rank arm measured 8.296121226410254 s/step and Cd
0.43806006706848422; the 96-rank arm measured 8.978244996461541
s/step and Cd 0.44034575240845725. Thus 96 ranks was 8.22% slower in
this controlled same-node pair. No repeat or larger job was submitted.
Detailed evidence and interpretation are in
`results/gadi-gcc162-ompi5010-scotch/rank-count-1n-40step.md`.
