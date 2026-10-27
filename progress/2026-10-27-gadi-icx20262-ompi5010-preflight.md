# ICX 2026.2 / Open MPI 5.0.10 compatibility preflight

The user approved one low-cost one-node two-rank preflight after reviewing
the intended difference from the 2025.3.2 module-based probe. The script is
`builds/build-scripts/gadi-icx20262-ompi5010/smoke_icx_ompi_1n_v1.pbs`.
It uses the verified private ICX 2026.2 archive, retained GCC 16.2.0 and
Open MPI 5.0.10 archives, and Gadi UCX 1.18.1 / UCC 1.4.4 modules.
The Intel MPI in the compiler archive is not sourced. The job requests
pm78 `normalsr`, one SPR node, four CPUs, 16 GB RAM, 30 GB JOBFS and
20 minutes. An OpenFOAM build and four-node run are outside this approval.

Accept only PBS Exit 0, the `ICX20262_OMPI5010_ABI_SMOKE_PASS` marker,
compiler and MPI versions, the private `libmpi` link, both MPI ranks and
UCX transport. Record the exact job ID, actual SU and evidence paths after
submission. No automatic repeat is approved.
