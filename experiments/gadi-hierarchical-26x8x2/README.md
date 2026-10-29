# Gadi GCC16.2 hierarchical `(26 8 2)` four-node comparison

This is the one four-node job approved after review of the proposed
single-factor diff. ICX jobs are outside this approval. The comparison
uses the same GCC 16.2.0, private Open MPI 5.0.10, OpenFOAM v2512
archives and Gadi `normalsr` four Xeon Platinum 8470Q nodes as the
completed hierarchical `(26 16 1)` run `182558696.gadi-pbs`.

The script is
`builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_26x8x2_v1.pbs`.
It changes only `nHierarchical` from `(26 16 1)` to `(26 8 2)` and the
unique PBS name, stdout, job-keyed scratch/JOBFS paths, provenance label,
and pass marker. Both tuples multiply to 416. The launcher retains
`--map-by ppr:104:node` with no explicit binding override, for 104 MPI
ranks per node. The module environment loads `ucx/1.18.1` and
`ucc/1.4.4`; the effective UCX library and collective selection of a
historical run cannot be inferred solely from those module names.

The approximately 65-million-cell `occDrivAerStaticMesh` mesh, official
v2512 `simpleFoam`, `fvSchemes`, `fvSolution.fixedIter`, other physics,
`order xyz`, `delta 0.001`, and 150 solver steps stay fixed. The whole
Allrun chain runs: `decomposePar -constant`, `restore0Dir -processor`,
`renumberMesh -constant -overwrite -parallel`,
`potentialFoam -initialiseUBCs -parallel`,
`applyBoundaryLayer -ybl 0.0450244 -parallel`, and
`simpleFoam -parallel`. The script gates source/archives/binary SHA-256,
four hosts at 104 ranks each, each preparation log `End`, solver
`Time = 150` and `End`, coded mean wall-clock time per step, and final
Cd from `coefficient.dat`.

The PBS request is 416 CPUs, 760 GB RAM, 100 GB JOBFS and one hour,
at most 832 SU under the established queue rate. At pre-submit check,
`nci_account -P pm78` showed 10.38 KSU available and zero reserved;
scratch used 156.87K/202K inodes. The one-run GCC hierarchical
`(16 13 2)` and `(26 16 1)` controls measured 2.058549642 and
2.053949465 s/step respectively; the two-run GCC Scotch mean was
1.989910155 s/step. A single new result will not establish a stable
hierarchical winner or change the selected Scotch performance baseline.

## Attempt 1

Prepared locally; PBS submission and outcome are pending.
