#!/bin/bash
# Compute-node Scotch A/B/C runner. Wrapper PBS scripts set RUN_MODE and BLOCK.
# Inputs: pinned occDrivAerStaticMesh template and AOCC stock Opt build.
# Outputs: unique PBS-ID scratch case trees with per-arm evidence.
# Never reuse, overwrite, or delete an existing case.
set -euo pipefail
: "${RUN_MODE:?wrapper must set RUN_MODE}"
: "${BLOCK:?wrapper must set BLOCK}"
case "$RUN_MODE:$BLOCK" in preflight:0|full:1|full:2|full:3) ;; *) echo "Invalid RUN_MODE/BLOCK" >&2; exit 2;; esac

CONTROL_REPO=/home/project/59000020/openfoam-isc26/control-repo
FOAM_INST_DIR="${HOME}/scratch/openfoam-v2512"
OF_DIR="${FOAM_INST_DIR}/OpenFOAM-v2512"
TEMPLATE_LINK="${FOAM_INST_DIR}/cases/occDrivAerStaticMesh-template"
RUN_ROOT="${FOAM_INST_DIR}/cases/scotch-abc-${RUN_MODE}-b${BLOCK}-v1-${PBS_JOBID%%.*}"
EVIDENCE="${RUN_ROOT}/evidence"
NRANKS=512
NNODES=4
RANKS_PER_NODE=128
ENDTIME=150
JOB_START_EPOCH=$(date +%s)

EXPECTED_SHA_CASEDEF=cc8476b011c0b6d04e9e4495c12078885218d81a8377ca1543d0477a21b891e7
EXPECTED_SHA_DECOMPOSE=ee76e1b47f56d98d5552de3c60e75801f194249bea8f47c19a0ac2816a570829
EXPECTED_SHA_CONTROL_NOWRITE=5d497aa829c0369dc3252a5af03043bc099d4ac31f39c780fc3184c602687c0c
EXPECTED_SHA_FVSCHEMES=064bb50455d37a7edd2c0fb24bbe30baaf851623f0250d550450c10e407889b3
EXPECTED_SHA_FVSOLUTION_FIXED=5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba
EXPECTED_SHA_FORCECOEFFS=4a66f9792320ef7775486f34a80185e3ab384f3529a231f448c3f80c78c7d001
EXPECTED_SHA_U=bcec9e7b7c5fdff940d960b4f32a1abde445411a9efaad24c4a9c4c8160fd8e8
EXPECTED_SHA_TRANSPORT=4994e93eac7370fc2f8921e7cef59022f1f677319bbb8e0e5187ff777ee90f27
EXPECTED_SHA_TURBULENCE=aa80a06db5870f620e484df3f97098c105c534bd473b114de99497b6f75c1e58
EXPECTED_SHA_POINTS=7c43587be473796d67fd735ba3e7b76733b5c93540123fad85c4b1d2b7b47a7e
EXPECTED_SHA_FACES=9aef04138f5107dbb47257cfca1b15eb0ba478b0963f1557d7d0b69ee534512d
EXPECTED_SHA_OWNER=7e784350e2e8c00f2fac9f847c94b7e3b317c9deb1740a8512b809b5863f80b2
EXPECTED_SHA_NEIGHBOUR=b5b0f90fbac0dc966c235b28c5712e4f2d38535a4f1e05b2f9ddbbc490545fea
EXPECTED_SHA_BOUNDARY=3f34abc678836a67f87bfea30c707df0a5571aaafa1e303d4b0b6ff5cc7c519b
EXPECTED_SHA_LIBFABRIC=4959baaffd6620659f9878693faba31bd3ac7c382a0e576a9e1816653873407f
EXPECTED_SHA_SIMPLEFOAM=7846a1250d3b95a80507f907f5a1ed9d2281a75b1bfd18d47af24b5105d2609f

test "$(readlink -f "${PBS_O_WORKDIR:?}")" = "$(readlink -f "$CONTROL_REPO")"
test ! -e "$RUN_ROOT" || { echo "ERROR: refusing to reuse $RUN_ROOT" >&2; exit 2; }
mkdir -p "$EVIDENCE"
exec > >(tee -a "$EVIDENCE/run.log") 2>&1

preserve_status()
{
    rc=$?
    set +e
    printf 'script_exit_rc=%s\n' "$rc" > "$EVIDENCE/exit-status.txt"
    return "$rc"
}
trap preserve_status EXIT

printf 'classification=SCOTCH A/B/C CONTROLLED STUDY\nofficial_result=false\nprofiled=false\nmode=%s\nblock=%s\njob=%s\n' "$RUN_MODE" "$BLOCK" "$PBS_JOBID"

echo '===== ALLOCATION ====='
sort -u "$PBS_NODEFILE" | tee "$EVIDENCE/nodes.txt"
cp -p "$PBS_NODEFILE" "$EVIDENCE/pbs-nodefile.txt"
test "$(sort -u "$PBS_NODEFILE" | wc -l | tr -d ' ')" -eq "$NNODES"
test "$(wc -l < "$PBS_NODEFILE" | tr -d ' ')" -eq "$NRANKS"
slots_per_node=$(awk '{n[$0]++} END {for (h in n) print n[h]}' "$PBS_NODEFILE" | sort -u)
test "$slots_per_node" = "$RANKS_PER_NODE"

echo '===== TOOLCHAIN ====='
module purge
module load aocc/5.0
module load gcc/11.2.0
module load openmpi/5.0.10-gcc11
module list 2>&1 | tee "$EVIDENCE/modules.txt"
export PATH="/app/apps/aocc/5.0/bin:${PATH}"
export OMPI_CC=clang
export OMPI_CXX=clang++
export OMPI_FC=flang
FABRIC_CANDIDATES=(
    /scratch/users/industry/ai-hpc/apacsc20/openfoam-v2512/ext/libfabric/lib/libfabric.so.1
    /scratch/users/industry/ai-hpc/apacsc20/openfoam-v2512/ext/libfabric-1.22.0-from-login/lib64/libfabric.so.1
)
FABRIC_LIB=
for candidate in "${FABRIC_CANDIDATES[@]}"; do
    if test -r "$candidate"; then
        FABRIC_LIB=$candidate
        break
    fi
done
test -n "$FABRIC_LIB" || {
    printf 'ERROR: no retained baseline libfabric is readable\n' >&2
    printf 'checked=%s\n' "${FABRIC_CANDIDATES[@]}" >&2
    exit 3
}
ls -l "$FABRIC_LIB" | tee "$EVIDENCE/libfabric.ls.txt"
readlink -f "$FABRIC_LIB" | tee "$EVIDENCE/libfabric.realpath.txt"
test "$(sha256sum "$(readlink -f "$FABRIC_LIB")" | awk '{print $1}')" = "$EXPECTED_SHA_LIBFABRIC"
sha256sum "$(readlink -f "$FABRIC_LIB")" | tee "$EVIDENCE/libfabric.sha256"
export FOAM_EXTRA_LD_LIBRARY_PATH="$(dirname "$FABRIC_LIB")"
export LD_LIBRARY_PATH="${FOAM_EXTRA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"
printf 'LD_LIBRARY_PATH=%s\n' "$LD_LIBRARY_PATH" > "$EVIDENCE/ld-library-path.txt"
export FOAM_INST_DIR

echo 'CHECKPOINT_LIBFABRIC_OK'
test -d "$OF_DIR"
test -r "$OF_DIR/etc/bashrc"
cd "$OF_DIR"
echo 'CHECKPOINT_OPENFOAM_TREE_OK'

set +eu
. etc/bashrc WM_COMPILER=Amd WM_MPLIB=SYSTEMOPENMPI WM_COMPILE_OPTION=Opt WM_LABEL_SIZE=32
bashrc_rc=$?
# OpenFOAM's sourced tools and shell functions intentionally probe optional
# variables. Keep nounset disabled, while restoring errexit and pipefail.
set -e
printf 'bashrc_rc=%s\n' "$bashrc_rc" | tee "$EVIDENCE/bashrc-status.txt"

test -n "${WM_PROJECT_DIR:-}" || { echo 'ERROR: WM_PROJECT_DIR is unset' >&2; exit 4; }
test -n "${FOAM_APPBIN:-}" || { echo 'ERROR: FOAM_APPBIN is unset' >&2; exit 4; }
test -n "${WM_PROJECT_VERSION:-}" || { echo 'ERROR: WM_PROJECT_VERSION is unset' >&2; exit 4; }
test -n "${WM_COMPILER:-}" || { echo 'ERROR: WM_COMPILER is unset' >&2; exit 4; }
test -n "${WM_OPTIONS:-}" || { echo 'ERROR: WM_OPTIONS is unset' >&2; exit 4; }
test -n "${WM_MPLIB:-}" || { echo 'ERROR: WM_MPLIB is unset' >&2; exit 4; }
test -n "${FOAM_MPI:-}" || { echo 'ERROR: FOAM_MPI is unset' >&2; exit 4; }
test -r "$WM_PROJECT_DIR/bin/tools/RunFunctions" || {
    echo 'ERROR: RunFunctions is unavailable' >&2
    exit 4
}
echo 'CHECKPOINT_FOAM_ENV_OK'

set +e
. "$WM_PROJECT_DIR/bin/tools/RunFunctions"
runfunctions_rc=$?
set -e
printf 'runfunctions_rc=%s\n' "$runfunctions_rc" | tee "$EVIDENCE/runfunctions-status.txt"
test "$(type -t restore0Dir)" = function || {
    echo 'ERROR: restore0Dir function is unavailable' >&2
    exit 4
}
echo 'CHECKPOINT_RUNFUNCTIONS_OK'

export LD_LIBRARY_PATH="${FOAM_EXTRA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"

SIMPLEFOAM="${FOAM_APPBIN}/simpleFoam"
test -x "$SIMPLEFOAM" || { echo "ERROR: simpleFoam is not executable: $SIMPLEFOAM" >&2; exit 4; }
echo 'CHECKPOINT_SIMPLEFOAM_FOUND'
command -v mpirun decomposePar foamDictionary | tee "$EVIDENCE/executables.txt"
clang --version | head -n 1 | tee "$EVIDENCE/clang.version"
mpirun --version | head -n 3 | tee "$EVIDENCE/mpirun.version"
printf 'WM_PROJECT_VERSION=%s\nWM_COMPILER=%s\nWM_OPTIONS=%s\nWM_MPLIB=%s\nFOAM_MPI=%s\n' \
    "$WM_PROJECT_VERSION" "$WM_COMPILER" "$WM_OPTIONS" "$WM_MPLIB" "$FOAM_MPI" \
    | tee "$EVIDENCE/foam-env.txt"
test "$(sha256sum "$SIMPLEFOAM" | awk '{print $1}')" = "$EXPECTED_SHA_SIMPLEFOAM"
sha256sum "$SIMPLEFOAM" | tee "$EVIDENCE/simpleFoam.sha256"
ldd "$SIMPLEFOAM" | tee "$EVIDENCE/simpleFoam.ldd"
! grep -Fq 'not found' "$EVIDENCE/simpleFoam.ldd"
grep -Fq 'libmpi.so.40 => /app/apps/openmpi/5.0.10-gcc11/' "$EVIDENCE/simpleFoam.ldd"
resolved_fabric=$(awk '$1 == "libfabric.so.1" && $2 == "=>" {print $3; exit}' "$EVIDENCE/simpleFoam.ldd")
test -r "$resolved_fabric"
test "$(readlink -f "$resolved_fabric")" = "$(readlink -f "$FABRIC_LIB")"
ldd "$FABRIC_LIB" | tee "$EVIDENCE/libfabric.ldd"
! grep -Fq 'not found' "$EVIDENCE/libfabric.ldd"
echo 'CHECKPOINT_LINKAGE_OK'
echo 'CHECKPOINT_PREFLIGHT_PASS'

echo '===== SOURCE WORKLOAD HASH GATE ====='
TEMPLATE=$(readlink -f "$TEMPLATE_LINK")
test -d "$TEMPLATE/constant/polyMesh"
cat > "$EVIDENCE/expected-source.sha256" <<SHAEOF
${EXPECTED_SHA_CASEDEF}  ${TEMPLATE}/system/include/caseDefinition
${EXPECTED_SHA_DECOMPOSE}  ${TEMPLATE}/system/decomposeParDict
${EXPECTED_SHA_CONTROL_NOWRITE}  ${TEMPLATE}/system/controlDict.noWrite
${EXPECTED_SHA_FVSCHEMES}  ${TEMPLATE}/system/fvSchemes
${EXPECTED_SHA_FVSOLUTION_FIXED}  ${TEMPLATE}/system/fvSolution.fixedIter
${EXPECTED_SHA_FORCECOEFFS}  ${TEMPLATE}/system/forceCoeffsAll
${EXPECTED_SHA_U}  ${TEMPLATE}/0.orig/U
${EXPECTED_SHA_TRANSPORT}  ${TEMPLATE}/constant/transportProperties
${EXPECTED_SHA_TURBULENCE}  ${TEMPLATE}/constant/turbulenceProperties
${EXPECTED_SHA_POINTS}  ${TEMPLATE}/constant/polyMesh/points
${EXPECTED_SHA_FACES}  ${TEMPLATE}/constant/polyMesh/faces
${EXPECTED_SHA_OWNER}  ${TEMPLATE}/constant/polyMesh/owner
${EXPECTED_SHA_NEIGHBOUR}  ${TEMPLATE}/constant/polyMesh/neighbour
${EXPECTED_SHA_BOUNDARY}  ${TEMPLATE}/constant/polyMesh/boundary
SHAEOF
sha256sum -c "$EVIDENCE/expected-source.sha256"


echo '===== LAUNCHER / AFFINITY ====='
XENV_ARGS=(-x PATH -x LD_LIBRARY_PATH -x HOME)
while IFS= read -r variable; do
    XENV_ARGS+=(-x "$variable")
done < <(env | awk -F= '/^(WM_|FOAM_|LLVM_|GCOV_)/ {print $1}' | sort -u)
PAREX=(mpirun --hostfile "$PBS_NODEFILE" --map-by ppr:128:node -np "$NRANKS" "${XENV_ARGS[@]}")
printf '%q ' "${PAREX[@]}" > "$EVIDENCE/launcher.txt"; printf '\n' >> "$EVIDENCE/launcher.txt"
"${PAREX[@]}" bash -c '
mask=$(awk "/Cpus_allowed_list/{print \$2}" /proc/self/status)
printf "%s,%s,%s,%s\n" "$OMPI_COMM_WORLD_RANK" "$OMPI_COMM_WORLD_LOCAL_RANK" "$(hostname -s)" "$mask"
' | sort -t, -k1,1n > "$EVIDENCE/rank-affinity.csv"
test "$(wc -l < "$EVIDENCE/rank-affinity.csv" | tr -d ' ')" -eq "$NRANKS"
test "$(cut -d, -f3 "$EVIDENCE/rank-affinity.csv" | sort -u | wc -l | tr -d ' ')" -eq "$NNODES"

# Every arm begins with an independent copy of the same pinned case. The
# preflight stops after decomposition; full blocks continue through 150 steps.
run_arm()
{
    label=$1
    case_root="${RUN_ROOT}/${label}"
    case_dir="${case_root}/case"
    ev="${case_root}/evidence"
    test ! -e "$case_root"
    mkdir -p "$case_dir" "$ev/logs"
    cp -a "$TEMPLATE/0.orig" "$TEMPLATE/constant" "$TEMPLATE/system" "$case_dir/"
    cd "$case_dir"
    test ! -e postProcessing
    test ! -e logFiles
    ! find . -maxdepth 1 -type d -name 'processor*' | grep -q .

    cp system/controlDict.noWrite system/controlDict
    cp system/fvSolution.fixedIter system/fvSolution
    foamDictionary -entry nCores -set "$NRANKS" system/include/caseDefinition
    foamDictionary -entry nHierarchical -set '(8 8 8)' system/include/caseDefinition
    foamDictionary -entry decompositionMethod -set scotch system/include/caseDefinition
    foamDictionary -entry endTime -set "$ENDTIME" system/controlDict
    case "$label" in
        A_plain) ;;
        B_uniform|C_weighted)
            if test "$label" = B_uniform; then
                weights='(1 1 1)'
            else
                weights='(1 1 0.01)'
            fi
            cat >> system/decomposeParDict <<DICT

coeffs
{
    domains       (4 8 16);
    domainWeights ${weights};
}
DICT
            ;;
        *) echo "Unknown arm: $label" >&2; exit 2 ;;
    esac
    test "$(foamDictionary -entry nCores -value system/include/caseDefinition | tr -d ' ')" = "$NRANKS"
    test "$(foamDictionary -entry decompositionMethod -value system/include/caseDefinition | tr -d ' ')" = scotch
    test "$(foamDictionary -entry endTime -value system/controlDict | tr -d ' ')" = "$ENDTIME"
    cmp -s system/fvSolution system/fvSolution.fixedIter
    sha256sum system/controlDict system/decomposeParDict system/include/caseDefinition \
        system/fvSchemes system/fvSolution system/forceCoeffsAll 0.orig/U \
        constant/transportProperties constant/turbulenceProperties \
        > "$ev/effective-inputs.sha256"
    cp -p system/decomposeParDict "$ev/decomposeParDict.effective"

    echo "===== ${label}: DECOMPOSE ====="
    decomposePar -constant > "$ev/logs/10_decomposePar.log" 2>&1
    test "$(find . -maxdepth 1 -type d -name 'processor*' | wc -l | tr -d ' ')" -eq "$NRANKS"
    sha256sum processor*/constant/polyMesh/boundary > "$ev/partition-boundary.sha256"
    if test "$RUN_MODE" = preflight; then
        printf 'arm=%s\nmode=preflight\npartitions=%s\n' "$label" "$NRANKS" > "$ev/summary.txt"
        cd "$OF_DIR"
        return
    fi

    restore0Dir -processor
    "${PAREX[@]}" renumberMesh -constant -overwrite -parallel > "$ev/logs/20_renumberMesh.log" 2>&1
    restore0Dir -processor
    "${PAREX[@]}" potentialFoam -initialiseUBCs -parallel > "$ev/logs/30_potentialFoam.log" 2>&1
    "${PAREX[@]}" applyBoundaryLayer -ybl 0.0450244 -parallel > "$ev/logs/40_applyBoundaryLayer.log" 2>&1

    echo "===== ${label}: UNPROFILED SOLVER ====="
    log="$ev/logs/50_simpleFoam.log"
    "${PAREX[@]}" simpleFoam -parallel > "$log" 2>&1
    test "$(grep -ac '^Time = [0-9][0-9]*[[:space:]]*$' "$log")" -eq "$ENDTIME"
    grep -aEq "^Time = ${ENDTIME}[[:space:]]*$" "$log"
    grep -aFq 'Finalising parallel run' "$log"
    grep -aEq '^End$' "$log"
    ! grep -aEqi '(^|[^[:alpha:]])(nan|inf)([^[:alpha:]]|$)|floating point|segmentation fault' "$log"
    test "$(grep -ac 'Average wall-clock time per time step' "$log")" -eq 1
    grep -a 'Average wall-clock time per time step' "$log" > "$ev/avg-step.txt"

    mapfile -t cd_files < <(find postProcessing/forceCoeffsAll -type f -name coefficient.dat)
    test "${#cd_files[@]}" -eq 1
    cd_file=${cd_files[0]}
    test "$(stat -c %Y "$cd_file")" -ge "$JOB_START_EPOCH"
    awk '!/^#/ {n++; if (n==1) first=$1; last=$1; cd=$2}
         END {exit !(n==150 && first==1 && last==150 && cd==cd)}' "$cd_file"
    cp -p "$cd_file" "$ev/coefficient.dat"
    sha256sum "$ev/coefficient.dat" > "$ev/coefficient.sha256"
    awk '!/^#/ {cd=$2} END {printf "Cd150=%.17g\n", cd}' "$ev/coefficient.dat" > "$ev/cd150.txt"
    printf 'arm=%s\nmode=full\nblock=%s\nprofiled=false\n' "$label" "$BLOCK" > "$ev/summary.txt"
    echo "ARM_${label}_PASS"
    cd "$OF_DIR"
}

case "$RUN_MODE:$BLOCK" in
    preflight:0) order=(B_uniform C_weighted) ;;
    full:1) order=(A_plain B_uniform C_weighted) ;;
    full:2) order=(B_uniform C_weighted A_plain) ;;
    full:3) order=(C_weighted A_plain B_uniform) ;;
esac
printf '%s\n' "${order[@]}" > "$EVIDENCE/run-order.txt"
for arm in "${order[@]}"; do
    run_arm "$arm"
done
printf 'classification=SCOTCH A/B/C CONTROLLED STUDY\nmode=%s\nblock=%s\nprofiled=false\npbs_jobid=%s\nnodes=%s\nranks=%s\nranks_per_node=%s\ncompiler=AOCC 5.0\nmpi=Open MPI 5.0.10\nbuild=stock Opt\nplacement=ppr:128:node without explicit binding\nendtime=%s\n' \
    "$RUN_MODE" "$BLOCK" "$PBS_JOBID" "$NNODES" "$NRANKS" "$RANKS_PER_NODE" "$ENDTIME" \
    > "$EVIDENCE/provenance.txt"
echo SCOTCH_ABC_PASS
