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
| 2 | `178137625.gadi-pbs` | `d720df60eb4cd1b1724b6def9dc77796d2b6d545` | L1 — PBS wrapper | The persistent output directory was created and PBS stdout captured `bash: /local/spool/pbs/mom_priv/jobs/build_s1_icc2021_impi2021.sh: No such file or directory`; 1 s walltime, `Exit_status=127`, and 0 B JOBFS use. PBS executed a spool copy, so `BASH_SOURCE[0]` could not locate the repository sibling shell. | Pending: use `${PBS_O_WORKDIR}` (the submitted control-repository directory) and a repository-relative S1 shell path. | Build not entered; not a compiler, MPI, source-identity, staging, or OpenFOAM build failure. |

## Current action

The persistent `submit-logs` directory is now present.  Apply and validate the
minimal PBS spool-wrapper correction, then submit S1 Attempt #3 from reviewed
Git provenance.  No S2/S3 build is in scope.  Later layers will be evaluated
only after the preceding layer passes.

## Current blocker

PBS spool execution made the original `BASH_SOURCE[0]` lookup invalid.  The
minimal pending correction uses the PBS-recorded submission directory and does
not alter the build shell, source identity, compiler/MPI stack, or JOBFS logic.
