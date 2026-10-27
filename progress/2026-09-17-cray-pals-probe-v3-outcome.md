# Cray PALS one-node probe v3 — outcome

**Date:** 2026-09-17. **Current step:** Completed exactly one approved v3 availability probe and stopped after preflight failure. PBS job `22815643.pbs101`; state `F`; `Exit_status = 2`; compute node `x1001c7s7b0n1`; wall time 3 seconds; start 17:23:12, end 17:23:18 (cluster local time).

## Actions and evidence

- Reviewed script `scripts/probe_cray_pals_1n_v3.pbs` unchanged from the displayed diff. Local `bash -n` passed; SHA256 `92261d86bffd8e56d391d87544e47d60063286cab45e6275c6a692fd9ca20a77`.
- Committed only the v3 script as `7d226e4bd7a26fecb4eb98038f5e2e15905d2e94`, pushed to `/home/project/59000020/openfoam-isc26/control.git`, and fast-forward pulled in the remote `control-repo`. Remote commit and SHA256 matched. The remote checkout retained only the expected untracked v1/v2 PBS outputs before submission; v3 `.o`/`.e` names did not exist.
- Submitted the script once. Raw outputs are `/home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v3.o` and `.e`. Stdout reports `ls: cannot access '/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1': No such file or directory`; stderr reports `Cray libfabric library missing or unreadable` at that path. The script exited before `LD_LIBRARY_PATH`, `ldd`, version commands, or `mpiexec`.
- The v1/v2 output files were not overwritten. No OpenFOAM build, Pstream build, 65M solver run, or four-node experiment occurred. No additional PBS job was submitted.

## Exact remote and scheduler commands

```sh
ssh -O check aspire2a-comp
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git rev-parse HEAD && git status --short && ls -l scripts/outputs/probe_cray_pals_1n_v1.o scripts/outputs/probe_cray_pals_1n_v1.e scripts/outputs/probe_cray_pals_1n_v2.o scripts/outputs/probe_cray_pals_1n_v2.e && test ! -e scripts/outputs/probe_cray_pals_1n_v3.o && test ! -e scripts/outputs/probe_cray_pals_1n_v3.e'
ssh aspire2a-comp 'git --git-dir=/home/project/59000020/openfoam-isc26/control.git rev-parse refs/heads/main'
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only && git rev-parse HEAD && git status --short && bash -n scripts/probe_cray_pals_1n_v3.pbs && sha256sum scripts/probe_cray_pals_1n_v3.pbs && test -f scripts/outputs/probe_cray_pals_1n_v1.o && test -f scripts/outputs/probe_cray_pals_1n_v1.e && test -f scripts/outputs/probe_cray_pals_1n_v2.o && test -f scripts/outputs/probe_cray_pals_1n_v2.e && test ! -e scripts/outputs/probe_cray_pals_1n_v3.o && test ! -e scripts/outputs/probe_cray_pals_1n_v3.e'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub scripts/probe_cray_pals_1n_v3.pbs'
ssh aspire2a-comp 'qstat -xf 22815643.pbs101 2>&1 | grep -E "^(Job Id:|[[:space:]]*(job_state|queue|comment|exec_host|stime|obittime|Exit_status|resources_used\.walltime|resources_used\.cput|Output_Path|Error_Path))"'
ssh aspire2a-comp 'qstat -xf 22815643.pbs101 2>&1 | grep -E "^(Job Id:|[[:space:]]*(job_state|queue|comment|exec_host|stime|obittime|Exit_status|resources_used\.walltime|resources_used\.cput))"'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && ls -l scripts/outputs/probe_cray_pals_1n_v3.o scripts/outputs/probe_cray_pals_1n_v3.e && printf "STDOUT\n" && cat scripts/outputs/probe_cray_pals_1n_v3.o && printf "STDERR\n" && cat scripts/outputs/probe_cray_pals_1n_v3.e'
```

## Facts, limits, and next action

- **DISCOVERED AND VERIFIED:** the allocated compute node lacks a readable `/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1`; PBS exited at the explicit file preflight. The approved control checkout contains the reviewed v3 script.
- **TBD:** whether an alternative compute-node libfabric exists; whether Cray MPICH dependencies can resolve there; whether PALS can launch ranks; whether MPI initializes; OpenFOAM compatibility and performance.
- **Remote state changes:** one approved commit synchronized to the control checkout and one PBS job with unique v3 raw outputs. No other remote files were modified by Codex.
- **Next action:** stop and review this evidence with the user. Any additional discovery, alternative runtime path, script change, or PBS job requires a new scoped decision and approval.
