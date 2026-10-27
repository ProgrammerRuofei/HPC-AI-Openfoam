# Cray PALS one-node probe v2

**Date:** 2026-09-17. **Current step:** One user-authorized retry of the minimal one-node Cray MPICH/PALS availability probe. **PBS job:** `22803616.pbs101`, queued in `qdev` at first check. No OpenFOAM build, Pstream build, solver run, or four-node experiment was performed.

## Completed work and evidence

- The user reviewed and approved the complete v1-to-v2 local diff. The v2 script is [`scripts/probe_cray_pals_1n_v2.pbs`](../scripts/probe_cray_pals_1n_v2.pbs); v1 script and v1 `.o`/`.e` were preserved.
- `bash -n` passed. `#PBS -P`, `-q`, `-l select`, and `-l walltime` match v1 byte-for-byte. V2 adds `libfabric/1.22.0`, records the requested environment and available versions, checks all `libmpi.so` dependencies and the resolved `libfabric.so.1` path, and only then runs `mpiexec -n 2 --ppn 2 /bin/hostname`.
- Committed **only** v2 as local commit `877695ada738819b8540d99140a068e6604688ae`, pushed to the already authorized bare transport repository, and pulled the remote control checkout with `git pull --ff-only`. The remote checkout reached the same commit. Local and remote v2 SHA256: `fd7d1c90823d22bd84fe901e5fe874b301f9250318623ed85fed2f72274b5fe7`. The remote checkout's only untracked files before submission were the two preserved v1 PBS outputs.
- `qsub` returned `22803616.pbs101`. The first `qstat -xf` showed `Q` in `qdev`, with the aggregate CPU limit comment. No result yet and no compute allocation consumed at that check.

## Exact commands

The persistent connection check `ssh -O check aspire2a-comp` returned `Master running`. Relevant remote and scheduler commands:

```sh
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git rev-parse HEAD && git status --short && ls -l scripts/outputs/probe_cray_pals_1n_v1.o scripts/outputs/probe_cray_pals_1n_v1.e && test ! -e scripts/outputs/probe_cray_pals_1n_v2.o && test ! -e scripts/outputs/probe_cray_pals_1n_v2.e'
GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push aspire2a-comp:/home/project/59000020/openfoam-isc26/control.git main:main
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && git pull --ff-only && git rev-parse HEAD && git status --short && bash -n scripts/probe_cray_pals_1n_v2.pbs && sha256sum scripts/probe_cray_pals_1n_v2.pbs && test -f scripts/outputs/probe_cray_pals_1n_v1.o && test -f scripts/outputs/probe_cray_pals_1n_v1.e && test ! -e scripts/outputs/probe_cray_pals_1n_v2.o && test ! -e scripts/outputs/probe_cray_pals_1n_v2.e'
ssh aspire2a-comp 'cd /home/project/59000020/openfoam-isc26/control-repo && qsub scripts/probe_cray_pals_1n_v2.pbs'
ssh aspire2a-comp 'qstat -xf 22803616.pbs101 2>&1 | grep -E "^(Job Id:|[[:space:]]*(job_state|queue|comment|exec_host|stime|obittime|Exit_status|resources_used\.walltime|resources_used\.cput))"'
ssh aspire2a-comp 'qstat -Q qdev'
```

## State and next action

**DISCOVERED AND VERIFIED:** v2 submitted exactly once; remote script checksum and commit match the approved local script; v1 evidence remains. **TBD:** compute-node dependency resolution, PALS launch result, MPI initialization (outside this probe). Check `qstat -xf 22803616.pbs101` at a bounded cadence. After completion, inspect the v2 `.o` and `.e` raw files and PBS exit code. If preflight fails, preserve evidence and stop. If the probe succeeds, report and stop. No additional module combinations, PBS jobs, builds, or performance runs are authorized.

## Final outcome — preflight failed

PBS history changed to `F`, `Exit_status = 2`, two seconds wall time on compute node `x1002c5s7b0n1` (`stime` 16:45:09, `obittime` 16:45:15 cluster local time). The v2 stderr reports `libfabric(4):ERROR:105: Unable to locate a modulefile for 'libfabric/1.22.0'` and `Unresolved Cray MPICH dependency`. Stdout confirms `module list` omitted libfabric, `LD_LIBRARY_PATH` omitted `/opt/cray/libfabric/1.22.0/lib64`, and `ldd` retained `libfabric.so.1 => not found`. The script exited before `mpiexec --version` or `mpiexec hostname`; neither PALS launch nor MPI initialization was tested. The login-node module visibility did not carry into this compute-node job.

Raw v2 evidence is retained at `/home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v2.o` and `.e`. V1 evidence was not overwritten. The failure is recorded in [`MANUAL_INSPECTION_ERROR.md`](../MANUAL_INSPECTION_ERROR.md). The authorized single retry is consumed. **Next action:** stop; await the user's decision before any further module combination, patch, or job. No OpenFOAM build/run or four-node experiment occurred.

Final read-only remote commands:

```sh
ssh aspire2a-comp 'qstat -xf 22803616.pbs101 2>&1 | grep -E "^(Job Id:|[[:space:]]*(job_state|queue|comment|exec_host|stime|obittime|Exit_status|resources_used\.walltime))"'
ssh aspire2a-comp 'cat /home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v2.o'
ssh aspire2a-comp 'cat /home/project/59000020/openfoam-isc26/control-repo/scripts/outputs/probe_cray_pals_1n_v2.e'
```
