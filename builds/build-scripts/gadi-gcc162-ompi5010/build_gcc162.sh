#!/bin/bash
# Build a private C/C++ GCC 16.2.0 on Gadi SPR using node-local jobfs.
# Inputs: official source tarball in the approved scratch project root.
# Outputs: job-specific evidence and an installed-prefix archive in scratch.
# The archive must pass a later relocation smoke before downstream use.
set -euo pipefail

PROJECT_ROOT=/scratch/pm78/kj7183/openfoam_cpu
STACK_ROOT="$PROJECT_ROOT/toolchain-screening/gadi-gcc162-ompi5010"
SOURCE_ARCHIVE="$PROJECT_ROOT/toolchain-screening/source/gcc-16.2.0.tar.xz"
SOURCE_SHA512=c51c30ca7422d0cbecf504b2e0f33c3aca31e0f90a76b65217f465163fa6fa17b3f5de39e145c47e5bab90ac0ce7fff3b03c8d553ae36e01faaea5a50f8648d1
JOB_ID=${PBS_JOBID:?PBS_JOBID is required}
JOBFS_ROOT="${PBS_JOBFS:?PBS_JOBFS is required}/gcc162-build"
SOURCE_DIR="$JOBFS_ROOT/gcc-16.2.0"
BUILD_DIR="$JOBFS_ROOT/build"
PREFIX="$JOBFS_ROOT/install/gcc-16.2.0"
EVIDENCE="$STACK_ROOT/evidence/$JOB_ID"
ARCHIVE="$STACK_ROOT/runtime-archive/gcc-16.2.0.$JOB_ID.tar.gz"

module purge
module load gcc/15.1.0
for tool in gcc g++ make tar sha512sum; do command -v "$tool" >/dev/null; done
test -f "$SOURCE_ARCHIVE"
test ! -e "$JOBFS_ROOT"
test ! -e "$EVIDENCE"
test ! -e "$ARCHIVE"
test "${PBS_NCPUS:?}" -eq 104
printf '%s  %s\n' "$SOURCE_SHA512" "$SOURCE_ARCHIVE" | sha512sum -c -

mkdir -p "$JOBFS_ROOT" "$BUILD_DIR" "$PREFIX" "$EVIDENCE" "${ARCHIVE%/*}"
exec > >(tee "$EVIDENCE/build.log") 2>&1
printf 'job_id=%s\njobfs=%s\nsource_archive=%s\nprefix=%s\n' \
    "$JOB_ID" "$PBS_JOBFS" "$SOURCE_ARCHIVE" "$PREFIX"
module list 2>&1
grep -m1 'model name' /proc/cpuinfo
gcc --version | head -n 1
tar -xJf "$SOURCE_ARCHIVE" -C "$JOBFS_ROOT"
test -x "$SOURCE_DIR/configure"

cd "$BUILD_DIR"
"$SOURCE_DIR/configure" --prefix="$PREFIX" --enable-languages=c,c++ \
    --disable-bootstrap --disable-multilib --disable-nls
make -j "$PBS_NCPUS"
make install
test -x "$PREFIX/bin/gcc"
test -x "$PREFIX/bin/g++"
"$PREFIX/bin/gcc" --version | head -n 1
"$PREFIX/bin/g++" --version | head -n 1
printf 'int main(void) { return 0; }\n' > "$JOBFS_ROOT/smoke.c"
"$PREFIX/bin/gcc" "$JOBFS_ROOT/smoke.c" -o "$JOBFS_ROOT/smoke"
"$JOBFS_ROOT/smoke"

tar -C "$JOBFS_ROOT/install" -czf "$ARCHIVE" gcc-16.2.0
sha256sum "$ARCHIVE" | tee "$ARCHIVE.sha256"
printf 'archive=%s\n' "$ARCHIVE"
echo GCC162_BUILD_ARCHIVE_PASS
