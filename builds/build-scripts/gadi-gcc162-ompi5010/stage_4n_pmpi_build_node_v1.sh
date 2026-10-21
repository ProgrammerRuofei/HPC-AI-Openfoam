#!/bin/bash
# Build the reviewed C-only PMPI interposer on this node's private JOBFS.
set -euo pipefail
ROOT=${1:?}; SOURCE=${2:?}; SOURCE_SHA=${3:?}; MARKER=${4:?}
test -d "$ROOT/openmpi-5.0.10"; test -d "$ROOT/gcc-16.2.0"
test ! -e "$MARKER"; test ! -e "$ROOT/libpmpi_timing.so"
printf '%s  %s\n' "$SOURCE_SHA" "$SOURCE" | sha256sum -c -
export OPAL_PREFIX="$ROOT/openmpi-5.0.10" PMIX_PREFIX="$ROOT/openmpi-5.0.10" PRTE_PREFIX="$ROOT/openmpi-5.0.10"
export OMPI_CC="$ROOT/gcc-16.2.0/bin/gcc"
export PATH="$ROOT/openmpi-5.0.10/bin:$ROOT/gcc-16.2.0/bin:$PATH"
export LD_LIBRARY_PATH="$ROOT/openmpi-5.0.10/lib:$ROOT/gcc-16.2.0/lib64:/opt/pbs/default/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
mkdir -p "$ROOT/pmpi-reports"
mpicc -O2 -g -std=gnu17 -Wall -Wextra -Werror -fPIC -shared "$SOURCE" -o "$ROOT/libpmpi_timing.so"
test -s "$ROOT/libpmpi_timing.so"
ldd "$ROOT/libpmpi_timing.so" > "$ROOT/pmpi_timing.ldd"
! grep -Fq 'not found' "$ROOT/pmpi_timing.ldd"
grep -F "libmpi.so.40 => $ROOT/openmpi-5.0.10/lib/" "$ROOT/pmpi_timing.ldd"
printf 'STAGE_4N_PMPI_BUILD_PASS host=%s lib_sha256=%s\n' "$(hostname)" "$(sha256sum "$ROOT/libpmpi_timing.so" | cut -d ' ' -f1)" > "$MARKER"
