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
Local syntax/diff checks completed; remote synchronization and one PBS
submission are pending. The isolated branch is `codex/gadi-gcc162-build`;
main and preexisting unrelated untracked files remain untouched.
