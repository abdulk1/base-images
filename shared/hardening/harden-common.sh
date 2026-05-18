#!/usr/bin/env bash
# Hardening steps applied on top of every Iron Bank base image.
# Runs as root during build; the image switches to UID 1001 afterward.
set -euo pipefail

# Patch what's installed. Iron Bank ships UBI-based images; dnf is available.
if command -v dnf >/dev/null 2>&1; then
  dnf -y upgrade --refresh
  dnf -y install ca-certificates tzdata tini
  dnf -y clean all
  rm -rf /var/cache/dnf /var/cache/yum
elif command -v microdnf >/dev/null 2>&1; then
  microdnf -y upgrade
  microdnf -y install ca-certificates tzdata tini
  microdnf -y clean all
  rm -rf /var/cache/yum
fi

update-ca-trust extract 2>/dev/null || true

# Strip setuid/setgid bits — defense in depth against local privesc.
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -exec chmod a-s {} + 2>/dev/null || true

# Remove package manager caches and docs to shrink image.
rm -rf /var/log/* /tmp/* /var/tmp/* /root/.cache

# Ensure /app exists and is writable by the runtime user.
install -d -o 1001 -g 0 -m 0775 /app

# Lock down /opt/hardening: world-readable, root-owned, executable.
chown -R root:0 /opt/hardening
chmod -R o-w /opt/hardening
chmod 0755 /opt/hardening/*.sh
