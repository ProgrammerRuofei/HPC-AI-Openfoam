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
Final solver, runtime-library, PBS and SU results are pending. No automatic
repeat or four-node run is authorized.
