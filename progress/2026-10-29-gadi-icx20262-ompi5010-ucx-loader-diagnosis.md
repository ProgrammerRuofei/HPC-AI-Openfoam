# Gadi private Open MPI UCX loader diagnosis — 2026-10-29

The prior path-gated smoke `182508155.gadi-pbs` stopped before MPI
initialization because `simpleFoam.ldd` found system `/usr/lib64/libucp.so.0`
after the site UCX path had been placed ahead of the prior library path.
The original output remains in its job-keyed evidence directory. The user
authorized bounded automatic diagnosis and low-cost repair attempts, then a
four-node run only after a small verification demonstrates the intended
runtime and functioning OpenFOAM solver.

Read-only `readelf -d` on Gadi shows site UCX 1.18.1 `libucp.so.0` and site
UCC 1.4.4 `libucc.so.1` both carry RPATH
`/apps/ucx/1.18.1/lib`. Site `libhcoll.so.1` carries RPATH
`/opt/mellanox/hcoll/lib`. This does not establish the private MPI ELF tags
or the reason for the earlier system-library selection.

The new `diagnose_ucx_loader_1n_v1.pbs` requests `pm78` `normalsr`, one SPR
node, 2 CPUs, 8 GB, 10 GB JOBFS and 10 minutes (maximum about 0.67 SU). It
checks the existing GCC 16.2 and Open MPI 5.0.10 archive hashes, extracts
only those archives into JOBFS, records relevant ELF tags and `ldd` under
the original and UCX-first path orders, captures a bounded loader search,
then runs a timeout-protected two-rank MPI-initialized UCP path/version probe.
The job does not run the fixed 65M case or the tutorial. Probe status is
recorded separately from diagnostic completion. Output paths are unique.

Local `bash -n` and both SHA-constant format checks passed; script SHA-256
is `6813d29b7323f734110aac07be723e8ecb4f548cc0311483ff7d22d0eae00d4d`.
Next: inspect the relevant diff, commit only task files, push GitHub/Gadi,
fast-forward the Gadi checkout, verify the script and unique output path,
submit once, and analyze the retained loader evidence. No four-node job may
proceed until a small solver smoke verifies the actual UCP path and version.
