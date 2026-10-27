# ASPIRE2A login-node libfabric module audit

**Date:** 2026-09-17. **Scope:** read-only login-node inspection. No PBS submission, remote file change, build, or OpenFOAM run. The prior v2 compute-node probe failed because `libfabric/1.22.0` was unavailable in that job's module search path; its `libmpi.so` still reported `libfabric.so.1 => not found` and exited before `mpiexec`. See [`progress/2026-09-17-cray-pals-probe-v2.md`](../../progress/2026-09-17-cray-pals-probe-v2.md).

## Module and filesystem evidence

The login-node `MODULEPATH` was:

```text
/opt/cray/pe/perftools/22.04.0/modulefiles:/opt/cray/pe/modulefiles:/opt/cray/modulefiles:/opt/modulefiles:/etc/scl/modulefiles:/usr/share/Modules/modulefiles:/etc/modulefiles:/usr/share/modulefiles:/opt/cray/pe/craype-targets/default/modulefiles:/app/apps/modulefiles:/app/libs/modulefiles
```

`module list` already contained `libfabric/1.22.0` in the login shell. `module show libfabric/1.22.0` identified `/opt/cray/modulefiles/libfabric/1.22.0`. `ls -l` showed a regular root-owned, world-readable, 536-byte modulefile dated 2025-07-22; `readlink -f` returned that same path. The complete actionable content of `module show` was:

```text
module-whatis "This module adds Libfabric 1.22.0 to the environment"
prepend-path PATH /opt/cray/libfabric/1.22.0/bin
prepend-path LD_LIBRARY_PATH /opt/cray/libfabric/1.22.0/lib64
prepend-path MANPATH /opt/cray/libfabric/1.22.0/share/man
prepend-path PKG_CONFIG_PATH /opt/cray/libfabric/1.22.0/lib64/pkgconfig
```

Reading the complete modulefile confirmed those four `prepend-path` directives and no other environmental directives, dependencies, or conditional logic. In one temporary SSH shell, unloading and reloading the module verified the precise changes:

| Variable | Before reload | After reload |
| --- | --- | --- |
| `PATH` | Existing path | `/opt/cray/libfabric/1.22.0/bin:` + existing path |
| `LD_LIBRARY_PATH` | `/opt/cray/pe/papi/6.0.0.14/lib64:/app/apps/local/lib64:/app/apps/local/lib` | `/opt/cray/libfabric/1.22.0/lib64:/opt/cray/pe/papi/6.0.0.14/lib64:/app/apps/local/lib64:/app/apps/local/lib` |
| `MANPATH` | Existing path | `/opt/cray/libfabric/1.22.0/share/man:` + existing path |
| `PKG_CONFIG_PATH` | `/opt/cray/pe/craype/2.7.15/pkg-config:/opt/cray/pe/atp/3.14.10/lib/pkgconfig` | `/opt/cray/libfabric/1.22.0/lib64/pkgconfig:/opt/cray/pe/craype/2.7.15/pkg-config:/opt/cray/pe/atp/3.14.10/lib/pkgconfig` |
| `LOADEDMODULES` | Existing module list | Appended `:libfabric/1.22.0` |
| `_LMFILES_` | Existing modulefile list | Appended `:/opt/cray/modulefiles/libfabric/1.22.0` |
| `MODULEPATH` | As printed above | Unchanged |

The last two changed entries are module-system bookkeeping. The modulefile itself modifies only the four path variables above. A separate login-shell check unloaded the module, prepended **only** `/opt/cray/libfabric/1.22.0/lib64` to `LD_LIBRARY_PATH`, and then resolved `libfabric.so.1` in `ldd libmpi.so` while `LOADEDMODULES` still omitted libfabric. Thus that one path is sufficient for this login-node runtime dependency check. The other three paths serve executables, manual pages, and package metadata.

The actual library is under `/opt/cray`, not project scratch or another named application path:

```text
/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1 -> libfabric.so.1.25.0
readlink -f: /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1.25.0
target: -rwxr-xr-x root root 1049856 bytes, 2025-07-22
```

On the login node, `df -T` and `findmnt -T` place both the modulefile and the library under `/`, whose reported filesystem is `overlay` (source `overlay`, lowerdir `/root_ro`, upperdir `/rootfs.rw/upperdir`). Thus `/opt/cray` is a system path on that node, but the available read-only evidence does **not** establish that its underlying mount is shared with compute nodes or that the compute-node image contains the library. The v2 compute-node output establishes only that its modulefile was unavailable and `libfabric` did not resolve without this path.

`ldd /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1` resolved every listed dependency on the login node:

```text
librdmacm.so.1 => /lib64/librdmacm.so.1
libibverbs.so.1 => /lib64/libibverbs.so.1
libatomic.so.1 => /lib64/libatomic.so.1
librt.so.1 => /lib64/librt.so.1
libpthread.so.0 => /lib64/libpthread.so.0
libdl.so.2 => /lib64/libdl.so.2
libc.so.6 => /lib64/libc.so.6
libnl-3.so.200 => /lib64/libnl-3.so.200
libnl-route-3.so.200 => /lib64/libnl-route-3.so.200
libgcc_s.so.1 => /lib64/libgcc_s.so.1
```

The loader (`/lib64/ld-linux-x86-64.so.2`) and `linux-vdso.so.1` were also listed. No `not found` line appeared. This checks login-node dynamic dependencies, not fabric-provider operation or compute-node availability.

## Cray MPICH resolution

The inspected GNU 9.1 MPICH library path is `/opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so`, a symlink to `libmpi_gnu_91.so`; `readlink -f` returned `libmpi_gnu_91.so.12.0.0` in the same directory. In the temporary login shell:

```text
module unload libfabric/1.22.0 ; ldd libmpi.so: libfabric.so.1 => not found
module load libfabric/1.22.0   ; ldd libmpi.so: libfabric.so.1 => /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1
```

After reload, the full `ldd` output had no `not found` entries. It also resolved Cray PMI/PALS libraries from `/opt/cray/pe/lib64`, GNU Fortran/GCC runtime libraries from `/opt/cray/pe/gcc-libs`, and system libraries from `/lib64`. This establishes login-node dependency resolution only; no launcher or MPI initialization was tested in this task.

## Candidate runtime-only diff for a *future* compute-node probe

This is an **unapplied candidate snippet**, relative to `scripts/probe_cray_pals_1n_v2.pbs`. It is not a v3 script or authorization to run a job. The relevant change reproduces only the library-search part of the module; the existing `ldd` and `libfabric.so.1` guards would still stop before `mpiexec` if the compute node lacks the file or another dependency.

```diff
 module purge
-module load aocc/5.0 gcc/11.2.0 cray-pals/1.1.6 libfabric/1.22.0
+module load aocc/5.0 gcc/11.2.0 cray-pals/1.1.6
+FABRIC_LIBDIR=/opt/cray/libfabric/1.22.0/lib64
+if [[ ! -r "${FABRIC_LIBDIR}/libfabric.so.1" ]]; then
+    printf 'Cray libfabric library unavailable: %s\n' "${FABRIC_LIBDIR}/libfabric.so.1" >&2
+    exit 2
+fi
+export LD_LIBRARY_PATH="${FABRIC_LIBDIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
 MPICH_DIR=/opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
```

The precondition remains unverified: the compute node must have a readable `/opt/cray/libfabric/1.22.0/lib64/libfabric.so.1` and its dependencies. Any future approved run would also need unique job/output names to preserve v1/v2 evidence. Do not treat this login-node check as evidence of compute-node launch or MPI compatibility.

## Exact remote commands in this task

All used the documented non-interactive `aspire2a-comp` alias. No scheduler command was issued.

```sh
ssh -O check aspire2a-comp
ssh aspire2a-comp 'printf "MODULEPATH=%s\n" "${MODULEPATH-<unset>}"; module list 2>&1; module show libfabric/1.22.0 2>&1'
ssh aspire2a-comp 'ls -l /opt/cray/modulefiles/libfabric/1.22.0; readlink -f /opt/cray/modulefiles/libfabric/1.22.0; cat /opt/cray/modulefiles/libfabric/1.22.0'
ssh aspire2a-comp 'ls -ld /opt/cray/libfabric/1.22.0 /opt/cray/libfabric/1.22.0/lib64; ls -l /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1; readlink -f /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1; ldd /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1; df -T /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1; findmnt -T /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1 -o TARGET,SOURCE,FSTYPE,OPTIONS'
ssh aspire2a-comp 'module unload libfabric/1.22.0; printf "=== BEFORE RELOAD ===\n"; for name in PATH LD_LIBRARY_PATH MANPATH PKG_CONFIG_PATH MODULEPATH LOADEDMODULES _LMFILES_; do eval "value=\${$name-<unset>}"; printf "%s=%s\n" "$name" "$value"; done; module load libfabric/1.22.0; printf "=== AFTER RELOAD ===\n"; for name in PATH LD_LIBRARY_PATH MANPATH PKG_CONFIG_PATH MODULEPATH LOADEDMODULES _LMFILES_; do eval "value=\${$name-<unset>}"; printf "%s=%s\n" "$name" "$value"; done; printf "=== MPI LDD ===\n"; ls -l /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so; readlink -f /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so; ldd /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so'
ssh aspire2a-comp 'ls -l /opt/cray/libfabric/1.22.0/lib64/libfabric.so.1.25.0; df -T /opt/cray/modulefiles/libfabric/1.22.0; findmnt -T /opt/cray/modulefiles/libfabric/1.22.0 -o TARGET,SOURCE,FSTYPE; module unload libfabric/1.22.0; ldd /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so | grep -E "libfabric|not found"; module load libfabric/1.22.0; ldd /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so | grep -E "libfabric|not found"'
ssh aspire2a-comp 'module unload libfabric/1.22.0; LD_LIBRARY_PATH="/opt/cray/libfabric/1.22.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"; export LD_LIBRARY_PATH; printf "LD_LIBRARY_PATH=%s\n" "$LD_LIBRARY_PATH"; ldd /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1/lib/libmpi.so | grep -E "libfabric|not found"; printf "LOADEDMODULES=%s\n" "$LOADEDMODULES"'
```

**State:** No remote state changes persist. The module unload/reload happened only inside short-lived SSH shells. Compute-node presence of the `/opt/cray/libfabric/...` library, its dependencies, PALS launch, and MPI initialization remain **TBD**.
