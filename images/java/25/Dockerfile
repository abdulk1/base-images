# syntax=docker/dockerfile:1.7
ARG IRONBANK_REGISTRY=registry1.dod.mil
ARG IRONBANK_REPO=ironbank/redhat/openjdk/openjdk25
ARG IRONBANK_TAG=25

FROM ${IRONBANK_REGISTRY}/${IRONBANK_REPO}:${IRONBANK_TAG}

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.title="platform-base-java25" \
      org.opencontainers.image.description="Hardened OpenJDK 25 base, derived from Iron Bank" \
      org.opencontainers.image.vendor="Platform Engineering" \
      org.opencontainers.image.base.name="${IRONBANK_REGISTRY}/${IRONBANK_REPO}:${IRONBANK_TAG}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}"

USER root

COPY shared/hardening/ /opt/hardening/
RUN /opt/hardening/harden-common.sh

# Container-aware JVM defaults — apps can override.
# UseContainerSupport is on by default in 25 but we set explicit memory ratios.
ENV JAVA_TOOL_OPTIONS="-XX:InitialRAMPercentage=50 -XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/urandom" \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Iron Bank openjdk images already create UID 1001 ('openjdk'); reuse it.
USER 1001
WORKDIR /app

ENTRYPOINT ["/opt/hardening/entrypoint.sh"]
CMD ["java", "-version"]
