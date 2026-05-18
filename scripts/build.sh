#!/usr/bin/env bash
# Local build using docker buildx. CI uses Kaniko (see .gitlab/ci/build.yml).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=scripts/_common.sh
source scripts/_common.sh

IMAGE=${1:-}
require_image "${IMAGE}"

TAG=$(build_tag "${IMAGE}")
LOCAL_REF="platform-base/$(image_family "${IMAGE}"):${TAG}"

docker buildx build \
  --file "images/${IMAGE}/Dockerfile" \
  --build-arg "BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg "VCS_REF=$(git rev-parse HEAD 2>/dev/null || echo local)" \
  --build-arg "VERSION=${TAG}" \
  --tag "${LOCAL_REF}" \
  --tag "platform-base/$(image_family "${IMAGE}"):$(image_version "${IMAGE}")-candidate" \
  --load \
  .

echo "built ${LOCAL_REF}"
