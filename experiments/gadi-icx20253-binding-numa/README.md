# ICX 2025 binding and NUMA first batch

User approved P0 + AB + BA, total requested ceiling 312 SU, on 2026-10-30 after reviewing full script diffs. Each job may be submitted once; failure stops subsequent submissions. No four-node solve or extra retry is included.

## Configuration

ICX 2025.3.2; private Open MPI 5.0.10 with GCC 16.2 runtime; OpenFOAM v2512 from build 181392981; ucx/1.18.1 and ucc/1.4.4 modules; UCX PML, no injected UCX preload or collective override. Actual runtime selection is recorded by the preflight, and is not inferred from module names.

Single normalsr SPR node, 104 ranks. P0: 104 CPU/16 GB/20 GB JOBFS/10 minutes. AB and BA: each 104 CPU/190 GB/100 GB JOBFS/40 minutes; two fresh 40-step Scotch cases. Fixed science copied only into private JOBFS from the existing source master. Binary and archive SHA gates are in the PBS files.

## Execution gates

See ../../planning/gadi-icx20253-binding-numa-plan.md and the review package. P0 must pass PBS, runtime and map checks. Identical binding masks skip solves. A per-rank core outside its default allowed mask stops progression. AB must validate before BA submission. Explicit distinct stdout overrides are mandatory for AB/BA. Keep original evidence and independent output names; no unknown-qsub resubmission.

## Evidence and outputs

Remote evidence roots: ICX OF root/binding-numa-preflight-v1/<job>/evidence and ICX OF root/binding-pair-1n-v1/<ab|ba>/<job>/evidence. Remote stdout is the established ICX submit-logs directory. Local raw PBS receipts belong in outputs/<job>/; all original evidence is also archived under planning/evidence/gadi-pbs-script-snapshot/logs/<job>/. Each solver arm has its own default/ or core/ directory. Require Exit 0, PASS, full preparation End, exactly 40 Time entries, End, Cd comparison, identical partition and input, actual placement, and actual SU. Diagnostic screen is not a 150-step score.

## Attempts and error handling

No PBS submission yet. Any error retains first failure, job ID and receipts; no retry authorized. Local syntactic/parser checks passed before deployment, including archived real GCC default/core evidence and negative placement cases.
