#!/bin/bash
# Future isolated OpenFOAM v2512 build for S1; never combines a build with a benchmark.
set -euo pipefail

STACK_ID=s1-icc2021-impi2021
AUTHORITATIVE_SOURCE=/apps/OpenFOAM/2512
BUILD_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/s1-icc2021-impi2021
EVIDENCE_DIR="${BUILD_ROOT}/evidence/${STACK_ID}.${PBS_JOBID:?PBS_JOBID is required}"
RUNTIME_DIR="${BUILD_ROOT}/runtime-archive"
JOBFS_ROOT="${PBS_JOBFS:?PBS_JOBFS is required}/openfoam-build/${STACK_ID}"
WORKTREE="${JOBFS_ROOT}/OpenFOAM-v2512"
IDENTITY_ALGORITHM=OPENFOAM_SOURCE_ID_V2
EXPECTED_REGULAR_MANIFEST_SHA256=802414c5b14ebb9cb4e3bab1a570e3c06c77e2d3028792faff865bcd4a181cc0
EXPECTED_SYMLINK_MANIFEST_SHA256=7d4ad344a50520ca0f79c6e45e198eb4f294e73759291fd4062c3ea2ab14b538
EXPECTED_SOURCE_ID_V2=5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db
EXPECTED_SYMLINK_ENTRY_COUNT=10976
EXPECTED_OPTIONS=linux64IccDPInt32Opt
EXPECTED_FOAM_API=2512
EXPECTED_API_INFO_SHA256=d03cf08cf48ab523323a8849439b2f1073df920e29e969f51f188568a4fa0a8a

module purge
module load intel-compiler/2021.10.0 intel-mpi/2021.10.0
export WM_COMPILER=Icc
export WM_MPLIB=INTELMPI
export WM_COMPILE_OPTION=Opt

for tool in icc icpc mpicc mpicxx mpirun rsync tar sha256sum perl; do command -v "$tool" >/dev/null; done
test -d "$AUTHORITATIVE_SOURCE"
test -d "$PBS_JOBFS"
test ! -e "$JOBFS_ROOT"
test ! -e "$WORKTREE"
mkdir -p "$JOBFS_ROOT" "$EVIDENCE_DIR" "$RUNTIME_DIR"
exec > >(tee -a "${EVIDENCE_DIR}/build.log") 2>&1

record_jobfs_usage() {
    local phase=$1
    printf '\nJOBFS_USAGE phase=%s path=%s\n' "$phase" "$PBS_JOBFS"
    df -h "$PBS_JOBFS"
    df -i "$PBS_JOBFS" || true
    du -sh "$JOBFS_ROOT"
    find "$JOBFS_ROOT" -xdev -printf . | wc -c | awk -v phase="$phase" '{printf "jobfs_entries[%s]=%s\\n", phase, $1}'
}

write_source_manifest() {
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

write_symlink_manifest() {
    local source_root=$1 manifest=$2
    (
        cd "$source_root"
        LC_ALL=C find . \
            \( -path './platforms' -o -path './platforms/*' \
               -o -path './ThirdParty-v2512/platforms' -o -path './ThirdParty-v2512/platforms/*' \
               -o -path './ThirdParty-v2512/build' -o -path './ThirdParty-v2512/build/*' \) -prune -o \
            -type l -printf '%p\0%l\0' | perl -0e '
                use bytes;
                my @records;
                while (defined(my $path = <>)) {
                    chomp $path;
                    my $target = <>;
                    die "odd symlink record stream\n" unless defined $target;
                    chomp $target;
                    push @records, [$path, $target];
                }
                for my $record (sort { $a->[0] cmp $b->[0] } @records) {
                    print $record->[0], "\0", $record->[1], "\0";
                }
            '
    ) > "$manifest"
}

manifest_entry_count() {
    local source_root=$1 entry_type=$2
    (
        cd "$source_root"
        LC_ALL=C find . \
            \( -path './platforms' -o -path './platforms/*' \
               -o -path './ThirdParty-v2512/platforms' -o -path './ThirdParty-v2512/platforms/*' \
               -o -path './ThirdParty-v2512/build' -o -path './ThirdParty-v2512/build/*' \) -prune -o \
            -type "$entry_type" -printf . | wc -c
    )
}

source_id_v2() {
    local regular_sha=$1 symlink_sha=$2
    printf '%s\0%s\0%s\0' "$IDENTITY_ALGORITHM" "$regular_sha" "$symlink_sha" | sha256sum | awk '{print $1}'
}

verify_identity_value() {
    local label=$1 expected=$2 observed=$3
    printf '%s expected=%s observed=%s\n' "$label" "$expected" "$observed" | tee -a "$IDENTITY_EVIDENCE"
    test "$expected" = "$observed" || { echo "ERROR: ${label} mismatch" >&2; exit 4; }
}

bootstrap_api_info() {
    local source_root=$1 api_info="${source_root}/META-INFO/api-info" observed_sha origin
    if test -e "$api_info" || test -L "$api_info"; then
        test -f "$api_info" || { echo "ERROR: api-info is not a regular file" >&2; exit 4; }
        origin=staged-source
    else
        # The authoritative site tree is missing this tracked v2512 metadata.
        # SOURCE_ID_V2 has already verified the unmodified staged copy; add only
        # the reviewed API metadata required by upstream environment bootstrap.
        mkdir -p "${api_info%/*}"
        printf 'api=2512\npatch=0\n' > "$api_info"
        origin=jobfs-bootstrap
    fi
    observed_sha=$(sha256sum "$api_info" | awk '{print $1}')
    printf 'api_info_origin=%s\napi_info_sha256_expected=%s\napi_info_sha256_observed=%s\n' \
        "$origin" "$EXPECTED_API_INFO_SHA256" "$observed_sha" | tee -a "$IDENTITY_EVIDENCE"
    test "$observed_sha" = "$EXPECTED_API_INFO_SHA256" || { echo "ERROR: api-info mismatch" >&2; exit 4; }
}

echo "stack_id=${STACK_ID}"; echo "authoritative_source=${AUTHORITATIVE_SOURCE}"; echo "persistent_build_root=${BUILD_ROOT}"; echo "jobfs_root=${JOBFS_ROOT}"
IDENTITY_EVIDENCE="${EVIDENCE_DIR}/source-identity-v2.txt"
{
    printf 'identity_algorithm=%s\n' "$IDENTITY_ALGORITHM"
    printf 'exclusion=/platforms/\nexclusion=/ThirdParty-v2512/platforms/\nexclusion=/ThirdParty-v2512/build/\n'
    printf 'expected_regular_manifest_sha256=%s\n' "$EXPECTED_REGULAR_MANIFEST_SHA256"
    printf 'expected_symlink_manifest_sha256=%s\n' "$EXPECTED_SYMLINK_MANIFEST_SHA256"
    printf 'expected_source_id_v2=%s\n' "$EXPECTED_SOURCE_ID_V2"
    printf 'expected_symlink_entry_count=%s\n' "$EXPECTED_SYMLINK_ENTRY_COUNT"
} > "$IDENTITY_EVIDENCE"
module list 2>&1
for tool in icc icpc mpicc mpicxx mpirun; do printf '%s=' "$tool"; command -v "$tool"; done
icc --version | head -n 1; icpc --version | head -n 1
mpicc -show; mpicxx -show; mpirun --version | head -n 3
record_jobfs_usage start
printf 'source_staging_command=rsync -a --exclude=/platforms/ --exclude=/ThirdParty-v2512/platforms/ --exclude=/ThirdParty-v2512/build/ %s/ %s/\n' "$AUTHORITATIVE_SOURCE" "$WORKTREE"
sha256sum "${AUTHORITATIVE_SOURCE}/etc/bashrc" "${AUTHORITATIVE_SOURCE}/etc/config.sh/settings" \
    "${AUTHORITATIVE_SOURCE}/src/Allwmake" "${AUTHORITATIVE_SOURCE}/applications/Allwmake" \
    "${AUTHORITATIVE_SOURCE}/wmake/rules/linux64Icc/mplibINTELMPI" \
    "${AUTHORITATIVE_SOURCE}/wmake/rules/linux64Icx/mplibINTELMPI" \
    "${AUTHORITATIVE_SOURCE}/ThirdParty-v2512/Allwmake" | tee "${EVIDENCE_DIR}/authoritative-key-files.sha256"
write_source_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-source-files.sha256"
write_symlink_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-symlink-files.nul"
AUTHORITATIVE_REGULAR_MANIFEST_SHA256=$(sha256sum "${EVIDENCE_DIR}/authoritative-source-files.sha256" | awk '{print $1}')
AUTHORITATIVE_SYMLINK_MANIFEST_SHA256=$(sha256sum "${EVIDENCE_DIR}/authoritative-symlink-files.nul" | awk '{print $1}')
AUTHORITATIVE_SOURCE_ID_V2=$(source_id_v2 "$AUTHORITATIVE_REGULAR_MANIFEST_SHA256" "$AUTHORITATIVE_SYMLINK_MANIFEST_SHA256")
verify_identity_value authoritative_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$AUTHORITATIVE_REGULAR_MANIFEST_SHA256"
verify_identity_value authoritative_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$AUTHORITATIVE_SYMLINK_MANIFEST_SHA256"
verify_identity_value authoritative_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$AUTHORITATIVE_SOURCE_ID_V2"
rsync -a --exclude='/platforms/' --exclude='/ThirdParty-v2512/platforms/' \
    --exclude='/ThirdParty-v2512/build/' "${AUTHORITATIVE_SOURCE}/" "${WORKTREE}/"
for required in etc/bashrc etc/config.sh/settings src/Allwmake applications/Allwmake \
    wmake/wmake wmake/src/Allmake ThirdParty-v2512/Allwmake; do test -f "${WORKTREE}/${required}"; done
test ! -e "${WORKTREE}/platforms"
test ! -e "${WORKTREE}/ThirdParty-v2512/platforms"
test ! -e "${WORKTREE}/ThirdParty-v2512/build"
write_source_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-source-files.sha256"
write_symlink_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-symlink-files.nul"
STAGED_REGULAR_MANIFEST_SHA256=$(sha256sum "${EVIDENCE_DIR}/staged-source-files.sha256" | awk '{print $1}')
STAGED_SYMLINK_MANIFEST_SHA256=$(sha256sum "${EVIDENCE_DIR}/staged-symlink-files.nul" | awk '{print $1}')
STAGED_SOURCE_ID_V2=$(source_id_v2 "$STAGED_REGULAR_MANIFEST_SHA256" "$STAGED_SYMLINK_MANIFEST_SHA256")
STAGED_REGULAR_ENTRY_COUNT=$(manifest_entry_count "$WORKTREE" f)
STAGED_SYMLINK_ENTRY_COUNT=$(manifest_entry_count "$WORKTREE" l)
printf 'staged_regular_entry_count=%s\nstaged_symlink_entry_count=%s\n' "$STAGED_REGULAR_ENTRY_COUNT" "$STAGED_SYMLINK_ENTRY_COUNT" | tee -a "$IDENTITY_EVIDENCE"
verify_identity_value staged_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$STAGED_REGULAR_MANIFEST_SHA256"
verify_identity_value staged_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$STAGED_SYMLINK_MANIFEST_SHA256"
verify_identity_value staged_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$STAGED_SOURCE_ID_V2"
bootstrap_api_info "$WORKTREE"
record_jobfs_usage post-stage
cd "$WORKTREE"
# The bashrc defaults WM_COMPILER/WM_MPLIB before config.sh/setup processes its
# arguments. Pass S1 values as arguments so Intel MPI selects its native branch.
# It also reads previously unset variables while cleaning paths, so temporarily
# disable nounset for this upstream source operation only.
set +u
. etc/bashrc WM_COMPILER=Icc WM_MPLIB=INTELMPI WM_COMPILE_OPTION=Opt
set -u
printf 'WM_PROJECT_VERSION=%s\nFOAM_API=%s\nWM_COMPILER=%s\nWM_MPLIB=%s\nWM_OPTIONS=%s\nFOAM_MPI=%s\nMPI_ARCH_PATH=%s\nI_MPI_ROOT=%s\nI_MPI_CC=%s\nI_MPI_CXX=%s\n' \
    "$WM_PROJECT_VERSION" "$FOAM_API" "$WM_COMPILER" "$WM_MPLIB" "$WM_OPTIONS" "$FOAM_MPI" \
    "$MPI_ARCH_PATH" "$I_MPI_ROOT" "$I_MPI_CC" "$I_MPI_CXX"
test "$WM_PROJECT_VERSION" = v2512
test "$FOAM_API" = "$EXPECTED_FOAM_API"
test "$WM_COMPILER" = Icc
test "$WM_MPLIB" = INTELMPI
test "$WM_OPTIONS" = "$EXPECTED_OPTIONS"
test "$FOAM_MPI" = intelmpi
test "$I_MPI_CC" = icc
test "$I_MPI_CXX" = icpc
printf 'ThirdParty/SCOTCH configuration (source default, unmodified):\n'
find etc config ThirdParty -maxdepth 3 -iname '*scotch*' -type f -print 2>/dev/null | sort || true
# The site tree ships no top-level Allwmake, so the per-directory steps are
# driven here -- and wmake's own tools must come first. platforms/tools is
# named ${WM_ARCH}${WM_COMPILER}, so changing compiler invalidates the
# prebuilt linux64Gcc set and wmkdepend has to be rebuilt for this one.
# Job 178141482 died exactly here: "wmkdepend: Command not found".
"${WM_PROJECT_DIR}/wmake/src/Allmake"
WMAKE_TOOLS="${WM_PROJECT_DIR}/platforms/tools/${WM_ARCH}${WM_COMPILER}"
test -x "${WMAKE_TOOLS}/wmkdepend" || { echo "ERROR: wmkdepend absent in ${WMAKE_TOOLS}" >&2; exit 5; }
printf 'wmake_tools=%s\n' "$WMAKE_TOOLS"; ls "$WMAKE_TOOLS"
"${WM_THIRD_PARTY_DIR}/Allwmake" -j "${PBS_NCPUS:?PBS_NCPUS is required}"
"${WM_PROJECT_DIR}/src/Allwmake" -j "${PBS_NCPUS:?PBS_NCPUS is required}"
"${WM_PROJECT_DIR}/applications/Allwmake" -j "${PBS_NCPUS:?PBS_NCPUS is required}"
record_jobfs_usage post-build
BIN="${FOAM_APPBIN}/simpleFoam"
test -x "$BIN"
case "$(realpath "$BIN")" in "${WORKTREE}"/*) ;; *) echo "ERROR: binary outside candidate worktree" >&2; exit 3;; esac
file "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.file"
ldd "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.ldd"
! grep -qi openmpi "${EVIDENCE_DIR}/simpleFoam.ldd"
sha256sum "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.sha256"
tar -C "$WORKTREE" -czf "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" \
    etc "platforms/${WM_OPTIONS}" ThirdParty-v2512/platforms
sha256sum "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" | tee "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz.sha256"
tar -tzf "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" > "${EVIDENCE_DIR}/runtime-archive-contents.txt"
echo "BUILD_VALIDATION_PASS"
