# Cray PALS one-node probe v3 — local preparation

**Date:** 2026-09-17. **Current step:** Locally prepared `scripts/probe_cray_pals_1n_v3.pbs` for user diff review. No commit, push, remote command, file transfer, or PBS submission was performed in this step. No PBS job ID exists for v3.

## Evidence and checks

- V2 job `22803616.pbs101` failed before `mpiexec` because the compute-node module search could not load `libfabric/1.22.0`; v1 job `22693051.pbs101` also failed at dependency preflight. Existing v1/v2 scripts and raw `.o`/`.e` evidence remain untouched.
- The authorized login-node audit in [`planning/analysis/libfabric-login-module-audit-2026-09-17.md`](../planning/analysis/libfabric-login-module-audit-2026-09-17.md) found that `/opt/cray/libfabric/1.22.0/lib64` alone resolved the Cray MPICH GNU 9.1 `libmpi.so` dependency on the login node. Compute-node availability remains unverified.
- The proposed v3 uses unique `probe_cray_pals_1n_v3` PBS job and output names. It omits the libfabric module load, checks and records the compute-node `libfabric.so.1` link before changing `LD_LIBRARY_PATH`, checks all `libmpi.so` dependencies, and only then permits the two-process PALS `hostname` launch.
- Local `bash -n scripts/probe_cray_pals_1n_v3.pbs` passed. The `#PBS -P`, `-q`, `-l select`, and `-l walltime` directives match v1 and v2 byte-for-byte.

## State and exact next action

Show the complete local v2-to-v3 script diff and this progress note to the user. Await explicit approval before committing, pushing, pulling on ASPIRE2A, or submitting **one** v3 PBS job. On a future authorized job, stop after either preflight failure or the minimal `mpiexec hostname` result; no build, solver case, or four-node run is in scope.
