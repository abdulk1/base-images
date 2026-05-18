# syntax=docker/dockerfile:1.7
ARG IRONBANK_REGISTRY=registry1.dod.mil
ARG IRONBANK_REPO=ironbank/opensource/python/python3.13
ARG IRONBANK_TAG=3.13

FROM ${IRONBANK_REGISTRY}/${IRONBANK_REPO}:${IRONBANK_TAG}

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.title="platform-base-python3.13" \
      org.opencontainers.image.description="Hardened CPython 3.13 base, derived from Iron Bank" \
      org.opencontainers.image.vendor="Platform Engineering" \
      org.opencontainers.image.base.name="${IRONBANK_REGISTRY}/${IRONBANK_REPO}:${IRONBANK_TAG}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}"

USER root

COPY shared/hardening/ /opt/hardening/
RUN /opt/hardening/harden-common.sh \
 && python3 -m pip install --no-cache-dir --upgrade pip==24.2 uv==0.4.27 \
 && python3 -m pip check

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

USER 1001
WORKDIR /app

ENTRYPOINT ["/opt/hardening/entrypoint.sh"]
CMD ["python3", "--version"]
