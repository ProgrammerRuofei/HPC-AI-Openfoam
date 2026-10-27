# Cray PALS one-node probe preparation

**Date:** 2026-09-17. **Current step:** Prepare the first compute-node availability probe after the compiler and fast-screening analyses. The user confirmed the displayed probe diff and authorized the next preparation step. No PBS job has been submitted.

## Completed work

- Added the approved local probe at [`scripts/probe_cray_pals_1n_v1.pbs`](../scripts/probe_cray_pals_1n_v1.pbs) and an empty `scripts/outputs/.gitkeep`. `bash -n` passed. The probe checks Cray MPICH library resolution and PALS launch on one compute node; `mpiexec hostname` does **not** exercise `MPI_Init` or OpenFOAM.
- Confirmed that `/home/project/59000020/openfoam-isc26/control-repo` was absent. An anonymous, non-interactive GitHub clone to that path failed with `fatal: could not read Username for 'https://github.com'`. Git removed its attempted directory; a follow-up `ls` confirmed that `control-repo` remains absent. No credentials were supplied, stored, or requested.
- Created the user-approved remote output directory `/home/project/59000020/openfoam-isc26/scripts/outputs`. This is the only persistent remote state change. No source, case, build, or existing output was modified.

## Blocker and next action

The remote project root has no `.git`; its `src/openfoam-hpc-develop/.git` is the application-source repository, not this control repository. The approved probe cannot be submitted under `workflow/01-Git-Sync-Policy.md` until the control repository is synchronized. The cluster cannot anonymously clone the current GitHub origin. The local repository also has pre-existing unrelated changes and untracked evidence, which must be preserved.

The approved probe diff sends PBS output to the outer project root's `scripts/outputs`. If the working control checkout is created at `control-repo/`, its PBS paths should instead point to `control-repo/scripts/outputs` before submission, so raw output stays with the synchronized workflow tree. That two-line correction has not been applied and needs review.

Proposed credential-free route for separate approval: initialize a bare Git transport repository under the approved project root, commit only the probe and `.gitkeep` locally, push that commit directly over the documented SSH alias, clone a working control repository from the bare repository, verify both commit IDs and clean state, then submit the reviewed probe from that checkout. This requires explicit approval for the local commit, remote bare repository/checkout creation, Git push, and PBS submission. No such step has been done yet. The project adapter should then record the actual checkout path, distinct from the outer project root.

## Exact remote commands and evidence

The persistent SSH connection had been checked in the preceding turn with `ssh -O check aspire2a-comp` (`Master running`). This turn used:

```sh
ssh aspire2a-comp 'ls -ld /home/project/59000020/openfoam-isc26/control-repo /home/project/59000020/openfoam-isc26/scripts/outputs 2>&1'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26 && GIT_TERMINAL_PROMPT=0 git clone --branch main --single-branch https://github.com/ProgrammerRuofei/HPC-AI-Openfoam.git control-repo'
ssh aspire2a-comp 'ls -ld /home/project/59000020/openfoam-isc26/control-repo 2>&1'
ssh aspire2a-comp 'mkdir -p /home/project/59000020/openfoam-isc26/scripts/outputs && ls -ld /home/project/59000020/openfoam-isc26/scripts/outputs'
```

The clone exited 128; the final directory listing showed `scripts/outputs` owned by `apacsc20:59000020`. No scheduler command was issued. **DISCOVERED AND VERIFIED:** no control checkout at the proposed path; anonymous remote GitHub access unavailable; output directory now exists. **TBD:** approved Git synchronization route, actual control checkout path, compute-node PALS/Cray MPICH availability, and MPI initialization.
