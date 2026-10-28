# Gadi ICX 2026.2 / Open MPI 5.0.10 candidate

The first approved action is a small one-node compatibility preflight.
`smoke_icx_ompi_1n_v1.pbs` checks private ICX/ICPX 2026.2.0 against the
already validated GCC 16.2.0-built Open MPI 5.0.10 archive, loading Gadi
UCX 1.18.1 and UCC 1.4.4. It uses `normalsr` Sapphire Rapids, four CPUs,
16 GB RAM, 30 GB JOBFS and 20 minutes (about 2.67 SU request ceiling).
The Intel archive is SHA-256 checked and extracted in JOBFS, but only its
compiler environment is sourced; its Intel MPI is not selected. The
preflight compiles an MPI C++ program with ICX, checks its private Open MPI
link, and runs two ranks over UCX. Logs are job-keyed on pm78 scratch.

This preflight does not build OpenFOAM or produce a scored result. A later
OpenFOAM v2512 build would retain the verified source identity, `Opt`,
real Scotch and six benchmark application gates. A four-node performance
run requires separate approval.

The first approved preflight was submitted once as `182372451.gadi-pbs`.
PBS finished with `Exit_status=0` after 41 seconds and the
`ICX20262_OMPI5010_ABI_SMOKE_PASS` marker. ICX 2026.2.0 compiled a two-rank
program linked to the private Open MPI 5.0.10 `libmpi`. The Gadi UCX/UCC
modules were loaded, while `ldd` resolved `libucp.so.0` from `/usr/lib64`;
the effective UCP version and collective selection remain unverified.

The next approved action is one OpenFOAM build in a fresh JOBFS. The v1 build
scripts use the same verified compiler/GCC/MPI archives, preserve source
identity, require real Scotch and six benchmark executables, and archive the
runtime with a checked SHA-256. PBS requests one `normalsr` SPR node,
48 CPUs, 190 GB memory, 100 GB JOBFS and four hours (384 SU ceiling).
This build is not a performance result; a tutorial smoke test requires its
own subsequent decision.

The build was submitted exactly once as `182402775.gadi-pbs` from reviewed
commit `9a98f66` after the Gadi branch and script SHA-256 checks. Its first
PBS state was `Q` in `normalsr-exec`. The unique stdout is under this stack's
`submit-logs/build_openfoam_v2512_v1.pbs.out`; job-keyed build evidence is
under `gadi-icx20262-ompi5010-of2512/evidence/`.

Read-only inspection on 2026-10-28 found PBS `Exit_status=0`, walltime
`00:41:12`, and 65.92 SU. All six `BENCHMARK_APP_PASS` markers, real
`SCOTCH_BUILD_PASS`, and `BUILD_VALIDATION_PASS` are present. `simpleFoam`
links to the private Open MPI 5.0.10 `libmpi.so.40`. Its SHA-256 is
`d0125c49d047afd5e42164438d0a10af0c2a7310fa9b99fcabc41614275bb181`;
the checked runtime archive SHA-256 is
`73f62f4b06df806a7409a9a45d3de02d3cfb59b227fbe99fa2254305ccd5d2f5`.
This is a successful build, not an OpenFOAM run or performance result.
The retained `ldd` output resolves `libucp.so.0` from `/usr/lib64` despite
loading the UCX 1.18.1 module; the actual UCP version and collective
selection require a runtime diagnostic before a four-node comparison.

The user approved one low-cost tutorial smoke after reviewing its proposed
diff. `smoke_openfoam_v2512_v1.pbs` reuses the hash-pinned successful build,
the private compiler/GCC/MPI archives and the established five-rank
`pitzDaily_fused` Scotch tutorial. It records the UCP library path, the
version returned after `MPI_Init`, its SHA-256, and Open MPI's collective
selection messages without forcing UCC. The request is one `normalsr` SPR
node, 5 CPUs, 16 GB memory, 30 GB JOBFS and 20 minutes (about 1.67 SU
ceiling). This does not run the fixed 65M scientific case.

The reviewed smoke script passed local and Gadi `bash -n`, with matching
SHA-256 `9e2bfeb6ec2cd7d06b21e39386b3ae9c9e3e72986e34131fb2c679b80aa249f7`.
Commit `0a203c4` was pushed to the isolated GitHub and Gadi branches; the
Gadi checkout was clean at that commit. Exactly one PBS submission returned
`182469604.gadi-pbs`, initially `Q` in `normalsr-exec`. Its independent
stdout is `gadi-icx20262-ompi5010/submit-logs/smoke_openfoam_v2512_v1.pbs.out`
under the toolchain-screening root; job-keyed evidence will be under
`gadi-icx20262-ompi5010-of2512/evidence/smoke.182469604.gadi-pbs/`.
No automatic repeat or four-node run is authorized.

The smoke job subsequently finished with PBS `Exit_status=0`, walltime
`00:01:14`, and 0.21 SU on `gadi-cpu-spr-0611`. The job-keyed exit file says
`pbs_exit_status=0`; the log ends with
`OF2512_ICX20262_OMPI5010_SMOKE_PASS`. `decomposePar` records real Scotch,
and the five-rank `simpleFoam` reaches tutorial `Time = 20`, coded timing,
`End` and `Finalising parallel run`. Its tutorial average is
`0.003752561789473684` s/step and is **not** a 65M-case performance result.
The binary links to private Open MPI 5.0.10.

After `MPI_Init`, both ranks in the separate two-rank communication probe
loaded `/usr/lib64/libucp.so.0`, whose own version string is **1.21.0** and
SHA-256 is `c5f993ab980f2bc736fe34cfb933acd6fb4d767444f6d64c3326766908277abc`.
The modules `ucx/1.18.1` and `ucc/1.4.4` were loaded; `ldd` found
`libucc.so.1` in `/apps/ucc/1.4.4/lib`. The probe's verbose selection log
disqualified UCC and selected `hcoll` for the two-rank communicator. This
selection is probe evidence, not a claim that every collective in the
five-rank solver used the same component. Do not label the effective UCX
runtime as 1.18.1 or the run as UCC-backed. No further run is authorized by
this smoke approval.

On 2026-10-29, the user separately approved one small UCX 1.18.1 path check
after seeing the proposed difference. The new
`smoke_openfoam_v2512_ucx118_v1.pbs` leaves the prior output intact. It
reasserts `/apps/ucx/1.18.1/lib` after compiler/OpenFOAM setup, checks the
site `libucp.so.0` SHA-256
`f983f10603d6b9e623f1d3a0ef0f2a69c54a41e7a72c0c41e8694cfabaf588a7`,
requires the two-rank probe to load that path and report 1.18.1, then runs
the same five-rank, 20-step Scotch tutorial. UCC is not forced. Allocation
remains one `normalsr` SPR node, 5 CPUs, 16 GB, 30 GB JOBFS, 20 minutes,
at most about 1.67 SU. The new script and output paths are unique. This
does not authorize a four-node run or a repeated job.

The script was committed as `c3753cb`, pushed to both isolated branches and
verified on Gadi with SHA-256
`e46f2be4c93d514ed5404b1946514157f2da2859577cdb100fcd040a159b967d`.
One `qsub` returned **`182508155.gadi-pbs`**, initially queued. Its stdout
and job-keyed evidence paths are recorded in
`progress/2026-10-29-gadi-icx20262-ompi5010-ucx118-smoke.md`. The PBS and
runtime results are pending; the approval covers no repeat.

The UCX path smoke ended `F`, PBS `Exit_status=1`, 1:00 walltime and
**0.17 SU** on `gadi-cpu-spr-0215`. Archive and version checks passed, but
`simpleFoam.ldd` still resolved `libucp.so.0` and related UCX libraries
from `/usr/lib64`. The first failure was the hard path check for
`/apps/ucx/1.18.1/lib`; the MPI probe and tutorial did not run. Both the
independent stdout and job-keyed run log are retained. Explicitly prepending
the site path after environment setup was insufficient; the loader cause
remains unconfirmed. No automatic retry or four-node run was submitted.
