#!/bin/bash
# AOCC 5.0 Allwmake into linux64AmdDPInt32PgoUse after llvm-profdata merge.
# Writes General/common/c++PgoUse only. Does not edit c++Opt.

set -eo pipefail
NCPUS="${PBS_NCPUS:-${NCPUS:-64}}"
FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
OF_DIR="${FOAM_INST_DIR}/OpenFOAM-v2512"
PGO_DIR="${FOAM_INST_DIR}/pgo/aocc"
PROFDATA="${PGO_DIR}/merged.profdata"
export CC=clang CXX=clang++ FC=flang F77=flang
export OMPI_CC=clang OMPI_CXX=clang++ OMPI_FC=flang
if [[ ! -x "${OF_DIR}/Allwmake" ]]; then
    echo "Missing ${OF_DIR}" >&2
    exit 1
fi
shopt -s nullglob
raws=("${PGO_DIR}"/*.profraw)
if [[ "${#raws[@]}" -lt 1 ]]; then
    echo "No ${PGO_DIR}/*.profraw from the PgoGen training run" >&2
    exit 1
fi
llvm-profdata merge -o "${PROFDATA}" "${raws[@]}"
ls -l "${PROFDATA}"
RULE="${OF_DIR}/wmake/rules/General/common/c++PgoUse"
if [[ ! -f "${RULE}" ]]; then
    cp "${OF_DIR}/wmake/rules/General/common/c++Opt" "${RULE}"
    if grep -q '^c++OPT' "${RULE}"; then
        sed -i 's/^c++OPT.*/c++OPT     := -O3/' "${RULE}"
    else
        echo 'c++OPT     := -O3' >> "${RULE}"
    fi
fi
export FOAM_INST_DIR WM_NCOMPPROCS="${NCPUS}"
cd "${OF_DIR}"
set +eu
# shellcheck disable=SC1091
source etc/bashrc WM_COMPILER=Amd WM_MPLIB=SYSTEMOPENMPI \
    WM_COMPILE_OPTION=PgoUse WM_LABEL_SIZE=32
set -eu
# bashrc unsets FOAM_EXTRA_*; set them after source.
FABRIC_LIB="${HOME}/scratch/openfoam-v2512/ext/libfabric/lib/libfabric.so.1"
export LD_LIBRARY_PATH="$(dirname "${FABRIC_LIB}"):${LD_LIBRARY_PATH:-}"
export FOAM_EXTRA_LDFLAGS="${FABRIC_LIB} -fuse-ld=bfd"
export FOAM_EXTRA_CXXFLAGS="-fprofile-instr-use=${PROFDATA}"
echo "FOAM_APPBIN=${FOAM_APPBIN} WM_COMPILE_OPTION=${WM_COMPILE_OPTION}"
echo "FOAM_EXTRA_CXXFLAGS=${FOAM_EXTRA_CXXFLAGS}"
echo "FOAM_EXTRA_LDFLAGS=${FOAM_EXTRA_LDFLAGS}"
echo "${FOAM_APPBIN}" | grep -q PgoUse || { echo "Refusing: not a PgoUse platform" >&2; exit 1; }
./Allwmake -k -j "${NCPUS}"
wmake -j "${NCPUS}" applications/solvers/incompressible/simpleFoam
if [[ ! -x "${FOAM_APPBIN}/simpleFoam" ]]; then
    echo "simpleFoam missing under ${FOAM_APPBIN}" >&2
    exit 1
fi
echo "Build OK: ${FOAM_APPBIN}/simpleFoam"
