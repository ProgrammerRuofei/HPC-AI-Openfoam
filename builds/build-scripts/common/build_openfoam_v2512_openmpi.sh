#!/bin/bash
# Shared isolated OpenFOAM v2512/OpenMPI build implementation. Candidate scripts
# provide the stack identity and module list; all source staging remains in JOBFS.
set -euo pipefail

: "${STACK_ID:?}" "${MODULE_LIST:?}" "${WM_COMPILER_VALUE:?}" "${OMPI_CC_VALUE:?}" "${OMPI_CXX_VALUE:?}"
# Architecture targeting is a build variable. Default Opt so every previously
# validated candidate (C1 generic included) resolves exactly as before.
WM_COMPILE_OPTION_VALUE="${WM_COMPILE_OPTION_VALUE:-Opt}"
EXPECT_COMPILE_FLAGS="${EXPECT_COMPILE_FLAGS:-}"
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
module load ${MODULE_LIST}
# Private archives are unpacked by the candidate wrapper in this job's JOBFS.
if test -n "${PRIVATE_MPI_PREFIX:-}"; then
    : "${PRIVATE_GCC_PREFIX:?}"
    test -x "$PRIVATE_GCC_PREFIX/bin/gcc"
    test -x "$PRIVATE_MPI_PREFIX/bin/mpicc"
    export OPAL_PREFIX="$PRIVATE_MPI_PREFIX" PMIX_PREFIX="$PRIVATE_MPI_PREFIX" PRTE_PREFIX="$PRIVATE_MPI_PREFIX"
    export PATH="$PRIVATE_MPI_PREFIX/bin:$PRIVATE_GCC_PREFIX/bin:$PATH"
    export LD_LIBRARY_PATH="$PRIVATE_MPI_PREFIX/lib:$PRIVATE_GCC_PREFIX/lib64:/opt/pbs/default/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
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
# The build node's own CPU is the authoritative record of what the generated
# code must run on. lscpu alone omits the flag list, so read cpuinfo directly.
grep -m1 'model name' /proc/cpuinfo | tee "${EVIDENCE_DIR}/build-node-cpu.txt"
grep -m1 ^flags /proc/cpuinfo | tr ' ' '\n' | grep -i '^avx512' | sort \
    | tee "${EVIDENCE_DIR}/build-node-avx512-flags.txt" | tr '\n' ' '; echo
printf 'wm_compile_option=%s\n' "$WM_COMPILE_OPTION_VALUE"
for tool in "$OMPI_CC_VALUE" "$OMPI_CXX_VALUE" mpicc mpicxx mpirun; do printf '%s=' "$tool"; command -v "$tool"; done
"$OMPI_CC_VALUE" --version | head -n 2; "$OMPI_CXX_VALUE" --version | head -n 2; mpicc --showme:command; mpicxx --showme:command; mpicc --showme:link; mpirun --version | head -n 3
if test -n "${PRIVATE_MPI_PREFIX:-}"; then
    case "$WM_COMPILER_VALUE" in
        Gcc)
            "$OMPI_CC_VALUE" --version | head -n 1 | grep -Fx 'gcc (GCC) 16.2.0'
            "$OMPI_CXX_VALUE" --version | head -n 1 | grep -Fx 'g++ (GCC) 16.2.0' ;;
        Icx)
            "$OMPI_CC_VALUE" --version | head -n 1 | grep -F '2025.3.2'
            "$OMPI_CXX_VALUE" --version | head -n 1 | grep -F '2025.3.2' ;;
        *) echo "ERROR: unvalidated private-MPI compiler $WM_COMPILER_VALUE" >&2; exit 4 ;;
    esac
    mpirun --version | head -n 1 | grep -Fx 'mpirun (Open MPI) 5.0.10'
    mpicc --showme:command | grep -Fx "$OMPI_CC_VALUE"
    mpicxx --showme:command | grep -Fx "$OMPI_CXX_VALUE"
    test "${UCX_ROOT:?}" = /apps/ucx/1.18.1
    test "${UCC_ROOT:?}" = /apps/ucc/1.4.4
fi
write_regular_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-source-files.sha256"; write_symlink_manifest "$AUTHORITATIVE_SOURCE" "${EVIDENCE_DIR}/authoritative-symlink-files.nul"
auth_r=$(sha256sum "${EVIDENCE_DIR}/authoritative-source-files.sha256" | awk '{print $1}'); auth_s=$(sha256sum "${EVIDENCE_DIR}/authoritative-symlink-files.nul" | awk '{print $1}')
verify authoritative_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$auth_r"; verify authoritative_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$auth_s"; verify authoritative_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$(source_id_v2 "$auth_r" "$auth_s")"
rsync -a --exclude='/platforms/' --exclude='/ThirdParty-v2512/platforms/' --exclude='/ThirdParty-v2512/build/' "${AUTHORITATIVE_SOURCE}/" "${WORKTREE}/"
for f in etc/bashrc etc/config.sh/settings src/Allwmake applications/Allwmake wmake/wmake wmake/src/Allmake ThirdParty-v2512/Allwmake; do test -f "${WORKTREE}/$f"; done
write_regular_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-source-files.sha256"; write_symlink_manifest "$WORKTREE" "${EVIDENCE_DIR}/staged-symlink-files.nul"
stage_r=$(sha256sum "${EVIDENCE_DIR}/staged-source-files.sha256" | awk '{print $1}'); stage_s=$(sha256sum "${EVIDENCE_DIR}/staged-symlink-files.nul" | awk '{print $1}')
printf 'staged_regular_entry_count=%s\nstaged_symlink_entry_count=%s\n' "$(count_entries "$WORKTREE" f)" "$(count_entries "$WORKTREE" l)" | tee -a "$IDENTITY_EVIDENCE"
verify staged_regular_manifest "$EXPECTED_REGULAR_MANIFEST_SHA256" "$stage_r"; verify staged_symlink_manifest "$EXPECTED_SYMLINK_MANIFEST_SHA256" "$stage_s"; verify staged_source_id_v2 "$EXPECTED_SOURCE_ID_V2" "$(source_id_v2 "$stage_r" "$stage_s")"
# ICC 2021.10 accepts -std=c++17 but does not advertise __cpp_aligned_new.
# OpenFOAM v2512 ListPolicy uses aligned new[]/delete[], while the GCC 8
# libstdc++ declarations are gated on that feature macro.  Apply this only to
# C1's JOBFS staging after authoritative SOURCE_ID_V2 verification; /apps is
# never changed and other compiler candidates leave this branch untouched.
if [ "${ICC_ALIGNED_NEW_WORKAROUND:-0}" = 1 ]; then
    test "$WM_COMPILER_VALUE" = Icc
    ICC_RULE="${WORKTREE}/wmake/rules/linux64Icc/c++"
    test -f "$ICC_RULE"
    printf '\n# C1 ICC 2021.10 aligned-allocation compatibility workaround\nc++FLAGS += -D__cpp_aligned_new=201606L\n' >> "$ICC_RULE"
    grep -Fq -- '-D__cpp_aligned_new=201606L' "$ICC_RULE"
    printf 'icc_aligned_new_workaround=enabled\nicc_rule=%s\n' "$ICC_RULE" | tee -a "$IDENTITY_EVIDENCE"
fi
# ICC 2021.10 incorrectly propagates the top-level const qualifier from the
# CircularBuffer::toGlobal declaration to its out-of-line definition, making
# the local value parameter non-modifiable on instantiation.  Adjust only the
# staged JOBFS declaration after source-identity verification; /apps remains
# unmodified and non-C1 candidates do not enter this branch.
if [ "${ICC_CIRCULARBUFFER_CONST_WORKAROUND:-0}" = 1 ]; then
    test "$WM_COMPILER_VALUE" = Icc
    ICC_CIRCULARBUFFER_HEADER="${WORKTREE}/src/OpenFOAM/containers/Buffers/CircularBuffer.H"
    test -f "$ICC_CIRCULARBUFFER_HEADER"
    /bin/perl -0pi -e 's/inline label toGlobal\(const label i\) const;/inline label toGlobal(label i) const;/' "$ICC_CIRCULARBUFFER_HEADER"
    grep -Fqx '        inline label toGlobal(label i) const;' "$ICC_CIRCULARBUFFER_HEADER"
    ! grep -Fq 'toGlobal(const label i)' "$ICC_CIRCULARBUFFER_HEADER"
    printf 'icc_circularbuffer_const_workaround=enabled\nicc_circularbuffer_header=%s\n' "$ICC_CIRCULARBUFFER_HEADER" | tee -a "$IDENTITY_EVIDENCE"
fi
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
cd "$WORKTREE"; set +u; . etc/bashrc "WM_COMPILER=${WM_COMPILER_VALUE}" WM_MPLIB=SYSTEMOPENMPI "WM_COMPILE_OPTION=${WM_COMPILE_OPTION_VALUE}"; set -u
printf 'WM_PROJECT_VERSION=%s\nFOAM_API=%s\nWM_COMPILER=%s\nWM_MPLIB=%s\nWM_OPTIONS=%s\nFOAM_MPI=%s\nMPI_ARCH_PATH=%s\n' "$WM_PROJECT_VERSION" "$FOAM_API" "$WM_COMPILER" "$WM_MPLIB" "$WM_OPTIONS" "$FOAM_MPI" "$MPI_ARCH_PATH"
test "$WM_PROJECT_VERSION" = v2512; test "$FOAM_API" = "$EXPECTED_FOAM_API"; test "$WM_COMPILER" = "$WM_COMPILER_VALUE"; test "$WM_MPLIB" = SYSTEMOPENMPI; test "$WM_COMPILE_OPTION" = "$WM_COMPILE_OPTION_VALUE"; test "$FOAM_MPI" = sys-openmpi; test "$(command -v mpicc)" = "${PRIVATE_MPI_PREFIX:-/apps/openmpi/4.1.7}/bin/mpicc"
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
    # This benchmark needs six executables. ICX/CGAL 4.14.3 fails while
    # compiling unrelated optional surface tools; do not mutate that source.
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
if test -n "${PRIVATE_MPI_PREFIX:-}"; then
    grep -F "$PRIVATE_MPI_PREFIX/lib/libmpi.so" "${EVIDENCE_DIR}/simpleFoam.ldd"
    ! grep -Fq 'not found' "${EVIDENCE_DIR}/simpleFoam.ldd"
else
    grep -qi '/apps/openmpi/4.1.7' "${EVIDENCE_DIR}/simpleFoam.ldd"
fi
sha256sum "$BIN" | tee "${EVIDENCE_DIR}/simpleFoam.sha256"
if test -n "${PRIVATE_MPI_PREFIX:-}"; then
    # The private runtime needs source/META-INFO for fresh-job codeStream use.
    tar -C "$JOBFS_ROOT" -czf "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" OpenFOAM-v2512 ThirdParty-v2512
else
    tar -C "$JOBFS_ROOT" -czf "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" "OpenFOAM-v2512/etc" "OpenFOAM-v2512/platforms/${WM_OPTIONS}" ThirdParty-v2512/platforms
fi
sha256sum "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz" | tee "${RUNTIME_DIR}/${STACK_ID}.${PBS_JOBID}.tar.gz.sha256"
if test -n "${PRIVATE_MPI_PREFIX:-}"; then ( cd "$RUNTIME_DIR"; sha256sum -c "${STACK_ID}.${PBS_JOBID}.tar.gz.sha256"; ); fi
echo BUILD_VALIDATION_PASS
