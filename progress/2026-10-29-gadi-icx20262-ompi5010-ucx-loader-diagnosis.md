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

## Diagnostic v1 result and bounded repair

`182508262.gadi-pbs` finished with PBS `Exit_status=1` after 18 seconds
(about 0.02 SPR SU at 2 CPUs). Its job-keyed evidence remains under
`evidence/ucx-loader-diag.182508262.gadi-pbs/`. Both original and UCX-first
`LD_LIBRARY_PATH` orders resolved `libucp`, `libucs`, and `libuct` from
`/usr/lib64`. The private `libmpi.so.40` and `libopen-pal.so.80` both carry
`DT_RPATH` with `/usr/lib64` before `/apps/ucx/1.18.1/lib`, explaining why
merely prepending `LD_LIBRARY_PATH` did not select site UCX. The first fatal
error was later: archived `mpicc` points to a vanished JOBFS GCC path, so the
two-rank probe never started. This is not a UCX runtime result.

The proposed v2 diagnostic keeps the same 2-CPU allocation but uses the
hash-checked GCC binary directly to compile the probe. It sets `LD_PRELOAD`
for all four site UCX libraries (`ucs`, `ucm`, `uct`, `ucp`), checks the
preloaded `ldd` resolution, then requires both MPI ranks to report the actual
`/apps/ucx/1.18.1/lib/libucp.so.0` path and version `1.18.1` after
`MPI_Init`. Its stdout and evidence are unique. This changes runtime library
selection for a diagnostic only; the four-node scientific run remains gated
on a passing OpenFOAM tutorial smoke with the same selection.

## Diagnostic v2 result and OpenFOAM gate

`182508303.gadi-pbs` completed with PBS `Exit_status=0` in 23 seconds
(about 0.03 SPR SU),
`UCX118_RUNTIME_PROBE_PASS`, and `probe_exit_status=0`. Both ranks reported
`/apps/ucx/1.18.1/lib/libucp.so.0`, version `1.18.1`, after `MPI_Init`.
The original path-order `ldd` still found `/usr/lib64/libucp.so.0`; explicit
preloading of the site UCX family changed the actual runtime selection.
Evidence is retained under `evidence/ucx-loader-diag-v2.182508303.gadi-pbs/`.
The MPI output also contains a UCX warning that a component requested UCP
API >=1.19 while 1.18.1 was loaded. The two-rank collective completed, but
this warning needs attention in the solver smoke and cannot be labelled a
clean four-node validation by itself.

Prepared `smoke_openfoam_v2512_ucx118_v2.pbs` retains the prior five-rank
Scotch tutorial controls and hash-pinned archives. It adds the same UCX
preload after environment setup, requires the actual UCP path/version after
MPI initialization, then requires complete `simpleFoam` output and coded
per-step timing. It has a unique stdout and evidence path; no scored case
is touched. The four-node run remains gated on this job succeeding.

`182508353.gadi-pbs` (smoke v2) completed with PBS Exit 0 after 1:23,
approximately 0.23 SPR SU, and
`OF2512_ICX20262_OMPI5010_UCX118_SMOKE_PASS`. Five-rank Scotch
decomposition, private MPI `simpleFoam`, coded average wall-clock output,
`Finalising parallel run`, and `End` all passed. Both probe ranks reported
site UCP 1.18.1. However, the probe and solver logs still printed
`UCP API version is incompatible: required >=1.19, actual 1.18.1` while
Open MPI's verbose collective selection showed site HCOLL enabled with
priority 90 and UCC unavailable. The warning is not a solver failure but
would obscure the four-node attribution.

`smoke_openfoam_v2512_ucx118_v3.pbs` is a distinct 5-rank, 20-step
diagnostic to exclude only HCOLL using `--mca coll ^hcoll`. It keeps the
same archives, UCX preload, Scotch, tutorial and resource limit, records
collective selection and requires no incompatible-UCP warning as well as
the prior solver-completion gates. The high-cost four-node job remains
unsubmitted while this compatibility question is resolved.

`182508439.gadi-pbs` (v3) finished PBS Exit 0 after 1:22, about 0.23 SPR
SU, with `OF2512_ICX20262_OMPI5010_UCX118_NOHCOLL_SMOKE_PASS`.
Both MPI-initialized probe ranks loaded site UCP 1.18.1. Open MPI selected
the `tuned` collective in the verbose two-rank probe; five-rank Scotch
decomposition and `simpleFoam` reached `End` with coded timing. Neither
probe nor solver log contained the incompatible-UCP warning. UCC 1.4.4 was
loaded and linked but was not selected as the collective component; do not
claim UCC runtime use.

Before committing up to 832 SU to four nodes, the next small gate is
`preflight_ucx118_2n_v1.pbs`: two SPR nodes, one MPI rank per node, site
UCX preload, `--mca coll ^hcoll`, hash-pinned GCC/Open MPI archives, actual
UCP path/version and cross-node `MPI_Allreduce` checks. It requests 208
CPUs for at most 10 minutes (about 69.3 SU ceiling) but should finish in
well under a minute if healthy. Its stdout/evidence paths are unique.

`182508496.gadi-pbs` finished PBS Exit 0 in 36 seconds (about 4.16 SPR SU)
with `ICX20262_OMPI5010_UCX118_2N_PASS`. PBS allocated distinct
`gadi-cpu-spr-0248` and `gadi-cpu-spr-0249` nodes. One rank on each node
completed a cross-node `MPI_Allreduce`, and both reported the actual site
`/apps/ucx/1.18.1/lib/libucp.so.0` and UCP version `1.18.1`. No
incompatible-UCP warning appeared. The harmless site-module variables
`UCX_ROOT`, `UCX_VERSION` and `UCX_BASE` were reported as unused by UCX.
The job-keyed evidence remains under `evidence/ucx118-2n.182508496.gadi-pbs/`.

The single authorized four-node comparison can now be prepared using ICX
2026.2, the same private Open MPI 5.0.10 and site UCX preload, with HCOLL
excluded. The fixed source case, mesh, `fvSchemes`, `fvSolution`, Scotch,
416 ranks across four SPR nodes, and 150 steps match the established
four-node template. Its scientific result will be a new candidate; since
the collective path differs from older runs, any performance difference
cannot be attributed to the compiler alone.
