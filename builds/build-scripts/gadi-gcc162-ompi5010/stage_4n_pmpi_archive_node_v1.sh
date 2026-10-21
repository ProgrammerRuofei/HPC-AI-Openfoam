#!/bin/bash
# Validate 104 rank reports on one JOBFS and archive them to scratch.
set -euo pipefail
ROOT=${1:?}; FIRST=${2:?}; ARCHIVE=${3:?}; MARKER=${4:?}
LAST=$((FIRST + 103))
case "$FIRST" in 0|104|208|312) ;; *) exit 2 ;; esac
test ! -e "$ARCHIVE"; test ! -e "$MARKER"
test -d "$ROOT/pmpi-reports"
/bin/python3 - "$ROOT/pmpi-reports" "$FIRST" "$LAST" <<'PY'
import csv
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
first, last = map(int, sys.argv[2:])
summaries = sorted(root.glob("rank-??????.csv"))
buckets = sorted(root.glob("rank-??????-buckets.csv"))
assert len(summaries) == len(buckets) == 104, (len(summaries), len(buckets))
total_calls = 0
for rank in range(first, last + 1):
    summary = root / f"rank-{rank:06d}.csv"
    bucket = root / f"rank-{rank:06d}-buckets.csv"
    with summary.open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    with bucket.open(newline="") as stream:
        windows = list(csv.DictReader(stream))
    assert len(rows) == 14 and windows, rank
    assert all(int(row["rank"]) == rank for row in rows + windows), rank
    assert all(int(row["window_start_s"]) % 10 == 0 for row in windows), rank
    per_call = {row["call"]: row for row in rows}
    assert len(per_call) == 14, rank
    for call, row in per_call.items():
        selected = [window for window in windows if window["call"] == call]
        assert sum(int(window["count"]) for window in selected) == int(row["count"]), (rank, call, "count")
        assert sum(int(window["total_ns"]) for window in selected) == int(row["total_ns"]), (rank, call, "duration")
    total_calls += sum(int(row["count"]) for row in rows)
assert total_calls > 0, total_calls
print("PMPI_NODE_REPORT_PASS", first, last, total_calls)
PY
tar -czf "$ARCHIVE" -C "$ROOT" pmpi-reports
test -s "$ARCHIVE"
printf 'STAGE_4N_PMPI_ARCHIVE_PASS host=%s first=%s last=%s archive_sha256=%s\n' \
    "$(hostname)" "$FIRST" "$LAST" "$(sha256sum "$ARCHIVE" | cut -d ' ' -f1)" > "$MARKER"
