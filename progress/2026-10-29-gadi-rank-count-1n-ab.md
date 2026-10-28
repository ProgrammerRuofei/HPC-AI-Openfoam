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
The request ceiling is about 138.67 SPR SU; actual SU remains pending.
PBS stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_rankcount_1n_40step_ab_v1.pbs.out`.
Job-keyed evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/rank-count-1n-40step/182509859.gadi-pbs/evidence/`.

Next action: monitor this one job. Confirm PBS exit, both PASS markers,
40-step full-chain completion, input hashes, default binding, rank counts,
Cd, coded s/step, and charged SU. Preserve partial evidence on failure;
do not resubmit without new authorization. Record the result in `results/`
and this README before proposing any larger experiment.
