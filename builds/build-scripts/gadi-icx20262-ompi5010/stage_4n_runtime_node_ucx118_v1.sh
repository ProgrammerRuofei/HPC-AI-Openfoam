#!/bin/bash
# PBS TM helper: unpack four pinned archives on one node's private JOBFS.
set -euo pipefail
ROOT=${1:?}; INTEL_ARCHIVE=${2:?}; GCC_ARCHIVE=${3:?}; MPI_ARCHIVE=${4:?}; OF_ARCHIVE=${5:?}
INTEL_SHA=${6:?}; GCC_SHA=${7:?}; MPI_SHA=${8:?}; OF_SHA=${9:?}; MARKER=${10:?}
test ! -e "$ROOT"; test ! -e "$MARKER"
printf '%s  %s\n' "$INTEL_SHA" "$INTEL_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$GCC_SHA" "$GCC_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$MPI_SHA" "$MPI_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$OF_SHA" "$OF_ARCHIVE" | sha256sum -c -
mkdir -p "$ROOT/opt/intel"
tar -xzf "$INTEL_ARCHIVE" -C "$ROOT/opt/intel"
tar -xzf "$GCC_ARCHIVE" -C "$ROOT"
tar -xzf "$MPI_ARCHIVE" -C "$ROOT"
tar -xzf "$OF_ARCHIVE" -C "$ROOT"
test -x "$ROOT/gcc-16.2.0/bin/gcc"
test -x "$ROOT/opt/intel/oneapi/compiler/2026.2/bin/icx"
test -x "$ROOT/openmpi-5.0.10/bin/mpirun"
test -x "$ROOT/OpenFOAM-v2512/platforms/linux64IcxDPInt32Opt/bin/simpleFoam"
printf 'STAGE_4N_RUNTIME_PASS host=%s root=%s\n' "$(hostname)" "$ROOT" | tee "$MARKER"
