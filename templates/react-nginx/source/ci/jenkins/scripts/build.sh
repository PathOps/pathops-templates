#!/usr/bin/env bash
set -euo pipefail

: "${APP_NAME:?APP_NAME is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"
: "${DOCKERFILE:=ci/docker/Dockerfile}"

docker build \
  -f "$DOCKERFILE" \
  -t "$APP_NAME:$IMAGE_TAG" \
  .