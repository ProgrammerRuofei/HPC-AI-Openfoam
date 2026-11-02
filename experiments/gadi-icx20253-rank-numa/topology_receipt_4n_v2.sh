#!/bin/bash
# Execute on each allocated node via pbsdsh. Write topology at the supplied new receipt path.
# Inputs: receipt path and expected hostname. No scientific input or runtime setting changes.
set -euo pipefail
receipt=${1:?receipt path required}
expected_host=${2:?expected hostname required}
test ! -e "$receipt"
test "$(hostname)" = "$expected_host"
# pbsdsh output may go directly to PBS stdout; capture inside the node-side process.
( set -o noclobber; LC_ALL=C /usr/bin/lscpu > "$receipt" )
test -s "$receipt"
grep -Fq 'Xeon(R) Platinum 8470Q' "$receipt"
printf 'TOPOLOGY_RECEIPT_PASS host=%s receipt=%s\n' "$expected_host" "$receipt"
