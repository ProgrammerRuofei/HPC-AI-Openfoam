#!/bin/bash
# Called by pbsdsh once per node after the profiled solver has completed.
set -euo pipefail
local_root=${1:?}
first=${2:?}
archive=${3:?}
marker=${4:?}
second=$((first + 52))
test ! -e "$archive"; test ! -e "$marker"
test -d "$local_root/hpctoolkit-rank-$first"
test -d "$local_root/hpctoolkit-rank-$second"
for rank in "$first" "$second"; do
    test -n "$(find "$local_root/hpctoolkit-rank-$rank" -type f -name '*.hpcrun' -size +0c -print -quit)"
done
tar -czf "$archive" -C "$local_root" "hpctoolkit-rank-$first" "hpctoolkit-rank-$second"
test -s "$archive"
printf 'STAGE_4N_PROFILE_PASS host=%s first=%s second=%s archive_sha256=%s\n' \
    "$(hostname)" "$first" "$second" "$(sha256sum "$archive" | cut -d ' ' -f1)" > "$marker"
