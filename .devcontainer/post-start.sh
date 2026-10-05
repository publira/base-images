#!/usr/bin/env bash
# Prune unused images older than a week. dockerd may still be starting, so wait
# briefly and never fail the container start.

set -uo pipefail

deadline=$((SECONDS + 60))
until timeout 5 docker info >/dev/null 2>&1; do
  if ((SECONDS >= deadline)); then
    echo "dockerd is not ready; skipping the image prune" >&2
    exit 0
  fi
  sleep 2
done

docker image prune --all --force --filter "until=168h" || true
