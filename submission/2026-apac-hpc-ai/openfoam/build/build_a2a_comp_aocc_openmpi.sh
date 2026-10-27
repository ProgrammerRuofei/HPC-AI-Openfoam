#!/bin/bash
# Build OpenFOAM-v2512 with AOCC 5.0 and OpenMPI 5.0.10 on Aspire2A-comp.
# Working directory: this build-scripts directory.
# Inputs: unpacked source under $HOME/scratch/openfoam-v2512.
# Outputs: $FOAM_APPBIN/simpleFoam on platform linux64AmdDPInt32Opt.
# Submit only when no other Allwmake is running on this tree.

set -eo pipefail

NCPUS="${PBS_NCPUS:-${NCPUS:-64}}"
FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
OF_DIR="${FOAM_INST_DIR}/OpenFOAM-v2512"

export CC=clang
export CXX=clang++
export FC=flang
export F77=flang
export OMPI_CC=clang
export OMPI_CXX=clang++
export OMPI_FC=flang

echo "Build start host=$(hostname) ncpus=${NCPUS} clang=$(clang --version | head -1)"
if [[ ! -x "${OF_DIR}/Allwmake" ]]; then
    echo "Missing source at ${OF_DIR}. Run scripts/fetch_openfoam_v2512.sh on the login node." >&2
    exit 1
fi
command -v mpicxx >/dev/null || { echo "mpicxx not on PATH" >&2; exit 1; }
command -v cmake >/dev/null || { echo "cmake not on PATH" >&2; exit 1; }
command -v clang++ >/dev/null || { echo "clang++ not on PATH" >&2; exit 1; }

export FOAM_INST_DIR
export WM_NCOMPPROCS="${NCPUS}"
cd "${OF_DIR}"
set +eu
# shellcheck disable=SC1091
source etc/bashrc WM_COMPILER=Amd WM_MPLIB=SYSTEMOPENMPI WM_LABEL_SIZE=32
set -eu
FABRIC_LIB="${HOME}/scratch/openfoam-v2512/ext/libfabric/lib/libfabric.so.1"
if [[ ! -e "${FABRIC_LIB}" ]]; then
    echo "Missing ${FABRIC_LIB}. Copy libfabric 1.22 from the login node onto scratch." >&2
    exit 1
fi
export LD_LIBRARY_PATH="$(dirname "${FABRIC_LIB}"):${LD_LIBRARY_PATH:-}"
export FOAM_EXTRA_LDFLAGS="${FABRIC_LIB}"
echo "Sourced bashrc FOAM_APPBIN=${FOAM_APPBIN} FOAM_EXTRA_LDFLAGS=${FOAM_EXTRA_LDFLAGS}"

./Allwmake -k -j "${NCPUS}"
wmake -j "${NCPUS}" applications/solvers/incompressible/simpleFoam

if [[ ! -x "${FOAM_APPBIN}/simpleFoam" ]]; then
    echo "simpleFoam missing under ${FOAM_APPBIN}" >&2
    exit 1
fi
echo "Build OK: ${FOAM_APPBIN}/simpleFoam"
simpleFoam -help >/dev/null
