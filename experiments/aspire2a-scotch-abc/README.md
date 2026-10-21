# Scotch topology and weight A/B/C study

Status: **local proposal; no job submitted**.

Purpose: separate the effect of adding the Scotch topology (`domains (4 8 16)`) from the effect of changing its `domainWeights`. A is plain Scotch, B uses `(1 1 1)`, and C uses `(1 1 0.01)` with the same domains. B is a controlled topology arm; it is **not assumed equivalent** to A.

The preflight PBS job decomposes B and C on compute nodes and checks 512 partitions. Only after its output confirms that OpenFOAM v2512 accepts both dictionaries should the three full PBS jobs be submitted. The full jobs use a counterbalanced order: A-B-C, B-C-A, C-A-B. Each arm starts from a separate copy of the pinned 65M-cell template, uses the existing AOCC 5.0 / Open MPI 5.0.10 stock Opt build, 4 nodes and 512 ranks, 150 solver steps, the established `ppr:128:node` launcher, and no explicit core binding or profiler.

Each job writes a fresh PBS-ID case tree and refuses to reuse it. All solver logs, coefficient files, input hashes, decomposition logs, partition-boundary hashes, rank affinity, and job exit status remain there. PBS stdout and stderr land in `outputs/`. No script deletes or overwrites an existing case. Scientific workload files (`mesh`, `simpleFoam`, `fvSchemes`, `fvSolution`) are unchanged.

Existing one-off reference results: A job `20064271`, 2.912440185442953 s/step, Cd(150) 0.284050597; C job `20072244`, 2.905191457389262 s/step, Cd(150) 0.288550963. These are not repeats and do not demonstrate stable superiority.

After all jobs finish, check PBS exit status, 150 step markers, the exact average wall-clock line, new 150-row `coefficient.dat` and Cd, input/binary hashes, rank mappings, and partition evidence before comparing paired differences. Do not select a winner from one minimum. PMPI comparisons are a later, separately controlled diagnostic if a stable timing effect is observed.
