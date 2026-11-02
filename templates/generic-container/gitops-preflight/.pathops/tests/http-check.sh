#!/bin/sh
# TARGET_URL=<url> sh http-check.sh: <url>/healthz answers "ok".
set -eu
: "${TARGET_URL:?TARGET_URL is required}"
body=$(wget -q -T 10 -O - "$TARGET_URL/healthz")
[ "$body" = ok ] || { echo "FAIL $TARGET_URL/healthz answered: $body" >&2; exit 1; }
echo "PASS $TARGET_URL/healthz"
