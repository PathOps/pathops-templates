#!/bin/sh
# Source/component test of the generic-container application: the page and the
# health file the image serves exist and are not empty. Runs without a
# deployment: sh tests/check-content.sh
set -eu
cd "$(dirname "$0")/.."
for f in app/index.html app/healthz; do
  [ -s "$f" ] || { echo "FAIL $f is missing or empty" >&2; exit 1; }
done
[ "$(cat app/healthz)" = ok ] || { echo "FAIL app/healthz is not ok" >&2; exit 1; }
echo "PASS content"
