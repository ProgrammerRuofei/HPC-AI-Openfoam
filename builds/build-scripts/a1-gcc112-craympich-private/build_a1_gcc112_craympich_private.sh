#!/bin/bash
# Build A1 private source copy. Expected cwd: the control repository root.
# Input: ASPIRE2A's read-only openfoam/2512 source selected by its module.
# Output: copied source, compiled binary, and immutable attempt evidence.

set -euo pipefail

STACK_ID=a1-gcc112-craympich-private
PROJECT_ROOT=/home/project/59000020/openfoam-isc26
CONTROL_DIR="${PROJECT_ROOT}/builds/build-scripts/${STACK_ID}"
OUTPUT_DIR="${CONTROL_DIR}/outputs"
BUILD_ROOT="${PROJECT_ROOT}/builds/private-source/${STACK_ID}-a1_6"
PRIVATE_SOURCE="${BUILD_ROOT}/OpenFOAM-v2512"
PRIVATE_THIRD_PARTY="${BUILD_ROOT}/ThirdParty-v2512"
ATTEMPT=a1_6
EVIDENCE_DIR="${OUTPUT_DIR}/${ATTEMPT}.${PBS_JOBID:?PBS_JOBID is required}"

fail() {
    echo "A1 PRECHECK FAILED: $*" >&2
    exit 2
}

test -d "$CONTROL_DIR" || fail "control directory missing: $CONTROL_DIR"
test -d "$OUTPUT_DIR" || fail "PBS output directory missing: $OUTPUT_DIR"
test ! -e "$BUILD_ROOT" || fail "private build root already exists: $BUILD_ROOT"
mkdir -p "$EVIDENCE_DIR" "$BUILD_ROOT"
exec > >(tee -a "${EVIDENCE_DIR}/build.log") 2>&1

# resetmodule intentionally returns non-zero after its successful reset on this
# site.  Its own cleanup also reads optional variables, so isolate it from both
# errexit and nounset; module-load failure remains fatal and explicit.
set +eu
. /app/apps/resetmodule
module load openfoam/2512
module_rc=$?
set -eu
test "$module_rc" -eq 0 || fail "module load openfoam/2512 failed: rc=$module_rc"

AUTHORITATIVE_SOURCE="${WM_PROJECT_DIR:-}"
AUTHORITATIVE_THIRD_PARTY="$(dirname "$AUTHORITATIVE_SOURCE")/ThirdParty-v2512"
test -n "$AUTHORITATIVE_SOURCE" || fail "openfoam/2512 did not set WM_PROJECT_DIR"
test -d "$AUTHORITATIVE_SOURCE" || fail "site source missing: $AUTHORITATIVE_SOURCE"
test -d "$AUTHORITATIVE_THIRD_PARTY" || fail "site ThirdParty missing: $AUTHORITATIVE_THIRD_PARTY"
test -x "${AUTHORITATIVE_THIRD_PARTY}/Allwmake" || fail "site ThirdParty Allwmake missing"
test -f "${AUTHORITATIVE_SOURCE}/etc/bashrc" || fail "site bashrc missing"
test -x "${AUTHORITATIVE_SOURCE}/wmake/wmake" || fail "site wmake missing"

for tool in rsync sha256sum find sort xargs make; do
    command -v "$tool" >/dev/null || fail "required tool missing: $tool"
done

printf 'stack_id=%s\nattempt=%s\npbs_jobid=%s\nauthoritative_source=%s\nprivate_source=%s\n' \
    "$STACK_ID" "$ATTEMPT" "$PBS_JOBID" "$AUTHORITATIVE_SOURCE" "$PRIVATE_SOURCE"
date
hostname
module list 2>&1
printf 'module_wm_options=%s\nmodule_wm_compiler=%s\nmodule_wm_mplib=%s\n' \
    "${WM_OPTIONS:-unset}" "${WM_COMPILER:-unset}" "${WM_MPLIB:-unset}"
command -v gcc || true
gcc --version | head -n 1 || true
mpirun --version 2>&1 | head -n 8 || true

write_manifest() {
    local source_root=$1 manifest=$2
    (
        cd "$source_root"
        LC_ALL=C find . \
            \( -path './platforms' -o -path './platforms/*' \
               -o -path './ThirdParty-v2512/platforms' -o -path './ThirdParty-v2512/platforms/*' \
               -o -path './ThirdParty-v2512/build' -o -path './ThirdParty-v2512/build/*' \) -prune -o \
            -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum
    ) > "$manifest"
}

sha256sum "${AUTHORITATIVE_SOURCE}/etc/bashrc" \
    "${AUTHORITATIVE_SOURCE}/etc/config.sh/settings" \
    "${AUTHORITATIVE_SOURCE}/wmake/wmake" \
    "${AUTHORITATIVE_SOURCE}/src/Allwmake" \
    "${AUTHORITATIVE_SOURCE}/applications/Allwmake" \
    > "${EVIDENCE_DIR}/authoritative-key-files.sha256"
write_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-source.sha256"
AUTHORITATIVE_MANIFEST_SHA256=$(sha256sum "${EVIDENCE_DIR}/authoritative-source.sha256" | awk '{print $1}')
printf 'authoritative_manifest_sha256=%s\n' "$AUTHORITATIVE_MANIFEST_SHA256"

rsync -a \
    --exclude='/platforms/' \
    --exclude='/ThirdParty-v2512/platforms/' \
    --exclude='/ThirdParty-v2512/build/' \
    "${AUTHORITATIVE_SOURCE}/" "${PRIVATE_SOURCE}/"
rsync -a \
    --exclude='/platforms/' \
    --exclude='/build/' \
    "${AUTHORITATIVE_THIRD_PARTY}/" "${PRIVATE_THIRD_PARTY}/"

test -f "${PRIVATE_SOURCE}/etc/bashrc" || fail "copied bashrc missing"
test ! -e "${PRIVATE_SOURCE}/platforms" || fail "generated platforms copied unexpectedly"
test -x "${PRIVATE_THIRD_PARTY}/Allwmake" || fail "copied ThirdParty Allwmake missing"
write_manifest "$PRIVATE_SOURCE" "${EVIDENCE_DIR}/private-source.sha256"
PRIVATE_MANIFEST_SHA256=$(sha256sum "${EVIDENCE_DIR}/private-source.sha256" | awk '{print $1}')
printf 'private_manifest_sha256=%s\n' "$PRIVATE_MANIFEST_SHA256"
test "$AUTHORITATIVE_MANIFEST_SHA256" = "$PRIVATE_MANIFEST_SHA256" || fail "private source manifest mismatch"

cd "$PRIVATE_SOURCE"
# OpenFOAM's upstream bootstrap uses non-zero intermediate commands and reads
# optional variables while cleaning paths. Isolate only this source operation;
# require an explicit successful result before restoring strict mode.
set +eu
. "${PRIVATE_SOURCE}/etc/bashrc"
bashrc_rc=$?
set -eu
test "$bashrc_rc" -eq 0 || fail "private etc/bashrc failed: rc=$bashrc_rc"

printf 'private_wm_project_dir=%s\nprivate_wm_options=%s\nprivate_wm_compiler=%s\nprivate_wm_mplib=%s\n' \
    "$WM_PROJECT_DIR" "$WM_OPTIONS" "$WM_COMPILER" "$WM_MPLIB"
test "$WM_PROJECT_DIR" = "$PRIVATE_SOURCE" || fail "OpenFOAM environment did not select private source"
export WM_THIRD_PARTY_DIR="$PRIVATE_THIRD_PARTY"
printf 'private_third_party_dir=%s\n' "$WM_THIRD_PARTY_DIR"

BUILD_JOBS=$(getconf _NPROCESSORS_ONLN)
case "$BUILD_JOBS" in
    ''|*[!0-9]*) fail "invalid online processor count: $BUILD_JOBS" ;;
esac
test "$BUILD_JOBS" -ge 1 || fail "online processor count must be positive"
printf 'build_jobs=%s\n' "$BUILD_JOBS"

"${WM_PROJECT_DIR}/wmake/src/Allmake"
WMAKE_TOOLS="${WM_PROJECT_DIR}/platforms/tools/${WM_ARCH}${WM_COMPILER}"
test -x "${WMAKE_TOOLS}/wmkdepend" || fail "private wmkdepend missing: ${WMAKE_TOOLS}/wmkdepend"
"${WM_THIRD_PARTY_DIR}/Allwmake" -j "$BUILD_JOBS"
"${WM_PROJECT_DIR}/src/Allwmake" -j "$BUILD_JOBS"
"${WM_PROJECT_DIR}/applications/Allwmake" -j "$BUILD_JOBS"

SIMPLEFOAM_BIN="${FOAM_APPBIN}/simpleFoam"
test -x "$SIMPLEFOAM_BIN" || fail "private simpleFoam missing: $SIMPLEFOAM_BIN"
case "$(realpath "$SIMPLEFOAM_BIN")" in
    "${PRIVATE_SOURCE}"/*) ;;
    *) fail "simpleFoam resolves outside private source: $SIMPLEFOAM_BIN" ;;
esac
file "$SIMPLEFOAM_BIN" | tee "${EVIDENCE_DIR}/simpleFoam.file"
ldd "$SIMPLEFOAM_BIN" | tee "${EVIDENCE_DIR}/simpleFoam.ldd"
sha256sum "$SIMPLEFOAM_BIN" | tee "${EVIDENCE_DIR}/simpleFoam.sha256"
printf 'BUILD_VALIDATION_PASS\nbinary=%s\n' "$SIMPLEFOAM_BIN"
