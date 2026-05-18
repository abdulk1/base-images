#!/usr/bin/env bash
# Trivy scan of a locally built image. CI runs the same scan against the
# remote candidate tag.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=scripts/_common.sh
source scripts/_common.sh

IMAGE=${1:-}
require_image "${IMAGE}"

REF="platform-base/$(image_family "${IMAGE}"):$(image_version "${IMAGE}")-candidate"

trivy image \
  --config shared/trivy/trivy.yaml \
  --ignorefile shared/trivy/.trivyignore \
  "${REF}"
