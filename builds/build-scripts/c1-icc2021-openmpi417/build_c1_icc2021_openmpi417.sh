#!/bin/bash
set -euo pipefail
STACK_ID=c1-icc2021-openmpi417 MODULE_LIST='intel-compiler/2021.10.0 openmpi/4.1.7' WM_COMPILER_VALUE=Icc OMPI_CC_VALUE=icc OMPI_CXX_VALUE=icpc ICC_ALIGNED_NEW_WORKAROUND=1 \
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh"
