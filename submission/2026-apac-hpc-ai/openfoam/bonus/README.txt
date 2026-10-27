OpenFOAM Bonus evidence - keep separate from Basic
==================================================

The Basic weighted Scotch result is documented in ../README.txt. Under the
official F2 rule, a Bonus result cannot replace the Basic submission.

AOCC Opt KaHIP method comparison
--------------------------------
The 1node/, 2node/ and 4node/ directories contain the original stage and
solver logs, coefficient.dat, input dictionaries, PBS scripts and PBS output
for AOCC 5.0 + Open MPI 5.0.10, stock Opt, 128 ranks per node, no explicit
binding, and KaHIP config fast. The same common run_occdrivaer.sh used for
Basic is at ../run/run_occdrivaer.sh. The same AOCC build is under ../build/.

Nodes  Steps  Job ID    Average seconds/step       Final Cd
1       40    19399157  13.30693129451282         0.43638202288867967
2       80    20017437   6.407679841354432        0.34021478185909348
4      150    20030922   2.875901458550335        0.28004374694886786

At 4 nodes, the KaHIP Opt run is 1.01% lower in seconds/step than the Basic
weighted Scotch run (2.875901 vs 2.905191). These are individual runs, so
the small difference is sensitive to run-to-run noise. The differing method
and its coefficients are visible in the exact input dictionaries. A diff
of each Basic/Bonus caseDefinition pair shows only the decompositionMethod
line changing from scotch to kahip. The other method-specific settings are
in decomposeParDict. This is the method-only Bonus comparison under F2.

Additional PGO + binding candidate
----------------------------------
optimized-4node/ contains job 21252868, AOCC PgoUse + KaHIP + core binding:
2.867853826825502 seconds/step, Cd(150) 0.28004374694886786. Its 150-row
coefficient.dat is byte-identical to the AOCC Opt KaHIP 4-node run. Exact
build and training scripts plus the added wmake rules patch are under
optimized-4node/build/. Binary profile data and executables are excluded.

This run changes PGO and binding in addition to using KaHIP relative to the
submitted Basic configuration. It is preserved as an observed candidate,
but the package does not assert that it satisfies the F2 method-only
exception or a complete F3 1/2/4-node self-proof for those additional
changes. Do not label it as a fully proved Bonus claim without that review.

The original 1/2/4 KaHIP logs and Cd were checked for the required step
counts, the log's Average wall-clock time per time step, final Cd, End marker,
and remote SHA256 of the solver log and coefficient.dat. The optimized
4-node candidate passed the same checks. All four runs use text evidence.
