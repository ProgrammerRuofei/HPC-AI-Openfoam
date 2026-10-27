#!/bin/bash
# Private ICX 2026.2 compiler with the already validated GCC 16.2 / Open MPI 5.0.10 runtime.
set -euo pipefail
: "${PBS_JOBID:?}" "${PBS_JOBFS:?}" "${PBS_NCPUS:?}"
test "$PBS_NCPUS" -eq 48
BASE=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening
INTEL_ARCHIVE="$BASE/gadi-icx20262-impi202119/runtime-archive/gadi-icx20262-impi202119.182138851.gadi-pbs.tar.gz"
INTEL_SHA=013ea4758e05b3656b5474845577fcd0631b28d783e115b5e42d644d321a2fbc
GCC_ARCHIVE="$BASE/gadi-gcc162-ompi5010/runtime-archive/gcc-16.2.0.181342083.gadi-pbs.tar.gz"
MPI_ARCHIVE="$BASE/gadi-gcc162-ompi5010/runtime-archive/openmpi-5.0.10.181346004.gadi-pbs.tar.gz"
GCC_SHA=1149c0d97412ae3741cc18d60f233cdd3dd5e33bc92c55c59db2dd8cf535b714
MPI_SHA=8ac121e4f64eb329dc33cd2cc8229dc9f655064a757cbcaa36af962b21619fc6
ROOT="$PBS_JOBFS/icx20262-ompi5010-toolchain-$PBS_JOBID"
test ! -e "$ROOT"
for item in "$INTEL_SHA $INTEL_ARCHIVE" "$GCC_SHA $GCC_ARCHIVE" "$MPI_SHA $MPI_ARCHIVE"; do
    read -r hash archive <<< "$item"
    printf '%s  %s\n' "$hash" "$archive" | sha256sum -c -
done
mkdir -p "$ROOT/opt/intel"
tar -xzf "$INTEL_ARCHIVE" -C "$ROOT/opt/intel"
tar -xzf "$GCC_ARCHIVE" -C "$ROOT"
tar -xzf "$MPI_ARCHIVE" -C "$ROOT"
export PRIVATE_COMPILER_VARS_SH="$ROOT/opt/intel/oneapi/compiler/2026.2/env/vars.sh"
export PRIVATE_GCC_PREFIX="$ROOT/gcc-16.2.0"
export PRIVATE_MPI_PREFIX="$ROOT/openmpi-5.0.10"
test -f "$PRIVATE_COMPILER_VARS_SH"
test -x "$PRIVATE_GCC_PREFIX/bin/gcc"
test -x "$PRIVATE_MPI_PREFIX/bin/mpicxx"
export STACK_ID=gadi-icx20262-ompi5010-of2512
export MODULE_LIST='ucx/1.18.1 ucc/1.4.4'
export WM_COMPILER_VALUE=Icx
export OMPI_CC_VALUE=icx OMPI_CXX_VALUE=icpx
export EXPECTED_ICX_VERSION=2026.2.0
export WM_COMPILE_OPTION_VALUE=Opt
export SCOTCH_C17_WORKAROUND=1
export APPLICATION_BUILD_MODE=benchmark-required
exec bash builds/build-scripts/common/build_openfoam_v2512_openmpi.sh
