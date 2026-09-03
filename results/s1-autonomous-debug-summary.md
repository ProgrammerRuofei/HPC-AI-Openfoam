# S1 autonomous debug summary

## Scope

Candidate S1 is OpenFOAM v2512 built with ICC 2021.10 and Intel MPI
2021.10.  The authoritative source is `/apps/OpenFOAM/2512`; its reviewed
source identity is `OPENFOAM_SOURCE_ID_V2`:

- regular manifest: `802414c5b14ebb9cb4e3bab1a570e3c06c77e2d3028792faff865bcd4a181cc0`
- symlink manifest: `7d4ad344a50520ca0f79c6e45e198eb4f294e73759291fd4062c3ea2ab14b538`
- composite source ID: `5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db`

## Attempts

| Attempt | Job ID | Commit | Layer | Root cause / evidence | Correction | Result |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `178136462.gadi-pbs` | `70d6dc06e571836427890a6c242b5c0580b2c4c5` | L1 — PBS startup | PBS state `F`, `Exit_status=127`, 1 s walltime; no build root, log, source-identity evidence, manifest, or archive. The configured `#PBS -o` parent `.../s1-icc2021-impi2021/submit-logs` was absent. | Pending: create only the persistent PBS output directory before retry. Do not create a JOBFS worktree manually. | Build not entered; not a compiler, MPI, source-identity, staging, or OpenFOAM build failure. |

## Current action

Create and validate the missing persistent `submit-logs` directory, then
submit S1 Attempt #2 from reviewed Git provenance.  No S2/S3 build is in
scope.  Later layers will be evaluated only after the preceding layer passes.

## Current blocker

None after the identified L1 launch-preparation correction has been applied;
S1 Attempt #2 is required to validate the PBS_JOBFS staging pipeline.
