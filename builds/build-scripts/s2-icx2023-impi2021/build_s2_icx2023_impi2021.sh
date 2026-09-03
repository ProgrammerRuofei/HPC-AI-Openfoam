#!/bin/bash
# Future isolated OpenFOAM v2512 build for S2; never combines a build with a benchmark.
set -euo pipefail

STACK_ID=s2-icx2023-impi2021
AUTHORITATIVE_SOURCE=/apps/OpenFOAM/2512
BUILD_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s2-icx2023-impi2021
WORKTREE="${BUILD_ROOT}/OpenFOAM-v2512"
EVIDENCE_DIR="${BUILD_ROOT}/evidence/${STACK_ID}.${PBS_JOBID:?PBS_JOBID is required}"
EXPECTED_OPTIONS=linux64IcxDPInt32Opt

module purge
module load intel-compiler-llvm/2023.2.0 intel-mpi/2021.10.0
export WM_COMPILER=Icx
export WM_MPLIB=INTELMPI
export WM_COMPILE_OPTION=Opt

for tool in icx icpx mpicc mpicxx mpirun rsync; do command -v "$tool" >/dev/null; done
test -d "$AUTHORITATIVE_SOURCE"
test ! -e "$WORKTREE"
mkdir -p "$EVIDENCE_DIR"
exec > >(tee -a "${EVIDENCE_DIR}/build.log") 2>&1

echo "stack_id=${STACK_ID}"; echo "authoritative_source=${AUTHORITATIVE_SOURCE}"; echo "build_root=${BUILD_ROOT}"
module list 2>&1
for tool in icx icpx mpicc mpicxx mpirun; do printf '%s=' "$tool"; command -v "$tool"; done
icx --version | head -n 1; icpx --version | head -n 1
mpicc -show; mpicxx -show; mpirun --version | head -n 3
printf 'source_staging_command=rsync -a --exclude=/platforms/ --exclude=/ThirdParty-v2512/platforms/ --exclude=/ThirdParty-v2512/build/ %s/ %s/\n' "$AUTHORITATIVE_SOURCE" "$WORKTREE"
sha256sum "${AUTHORITATIVE_SOURCE}/etc/bashrc" "${AUTHORITATIVE_SOURCE}/etc/config.sh/settings" \
    "${AUTHORITATIVE_SOURCE}/src/Allwmake" "${AUTHORITATIVE_SOURCE}/applications/Allwmake" \
    "${AUTHORITATIVE_SOURCE}/wmake/rules/linux64Icc/mplibINTELMPI" \
    "${AUTHORITATIVE_SOURCE}/wmake/rules/linux64Icx/mplibINTELMPI" \
    "${AUTHORITATIVE_SOURCE}/ThirdParty-v2512/Allwmake"
rsync -a --exclude='/platforms/' --exclude='/ThirdParty-v2512/platforms/' \
    --exclude='/ThirdParty-v2512/build/' "${AUTHORITATIVE_SOURCE}/" "${WORKTREE}/"
for required in etc/bashrc etc/config.sh/settings src/Allwmake applications/Allwmake \
    wmake/wmake ThirdParty-v2512/Allwmake; do test -f "${WORKTREE}/${required}"; done
test ! -e "${WORKTREE}/platforms"
test ! -e "${WORKTREE}/ThirdParty-v2512/platforms"
test ! -e "${WORKTREE}/ThirdParty-v2512/build"
(
    cd "$WORKTREE"
    LC_ALL=C find . -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum
) > "${EVIDENCE_DIR}/staged-source-files.sha256"
sha256sum "${EVIDENCE_DIR}/staged-source-files.sha256"
cd "$WORKTREE"
. etc/bashrc
printf 'WM_PROJECT_VERSION=%s\nWM_COMPILER=%s\nWM_MPLIB=%s\nWM_OPTIONS=%s\n' \
    "$WM_PROJECT_VERSION" "$WM_COMPILER" "$WM_MPLIB" "$WM_OPTIONS"
test "$WM_PROJECT_VERSION" = v2512
test "$WM_OPTIONS" = "$EXPECTED_OPTIONS"
printf 'ThirdParty/SCOTCH configuration (source default, unmodified):\n'
find etc config ThirdParty -maxdepth 3 -iname '*scotch*' -type f -print 2>/dev/null | sort || true
"${WM_THIRD_PARTY_DIR}/Allwmake" -j "${PBS_NCPUS:?PBS_NCPUS is required}"
"${WM_PROJECT_DIR}/src/Allwmake" -j "${PBS_NCPUS:?PBS_NCPUS is required}"
"${WM_PROJECT_DIR}/applications/Allwmake" -j "${PBS_NCPUS:?PBS_NCPUS is required}"
BIN="${FOAM_APPBIN}/simpleFoam"
test -x "$BIN"
case "$(realpath "$BIN")" in "${WORKTREE}"/*) ;; *) echo "ERROR: binary outside candidate worktree" >&2; exit 3;; esac
file "$BIN"; ldd "$BIN"; ! ldd "$BIN" | grep -qi openmpi
sha256sum "$BIN"
echo "BUILD_VALIDATION_PASS"
