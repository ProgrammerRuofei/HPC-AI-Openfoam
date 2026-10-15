#!/bin/bash
# Build one private Open MPI archive; source and GCC inputs are checksum pinned.
# All expanded trees stay in node-local PBS_JOBFS because pm78 scratch is near
# its inode quota. OpenFOAM builds and benchmarks require separate review.
set -euo pipefail

PROJECT_ROOT=/scratch/pm78/kj7183/openfoam_cpu
STACK_ROOT="$PROJECT_ROOT/toolchain-screening/gadi-gcc162-ompi5010"
SOURCE_ARCHIVE="$PROJECT_ROOT/toolchain-screening/source/openmpi-5.0.10.tar.gz"
SOURCE_SHA256=5692cc80554a7117c99eaa725d35100edd8bbf73423a5e265ff867979192df7d
GCC_ARCHIVE="$STACK_ROOT/runtime-archive/gcc-16.2.0.181342083.gadi-pbs.tar.gz"
GCC_SHA256=1149c0d97412ae3741cc18d60f233cdd3dd5e33bc92c55c59db2dd8cf535b714
JOB_ID=${PBS_JOBID:?PBS_JOBID is required}
JOBFS_ROOT="${PBS_JOBFS:?PBS_JOBFS is required}/ompi5010-build"
GCC_PREFIX="$JOBFS_ROOT/gcc-16.2.0"
SOURCE_DIR="$JOBFS_ROOT/openmpi-5.0.10"
BUILD_DIR="$JOBFS_ROOT/build"
PREFIX="$JOBFS_ROOT/install/openmpi-5.0.10"
EVIDENCE="$STACK_ROOT/evidence/$JOB_ID"
ARCHIVE="$STACK_ROOT/runtime-archive/openmpi-5.0.10.$JOB_ID.tar.gz"

test "${PBS_NCPUS:?PBS_NCPUS is required}" -eq 32
test -f "$SOURCE_ARCHIVE"
test -f "$GCC_ARCHIVE"
test ! -e "$JOBFS_ROOT"
test ! -e "$EVIDENCE"
test ! -e "$ARCHIVE"
printf '%s  %s\n' "$SOURCE_SHA256" "$SOURCE_ARCHIVE" | sha256sum -c -
printf '%s  %s\n' "$GCC_SHA256" "$GCC_ARCHIVE" | sha256sum -c -

mkdir -p "$JOBFS_ROOT" "$BUILD_DIR" "$EVIDENCE" "${ARCHIVE%/*}"
exec > >(tee "$EVIDENCE/build_ompi5010.log") 2>&1
finish() {
    rc=$?
    if test "$rc" -ne 0; then
        if test -f "$BUILD_DIR/config.log"; then
            cp "$BUILD_DIR/config.log" "$EVIDENCE/config.log"
        fi
        printf 'OMPI5010_BUILD_FAIL exit=%s\n' "$rc"
    fi
}
trap finish EXIT
printf 'job_id=%s\njobfs=%s\nsource=%s\ngcc_archive=%s\n' \
    "$JOB_ID" "$PBS_JOBFS" "$SOURCE_ARCHIVE" "$GCC_ARCHIVE"
grep -m1 'model name' /proc/cpuinfo

module purge
module load ucx/1.18.1 ucc/1.4.4
module list 2>&1
test "${UCX_ROOT:?}" = /apps/ucx/1.18.1
test "${UCC_ROOT:?}" = /apps/ucc/1.4.4
test -f /opt/pbs/default/include/tm.h
test -f /opt/pbs/default/lib/libpbs.so

tar -xzf "$GCC_ARCHIVE" -C "$JOBFS_ROOT"
tar -xzf "$SOURCE_ARCHIVE" -C "$JOBFS_ROOT"
# Open MPI upstream aa024ac fixes GCC 16 recursive always-inline failure in 5.0.10.
# Apply exactly that one-line change to this job-local copy of the MPI source.
python3 - "$SOURCE_DIR/ompi/mca/part/persist/part_persist.h" <<'PY_PATCH'
from pathlib import Path
import sys
path = Path(sys.argv[1])
s = path.read_text()
old = "__opal_attribute_always_inline__ static inline int\nmca_part_persist_start("
new = "static inline int\nmca_part_persist_start("
if s.count(old) != 1:
    raise SystemExit("Unexpected Open MPI 5.0.10 part/persist source; refusing patch")
path.write_text(s.replace(old, new, 1))
PY_PATCH
grep -A1 -B1 '^mca_part_persist_start(' "$SOURCE_DIR/ompi/mca/part/persist/part_persist.h"
test -x "$GCC_PREFIX/bin/gcc"
test -x "$GCC_PREFIX/bin/g++"
test -x "$SOURCE_DIR/configure"
export PATH="$GCC_PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$GCC_PREFIX/lib64:/opt/pbs/default/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export CC="$GCC_PREFIX/bin/gcc"
export CXX="$GCC_PREFIX/bin/g++"
"$CC" --version | head -n 1 | grep -Fx 'gcc (GCC) 16.2.0'
"$CXX" --version | head -n 1 | grep -Fx 'g++ (GCC) 16.2.0'

cd "$BUILD_DIR"
"$SOURCE_DIR/configure" --prefix="$PREFIX" --disable-mpi-fortran --disable-oshmem \
    --with-ucx="$UCX_ROOT" --with-ucc="$UCC_ROOT" \
    --with-tm=/opt/pbs/default \
    --with-hwloc=internal --with-libevent=internal \
    --with-pmix=internal --with-prrte=internal
make -j "$PBS_NCPUS"
make install
test -x "$PREFIX/bin/mpicc"
test -x "$PREFIX/bin/mpirun"
test -x "$PREFIX/bin/ompi_info"
test -x "$PREFIX/bin/prte_info"
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
mpirun --version | head -n 1
mpicc --showme:command | grep -F "$GCC_PREFIX/bin/gcc"
ompi_info --param pml ucx | tee "$EVIDENCE/pml-ucx.txt"
ompi_info --param coll ucc | tee "$EVIDENCE/coll-ucc.txt"
prte_info --param ras tm | tee "$EVIDENCE/ras-tm.txt"
grep -E 'MCA pml: ucx' "$EVIDENCE/pml-ucx.txt"
grep -E 'MCA coll: ucc' "$EVIDENCE/coll-ucc.txt"
grep -E 'MCA ras: tm' "$EVIDENCE/ras-tm.txt"

cat > "$JOBFS_ROOT/mpi-smoke.c" <<'EOF'
#include <mpi.h>
#include <stdio.h>
int main(int argc, char **argv) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    printf("OMPI5010_RANK_%d_OF_%d\n", rank, size);
    MPI_Finalize();
    return size == 2 ? 0 : 1;
}
EOF
mpicc "$JOBFS_ROOT/mpi-smoke.c" -o "$JOBFS_ROOT/mpi-smoke"
mpirun --mca pml ucx -np 2 "$JOBFS_ROOT/mpi-smoke" | tee "$EVIDENCE/mpi-smoke.txt"
grep -Fx OMPI5010_RANK_0_OF_2 "$EVIDENCE/mpi-smoke.txt"
grep -Fx OMPI5010_RANK_1_OF_2 "$EVIDENCE/mpi-smoke.txt"

tar -C "$JOBFS_ROOT/install" -czf "$ARCHIVE" openmpi-5.0.10
sha256sum "$ARCHIVE" | tee "$ARCHIVE.sha256"
printf 'archive=%s\n' "$ARCHIVE"
echo OMPI5010_BUILD_ARCHIVE_PASS
