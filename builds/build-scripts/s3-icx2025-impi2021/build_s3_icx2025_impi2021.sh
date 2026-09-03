#!/bin/bash
# Future isolated OpenFOAM v2512 build for S3; never combines a build with a benchmark.
set -euo pipefail

STACK_ID=s3-icx2025-impi2021
SOURCE_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/source/OpenFOAM-v2512
BUILD_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s3-icx2025-impi2021
WORKTREE="${BUILD_ROOT}/OpenFOAM-v2512"
EVIDENCE_DIR="${BUILD_ROOT}/evidence/${STACK_ID}.${PBS_JOBID:?PBS_JOBID is required}"
EXPECTED_OPTIONS=linux64IcxDPInt32Opt

module purge
module load intel-compiler-llvm/2025.1.1 intel-mpi/2021.17.2
export WM_COMPILER=Icx
export WM_MPLIB=INTELMPI
export WM_COMPILE_OPTION=Opt

for tool in icx icpx mpicc mpicxx mpirun; do command -v "$tool" >/dev/null; done
test -d "$SOURCE_ROOT"
test ! -e "$WORKTREE"
if find "${SOURCE_ROOT}/platforms" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null | grep -q .; then
    echo "ERROR: common source snapshot contains platform output" >&2; exit 2
fi
mkdir -p "$EVIDENCE_DIR"
exec > >(tee -a "${EVIDENCE_DIR}/build.log") 2>&1

echo "stack_id=${STACK_ID}"; echo "source_root=${SOURCE_ROOT}"; echo "build_root=${BUILD_ROOT}"
module list 2>&1
for tool in icx icpx mpicc mpicxx mpirun; do printf '%s=' "$tool"; command -v "$tool"; done
icx --version | head -n 1; icpx --version | head -n 1
mpicc -show; mpicxx -show; mpirun --version | head -n 3
sha256sum "${SOURCE_ROOT}/etc/bashrc" "${SOURCE_ROOT}/etc/config.sh/settings"
cp -a "${SOURCE_ROOT}/." "$WORKTREE/"
cd "$WORKTREE"
. etc/bashrc
printf 'WM_PROJECT_VERSION=%s\nWM_COMPILER=%s\nWM_MPLIB=%s\nWM_OPTIONS=%s\n' \
    "$WM_PROJECT_VERSION" "$WM_COMPILER" "$WM_MPLIB" "$WM_OPTIONS"
test "$WM_PROJECT_VERSION" = v2512
test "$WM_OPTIONS" = "$EXPECTED_OPTIONS"
printf 'ThirdParty/SCOTCH configuration (source default, unmodified):\n'
find etc config ThirdParty -maxdepth 3 -iname '*scotch*' -type f -print 2>/dev/null | sort || true
./Allwmake -j "${PBS_NCPUS:?PBS_NCPUS is required}"
BIN="${FOAM_APPBIN}/simpleFoam"
test -x "$BIN"
case "$(realpath "$BIN")" in "${WORKTREE}"/*) ;; *) echo "ERROR: binary outside candidate worktree" >&2; exit 3;; esac
file "$BIN"; ldd "$BIN"; ! ldd "$BIN" | grep -qi openmpi
sha256sum "$BIN"
echo "BUILD_VALIDATION_PASS"
