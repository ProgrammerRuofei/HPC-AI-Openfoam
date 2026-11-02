#!/bin/bash
# Run once per node via pbsdsh; write quota receipt from that node.
set -euo pipefail
root=$1;reserve=$2;phase=$3;receipt=$4
used=$(du -sk "$root" | awk '{print $1}')
quota=$((100 * 1024 * 1024))
printf 'host=%s phase=%s used_kib=%s quota_kib=%s reserve_kib=%s\n' "$(hostname)" "$phase" "$used" "$quota" "$reserve" > "$receipt"
test "$((used + reserve))" -le "$quota"
