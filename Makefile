SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

IMAGE         ?=
ECR_REGISTRY  ?= $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
ECR_REPO_PREFIX ?= platform/base
AWS_REGION    ?= us-east-1

IMAGES := $(shell find images -mindepth 2 -maxdepth 2 -type d | sed 's|^images/||' | sort)

help: ## Show this help
	@awk 'BEGIN{FS=":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*##/ {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

list: ## List buildable images
	@printf '%s\n' $(IMAGES)

build: _require-image ## Build IMAGE=<family>/<version> locally with docker
	./scripts/build.sh "$(IMAGE)"

scan: _require-image ## Trivy scan of locally built image
	./scripts/scan.sh "$(IMAGE)"

push: _require-image ## Push to ECR (requires AWS creds in env)
	./scripts/push-ecr.sh "$(IMAGE)"

build-all: ## Build every image locally
	@for img in $(IMAGES); do ./scripts/build.sh "$$img"; done

lint: ## Hadolint all Dockerfiles
	hadolint images/*/*/Dockerfile

_require-image:
	@test -n "$(IMAGE)" || { echo "IMAGE=<family>/<version> required (e.g. IMAGE=java/25)"; exit 2; }
	@test -d "images/$(IMAGE)"   || { echo "images/$(IMAGE) does not exist"; exit 2; }

.PHONY: help list build scan push build-all lint _require-image
