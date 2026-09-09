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
| 3 | `178137861.gadi-pbs` | `9a4adb79e69d05da4897534f1883aed8f778b6fb` | L4 — environment activation | PBS wrapper entered the build workflow. Both authoritative and staged regular/symlink/composite source identities passed; staged tree had 192042 regular files and 10976 symlinks. The first failure was `etc/bashrc: line 184: WM_PROJECT_DIR: unbound variable` while the shell's global `set -u` was active. | Pending: disable `nounset` only while sourcing the upstream OpenFOAM `etc/bashrc`, then restore it. | No compiler invocation or OpenFOAM build occurred; not an ICC/Intel MPI, staging, or SOURCE_ID_V2 failure. |
| 4 | `178138805.gadi-pbs` | `357c8324f9595add1d3fe64ef48bb4d106c7776f` | L4 — environment / compiler-MPI integration | L1 and L2 passed; the 2.3 GB JOBFS worktree matched SOURCE_ID_V2 (192042 regular files, 10976 symlinks).  The authoritative tree lacks `META-INFO/api-info`, so `etc/config.sh/setup:30` cannot set `FOAM_API`. Separately, `etc/bashrc` resets pre-source `WM_MPLIB=INTELMPI` to `SYSTEMOPENMPI`; `etc/config.sh/mpi:130-136` consequently sends `mpicc --showme:link` to Intel MPI's wrapper, which forwards it to ICC and fails. | Pending review: after the exact staged-source identity check, create only reviewed `META-INFO/api-info` in JOBFS and source `etc/bashrc` with `WM_COMPILER=Icc WM_MPLIB=INTELMPI WM_COMPILE_OPTION=Opt` arguments. | No ThirdParty or OpenFOAM compilation began. This is neither an ICC nor Intel MPI compatibility result; it is an OpenFOAM environment-integration failure. |

## Positive validation to date

- The persistent PBS output directory and spool-safe wrapper now work.
- The PBS_JOBFS design, source staging, and source isolation work.
- Both the authoritative and staged SOURCE_ID_V2 checks passed before L4:
  192042 regular files and 10976 symlinks matched the reviewed digests.
- ICC 2021.10 and Intel MPI 2021.10 modules and wrappers were recorded before
  failure; `mpicc -show` and `mpicxx -show` resolve to ICC/ICPC with Intel MPI
  include and link paths.
- No actual OpenFOAM or ThirdParty compilation has started in any attempt.

## Current action and blocker

The autonomous PBS retry budget is exhausted.  The next action is local-only
repair preparation and non-build validation: source `etc/bashrc` using its
supported command-line overrides so setup selects `INTELMPI`, and provide the
reviewed missing v2512 `META-INFO/api-info` only in the ephemeral JOBFS tree
after the original staged tree has passed SOURCE_ID_V2.  The raw authoritative
source identity remains mandatory and unchanged; the metadata overlay is
separately hash-checked and recorded.  Any Attempt #5 requires a separate user
approval after this diff is reviewed.  S2/S3 remain out of scope.
