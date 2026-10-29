# Gadi hierarchical (26 16 1) controlled comparison

The user asked for one Gadi four-node run using the same GCC 16.2.0,
private Open MPI 5.0.10, and OpenFOAM v2512 stack as the completed
hierarchical `(16 13 2)` control. The official rules permit the
`nHierarchical` setting in Basic, and 26 × 16 × 1 = 416 ranks.

The new script copies the validated four-node hierarchical script and
changes only the tuple, unique PBS/job-keyed paths, and pass marker.
It retains four `normalsr` SPR nodes, 104 ranks/node, Scotch-free
hierarchical decomposition, default binding, fixed approximately 65M
mesh and scientific controls, the entire preparation chain, and 150
solver steps. The previous `(16 13 2)` result was 2.058549642 s/step,
Cd 0.282306143 and 188.36 SU; the two GCC/Scotch results averaged
1.989910155 s/step and Cd 0.291875949. This experiment does not change
the selected Scotch performance baseline before a valid outcome exists.

The PBS request ceiling is 832 SU (416 CPUs × one hour × 2 SU/core-hour).
Pre-submit account inspection reported 10.57 KSU available, zero SU
reserved, and 156.25K/202K scratch inodes used.
The reviewed script is
`builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_26x16x1_v1.pbs`.
Local syntax and exact single-factor diff checks passed. Commit
`edbd0a133eff9eb71a3fb8576a5d28dab7223d62` was pushed to the
isolated GitHub and Gadi branches. The Gadi checkout HEAD and script
SHA-256 matched the local copy; remote `bash -n` passed. The script
hash is `2c68fb9a13735919a0f9b542594ebf6ee862420180ff808b94b7c3c4838e78c5`.
The unique PBS stdout path was absent before submission. The exact
single remote submission command was:

```sh
cd /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/control-repo
/opt/pbs/default/bin/qsub builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_26x16x1_v1.pbs
```

PBS returned **`182558696.gadi-pbs`**. Its first `qstat -f` showed
`Q` in `normalsr-exec`, `select=4:ncpus=104:mpiprocs=104`, 416 CPUs,
100 GB JOBFS and one-hour walltime. Independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_hierarchical_26x16x1_v1.pbs.out`;
job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-hierarchical-26x16x1/182558696.gadi-pbs/evidence/`.
At submission, the final result and actual SU were pending. That
submission did not authorize another four-node job or a baseline change.
Main and preexisting unrelated untracked files remain untouched.

## Completed result

Job `182558696.gadi-pbs` completed with PBS `Exit_status=0`, script
`GCC162_OMPI5010_OF2512_HIERARCHICAL_26X16X1_4N_PASS`, and NCI receipt
**187.89 SU** for 13:33 walltime. Four SPR hosts each had 104 ranks;
source and three runtime archive SHA-256 gates plus the `simpleFoam`
binary gate passed, and `ldd` resolved private Open MPI 5.0.10.
`decomposePar`, `renumberMesh`, `potentialFoam`, `applyBoundaryLayer`, and
`simpleFoam` all ended normally. The solver reached `Time = 150` and
finalised MPI. Coded mean **2.05394946522819 s/step**, final
**Cd 0.28866830865734072**, solver ClockTime 317 s. Cell counts were
157,054–157,065/rank; processor faces were 9,208–36,459/rank.
This is 0.223% faster than the single `(16 13 2)` run but 3.218% slower
than the two-run Scotch mean. No repeat or additional PBS job was
submitted, and the Scotch performance baseline remains in place.
