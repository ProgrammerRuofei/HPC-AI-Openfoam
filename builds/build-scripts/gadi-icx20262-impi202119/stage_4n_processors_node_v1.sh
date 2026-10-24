#!/bin/bash
# PBS TM helper: expand only this node's 104 processor directories in JOBFS.
set -euo pipefail
CASE=${1:?}; ARCHIVE=${2:?}; FIRST=${3:?}; LAST=${4:?}; MARKER=${5:?}
test ! -e "$CASE"; test ! -e "$MARKER"; test -s "$ARCHIVE"
mkdir -p "$CASE"
tar -xf "$ARCHIVE" -C "$CASE"
count=$(find "$CASE" -mindepth 1 -maxdepth 1 -type d -name 'processor*' | wc -l)
test "$count" -eq 104
test -d "$CASE/processor$FIRST"; test -d "$CASE/processor$LAST"
printf 'STAGE_4N_PROCESSORS_PASS host=%s first=%s last=%s count=%s\n' "$(hostname)" "$FIRST" "$LAST" "$count" | tee "$MARKER"
