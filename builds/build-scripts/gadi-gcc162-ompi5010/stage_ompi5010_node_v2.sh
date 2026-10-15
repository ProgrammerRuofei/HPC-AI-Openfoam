#!/bin/bash
# Called by pbsdsh once per allocated SPR node; stage immutable archives to local JOBFS.
set -euo pipefail
JOBFS_ROOT=${1:?JOBFS_ROOT required}
GCC_ARCHIVE=${2:?GCC_ARCHIVE required}
MPI_ARCHIVE=${3:?MPI_ARCHIVE required}
GCC_SHA=${4:?GCC_SHA required}
MPI_SHA=${5:?MPI_SHA required}
MARKER=${6:?MARKER required}
test ! -e "$MARKER"
test ! -e "$JOBFS_ROOT"
printf '%s  %s\n' "$GCC_SHA" "$GCC_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$MPI_SHA" "$MPI_ARCHIVE" | sha256sum -c -
mkdir -p "$JOBFS_ROOT"
tar -xzf "$GCC_ARCHIVE" -C "$JOBFS_ROOT"
tar -xzf "$MPI_ARCHIVE" -C "$JOBFS_ROOT"
test -x "$JOBFS_ROOT/gcc-16.2.0/bin/gcc"
test -x "$JOBFS_ROOT/openmpi-5.0.10/bin/mpirun"
printf 'STAGE_OMPI5010_NODE_PASS host=%s root=%s\n' "$(hostname)" "$JOBFS_ROOT" | tee "$MARKER"
