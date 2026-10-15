#!/bin/bash
set -euo pipefail
STACK_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-gcc162-ompi5010
GCC_ARCHIVE="$STACK_ROOT/runtime-archive/gcc-16.2.0.181342083.gadi-pbs.tar.gz"
MPI_ARCHIVE="$STACK_ROOT/runtime-archive/openmpi-5.0.10.181346004.gadi-pbs.tar.gz"
GCC_SHA=1149c0d97412ae3741cc18d60f233cdd3dd5e33bc92c55c59db2dd8cf535b714
MPI_SHA=8ac121e4f64eb329dc33cd2cc8229dc9f655064a757cbcaa36af962b21619fc6
TOOLCHAIN_ROOT="${PBS_JOBFS:?}/openfoam-toolchain-${PBS_JOBID:?}"
test "${PBS_NCPUS:?}" -eq 48
test ! -e "$TOOLCHAIN_ROOT"
printf '%s  %s\n' "$GCC_SHA" "$GCC_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$MPI_SHA" "$MPI_ARCHIVE" | sha256sum -c -
mkdir "$TOOLCHAIN_ROOT"
tar -xzf "$GCC_ARCHIVE" -C "$TOOLCHAIN_ROOT"
tar -xzf "$MPI_ARCHIVE" -C "$TOOLCHAIN_ROOT"
export PRIVATE_GCC_PREFIX="$TOOLCHAIN_ROOT/gcc-16.2.0"
export PRIVATE_MPI_PREFIX="$TOOLCHAIN_ROOT/openmpi-5.0.10"
test -x "$PRIVATE_GCC_PREFIX/bin/gcc"
test -x "$PRIVATE_GCC_PREFIX/bin/g++"
test -x "$PRIVATE_MPI_PREFIX/bin/mpicc"
test -x "$PRIVATE_MPI_PREFIX/bin/mpirun"
export STACK_ID=gadi-gcc162-ompi5010-of2512
export MODULE_LIST='ucx/1.18.1 ucc/1.4.4'
export WM_COMPILER_VALUE=Gcc
export OMPI_CC_VALUE="$PRIVATE_GCC_PREFIX/bin/gcc"
export OMPI_CXX_VALUE="$PRIVATE_GCC_PREFIX/bin/g++"
export WM_COMPILE_OPTION_VALUE=Opt
exec bash builds/build-scripts/common/build_openfoam_v2512_openmpi.sh
