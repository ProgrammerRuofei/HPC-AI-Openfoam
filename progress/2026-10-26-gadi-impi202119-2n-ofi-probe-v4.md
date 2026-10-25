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

The reviewed script commit is `93c4779785e82fc8f8413c5028f0222795abf708`,
pushed to GitHub and fast-forwarded on Gadi's isolated branch from a
SHA-256-verified Git bundle. The staged PBS script SHA-256 is
`05ba0080bb2560cab1c8045d573db89f0f59b842e2788bcd316226228085654f`.
Exactly one `qsub` returned `182237093.gadi-pbs`. Independent stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/submit-logs/probe_impi202119_2n_v4.pbs.out`.
Job-keyed evidence:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119/evidence/impi-ofi-2n-v4.182237093.gadi-pbs/`.
The job finished PBS Exit Status 0 after 00:00:57, charging
**6.59 SU**. The private libfabric `fi_info` reported 2.6.13.
The saved `library-path.txt` contains the private libfabric directory.
Intel MPI 2021.19 loaded `libfabric.so.1` 2.6.13 and selected OFI
provider `mlx` without forcing a provider. Hydra/PBS placed rank 0 on
`gadi-cpu-spr-0718` and rank 1 on `gadi-cpu-spr-0720`.
Both ranks printed `INIT`; `MPI_Sendrecv` returned the other rank,
`MPI_Allreduce` returned sum 1, and `default_rc=0`.
The optional explicit TCP branch was skipped because the default provider
passed. Thus the two-node, two-rank default OFI communication preflight
passes. It does not validate 416 ranks, OpenFOAM, Cd or performance.
The original v1-v3 evidence remains intact. No four-node retry is
authorized by this preflight approval.
