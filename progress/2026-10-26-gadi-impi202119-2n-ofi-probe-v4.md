# Intel MPI 2021.19 two-node OFI preflight v4

The v3 diagnostic `182236904.gadi-pbs` staged both nodes, proved Hydra
one-rank-per-node placement and private Intel MPI linkage, then failed
`MPI_Init` because Intel MPI could not load `libfabric.so.1`.
PBS Exit Status 0 meant only that the diagnostic script completed;
`default_rc=143` in the saved probe report, and the job charged 6.59 SU.
The original logs remain intact.

Read-only inspection of the cached official
`intel-oneapi-libfabric-2.6-2.6.13-112.x86_64.rpm` found the
`libfabric.so.1` symlink, `fi_info`, and `env/vars.sh`. The latter
exports `LD_LIBRARY_PATH` and `FI_PROVIDER_PATH`; v3 sourced only the
compiler and MPI component scripts. The user approved one v4 attempt
after reviewing the exact correction. v4 sources the private libfabric
environment, checks the SONAME symlink and `fi_info`, then runs the
same two-node two-rank communication probe with unique output paths.
No four-node solver or automatic repeat is authorized.
