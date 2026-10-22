# Gadi GCC 16.2/Open MPI 5.0.10 binding audit — 2026-10-22

The user approved exactly one low-cost single-node affinity probe after its
remote-affecting script diff and 17.33 SU request ceiling were shown. The
isolated branch `codex/gadi-gcc162-build` added the PBS probe and README in
commit `84e2847835f81aaedf00c0068ac8da65843d9951`. GitHub and Gadi branch
refs matched that commit. The immutable submitted PBS copy passed SHA-256
`38f5e10105ebf08ad8560093103f1ea76550a2b79b7a4d95cb485386a8b68d34`
and `bash -n`; the independent stdout path was unused before submission.
The unrelated untracked files in the Gadi `main` checkout were preserved.

One `qsub` returned `182017185.gadi-pbs`. It requested `pm78`, `normalsr`,
one SPR node, 104 CPUs/ranks, 16 GB memory, 20 GB JOBFS and five minutes.
PBS reported `F`, `Exit_status=0`, 16 seconds walltime, 3.22 GB peak memory,
1.94 GB JOBFS and **0.92 SU**. The script recorded exit code 0 and its
evidence-complete PASS marker. All 104 ranks were observed in each of two
launches with the same `ppr:104:node` mapping and UCX PML. Default binding
gave each rank a 13-core mask within one NUMA domain; 13 ranks shared each of
the eight domain masks. `--bind-to core` gave 104 unique single-core masks.
Both policies gave 13 ranks per NUMA domain, and each world rank stayed in
the same domain across policies. See
`results/gadi-gcc162-ompi5010-scotch/binding-182017185.md` for evidence paths
and hashes. This was not a solver run and does not show a speedup.

Next action: prepare a controlled one-node 104-rank, 40-step Scotch solver
comparison only after showing its concrete script diff and obtaining the
separate approval required by root `AGENTS.md`. It must compare default versus
explicit core binding with the same source, mesh, fvSchemes, fvSolution,
solver binary, MPI settings and decomposition. Do not spend four-node SU
unless the one-node result gives a credible improvement and the user approves
a separate four-node run.
