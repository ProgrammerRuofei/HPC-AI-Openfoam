# Gadi GCC16 hierarchical `(26 8 2)` controlled comparison

The user approved only the GCC 16.2/Open MPI 5.0.10 four-node
hierarchical `(26 8 2)` run, after reviewing its intended single-factor
diff against completed `(26 16 1)` job `182558696.gadi-pbs`. The ICX
version and future ICX jobs remain for discussion and are not submitted.

The new local script is
`builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs`.
Its source template is the successful `(26 16 1)` script. Only the tuple,
derived identifiers, unique stdout/job-keyed output paths, and pass
marker changed. `bash -n` passed and the local `diff -u` matched this
scope. No scientific input, compiler, MPI, launcher, binding, resource,
or preparation-chain change was made.

Gadi `pm78/normalsr`: four Sapphire Rapids nodes, each 104 CPUs and
104 MPI ranks, 416 ranks total, 760 GB RAM, 100 GB JOBFS, one-hour
request (832 SU maximum). OpenFOAM v2512 uses the fixed approximately
65M-cell case and 150 solver steps. Source and runtime archive hashes
remain pinned in the script. The pre-submit pm78 report had 10.38 KSU
available, zero reserved, and 156.87K/202K scratch inodes used.

Next: review the exact local diff and script hash; commit only the new
script and these records to `codex/gadi-gcc162-build`, push GitHub/Gadi,
verify the remote checkout and script hash, then submit this script once
with a unique stdout path. Check PBS exit, all pass markers/logs, rank
map, Cd, coded seconds/step, and actual SU. Do not submit any ICX job or
automatic repeat.

## Submission

The reviewed script and initial records were committed as
`02db39c92b058ccc80ae311f88cec9d1e47642ae` and pushed to the
existing GitHub/Gadi isolated branches. The Gadi execution checkout
was already at that commit; `git pull --ff-only` from the Gadi source
repository reported `Already up to date`. Local and remote script
SHA-256 both equalled
`f294fa2b0ded85bdec585d16551e012019089e67707482215f8ed4c7ea1c9cd0`.
Remote `bash -n` passed, and unique stdout did not exist beforehand.

The exact one-time submission from the execution checkout was:

```sh
/opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs
```

PBS returned **`182561241.gadi-pbs`**. Initial `qstat -f`: `Q` in
`normalsr-exec`, 4 × 104 CPUs/ranks, one hour and 100 GB JOBFS.
Independent stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_hierarchical_26x8x2_v1.pbs.out`.
Job-keyed evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-hierarchical-26x8x2/182561241.gadi-pbs/evidence/`.
Final result and actual SU are pending; do not submit a repeat or ICX job.
