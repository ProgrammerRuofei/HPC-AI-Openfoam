#!/bin/bash
# Run once per allocated node via pbsdsh.  The archive is shared; JOBFS is local.
set -euo pipefail
: "${STACK_ID:?}" "${RUNTIME_ARCHIVE:?}" "${RUNTIME_ARCHIVE_SHA256:?}" "${RUNTIME_ROOT:?}" "${CANDIDATE_BINARY_REL:?}" "${CANDIDATE_BINARY_SHA256:?}"
test -r "$RUNTIME_ARCHIVE"
printf '%s  %s\n' "$RUNTIME_ARCHIVE_SHA256" "$RUNTIME_ARCHIVE" | sha256sum -c -
test ! -e "$RUNTIME_ROOT"
mkdir -p "$RUNTIME_ROOT"
tar -C "$RUNTIME_ROOT" -xzf "$RUNTIME_ARCHIVE"
mkdir -p "$RUNTIME_ROOT/META-INFO"
printf 'api=2512\npatch=0\n' > "$RUNTIME_ROOT/META-INFO/api-info"
printf '%s  %s\n' d03cf08cf48ab523323a8849439b2f1073df920e29e969f51f188568a4fa0a8a "$RUNTIME_ROOT/META-INFO/api-info" | sha256sum -c -
test -x "$RUNTIME_ROOT/$CANDIDATE_BINARY_REL"
binary_sha=$(sha256sum "$RUNTIME_ROOT/$CANDIDATE_BINARY_REL" | awk '{print $1}')
test "$binary_sha" = "$CANDIDATE_BINARY_SHA256"
printf 'runtime_stage_pass stack_id=%s node=%s archive_sha256=%s binary_sha256=%s\n' "$STACK_ID" "$(hostname)" "$RUNTIME_ARCHIVE_SHA256" "$binary_sha"
