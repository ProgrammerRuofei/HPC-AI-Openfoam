#!/bin/bash
# Shared isolated OpenFOAM v2512/OpenMPI build implementation. Candidate scripts
# provide the stack identity and module list; all source staging remains in JOBFS.
set -euo pipefail

: "${STACK_ID:?}" "${MODULE_LIST:?}" "${WM_COMPILER_VALUE:?}" "${OMPI_CC_VALUE:?}" "${OMPI_CXX_VALUE:?}"
AUTHORITATIVE_SOURCE=/apps/OpenFOAM/2512
BUILD_ROOT="/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/${STACK_ID}"
EVIDENCE_DIR="${BUILD_ROOT}/evidence/${STACK_ID}.${PBS_JOBID:?}"
RUNTIME_DIR="${BUILD_ROOT}/runtime-archive"
JOBFS_ROOT="${PBS_JOBFS:?}/openfoam-build/${STACK_ID}"
WORKTREE="${JOBFS_ROOT}/OpenFOAM-v2512"
IDENTITY_ALGORITHM=OPENFOAM_SOURCE_ID_V2
EXPECTED_REGULAR_MANIFEST_SHA256=802414c5b14ebb9cb4e3bab1a570e3c06c77e2d3028792faff865bcd4a181cc0
EXPECTED_SYMLINK_MANIFEST_SHA256=7d4ad344a50520ca0f79c6e45e198eb4f294e73759291fd4062c3ea2ab14b538
EXPECTED_SOURCE_ID_V2=5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db
EXPECTED_SYMLINK_ENTRY_COUNT=10976
EXPECTED_FOAM_API=2512
EXPECTED_API_INFO_SHA256=d03cf08cf48ab523323a8849439b2f1073df920e29e969f51f188568a4fa0a8a

module purge
module load ${MODULE_LIST}
export OMPI_CC="$OMPI_CC_VALUE" OMPI_CXX="$OMPI_CXX_VALUE"
for tool in "$OMPI_CC_VALUE" "$OMPI_CXX_VALUE" mpicc mpicxx mpirun rsync tar sha256sum perl; do command -v "$tool" >/dev/null; done
test -d "$AUTHORITATIVE_SOURCE"; test -d "$PBS_JOBFS"; test ! -e "$JOBFS_ROOT"; test ! -e "$WORKTREE"
mkdir -p "$JOBFS_ROOT" "$EVIDENCE_DIR" "$RUNTIME_DIR"
exec > >(tee -a "${EVIDENCE_DIR}/build.log") 2>&1

write_regular_manifest() { ( cd "$1"; LC_ALL=C find . \( -path './platforms' -o -path './platforms/*' -o -path './ThirdParty-v2512/platforms' -o -path './ThirdParty-v2512/platforms/*' -o -path './ThirdParty-v2512/build' -o -path './ThirdParty-v2512/build/*' \) -prune -o -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum; ) > "$2"; }
write_symlink_manifest() { ( cd "$1"; LC_ALL=C find . \( -path './platforms' -o -path './platforms/*' -o -path './ThirdParty-v2512/platforms' -o -path './ThirdParty-v2512/platforms/*' -o -path './ThirdParty-v2512/build' -o -path './ThirdParty-v2512/build/*' \) -prune -o -type l -printf '%p\0%l\0' | perl -0e 'use bytes; my @r; while (defined(my $p = <>)) { chomp $p; my $t = <>; die "odd symlink record stream\n" unless defined $t; chomp $t; push @r, [$p,$t]; } for my $r (sort {$a->[0] cmp $b->[0]} @r) { print $r->[0],"\0",$r->[1],"\0"; }'; ) > "$2"; }
count_entries() { ( cd "$1"; LC_ALL=C find . \( -path './platforms' -o -path './platforms/*' -o -path './ThirdParty-v2512/platforms' -o -path './ThirdParty-v2512/platforms/*' -o -path './ThirdParty-v2512/build' -o -path './ThirdParty-v2512/build/*' \) -prune -o -type "$2" -printf . | wc -c; ); }
source_id_v2() { printf '%s\0%s\0%s\0' "$IDENTITY_ALGORITHM" "$1" "$2" | sha256sum | awk '{print $1}'; }
verify() { printf '%s expected=%s observed=%s\n' "$1" "$2" "$3" | tee -a "$IDENTITY_EVIDENCE"; test "$2" = "$3" || { echo "ERROR: $1 mismatch" >&2; exit 4; }; }
bootstrap_api_info() {
    local api_info="${WORKTREE}/META-INFO/api-info" actual origin
    if test -e "$api_info" || test -L "$api_info"; then test -f "$api_info" || { echo 'ERROR: api-info is not regular' >&2; exit 4; }; origin=staged-source
    else mkdir -p "${api_info%/*}"; printf 'api=2512\npatch=0\n' > "$api_info"; origin=jobfs-bootstrap; fi
    actual=$(sha256sum "$api_info" | awk '{print $1}')
    printf 'api_info_origin=%s\napi_info_sha256_expected=%s\napi_info_sha256_observed=%s\n' "$origin" "$EXPECTED_API_INFO_SHA256" "$actual" | tee -a "$IDENTITY_EVIDENCE"
    test "$actual" = "$EXPECTED_API_INFO_SHA256" || { echo 'ERROR: api-info mismatch' >&2; exit 4; }
}

echo "stack_id=$STACK_ID"; echo "authoritative_source=$AUTHORITATIVE_SOURCE"; echo "jobfs_root=$JOBFS_ROOT"
IDENTITY_EVIDENCE="${EVIDENCE_DIR}/source-identity-v2.txt"
printf 'identity_algorithm=%s\nexclusion=/platforms/\nexclusion=/ThirdParty-v2512/platforms/\nexclusion=/ThirdParty-v2512/build/\nexpected_regular_manifest_sha256=%s\nexpected_symlink_manifest_sha256=%s\nexpected_source_id_v2=%s\nexpected_symlink_entry_count=%s\n' "$IDENTITY_ALGORITHM" "$EXPECTED_REGULAR_MANIFEST_SHA256" "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$EXPECTED_SOURCE_ID_V2" "$EXPECTED_SYMLINK_ENTRY_COUNT" > "$IDENTITY_EVIDENCE"
module list 2>&1
for tool in "$OMPI_CC_VALUE" "$OMPI_CXX_VALUE" mpicc mpicxx mpirun; do printf '%s=' "$tool"; command -v "$tool"; done
"$OMPI_CC_VALUE" --version | head -n 2; "$OMPI_CXX_VALUE" --version | head -n 2; mpicc --showme:command; mpicxx --showme:command; mpicc --showme:link; mpirun --version | head -n 3
write_regular_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-source-files.sha256"; write_symlink_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-symlink-files.nul"
auth_r=$(sha256sum "${EVIDENCE_DIR}/authoritative-source-files.sha256" | awk '{print $1}'); auth_s=$(sha256sum "${EVIDENCE_DIR}/authoritative-symlink-files.nul" | awk '{print $1}')
verify authoritative_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$auth_r"; verify authoritative_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$auth_s"; verify authoritative_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$(source_id_v2 "$auth_r" "$auth_s")"
rsync -a --exclude='/platforms/' --exclude='/ThirdParty-v2512/platforms/' --exclude='/ThirdParty-v2512/build/' "${AUTHORITATIVE_SOURCE}/" "${WORKTREE}/"
for f in etc/bashrc etc/config.sh/settings src/Allwmake applications/Allwmake wmake/wmake ThirdParty-v2512/Allwmake; do test -f "${WORKTREE}/$f"; done
write_regular_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-source-files.sha256"; write_symlink_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-symlink-files.nul"
stage_r=$(sha256sum "${EVIDENCE_DIR}/staged-source-files.sha256" | awk '{print $1}'); stage_s=$(sha256sum "${EVIDENCE_DIR}/staged-symlink-files.nul" | awk '{print $1}')
printf 'staged_regular_entry_count=%s\nstaged_symlink_entry_count=%s\n' "$(count_entries "$WORKTREE" f)" "$(count_entries "$WORKTREE" l)" | tee -a "$IDENTITY_EVIDENCE"
verify staged_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$stage_r"; verify staged_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$stage_s"; verify staged_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$(source_id_v2 "$stage_r" "$stage_s")"
bootstrap_api_info
cd "$WORKTREE"; set +u; . etc/bashrc "WM_COMPILER=${WM_COMPILER_VALUE}" WM_MPLIB=SYSTEMOPENMPI WM_COMPILE_OPTION=Opt; set -u
printf 'WM_PROJECT_VERSION=%s\nFOAM_API=%s\nWM_COMPILER=%s\nWM_MPLIB=%s\nWM_OPTIONS=%s\nFOAM_MPI=%s\nMPI_ARCH_PATH=%s\n' "$WM_PROJECT_VERSION" "$FOAM_API" "$WM_COMPILER" "$WM_MPLIB" "$WM_OPTIONS" "$FOAM_MPI" "$MPI_ARCH_PATH"
test "$WM_PROJECT_VERSION" = v2512; test "$FOAM_API" = "$EXPECTED_FOAM_API"; test "$WM_COMPILER" = "$WM_COMPILER_VALUE"; test "$WM_MPLIB" = SYSTEMOPENMPI; test "$FOAM_MPI" = sys-openmpi; test "$(command -v mpicc)" = /apps/openmpi/4.1.7/bin/mpicc
"${WM_THIRD_PARTY_DIR}/Allwmake" -j "${PBS_NCPUS:?}"; "${WM_PROJECT_DIR}/src/Allwmake" -j "${PBS_NCPUS:?}"; "${WM_PROJECT_DIR}/applications/Allwmake" -j "${PBS_NCPUS:?}"
BIN="${FOAM_APPBIN}/simpleFoam"; test -x "$BIN"; case "$(realpath "$BIN")" in "${WORKTREE}"/*) ;; *) echo 'ERROR: binary outside candidate worktree' >&2; exit 3;; esac
file "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.file"; ldd "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.ldd"; grep -qi '/apps/openmpi/4.1.7' "${EVIDENCE_DIR}/simpleFoam.ldd"; sha256sum "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.sha256"
tar -C "$WORKTREE" -czf "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" etc "platforms/${WM_OPTIONS}" ThirdParty-v2512/platforms
sha256sum "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" | tee "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz.sha256"
echo BUILD_VALIDATION_PASS
