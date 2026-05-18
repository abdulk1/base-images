#!/usr/bin/env bash
# Used by CI: exchange GitLab OIDC token for AWS creds, then write a
# docker config that authenticates to ECR + Iron Bank. The artifact at
# DOCKER_CONFIG is consumed by Kaniko in the build job.
set -euo pipefail

: "${AWS_ID_TOKEN:?AWS_ID_TOKEN must be set (id_tokens in .gitlab-ci.yml)}"
: "${AWS_ROLE_ARN:?AWS_ROLE_ARN must be set}"
: "${AWS_REGION:?AWS_REGION must be set}"
: "${ECR_REGISTRY:?ECR_REGISTRY must be set}"
: "${IRONBANK_REGISTRY:=registry1.dod.mil}"

DOCKER_CONFIG_DIR=${DOCKER_CONFIG_DIR:-${CI_PROJECT_DIR:-.}/.docker}
mkdir -p "${DOCKER_CONFIG_DIR}"

read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN < <(
  aws sts assume-role-with-web-identity \
    --role-arn "${AWS_ROLE_ARN}" \
    --role-session-name "gitlab-${CI_PROJECT_ID:-local}-${CI_PIPELINE_ID:-0}" \
    --web-identity-token "${AWS_ID_TOKEN}" \
    --duration-seconds 3600 \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
)
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

ECR_PASSWORD=$(aws ecr get-login-password --region "${AWS_REGION}")
ECR_AUTH=$(printf 'AWS:%s' "${ECR_PASSWORD}" | base64 -w0)

if [[ -z "${IRONBANK_USER:-}" || -z "${IRONBANK_TOKEN:-}" ]]; then
  echo "warning: IRONBANK_USER/IRONBANK_TOKEN not set — pulls from ${IRONBANK_REGISTRY} will fail" >&2
  IB_AUTH=""
else
  IB_AUTH=$(printf '%s:%s' "${IRONBANK_USER}" "${IRONBANK_TOKEN}" | base64 -w0)
fi

cat > "${DOCKER_CONFIG_DIR}/config.json" <<JSON
{
  "auths": {
    "${ECR_REGISTRY}":      {"auth": "${ECR_AUTH}"},
    "${IRONBANK_REGISTRY}": {"auth": "${IB_AUTH}"}
  }
}
JSON

chmod 600 "${DOCKER_CONFIG_DIR}/config.json"
echo "wrote ${DOCKER_CONFIG_DIR}/config.json"
