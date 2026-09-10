#!/bin/bash
# D4: Intel MPI 2021.17.2, compiler held at D2. Contamination gates invert.
# PREPARED, NOT RUN. See README.md in this directory.
set -euo pipefail
STACK_ID=d4-icx2025-intelmpi \
MODULE_LIST='intel-compiler-llvm/2025.3.2 intel-mpi/2021.17.2' \
WM_COMPILER_VALUE=Icx OMPI_CC_VALUE=icx OMPI_CXX_VALUE=icpx \
WM_COMPILE_OPTION_VALUE=Opt \
WM_MPLIB_VALUE=INTELMPI \
EXPECT_FOAM_MPI=intelmpi \
EXPECT_MPICC=/apps/intel-tools/intel-mpi/2021.17.2/bin/mpicc \
EXPECT_LDD_MPI=/apps/intel-tools/intel-mpi/2021.17.2 \
MPI_SHOW_FLAG='-show' \
EXPECT_COMPILE_FLAGS='-O3' \
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh"
