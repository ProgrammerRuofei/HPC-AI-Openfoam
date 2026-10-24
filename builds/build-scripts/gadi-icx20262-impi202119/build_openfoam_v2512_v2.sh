#!/bin/bash
# Isolated OpenFOAM v2512 build with private ICX 2026.2 and Intel MPI 2021.19.
# All source staging and software extraction remain in this job's JOBFS.
set -euo pipefail

: "${PBS_JOBID:?}" "${PBS_JOBFS:?}" "${PBS_NCPUS:?}"
test "$PBS_NCPUS" -eq 48
STACK_ID=gadi-icx20262-impi202119-of2512
WM_COMPILER_VALUE=Icx
WM_COMPILE_OPTION_VALUE=Opt
SCOTCH_C17_WORKAROUND=1
APPLICATION_BUILD_MODE=benchmark-required
EXPECT_COMPILE_FLAGS=
INTEL_STACK_ROOT=/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/gadi-icx20262-impi202119
INTEL_ARCHIVE="$INTEL_STACK_ROOT/runtime-archive/gadi-icx20262-impi202119.182138851.gadi-pbs.tar.gz"
INTEL_ARCHIVE_SHA=013ea4758e05b3656b5474845577fcd0631b28d783e115b5e42d644d321a2fbc
AUTHORITATIVE_SOURCE=/apps/OpenFOAM/2512
BUILD_ROOT="/scratch/pm78/kj7183/openfoam_cpu/toolchain-screening/${STACK_ID}"
EVIDENCE_DIR="${BUILD_ROOT}/evidence/${STACK_ID}.${PBS_JOBID:?}"
RUNTIME_DIR="${BUILD_ROOT}/runtime-archive"
JOBFS_ROOT="${PBS_JOBFS:?}/openfoam-build/${STACK_ID}"
WORKTREE="${JOBFS_ROOT}/OpenFOAM-v2512"
THIRDPARTY_TREE="${JOBFS_ROOT}/ThirdParty-v2512"
IDENTITY_ALGORITHM=OPENFOAM_SOURCE_ID_V2
EXPECTED_REGULAR_MANIFEST_SHA256=802414c5b14ebb9cb4e3bab1a570e3c06c77e2d3028792faff865bcd4a181cc0
EXPECTED_SYMLINK_MANIFEST_SHA256=7d4ad344a50520ca0f79c6e45e198eb4f294e73759291fd4062c3ea2ab14b538
EXPECTED_SOURCE_ID_V2=5e43349d5b302beb354e4e0d9842ff8148cfed069fb0f1a224616df6021c18db
EXPECTED_SYMLINK_ENTRY_COUNT=10976
EXPECTED_FOAM_API=2512
EXPECTED_API_INFO_SHA256=d03cf08cf48ab523323a8849439b2f1073df920e29e969f51f188568a4fa0a8a

module purge
printf '%s  %s\n' "$INTEL_ARCHIVE_SHA" "$INTEL_ARCHIVE" | sha256sum -c -
INTEL_WORK="${PBS_JOBFS}/intel-toolchain/${STACK_ID}"
test ! -e "$INTEL_WORK"
mkdir -p "$INTEL_WORK/opt/intel"
tar -C "$INTEL_WORK/opt/intel" -xzf "$INTEL_ARCHIVE"
PRIVATE_COMPILER_PREFIX="$INTEL_WORK/opt/intel/oneapi/compiler/2026.2"
PRIVATE_MPI_PREFIX="$INTEL_WORK/opt/intel/oneapi/mpi/2021.19"
test -f "$PRIVATE_COMPILER_PREFIX/env/vars.sh"
test -f "$PRIVATE_MPI_PREFIX/env/vars.sh"
set +u
. "$PRIVATE_COMPILER_PREFIX/env/vars.sh"
. "$PRIVATE_MPI_PREFIX/env/vars.sh"
set -u
export I_MPI_ROOT="$PRIVATE_MPI_PREFIX" MPI_ROOT="$PRIVATE_MPI_PREFIX"
export I_MPI_HYDRA_BOOTSTRAP=rsh I_MPI_HYDRA_BOOTSTRAP_EXEC=/opt/pbs/default/bin/pbs_tmrsh
for tool in icx icpx mpiicx mpiicpx mpirun rsync tar sha256sum perl; do command -v "$tool" >/dev/null; done
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
# The build node's own CPU is the authoritative record of what the generated
# code must run on. lscpu alone omits the flag list, so read cpuinfo directly.
grep -m1 'model name' /proc/cpuinfo | tee "${EVIDENCE_DIR}/build-node-cpu.txt"
grep -m1 ^flags /proc/cpuinfo | tr ' ' '\n' | grep -i '^avx512' | sort \
    | tee "${EVIDENCE_DIR}/build-node-avx512-flags.txt" | tr '\n' ' '; echo
printf 'wm_compile_option=%s\n' "$WM_COMPILE_OPTION_VALUE"
for tool in icx icpx mpiicx mpiicpx mpirun; do printf '%s=' "$tool"; command -v "$tool"; done
icx --version | head -n 2 | tee "${EVIDENCE_DIR}/icx-version.txt"
icpx --version | head -n 2 | tee "${EVIDENCE_DIR}/icpx-version.txt"
mpirun -version | head -n 2 | tee "${EVIDENCE_DIR}/mpi-version.txt"
mpiicx -show | tee "${EVIDENCE_DIR}/mpiicx-show.txt"
mpiicpx -show | tee "${EVIDENCE_DIR}/mpiicpx-show.txt"
grep -Fq '2026.2.0' "${EVIDENCE_DIR}/icx-version.txt"
grep -Fq '2026.2.0' "${EVIDENCE_DIR}/icpx-version.txt"
grep -Fq '2021.19.0' "${EVIDENCE_DIR}/mpi-version.txt"
test "$(command -v icx)" = "$PRIVATE_COMPILER_PREFIX/bin/icx"
test "$(command -v mpirun)" = "$PRIVATE_MPI_PREFIX/bin/mpirun"
write_regular_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-source-files.sha256"; write_symlink_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-symlink-files.nul"
auth_r=$(sha256sum "${EVIDENCE_DIR}/authoritative-source-files.sha256" | awk '{print $1}'); auth_s=$(sha256sum "${EVIDENCE_DIR}/authoritative-symlink-files.nul" | awk '{print $1}')
verify authoritative_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$auth_r"; verify authoritative_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$auth_s"; verify authoritative_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$(source_id_v2 "$auth_r" "$auth_s")"
rsync -a --exclude='/platforms/' --exclude='/ThirdParty-v2512/platforms/' --exclude='/ThirdParty-v2512/build/' "${AUTHORITATIVE_SOURCE}/" "${WORKTREE}/"
for f in etc/bashrc etc/config.sh/settings src/Allwmake applications/Allwmake wmake/wmake wmake/src/Allmake ThirdParty-v2512/Allwmake; do test -f "${WORKTREE}/$f"; done
write_regular_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-source-files.sha256"; write_symlink_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-symlink-files.nul"
stage_r=$(sha256sum "${EVIDENCE_DIR}/staged-source-files.sha256" | awk '{print $1}'); stage_s=$(sha256sum "${EVIDENCE_DIR}/staged-symlink-files.nul" | awk '{print $1}')
printf 'staged_regular_entry_count=%s\nstaged_symlink_entry_count=%s\n' "$(count_entries "$WORKTREE" f)" "$(count_entries "$WORKTREE" l)" | tee -a "$IDENTITY_EVIDENCE"
verify staged_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$stage_r"; verify staged_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$stage_s"; verify staged_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$(source_id_v2 "$stage_r" "$stage_s")"
# v2512 discovers ThirdParty-v<api> alongside, not inside, WM_PROJECT_DIR.
# Verify the authoritative nested source first, then relocate it without changing
# contents to reproduce the supported OpenFOAM/ThirdParty installation topology.
test -d "${WORKTREE}/ThirdParty-v2512"; test ! -e "$THIRDPARTY_TREE"
mv "${WORKTREE}/ThirdParty-v2512" "$THIRDPARTY_TREE"
test -f "$THIRDPARTY_TREE/Allwmake"; test ! -e "${WORKTREE}/ThirdParty-v2512"
if [ "${SCOTCH_C17_WORKAROUND:-${GCC16_SCOTCH_C17_WORKAROUND:-0}}" = 1 ]; then
    case "$WM_COMPILER_VALUE" in Gcc|Icx) ;; *) exit 4;; esac
    SCOTCH_RULE="$THIRDPARTY_TREE/etc/makeFiles/scotch/Makefile.inc.Linux.shlib"
    test -f "$SCOTCH_RULE"
    printf '\n# Scotch 6.1.0 uses pre-C23 unprototyped function pointers.\nCFLAGS += -std=gnu17\n' >> "$SCOTCH_RULE"
    grep -Fxq 'CFLAGS += -std=gnu17' "$SCOTCH_RULE"
    printf 'scotch_c17_workaround=enabled\nscotch_rule=%s\n' "$SCOTCH_RULE" | tee -a "$IDENTITY_EVIDENCE"
fi
bootstrap_api_info
cd "$WORKTREE"; set +u; . etc/bashrc "WM_COMPILER=${WM_COMPILER_VALUE}" WM_MPLIB=INTELMPI "WM_COMPILE_OPTION=${WM_COMPILE_OPTION_VALUE}"; set -u
printf 'WM_PROJECT_VERSION=%s\nFOAM_API=%s\nWM_COMPILER=%s\nWM_MPLIB=%s\nWM_OPTIONS=%s\nFOAM_MPI=%s\nMPI_ARCH_PATH=%s\n' "$WM_PROJECT_VERSION" "$FOAM_API" "$WM_COMPILER" "$WM_MPLIB" "$WM_OPTIONS" "$FOAM_MPI" "$MPI_ARCH_PATH"
test "$WM_PROJECT_VERSION" = v2512; test "$FOAM_API" = "$EXPECTED_FOAM_API"; test "$WM_COMPILER" = "$WM_COMPILER_VALUE"; test "$WM_MPLIB" = INTELMPI; test "$WM_COMPILE_OPTION" = "$WM_COMPILE_OPTION_VALUE"; test "$FOAM_MPI" = intelmpi
test "$MPI_ARCH_PATH" = "$PRIVATE_MPI_PREFIX"
test "$WM_THIRD_PARTY_DIR" = "$THIRDPARTY_TREE"; test -f "$WM_THIRD_PARTY_DIR/Allwmake"; test -f "$WM_PROJECT_DIR/src/Allwmake"
# The site tree ships no top-level Allwmake, so the per-directory steps are
# driven here -- and wmake's own tools must come first. platforms/tools is
# named ${WM_ARCH}${WM_COMPILER}, so changing compiler invalidates the
# prebuilt linux64Gcc set and wmkdepend has to be rebuilt for this one.
# Job 178141482 died exactly here: "wmkdepend: Command not found".
"${WM_PROJECT_DIR}/wmake/src/Allmake"
WMAKE_TOOLS="${WM_PROJECT_DIR}/platforms/tools/${WM_ARCH}${WM_COMPILER}"
test -x "${WMAKE_TOOLS}/wmkdepend" || { echo "ERROR: wmkdepend absent in ${WMAKE_TOOLS}" >&2; exit 5; }
printf 'wmake_tools=%s\n' "$WMAKE_TOOLS"; ls "$WMAKE_TOOLS"
"${WM_THIRD_PARTY_DIR}/Allwmake" -j "${PBS_NCPUS:?}"
"${WM_PROJECT_DIR}/src/Allwmake" -j "${PBS_NCPUS:?}"
if [ "${APPLICATION_BUILD_MODE:-all}" = benchmark-required ]; then
    test "$WM_COMPILER_VALUE" = Icx
    # This benchmark needs six executables. Earlier ICX/CGAL 4.14.3 builds
    # failed in unrelated optional surface tools; keep that source unchanged.
    for app in \
        applications/utilities/mesh/generation/blockMesh \
        applications/utilities/parallelProcessing/decomposePar \
        applications/utilities/mesh/manipulation/renumberMesh \
        applications/solvers/basic/potentialFoam \
        applications/utilities/preProcessing/applyBoundaryLayer \
        applications/solvers/incompressible/simpleFoam; do
        ( cd "$WM_PROJECT_DIR/$app" && wmake -j "${PBS_NCPUS:?}" )
    done
    for app in blockMesh decomposePar renumberMesh potentialFoam applyBoundaryLayer simpleFoam; do
        test -x "$FOAM_APPBIN/$app" || { echo "ERROR: benchmark executable absent: $app" >&2; exit 8; }
        printf 'BENCHMARK_APP_PASS %s\n' "$app" | tee -a "$IDENTITY_EVIDENCE"
    done
else
    "${WM_PROJECT_DIR}/applications/Allwmake" -j "${PBS_NCPUS:?}"
fi
if [ "${SCOTCH_C17_WORKAROUND:-${GCC16_SCOTCH_C17_WORKAROUND:-0}}" = 1 ]; then
    test -f "$FOAM_EXT_LIBBIN/libscotch.so" || { echo 'ERROR: Scotch library absent' >&2; exit 8; }
    test -f "$FOAM_LIBBIN/libscotchDecomp.so" || { echo 'ERROR: real scotchDecomp library absent' >&2; exit 8; }
    printf 'SCOTCH_BUILD_PASS\n' | tee -a "$IDENTITY_EVIDENCE"
fi
# Rule-file text is not proof. Count the flags in real compiler invocations.
sync
BUILD_LOG="${EVIDENCE_DIR}/build.log"
{
  printf 'wm_options=%s\n' "$WM_OPTIONS"
  printf 'wm_compile_option=%s\n' "$WM_COMPILE_OPTION"
  for f in -O3 -O2 -xCORE-AVX512 -xCORE-AVX2 -march= -mtune=; do
      printf 'flag_occurrences %-16s = %s\n' "$f" "$(grep -c -- "$f" "$BUILD_LOG" || true)"
  done
} | tee "${EVIDENCE_DIR}/compile-flags.txt"
# Each flag named in EXPECT_COMPILE_FLAGS must appear in a real invocation.
for f in $EXPECT_COMPILE_FLAGS; do
    n=$(grep -c -- "$f" "$BUILD_LOG" || true)
    printf 'required_flag %s occurrences=%s\n' "$f" "$n"
    test "$n" -gt 0 || { echo "ERROR: required compile flag $f never appeared" >&2; exit 7; }
done
BIN="${FOAM_APPBIN}/simpleFoam"; test -x "$BIN"; case "$(realpath "$BIN")" in "${WORKTREE}"/*) ;; *) echo 'ERROR: binary outside candidate worktree' >&2; exit 3;; esac
file "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.file"
ldd "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.ldd"
grep -F "libmpi.so.12 => $PRIVATE_MPI_PREFIX/lib/release/libmpi.so.12" "${EVIDENCE_DIR}/simpleFoam.ldd"
! grep -Fq 'not found' "${EVIDENCE_DIR}/simpleFoam.ldd"
! grep -Fqi openmpi "${EVIDENCE_DIR}/simpleFoam.ldd"
sha256sum "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.sha256"
# Fresh-job codeStream needs the v2512 source and META-INFO in the archive.
tar -C "$JOBFS_ROOT" -czf "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" OpenFOAM-v2512 ThirdParty-v2512
sha256sum "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" | tee "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz.sha256"
( cd "$RUNTIME_DIR"; sha256sum -c "${STACK_ID}.${PBS_JOBID}.tar.gz.sha256"; )
echo BUILD_VALIDATION_PASS
