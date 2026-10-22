# Gadi one-node core-binding comparison — 2026-10-22

After the 0.92-SU affinity probe, the user approved exactly two controlled
one-node 104-rank, 40-step Scotch solves: default binding followed by
`--bind-to core`, each capped at a 20-minute/69.33-SU request. The reviewed
script and experiment README were committed as
`a651b16d4de81c3296c2a5e595ab84d7f171f299` on the isolated
`codex/gadi-gcc162-build` branch and pushed to GitHub and Gadi. The submitted
immutable script had SHA-256
`5da574e9834a1b0129984558364c65c8b61a8ebcedb12ddf49328c34a4fa72ae`.
The Gadi control checkout remained on `main`; its unrelated untracked files
were preserved.

From `/scratch/pm78/kj7183/openfoam_cpu/control-repo`, the two submissions
used the same submitted script with separate output paths and variables:

```sh
/opt/pbs/default/bin/qsub -v BIND_POLICY=default -N gcc162_bind_default_1n -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_binding_1n_40step_v1_default.pbs.out /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_binding_1n_40step_v1.submitted.pbs
/opt/pbs/default/bin/qsub -v BIND_POLICY=core -N gcc162_bind_core_1n -o /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_binding_1n_40step_v1_core.pbs.out /scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_binding_1n_40step_v1.submitted.pbs
```

The default job `182017873.gadi-pbs` passed PBS F/Exit 0, all five stage
`End` checks, `Time = 40`, the pass marker and finite Cd. It ran 11:41,
charged **40.50 SU**, and yielded **8.373520290307694 s/step** and
**Cd 0.43806006706848422**. After verifying that terminal result, the core
job `182019151.gadi-pbs` was submitted once and passed the same checks. It
ran 11:32, charged **39.98 SU**, and yielded **8.346359078358972 s/step**
with identical Cd. Both jobs ran on the same SPR host and used identical
source/solver hashes, fvSchemes/fvSolution and decomposition statistics.
The core launch changed the mask from one 13-core NUMA domain per rank to one
distinct physical core per rank.

The observed difference is **0.32437%** in one pair, below a persuasive
effect size without repetitions. Given the user's SU limit and no-repeat
preference, the four-node confirmation gate is not met. No repeat or four-node
binding job was submitted. Detailed metrics and evidence paths are in
`results/gadi-gcc162-ompi5010-scotch/binding-1n-40step.md`.

Next: report this result to the user and choose a different, evidence-led
optimization direction only after a new explicit authorization. The existing
GCC 16.2/Open MPI 5.0.10/Scotch 4N 150-step baseline is unchanged.
