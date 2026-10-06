#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$REPO_ROOT" | tr '.' '-')"
OUTPUT="${REPO_NAME}_dump.txt"

git ls-files | while read -r file; do
  if file --mime "$file" | grep -q 'charset='; then
    echo "===== FILE: $REPO_ROOT/$file ====="
    cat "$file"
    echo
  fi
done > "$OUTPUT"

echo "Export completed -> $OUTPUT"