#!/usr/bin/env bash
# Push a locally built image to ECR. Requires AWS creds already in env
# (e.g. via aws-vault or `aws sso login`). CI uses OIDC instead — see
# .gitlab/ci/build.yml.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=scripts/_common.sh
source scripts/_common.sh

IMAGE=${1:-}
require_image "${IMAGE}"

: "${AWS_REGION:?AWS_REGION must be set}"
: "${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID must be set}"
export ECR_REGISTRY="${ECR_REGISTRY:-${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com}"

TAG=$(build_tag "${IMAGE}")
LOCAL_REF="platform-base/$(image_family "${IMAGE}"):${TAG}"
REPO=$(ecr_repo "${IMAGE}")

aws ecr describe-repositories --repository-names "${ECR_REPO_PREFIX}/$(image_family "${IMAGE}")" >/dev/null 2>&1 \
  || aws ecr create-repository \
       --repository-name "${ECR_REPO_PREFIX}/$(image_family "${IMAGE}")" \
       --image-tag-mutability IMMUTABLE \
       --image-scanning-configuration scanOnPush=true \
       --encryption-configuration encryptionType=KMS

aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

docker tag "${LOCAL_REF}" "${REPO}:${TAG}"
docker tag "${LOCAL_REF}" "${REPO}:$(image_version "${IMAGE}")-candidate"
docker push "${REPO}:${TAG}"
docker push "${REPO}:$(image_version "${IMAGE}")-candidate"

echo "pushed ${REPO}:${TAG}"
