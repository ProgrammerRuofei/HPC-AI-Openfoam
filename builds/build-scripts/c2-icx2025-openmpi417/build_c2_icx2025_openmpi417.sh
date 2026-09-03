#!/bin/bash
set -euo pipefail
STACK_ID=c2-icx2025-openmpi417 MODULE_LIST='intel-compiler-llvm/2025.1.1 openmpi/4.1.7' WM_COMPILER_VALUE=Icx OMPI_CC_VALUE=icx OMPI_CXX_VALUE=icpx \
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh"
