#!/usr/bin/env bash
# Sourced by other scripts. Resolves IMAGE=<family>/<version> into
# context, tags, and ECR repo names.
set -euo pipefail

require_image() {
  local image=${1:-}
  if [[ -z "${image}" ]]; then
    echo "usage: $0 <family>/<version>  (e.g. java/25)" >&2
    exit 2
  fi
  if [[ ! -d "images/${image}" ]]; then
    echo "images/${image} does not exist" >&2
    exit 2
  fi
}

image_family() { echo "${1%%/*}"; }   # java/25 -> java
image_version(){ echo "${1#*/}"; }    # java/25 -> 25

build_tag() {
  local image=$1
  local sha=${CI_COMMIT_SHORT_SHA:-$(git rev-parse --short HEAD 2>/dev/null || echo local)}
  echo "$(image_version "${image}")-$(date -u +%Y%m%d)-${sha}"
}

ecr_repo() {
  : "${ECR_REGISTRY:?ECR_REGISTRY must be set (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com)}"
  : "${ECR_REPO_PREFIX:=platform/base}"
  echo "${ECR_REGISTRY}/${ECR_REPO_PREFIX}/$(image_family "$1")"
}
