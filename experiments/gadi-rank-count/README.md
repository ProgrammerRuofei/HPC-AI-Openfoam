# Gadi GCC16.2/Open MPI5.0.10 Scotch one-node rank-count comparison

The selected 1N Scotch baseline is PBS `182017873.gadi-pbs`: 104 ranks,
40 steps, default Open MPI binding, 8.373520290307694 s/step, final Cd
0.43806006706848422 and 40.50 SPR SU. This experiment compares 104 and
96 ranks sequentially on **the same allocated Sapphire Rapids node** to
reduce host-to-host timing variation. It is a diagnostic, not a scored
four-node result.

`run_rankcount_1n_40step_ab_v1.pbs` requests `pm78/normalsr`, one
104-core SPR node, 190 GB memory, 100 GB JOBFS and at most 40 minutes
(approximately 138.67 SPR SU requested ceiling). Both arms use the pinned
GCC 16.2.0, private Open MPI 5.0.10, OpenFOAM.com v2512 and real Scotch
6.1.0 archives from the completed baseline. UCX 1.18.1 and UCC 1.4.4
modules are loaded; the existing stack's effective UCP version and
collective selection remain unproven. The MPI launcher uses
`--map-by ppr:<ranks>:node --mca pml ucx -np <ranks>` without an explicit
binding override. The only intentional arm-level change is 104 versus 96
ranks, including `nCores` and the corresponding Scotch partition.

Each arm receives a separate copied case and evidence directory. Source,
archive, solver binary, mesh and scientific-input SHA-256 gates follow the
validated 1N script. The full `decomposePar -constant`, `restore0Dir
-processor`, `renumberMesh -constant -overwrite -parallel`,
`potentialFoam -initialiseUBCs -parallel`, `applyBoundaryLayer -ybl
0.0450244 -parallel` and `simpleFoam -parallel` chain is required.
Evidence includes stage logs, processor counts, rank affinity and binding,
the coded mean s/step, final `coefficient.dat`/Cd, PBS exit and actual SU.
Both arms must reach `Time = 40`, `End` and Cd in the 0.42–0.45
sanity band. The script never touches the original case or previous runs.

This pair can reject an obviously poor 96-rank candidate; a small one-pair
gain does not establish a four-node win. Any two/four-node follow-up
requires separate review and authorization. Preserve the job-keyed logs
and do not automatically repeat this job.

## Completed same-node A/B result

The reviewed script and this README were committed as `3dc32da`, pushed
to the isolated GitHub and Gadi branches, and verified at the same commit
and script SHA-256 `dccc848a9f9f65c7dc219f6faf816f72385b41446ea3d5d067b412a1292745e8`
in the Gadi branch checkout. A single `qsub` returned
`182509859.gadi-pbs`. The first `qstat -f` showed `Q`, 104 CPUs and
00:40:00 requested. PBS stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_rankcount_1n_40step_ab_v1.pbs.out`;
job-keyed evidence is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/rank-count-1n-40step/182509859.gadi-pbs/evidence/`.
PBS finished with `Exit_status=0` and both arm-level PASS markers plus the
aggregate PASS marker. The two arms ran on the same
`gadi-cpu-spr-0002.gadi.nci.org.au` node, with 104 and 96 affinity rows
respectively. Both full preparation chains and solvers ended at `Time = 40`;
the case-input SHA-256 manifests match byte for byte.

| Arm | Coded mean s/step | Final Cd | Processor faces |
| --- | ---: | ---: | ---: |
| 104 ranks | 8.296121226410254 | 0.43806006706848422 | 1,420,042 |
| 96 ranks | 8.978244996461541 | 0.44034575240845725 | 1,358,817 |

The 96-rank arm was **8.22% slower** (+0.6821 s/step), despite having
4.31% fewer processor faces. Both Cd values are within the prespecified
0.42–0.45 sanity band. This one paired 40-step result argues against
spending four-node SU on 96 ranks/node now; it does not establish why
the 96-rank arm is slower or predict a 384-rank four-node result. The
104-rank arm is 0.92% faster than the earlier independent 104-rank run,
which illustrates normal run-to-run variation.

PBS used 00:22:48 walltime and charged **79.04 SPR SU** (104 CPUs,
190 GB memory, 100 GB requested JOBFS; reported JOBFS use 39.8 GB).
The detailed result and evidence locations are in
`results/gadi-gcc162-ompi5010-scotch/rank-count-1n-40step.md`.
