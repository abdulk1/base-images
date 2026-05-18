#!/usr/bin/env bash
# Wraps the container CMD with tini (PID 1, signal forwarding, zombie reaping).
set -euo pipefail

if [[ -x /usr/bin/tini ]]; then
  exec /usr/bin/tini -g -- "$@"
elif [[ -x /sbin/tini ]]; then
  exec /sbin/tini -g -- "$@"
else
  exec "$@"
fi
