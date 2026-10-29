# Gadi GCC16.2 hierarchical shape: (26 16 1)

This is one four-node, 416-rank, 150-step comparison against the completed
same-stack hierarchical `(16 13 2)` run `181519873.gadi-pbs` and the two
same-stack Scotch runs `181368883.gadi-pbs` and `181371071.gadi-pbs`.
The user authorized this single candidate; no automatic repeat or other
XYZ shape is included. This candidate is not designated the new baseline
before its correctness and performance evidence is reviewed.

The script is
`builds/build-scripts/gadi-gcc162-ompi5010/run_baseline_4n_hierarchical_26x16x1_v1.pbs`.
It derives from the validated `(16 13 2)` private-stack script, changing
only the hierarchical tuple and job/evidence labels. The tuple product is
26 × 16 × 1 = 416. The previous ASPIRE2A `(32 16 1)` is a 512-rank shape
and cannot be copied verbatim to Gadi's 416-rank run.

Configuration: Gadi `pm78/normalsr`, four Intel Xeon Platinum 8470Q
Sapphire Rapids nodes, 104 allocated physical cores and MPI ranks per
node; 416 ranks total. GCC 16.2.0, private Open MPI 5.0.10, private
OpenFOAM.com v2512 `linux64GccDPInt32Opt`, real hierarchical
decomposition, UCX PML, and the existing `ucx/1.18.1` and `ucc/1.4.4`
module environment. These module names do not by themselves prove the
effective historical UCX library version or UCC collective selection.
Placement remains `--map-by ppr:104:node` with no explicit binding
override. The source case and runtime archives retain their SHA-256 gates.

The fixed approximately 65-million-cell `occDrivAerStaticMesh` case keeps
the original mesh, `simpleFoam` source, `fvSchemes`, `fvSolution.fixedIter`,
physics, `controlDict.noWrite`, all function objects, `delta 0.001`, and
`order xyz`. The full `decomposePar -constant`, `restore0Dir -processor`,
`renumberMesh -constant -overwrite -parallel`,
`potentialFoam -initialiseUBCs -parallel`,
`applyBoundaryLayer -ybl 0.0450244 -parallel`, and `simpleFoam -parallel`
chain is retained. Only the permitted job-local `nCores 416`,
`decompositionMethod hierarchical`, and `nHierarchical (26 16 1)` fields
are set. Solver end time remains 150.

The PBS request is 416 CPUs, 760 GB memory, 100 GB JOBFS and one hour;
at the established 2 SU/core-hour rate the request ceiling is 832 SU.
The pre-submit `nci_account -P pm78` report on 2026-10-29 showed
10.57 KSU available and zero reserved, with 156.25K of 202K scratch
inodes used.
The actual charge must come from the NCI receipt. Unique PBS stdout and
job-keyed scratch paths preserve all earlier runs. Completion requires
PBS Exit Status 0, the candidate PASS marker, four SPR hosts with 104
ranks each, every preparation and solver `End`, `Time = 150`, coded
average wall-clock seconds/step, fresh `coefficient.dat`/Cd, source and
binary hashes, and actual SU. Cd must be checked against the contest's
approximate 150-step sanity values; the rules do not prescribe a hard
Basic-tier percentage threshold. Compare processor-face and cell-balance
statistics from decomposition logs where retained, without claiming the
old Scotch PMPI profile measures this candidate's MPI time.

The official task rules permit hierarchical settings in the Basic tier:
https://github.com/hpcac/2026-APAC-HPC-AI/blob/main/2.%20OpenFOAM%20HPC%20Task%20Rules.md

## Attempt 1: submitted

The reviewed script was committed as `edbd0a133eff9eb71a3fb8576a5d28dab7223d62`,
pushed to the existing isolated GitHub and Gadi branches, and validated
in the Gadi branch checkout with `bash -n` and identical SHA-256
`2c68fb9a13735919a0f9b542594ebf6ee862420180ff808b94b7c3c4838e78c5`.
One `qsub` returned **`182558696.gadi-pbs`**. Its first `qstat -f` showed
`Q` in `normalsr-exec`, four allocations of 104 CPUs, 416 CPUs total,
100 GB JOBFS and one-hour walltime. PBS stdout is
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010/submit-logs/run_baseline_4n_hierarchical_26x16x1_v1.pbs.out`.
Job-keyed evidence is expected under
`/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010-of2512/baseline-4n-hierarchical-26x16x1/182558696.gadi-pbs/evidence/`.
At submission, the final PBS outcome, coded seconds/step, Cd and actual
SU were pending. This submission did not authorize a repeat or a baseline
change.

## Attempt 1: completed

PBS job `182558696.gadi-pbs` finished with `Exit_status=0` and
`GCC162_OMPI5010_OF2512_HIERARCHICAL_26X16X1_4N_PASS`.
The four Sapphire Rapids hosts each carried 104 ranks. All source and
runtime archive SHA-256 checks, the `simpleFoam` binary check, and private
MPI linkage check passed. The four preparation logs and solver ended
normally; `Time = 150` and MPI finalisation were present.

The coded mean was **2.05394946522819 s/step** over 149 measured steps
(standard deviation 0.015273468 s); solver `ClockTime` was 317 s. Final
`Cd` from `coefficient.dat` was **0.28866830865734072**. PBS used 13:33,
and the NCI receipt charged **187.89 SU**. Decomposition reported
65,334,765 cells with 157,054–157,065 cells/rank and 9,208–36,459
processor faces/rank (9,797,214 summed rank faces; 4,898,607 unique
processor faces). These are decomposition statistics, not a measured MPI
time breakdown.

This single `(26 16 1)` result is 0.223% faster per step than the one
same-stack `(16 13 2)` result, but 3.218% slower than the two-run Scotch
mean of 1.989910155 s/step. Its Cd differs from both controls while
remaining in the historical 150-step sanity range. The small difference
between hierarchical shapes is not a reproducible gain without a matched
repeat. Scotch remains the selected performance baseline.
