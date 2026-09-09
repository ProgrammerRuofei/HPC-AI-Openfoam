#!/bin/bash
# Stage the C1 runtime-v2 archive into node-local JOBFS. One invocation per
# allocated node. Every input is passed as an argument: pbsdsh/mpirun task
# environments are not a reliable carrier for values set after job start.
#
# The runtime-v2 tarball stores OpenFOAM-v2512/ and ThirdParty-v2512/ as
# top-level members, so it must be extracted into a *container* directory; the
# OpenFOAM project root is the OpenFOAM-v2512/ child of that container.
set -euo pipefail

test "$#" -eq 5 || { echo 'ERROR: usage: stage_c1_runtime_node.sh ARCHIVE ARCHIVE_SHA256 CONTAINER BINARY_REL BINARY_SHA256' >&2; exit 2; }
ARCHIVE=$1
ARCHIVE_SHA256=$2
CONTAINER=$3
BINARY_REL=$4
BINARY_SHA256=$5

RUNTIME_ROOT="${CONTAINER}/OpenFOAM-v2512"
THIRDPARTY_ROOT="${CONTAINER}/ThirdParty-v2512"

test -r "$ARCHIVE"
printf '%s  %s\n' "$ARCHIVE_SHA256" "$ARCHIVE" | sha256sum -c - > /dev/null

test ! -e "$CONTAINER"
mkdir -p "$CONTAINER"
tar -C "$CONTAINER" -xzf "$ARCHIVE"
test -d "$RUNTIME_ROOT"
test -d "$THIRDPARTY_ROOT"
test -x "$RUNTIME_ROOT/bin/foamEtcFile"
test -x "$RUNTIME_ROOT/bin/foamCleanPath"
test -r "$RUNTIME_ROOT/etc/bashrc"

# The site v2512 source omits this release metadata file. Recreate the same
# reviewed job-local metadata already used by the passing C1 build and smoke.
mkdir -p "$RUNTIME_ROOT/META-INFO"
printf 'api=2512\npatch=0\n' > "$RUNTIME_ROOT/META-INFO/api-info"
printf '%s  %s\n' d03cf08cf48ab523323a8849439b2f1073df920e29e969f51f188568a4fa0a8a "$RUNTIME_ROOT/META-INFO/api-info" | sha256sum -c - > /dev/null

test -x "$RUNTIME_ROOT/$BINARY_REL"
binary_sha=$(sha256sum "$RUNTIME_ROOT/$BINARY_REL" | awk '{print $1}')
test "$binary_sha" = "$BINARY_SHA256"

printf 'runtime_stage_pass node=%s container=%s archive_sha256=%s binary_sha256=%s\n' \
    "$(hostname)" "$CONTAINER" "$ARCHIVE_SHA256" "$binary_sha"
