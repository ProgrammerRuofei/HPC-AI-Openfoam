OpenFOAM Basic submission - ASPIRE2A, OpenFOAM.com v2512
=========================================================

STATUS: BASIC EVIDENCE ASSEMBLED AND VALIDATED. The full team submission is
still pending the combined Qwen + OpenFOAM presentation and Qwen materials.
See ../../README.md before upload.

Chosen Basic configuration
--------------------------
Cluster: ASPIRE2A, AMD EPYC 7713 standard CPU nodes.
Case: official occDrivAerStaticMesh coarse case, about 65 million cells.
Solver: unmodified OpenFOAM.com v2512 simpleFoam, IEEE double precision,
32-bit labels, stock Opt build. Build stack: site AOCC 5.0 and Open MPI
5.0.10-gcc11, WM_COMPILER=Amd, WM_MPLIB=SYSTEMOPENMPI. The checked remote
stock Opt rule is -O3. The source-fetch script points to the official
OpenFOAM.com v2512 tarballs and pins their MD5 values; the remote
unpacked source tree has no Git metadata. Build script and PBS wrapper are
under build/.

The decomposition is weighted Scotch, method scotch, with 128 MPI ranks per
node and no explicit binding. Per-node-count coefficients are specified in
the PBS scripts and the exact resulting input dictionaries belong in dicts/:
1 node: 128 ranks; domains (8 16), weights (1 0.01); 40 steps; job 19730482.
2 nodes: 256 ranks; domains (2 8 16), weights (1 1 0.01); 80 steps; job 20030920.
4 nodes: 512 ranks; domains (4 8 16), weights (1 1 0.01); 150 steps; job 20072244.

The existing run scripts call run/run_occdrivaer.sh. The runner sets the
per-run dictionary values, then performs the official preparation chain:
decomposePar -constant; restore0Dir -processor;
renumberMesh -constant -overwrite -parallel;
potentialFoam -initialiseUBCs -parallel;
applyBoundaryLayer -ybl 0.0450244 -parallel; simpleFoam -parallel.
These scripts reproduce the *method* in the team environment; they reference
the existing site modules, scratch installation, mesh template, and libfabric.
The package intentionally excludes binaries, mesh and processor directories.

Summary values from the copied original solver logs and coefficient files
--------------------------------------------------------------------------
Nodes  Steps  Job ID    Average wall-clock seconds/step  Cd at last step
1       40    19730482  13.34507191794872               0.43453616151492563
2       80    20030920   6.396119317455696              0.34026321604269161
4      150    20072244   2.905191457389262              0.28855096338109487

The official 4-node score is the Average wall-clock time per time step line
in the original simpleFoam log, not PBS walltime or ClockTime/150.
These are one completed run per final node count. Do not claim that the
small timing gaps between close configurations are statistically robust.

File map
--------
build/: exact source-fetch and AOCC/Open MPI build scripts from team repo.
run/: exact PBS scripts plus their shared runner from team repo.
results/{1node,2node,4node}/: retained PBS stdout/stderr, original stage and
solver logs, and same-run coefficient.dat files.
dicts/{1node,2node,4node}/: exact caseDefinition, decomposeParDict, and
controlDict from each completed case. dicts/fixed-case/ holds fvSchemes,
fvSolution and forceCoeffsAll, whose SHA256 was identical across all three.
analysis/basic_metrics_from_teammate.csv: secondary three-run registry.
scaling/scaling.csv: values extracted from the copied original logs and Cd.

Source of local scripts and PBS files: team Git checkout at
cc5861fdbc0ab6330c5cd122701bb73c7260d75d, under
references/teammate/OpenFoam-HPCAI-26 in the control repository. The shared
runner has one Unicode ellipsis in a comment replaced with ASCII dots;
executable commands are unchanged.
Remote original paths and checksums: ../REMOTE_EVIDENCE.txt.
