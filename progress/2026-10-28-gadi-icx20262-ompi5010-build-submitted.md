# ICX 2026.2 / Open MPI 5.0.10 OpenFOAM build submitted

The approved compatibility probe `182372451.gadi-pbs` completed with PBS
`Exit_status=0` and `ICX20262_OMPI5010_ABI_SMOKE_PASS`; see the preceding
preflight report. This is not an OpenFOAM build or benchmark result.

The user approved one isolated OpenFOAM v2512 build with private ICX 2026.2,
retained GCC 16.2.0 runtime, private Open MPI 5.0.10, loaded UCX 1.18.1 and
UCC 1.4.4 modules, real Scotch, and the six benchmark applications. The
scientific mesh, solver source, `fvSchemes` and `fvSolution` are unchanged.
The common build script requires source identity `OPENFOAM_SOURCE_ID_V2`,
the six executables, `SCOTCH_BUILD_PASS`, a private MPI `simpleFoam` link,
and a SHA-256-checked runtime archive before `BUILD_VALIDATION_PASS`.
Actual UCX/UCC selection needs separate runtime evidence.

Local `bash -n` and `git diff --check` passed. Only the two new build scripts,
the common compiler-version gate, the stack README and preflight outcome
were committed as `9a98f66acba225567e51dfe25f0df3e80cf36f53` on
`codex/gadi-gcc162-build` and pushed to GitHub/Gadi. Gadi's checkout of
that branch was created separately from the existing `main` checkout,
fast-forward checked, and verified clean at the intended commit. Gadi
`bash -n` and SHA-256 checks matched the local scripts:

| Script | SHA-256 |
| --- | --- |
| `build_openfoam_v2512_v1.pbs` | `be321e843be2dc7d4f1b5fa30275ccc125db4ba33e994c3627911da400cf211a` |
| `build_openfoam_v2512_v1.sh` | `c6956d38813fe042f9484986cee49dea0ba44cd1298b23b78aeacb635ce05bde` |

Before submission, `nci_account -P pm78` reported 11.00 KSU available,
zero reserved, and scratch 154.96K/202K inodes. The unique stdout path was
absent. A single `qsub` returned **`182402775.gadi-pbs`**. Initial `qstat -f`
reported `Q` in `normalsr-exec`, one Sapphire Rapids node, 48 CPUs, 190 GB
memory, 100 GB JOBFS and four hours (384 SU maximum request).

Independent stdout:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010/submit-logs/build_openfoam_v2512_v1.pbs.out`.
Job-keyed build log when running:
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-ompi5010-of2512/evidence/gadi-icx20262-ompi5010-of2512.182402775.gadi-pbs/build.log`.
Final PBS exit, gates, archive hash and actual SU are pending. Do not submit
another job if this one is merely queued or running, and do not automatically
retry a failure. A tutorial run or four-node benchmark needs a new decision.
