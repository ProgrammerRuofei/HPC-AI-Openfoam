#!/bin/bash
# Run contest occDrivAerStaticMesh Allrun chain for one node count.
# Working directory: experiments/occdrivaer-static (called from a PBS script).
# Inputs: FOAM_INST_DIR, ATTEMPT, NCORES, NHIERARCHICAL, ENDTIME.
# Optional: DECOMP_METHOD, SCOTCH_DOMAINS, SCOTCH_DOMAIN_WEIGHTS, MPI_ARGS.
# Outputs: case on scratch, logFiles, coefficient.dat, stdout markers.
# Mesh must already exist under the template constant/polyMesh.

set -eo pipefail

FOAM_INST_DIR="${FOAM_INST_DIR:-${HOME}/scratch/openfoam-v2512}"
OF_DIR="${FOAM_INST_DIR}/OpenFOAM-v2512"
ATTEMPT="${ATTEMPT:?set ATTEMPT}"
NCORES="${NCORES:?set NCORES}"
NHIERARCHICAL="${NHIERARCHICAL:?set NHIERARCHICAL}"
ENDTIME="${ENDTIME:?set ENDTIME}"
WM_COMPILER="${WM_COMPILER:-Icx}"
WM_MPLIB="${WM_MPLIB:-INTELMPI}"
WM_COMPILE_OPTION="${WM_COMPILE_OPTION:-Opt}"
TEMPLATE="${FOAM_INST_DIR}/cases/occDrivAerStaticMesh-template"
CASE="${FOAM_INST_DIR}/cases/occdrivaer-${ATTEMPT}"

echo "DrivAer start host=$(hostname) attempt=${ATTEMPT} ncores=${NCORES} endTime=${ENDTIME}"
if [[ ! -d "${TEMPLATE}/constant/polyMesh" ]]; then
    echo "Missing mesh at ${TEMPLATE}/constant/polyMesh" >&2
    exit 1
fi

export FOAM_INST_DIR
cd "${OF_DIR}"
set +eu
# shellcheck disable=SC1091
source etc/bashrc WM_COMPILER="${WM_COMPILER}" WM_MPLIB="${WM_MPLIB}" \
    WM_COMPILE_OPTION="${WM_COMPILE_OPTION}" WM_LABEL_SIZE=32
# Official Allrun: restore0Dir is a function in RunFunctions, not a binary.
# shellcheck disable=SC1091
. "${WM_PROJECT_DIR:?}/bin/tools/RunFunctions"
set -eu
if [[ -n "${FOAM_EXTRA_LD_LIBRARY_PATH:-}" ]]; then
    export LD_LIBRARY_PATH="${FOAM_EXTRA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"
fi
# PgoGen/PgoUse may only ship simpleFoam. Use Opt utilities (foamDictionary,
# decomposePar, ...) from the same compiler platform.
if [[ "${WM_COMPILE_OPTION}" == PgoGen || "${WM_COMPILE_OPTION}" == PgoUse ]]; then
    OPT_APPBIN="${FOAM_APPBIN/${WM_COMPILE_OPTION}/Opt}"
    if [[ -x "${OPT_APPBIN}/foamDictionary" ]]; then
        export PATH="${FOAM_APPBIN}:${OPT_APPBIN}:${PATH}"
        echo "PGO PATH utilities from ${OPT_APPBIN}"
    fi
fi
# Coded function objects (wallClockTimeStatistics) wmake at run time with
# the PgoGen/PgoUse rules and site bfd cannot read GCC 15 libgcov.a.
if [[ "${WM_COMPILER}" == Gcc && ( "${WM_COMPILE_OPTION}" == PgoGen || "${WM_COMPILE_OPTION}" == PgoUse ) ]]; then
    GOLD_WRAP="${HOME}/OpenFoam-HPCAI-26/builds/build-scripts/a2a-comp-gcc-pgo"
    if [[ -x "${GOLD_WRAP}/ld.gold" ]]; then
        export FOAM_EXTRA_LDFLAGS="${FABRIC_LIB:-} -B${GOLD_WRAP} -fuse-ld=gold"
        echo "PGO runtime gold wrap ${GOLD_WRAP}"
    fi
fi

if [[ ! -x "${FOAM_APPBIN}/simpleFoam" ]]; then
    echo "simpleFoam missing under ${FOAM_APPBIN}" >&2
    exit 1
fi

mkdir -p "${FOAM_INST_DIR}/cases"
# Template may be a symlink; cp -a would copy the symlink and write
# foamDictionary into the shared mesh case.
TEMPLATE_REAL="$(readlink -f "${TEMPLATE}")"
rm -rf "${CASE}"
mkdir -p "${CASE}"
cp -a "${TEMPLATE_REAL}/." "${CASE}/"
# Leftover processor* (not in a clean template) make decomposePar exit.
rm -rf "${CASE}"/processor*
cd "${CASE}"

foamDictionary -entry nCores -set "${NCORES}" system/include/caseDefinition
foamDictionary -entry nHierarchical -set "${NHIERARCHICAL}" system/include/caseDefinition
if [[ -n "${DECOMP_METHOD:-}" ]]; then
    foamDictionary -entry decompositionMethod -set "${DECOMP_METHOD}" system/include/caseDefinition
fi
if [[ -n "${SCOTCH_DOMAINS:-}" ]]; then
    # decomposeParDict has no coeffs key; foamDictionary -entry coeffs/... fails.
    {
        echo ""
        echo "coeffs"
        echo "{"
        echo "    domains         ${SCOTCH_DOMAINS};"
        echo "    domainWeights   ${SCOTCH_DOMAIN_WEIGHTS:-(1 0.01)};"
        echo "}"
    } >> system/decomposeParDict
    echo "Appended scotch coeffs domains=${SCOTCH_DOMAINS} domainWeights=${SCOTCH_DOMAIN_WEIGHTS:-(1 0.01)}"
fi
foamDictionary -entry endTime -set "${ENDTIME}" system/controlDict.noWrite
cp system/controlDict.noWrite system/controlDict
cp system/fvSolution.fixedIter system/fvSolution

echo "Binary: ${FOAM_APPBIN}/simpleFoam"
echo "Case: ${CASE}"
echo "WM_COMPILER=${WM_COMPILER} WM_MPLIB=${WM_MPLIB} WM_COMPILE_OPTION=${WM_COMPILE_OPTION}"
echo "mpirun=$(command -v mpirun)"
echo "MPI_ARGS=${MPI_ARGS:-unset}"
echo "I_MPI_FABRICS=${I_MPI_FABRICS:-unset}"
echo "I_MPI_OFI_PROVIDER=${I_MPI_OFI_PROVIDER:-unset}"
echo "FI_PROVIDER=${FI_PROVIDER:-unset}"
echo "FABRIC_LIB=${FABRIC_LIB:-unset}"
ldd "${FOAM_APPBIN}/simpleFoam" | grep -E 'libmpi|libfabric|libpmpi' || true
echo "nCores=$(foamDictionary -entry nCores -value system/include/caseDefinition)"
echo "nHierarchical=$(foamDictionary -entry nHierarchical -value system/include/caseDefinition)"
echo "decompositionMethod=$(foamDictionary -entry decompositionMethod -value system/include/caseDefinition)"
echo "endTime=$(foamDictionary -entry endTime -value system/controlDict)"

if [[ "${WM_MPLIB}" == "INTELMPI" ]]; then
    export I_MPI_HYDRA_BOOTSTRAP="${I_MPI_HYDRA_BOOTSTRAP:-pbs}"
fi
# MPI_ARGS is extra mpirun flags (OpenMPI bind/map). Intel pin is env-only.
# Multi-node OpenMPI needs the PBS hostfile; Intel MPI uses I_MPI_HYDRA_BOOTSTRAP=pbs.
# shellcheck disable=SC2086
if [[ "${WM_MPLIB}" == "SYSTEMOPENMPI" && -n "${PBS_NODEFILE:-}" ]]; then
    # Remote PRTE ranks do not inherit the PBS head-node env.
    # -x PATH/LD_LIBRARY_PATH lets the binary start; WM_/FOAM_ are
    # required for etc/controlDict (v1.1 died without them).
    XENV="-x PATH -x LD_LIBRARY_PATH -x HOME"
    while IFS= read -r v; do
        XENV="${XENV} -x ${v}"
    done < <(env | awk -F= '/^(WM_|FOAM_|LLVM_|GCOV_)/ {print $1}' | sort -u)
    if [[ -z "${MPI_ARGS:-}" ]]; then
        nn="$(sort -u "${PBS_NODEFILE}" | wc -l | tr -d ' ')"
        ppn=$(( NCORES / nn ))
        PAR="mpirun --hostfile ${PBS_NODEFILE} --map-by ppr:${ppn}:node -np ${NCORES} ${XENV}"
    else
        PAR="mpirun --hostfile ${PBS_NODEFILE} -np ${NCORES} ${XENV} ${MPI_ARGS}"
    fi
else
    PAR="mpirun -np ${NCORES} ${MPI_ARGS:-}"
fi
echo "PAR=${PAR}"
mkdir -p logFiles

echo "decomposePar"
time decomposePar -constant > logFiles/10_decomposePar.log 2>&1
echo "restore0Dir"
restore0Dir -processor
echo "renumberMesh"
time ${PAR} renumberMesh -constant -overwrite -parallel > logFiles/20_renumberMesh.log 2>&1
echo "potentialFoam"
time ${PAR} potentialFoam -initialiseUBCs -parallel > logFiles/30_potentialFoam.log 2>&1
echo "applyBoundaryLayer"
time ${PAR} applyBoundaryLayer -ybl 0.0450244 -parallel > logFiles/40_applyBoundaryLayer.log 2>&1
STAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
SFLOG="logFiles/50_simpleFoam.${STAMP}.log"
echo "simpleFoam log=${SFLOG}"
SPAR="${PAR}"
if [[ -n "${PROFILE_LIB:-}" ]]; then
    if [[ ! -f "${PROFILE_LIB}" ]]; then
        echo "Missing PROFILE_LIB ${PROFILE_LIB}" >&2
        exit 1
    fi
    export LD_PRELOAD="${PROFILE_LIB}"
    export PROFILE_OUT="${CASE}/foam_mpi_profile.txt"
    if [[ "${WM_MPLIB}" == "SYSTEMOPENMPI" ]]; then
        SPAR="${SPAR/mpirun /mpirun -x LD_PRELOAD -x PROFILE_OUT }"
    fi
    echo "PROFILE_LIB=${PROFILE_LIB}"
    echo "PROFILE_OUT=${PROFILE_OUT}"
fi
time ${SPAR} simpleFoam -parallel > "${SFLOG}" 2>&1
if [[ -n "${PROFILE_OUT:-}" && -f "${PROFILE_OUT}" ]]; then
    echo "===== FOAM_MPI_PROFILE ====="
    cat "${PROFILE_OUT}"
fi

if ! grep -q '^End' "${SFLOG}"; then
    echo "simpleFoam log has no End marker" >&2
    tail -40 "${SFLOG}" >&2
    exit 1
fi
if grep -Eiq '(^|[[:space:]])nan([[:space:]]|$)' "${SFLOG}"; then
    echo "simpleFoam log contains NaN" >&2
    exit 1
fi

AVG="$(awk -F'=' '/Average wall-clock time per time step/ { v=$NF } END { print v }' "${SFLOG}" | tr -d ' ')"
echo "AVG_WALL_PER_STEP=${AVG}"
CDFILE="$(find postProcessing/forceCoeffsAll -name coefficient.dat 2>/dev/null | head -1 || true)"
if [[ -n "${CDFILE}" ]]; then
    echo "CD_FILE=${CDFILE}"
    tail -3 "${CDFILE}"
fi
echo "DRIVAER_OK attempt=${ATTEMPT} avg=${AVG} log=${CASE}/${SFLOG}"
