#!/usr/bin/env bash
set -euo pipefail

: "${APP_NAME:?APP_NAME is required}"
: "${IMAGE_REPOSITORY:?IMAGE_REPOSITORY is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

LOCAL_IMAGE="$APP_NAME:$IMAGE_TAG"
REMOTE_IMAGE="$IMAGE_REPOSITORY:$IMAGE_TAG"

docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE"
docker push "$REMOTE_IMAGE"