#!/bin/bash
# C1-AVX512: identical to C1 generic in every respect except architecture
# targeting. WM_COMPILE_OPTION=OptAVX512 resolves, via wmake's
# linux64Icc/c++OptAVX512, to `-O3 -xCORE-AVX512` instead of plain `-O3`.
#
# Both ICC 2021.10 workarounds are still required and still apply:
#   - the aligned-new workaround appends to wmake/rules/linux64Icc/c++, which is
#     included for every WM_COMPILE_OPTION, so it covers OptAVX512 as well;
#   - the CircularBuffer const workaround patches a header and is likewise
#     independent of the optimisation level.
#
# This writes to its own STACK_ID tree. The validated C1 generic build,
# runtime-v2 archive and hashes are never touched.
set -euo pipefail
STACK_ID=c1avx512-icc2021-openmpi417 \
MODULE_LIST='intel-compiler/2021.10.0 openmpi/4.1.7' \
WM_COMPILER_VALUE=Icc OMPI_CC_VALUE=icc OMPI_CXX_VALUE=icpc \
WM_COMPILE_OPTION_VALUE=OptAVX512 \
EXPECT_COMPILE_FLAGS='-xCORE-AVX512 -O3' \
ICC_ALIGNED_NEW_WORKAROUND=1 ICC_CIRCULARBUFFER_CONST_WORKAROUND=1 \
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../common/build_openfoam_v2512_openmpi.sh"
