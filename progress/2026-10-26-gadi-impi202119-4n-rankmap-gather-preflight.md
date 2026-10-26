# Four-node Intel MPI rank-map gathering preflight

The user approved correcting the interleaved rank-map diagnostic and one
short four-node validation, while requiring a separate stop before another
large 65M-cell solve. Job `182277272.gadi-pbs` ended Exit 1 at the
rank-map text gate after 3:06 and 42.99 SU; its MPI launcher returned,
but multiple `printf` calls from 416 ranks produced mixed lines. The
scientific case had not been copied or decomposed.

The new script is
`builds/build-scripts/gadi-icx20262-impi202119/probe_impi202119_4n_rankmap_gather_v1.pbs`.
It requests pm78 / Gadi `normalsr`, four Sapphire Rapids nodes, 416 CPUs,
416 Intel MPI ranks at 104 per node, 190 GB memory, 20 GB JOBFS, and a
six-minute limit (83.2 SU ceiling). It loads the same private ICX 2026.2,
Intel MPI 2021.19 and libfabric 2.6.13 archive. Only a small C/MPI
placement probe runs; OpenFOAM and the 65M-cell case are not staged.

Each rank formats one row in memory and participates in `MPI_Gather`;
rank zero alone prints the 416 rows. The post-launch gate checks every
rank exactly once, four expected hosts with 104 ranks each, and a
non-empty affinity mask. Local `bash -n`, C syntax checking with MPI/sched
API stubs, and positive/negative AWK gate fixtures passed. The original
v2 evidence remains untouched. Record the new PBS ID, status, marker,
host counts, walltime and actual SU here after submission/completion.

## Submission

Reviewed commit `4916e9670ae0a80aec896a675815cbd976908ee5` was pushed to
GitHub and fast-forwarded on Gadi's isolated branch. The staged PBS script
passed remote `bash -n` and matched local SHA-256
`7687eeac6d117c82030fe62f4e8182dbe1c4d34039dfe1de0d38bb2b48c4f973`.
Exactly one `qsub` returned `182291343.gadi-pbs`. Initial PBS state was
`Q`, with 416 CPUs, 190 GB memory, 20 GB JOBFS and a six-minute walltime.
Independent stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/probe_impi202119_4n_rankmap_gather_v1.pbs.out`;
job-keyed evidence will be under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/evidence/impi-rankmap-4n-gather-v1.182291343.gadi-pbs/`.
Do not resubmit on an unknown status or proceed to the 65M solve without
reviewing this result and the separate large-run approval.

## Final outcome

`182291343.gadi-pbs` finished PBS state `F`, `Exit_status=0`, walltime
`00:01:47`, with **24.73 SU** charged. The four node-local stages passed.
The run log contains `IMPI202119_4N_RANKMAP_GATHER_PASS`; the gathered
map has exactly 416 records and zero MPI stderr bytes. Host counts were:

| SPR host | MPI ranks |
| --- | ---: |
| `gadi-cpu-spr-0088.gadi.nci.org.au` | 104 |
| `gadi-cpu-spr-0105.gadi.nci.org.au` | 104 |
| `gadi-cpu-spr-0106.gadi.nci.org.au` | 104 |
| `gadi-cpu-spr-0107.gadi.nci.org.au` | 104 |

All 416 ranks reported affinity to exactly one CPU, with zero duplicate
host/CPU masks. The script checked ICX 2026.2.0, Intel MPI 2021.19.0,
private libfabric 2.6.13, and the private Intel MPI library. The archive
SHA-256 gate and each node's extraction marker passed. This validates
four-node MPI startup, gather, placement and CPU affinity for the private
toolchain. It does not provide OpenFOAM correctness, Cd or step time.

The next large step would be a separately approved v3 full scientific run
that adopts the gathered rank-map gate and preserves the original mesh,
source, fvSchemes, fvSolution, Scotch decomposition, 416 ranks and 150 steps.
No full run has been submitted on the basis of this preflight.
