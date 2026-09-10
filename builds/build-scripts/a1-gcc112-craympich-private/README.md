# A1 — private-source OpenFOAM v2512 rebuild on ASPIRE2A

## Purpose

Build OpenFOAM.com v2512 from a private copy of the ASPIRE2A site source.  A1
uses the exact compiler/MPI environment selected by `module load
openfoam/2512`; it is not a compiler, MPI, rank-placement, decomposition, or
scientific-workload optimisation.  Its purpose is to separate a site-supplied
binary issue from the already observed multi-node finalisation failure.

## Source and destination

- Read-only source: the `WM_PROJECT_DIR` provided by `openfoam/2512` (observed
  as `/app/apps/openfoam/2512/OpenFOAM-v2512` on 2026-09-04).
- Private source and build tree:
  `/home/project/59000020/openfoam-isc26/builds/private-source/a1-gcc112-craympich-private/OpenFOAM-v2512`.
- Evidence and PBS output:
  `/home/project/59000020/openfoam-isc26/builds/build-scripts/a1-gcc112-craympich-private/outputs/`.

The PBS job requires an absent attempt-specific private source directory.  It
uses `rsync -a` without `--delete`, preserves a source manifest and key-file
hashes, excludes upstream/generated build outputs, and refuses to accept a
binary outside the copied source tree.  It never writes under the site source.

## Attempt A1.1 — PBS environment startup failure

PBS job `16136778.pbs101` started and stopped after two seconds with
`Exit_status=1`, before source copying or compilation.  Its only retained output
was the initial `resetmodule` banner.  A read-only reproduction confirmed that
`/app/apps/resetmodule` exits when Bash `set -u` is already active, while the
same reset plus `module load openfoam/2512` succeeds without nounset.

## Attempt A1.2 — resetmodule return-status failure

PBS job `16136780.pbs101` stopped after three seconds, again before copying or
compilation.  The remote `/home/project` and `/data/projects` paths were
verified to expose identical A1.2 files.  A precise shell reproduction then
showed that `resetmodule` returns non-zero after emitting its successful reset
banner, so the temporary `set -e` still terminated the script.

## Attempt A1.3

The A1.3 repair disables both `errexit` and `nounset` only around
`resetmodule`, loads `openfoam/2512`, explicitly checks that module-load return
code, and immediately restores strict mode.  It uses the distinct
`a1_3.pbs.out` PBS output and private build root
`a1-gcc112-craympich-private-a1_3`.  A successful build requires PBS success,
a matching copied source manifest, and an executable private `simpleFoam`
binary; PBS exit status alone is insufficient.

## Attempt A1.3 — upstream bashrc return-status failure

PBS job `16136782.pbs101` completed source staging successfully: the
authoritative and private source manifests matched
`5cf984e911385f6dbde456a98dd1c0afbc7567747883053811954ec6c6779d62`.
It then stopped before compilation with `Exit_status=1`. A read-only
reproduction shows that the private `etc/bashrc` completes successfully but
contains a non-zero intermediate command that exits the caller while
`errexit` is active.

## Attempt A1.4

A1.4 disables `errexit` and `nounset` only while sourcing the copied upstream
`etc/bashrc`, captures the source return code, restores strict mode, and
explicitly requires success. It uses `a1_4.pbs.out` and the distinct private
build root `a1-gcc112-craympich-private-a1_4`.

## Attempt A1.4 — PBS CPU-variable mismatch

PBS job `16136822.pbs101` passed module initialization, source staging, source
manifest verification, private environment activation, and construction of the
private `lemon` and `wmkdepend` tools. It then stopped before ThirdParty with
`PBS_NCPUS: PBS_NCPUS is required`; this PBS environment does not export that
variable despite allocating 128 CPUs.

## Attempt A1.5

A1.5 derives the parallel build count from `getconf _NPROCESSORS_ONLN` on the
allocated compute node, validates it is positive, and uses that value for all
three upstream `Allwmake` stages. It changes neither the PBS request nor build
strategy. It uses `a1_5.pbs.out` and private root
`a1-gcc112-craympich-private-a1_5`.

## Attempt A1.5 — incomplete private source topology

PBS job `16136837.pbs101` again passed source staging, manifest verification,
private environment activation, and private wmake-tool compilation. It then
found that the site installation keeps `ThirdParty-v2512` beside, rather than
inside, `OpenFOAM-v2512`; the private copy contained only OpenFOAM and had no
ThirdParty `Allwmake` path.

## Attempt A1.6

A1.6 copies the read-only sibling `ThirdParty-v2512` to a matching private
sibling under the same attempt root, excluding only generated `platforms/` and
`build/` outputs. It explicitly sets `WM_THIRD_PARTY_DIR` to this copied tree
after private OpenFOAM environment activation. It uses `a1_6.pbs.out` and
private root `a1-gcc112-craympich-private-a1_6`.

## Deliberately unchanged

- OpenFOAM release and source content;
- compiler/MPI environment selected by the site module;
- OpenFOAM compilation options selected by its upstream `etc/bashrc`;
- mesh, solver source, dictionaries, decomposition, and run resources.

Any alternate compiler or MPI stack is a later, separately reviewed build.
