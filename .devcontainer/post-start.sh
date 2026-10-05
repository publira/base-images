#!/usr/bin/env bash
# Prune old images from the inner Docker daemon on every start.
#
# Docker Engine never removes unused images, so the daemon's volumes would grow
# until the host disk fills. With the containerd image store, `until` compares
# against when the image was pulled or built here, not its upstream creation
# date. An image that any container uses, running or stopped, is always kept.
#
# The docker-in-docker feature starts dockerd in the background, so it may not
# answer yet. Wait for it for a bounded time and never fail the start.

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
