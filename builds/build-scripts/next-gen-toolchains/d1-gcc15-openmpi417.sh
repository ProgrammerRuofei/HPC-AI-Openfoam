#!/bin/bash
# D1: GCC 15.1.0 vs the GCC 8.5.0 site build. Compiler only.
# PREPARED, NOT RUN. See README.md in this directory.
set -euo pipefail
STACK_ID=d1-gcc15-openmpi417 \
MODULE_LIST='gcc/15.1.0 openmpi/4.1.7' \
WM_COMPILER_VALUE=Gcc OMPI_CC_VALUE=gcc OMPI_CXX_VALUE=g++ \
WM_COMPILE_OPTION_VALUE=Opt \
WM_MPLIB_VALUE=SYSTEMOPENMPI \
EXPECT_FOAM_MPI=sys-openmpi \
EXPECT_MPICC=/apps/openmpi/4.1.7/bin/mpicc \
EXPECT_LDD_MPI=/apps/openmpi/4.1.7 \
MPI_SHOW_FLAG='--showme:command' \
EXPECT_COMPILE_FLAGS='-O3' \
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh"
