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
