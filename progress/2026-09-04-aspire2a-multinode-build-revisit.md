# ASPIRE2A multi-node revisit and isolated-build follow-up

## Current step

Historical evidence was re-audited.  A new ASPIRE2A build or diagnostic job
was **not** submitted because the documented persistent SSH master accepts the
control check but no command channel returns, including `exit 0`.

## Recovered four-node planning and failure evidence

The previously unresolved planning item is
`planning/aspire2a-nscc-support-draft.md`.  Its controlled diagnostic results
are:

| Test | Allocation | Outcome |
| --- | ---: | --- |
| T1 | 1 node x 128 ranks | PASS |
| T4 | 2 nodes x 64 ranks | signal 7 after `End` / `Finalising parallel run` |
| T2 | 2 nodes x 128 ranks | signal 7 after `End` / `Finalising parallel run` |
| baseline / retry | 4 nodes x 128 ranks | signal 7 after `End` / `Finalising parallel run` |

T1 and T4 have the same total rank count, so the preserved evidence supports
the classification `MULTI-NODE / INTER-NODE PALS-MPI RUNTIME SUSPECT`, not a
simple total-rank limit.  The failed rank and node vary.  The diagnosis did
not find an OpenFOAM fatal error, NaN, explicit MPI error, or retained PALS
server-side record.

Relevant evidence is retained in:

- `experiments/aspire2a-baseline/README.md`
- `MANUAL_INSPECTION_ERROR.md`
- `planning/aspire2a-nscc-support-draft.md`

## Isolated source/build direction

The local repository contains a separate, Gadi-specific S1 isolated-source
build design (`builds/build-scripts/s1-icc2021-impi2021/`).  It stages the
authoritative source into per-job `PBS_JOBFS`, verifies the source identity,
and builds only the staged copy.  It is not an ASPIRE2A build definition and
must not be transferred or submitted there without an ASPIRE2A module/source
discovery and a reviewed ASPIRE2A-specific diff.

## Remote check and blocker

At 2026-09-04, the following documented read-only control check succeeded:

```text
ssh -O check aspire2a-comp
Master running (pid=82122)
```

The following authorized read-only command-channel checks did not return
within their bounded waits and yielded no remote output:

```text
ssh aspire2a-comp 'exit 0'
ssh -o BatchMode=yes -o ConnectTimeout=10 aspire2a-comp 'hostname; whoami; pwd; command -v qsub; command -v qstat'
```

The adapter documents the recovery action for an unavailable connection as
`TBD`; no attempt was made to close, restart, or otherwise alter the SSH
master.  No remote state changed, no files were transferred, and no jobs were
submitted or cancelled.

### Recheck — connection restored

The user authorized an SSH retry.  The command channel then returned normally:

```text
host=asp2a-login-ntu01
user=apacsc20
pwd=/home/users/industry/ai-hpc/apacsc20
/opt/pbs/bin/qsub
/opt/pbs/bin/qstat
```

Read-only ASPIRE2A discovery confirmed:

- `openfoam/2512` sets
  `WM_PROJECT_DIR=/app/apps/openfoam/2512/OpenFOAM-v2512` and uses GCC 11.2.0,
  Cray MPICH 8.1.15, and PALS 1.1.6.
- Candidate compiler/MPI modules include Intel 2025.1.3, `intel-classic`,
  `openmpi/4.1.7-icc24.2.1`, and `openmpi/5.0.5-icc24.2.1`, alongside the
  existing Cray programming environments.  No stack was loaded or changed
  beyond the read-only OpenFOAM module inspection.
- The approved remote root exists but is **not** a Git working tree; it has no
  visible `.git` directory and no `builds/` or `builds/source/` subtree.

This blocks any remote build submission: the project's required local review,
commit/push, and remote `git pull --ff-only` sequence cannot be performed
against the current remote root.  No remote state changed and no job was
submitted during the recheck.

## Exact next action

Resolve the missing ASPIRE2A remote Git clone (or explicitly authorize a
different compliant synchronization method).  Then prepare an
ASPIRE2A-specific isolated-source build script locally, show its diff before
any remote-affecting action, synchronize it, and submit only after that
review.

## Repository source confirmed

The user supplied `https://github.com/ProgrammerRuofei/HPC-AI-Openfoam` as
the intended source.  Local read-only verification confirms that it is this
control repository's `origin`, with default branch `main` at
`49dc0c960dab0e2bed1f3448f8d9d2061d7dd21a`, equal to local `HEAD`.

The follow-up ASPIRE2A inspection was unable to use the previously working
non-interactive channel: SSH instead requested authentication and returned
`Permission denied (gssapi-keyex,gssapi-with-mic,password)`.  No interactive
authentication, SSH-configuration access/change, remote clone, transfer, or
remote file change was attempted.
