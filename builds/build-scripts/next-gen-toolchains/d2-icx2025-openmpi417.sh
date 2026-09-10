#!/bin/bash
# D2: ICX 2025.3.2 vs ICC 2021.10 generic, matched -O3.
# PREPARED, NOT RUN. See README.md in this directory.
set -euo pipefail
STACK_ID=d2-icx2025-openmpi417 \
MODULE_LIST='intel-compiler-llvm/2025.3.2 openmpi/4.1.7' \
WM_COMPILER_VALUE=Icx OMPI_CC_VALUE=icx OMPI_CXX_VALUE=icpx \
WM_COMPILE_OPTION_VALUE=Opt \
WM_MPLIB_VALUE=SYSTEMOPENMPI \
EXPECT_FOAM_MPI=sys-openmpi \
EXPECT_MPICC=/apps/openmpi/4.1.7/bin/mpicc \
EXPECT_LDD_MPI=/apps/openmpi/4.1.7 \
MPI_SHOW_FLAG='--showme:command' \
EXPECT_COMPILE_FLAGS='-O3' \
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh"
