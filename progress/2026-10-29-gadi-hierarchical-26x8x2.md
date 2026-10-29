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
