#!/bin/bash
# Stage private Intel MPI/libfabric and ICX 2025 OpenFOAM on node-local JOBFS.
set -euo pipefail
ROOT=${1:?}; INTEL_ARCHIVE=${2:?}; OF_ARCHIVE=${3:?}
INTEL_SHA=${4:?}; OF_SHA=${5:?}; MARKER=${6:?}
test ! -e "$ROOT"; test ! -e "$MARKER"
printf '%s  %s\n' "$INTEL_SHA" "$INTEL_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$OF_SHA" "$OF_ARCHIVE" | sha256sum -c -
mkdir -p "$ROOT/opt/intel"
tar -xzf "$INTEL_ARCHIVE" -C "$ROOT/opt/intel"
tar -xzf "$OF_ARCHIVE" -C "$ROOT"
test -x "$ROOT/opt/intel/oneapi/mpi/2021.19/bin/mpirun"
test -e "$ROOT/opt/intel/oneapi/libfabric/2.6/lib/libfabric.so.1"
test -x "$ROOT/OpenFOAM-v2512/platforms/linux64IcxDPInt32Opt/bin/simpleFoam"
printf 'STAGE_4N_RUNTIME_PASS host=%s root=%s\n' "$(hostname)" "$ROOT" | tee "$MARKER"
