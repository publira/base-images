#!/usr/bin/env bash
# Verify that every version this repository pins is one Renovate can update.
#
# Renovate only proposes updates for dependencies it detects, so an argument
# without an annotation, an unpinned base image, or a floating action would
# silently stop receiving updates.

set -euo pipefail

cd "$(dirname "$0")/.."

failures=0

fail() {
  printf 'error: %s\n' "$*" >&2
  failures=$((failures + 1))
}

# Every version argument needs the annotation that drives Renovate's custom
# Dockerfile manager, and every base image needs a digest.
while IFS= read -r dockerfile; do
  awk -v dockerfile="$dockerfile" '
    BEGIN { missing = 0 }
    /^ARG [A-Za-z0-9_]+=/ && previous !~ /^# renovate: / {
      printf "%s:%d: %s\n", dockerfile, FNR, $0
      missing = 1
    }
    { previous = $0 }
    END { exit missing }
  ' "$dockerfile" || fail "$dockerfile declares build arguments without a \"# renovate:\" annotation"

  while IFS= read -r from_line; do
    case "$from_line" in
      *@sha256:*) ;;
      *) fail "$dockerfile does not pin a base image by digest: $from_line" ;;
    esac
  done < <(grep '^FROM ' "$dockerfile")
done < <(find . -name Dockerfile -not -path './.git/*' | sort)

# The Dev Container image is pinned the same way.
if ! grep --quiet '"image": *"[^"]*@sha256:[0-9a-f]\{64\}"' .devcontainer/devcontainer.json; then
  fail ".devcontainer/devcontainer.json does not pin its image by digest"
fi

# Workflow actions are pinned to a commit with the readable version beside it,
# which is what "config:best-practices" expects in order to update them.
while IFS= read -r workflow; do
  while IFS= read -r uses_line; do
    if ! printf '%s\n' "$uses_line" \
      | grep --quiet --extended-regexp 'uses: [^@]+@[0-9a-f]{40} # v?[0-9]+'; then
      fail "$workflow does not pin an action to a commit with a version comment:${uses_line#*uses:}"
    fi
  done < <(grep --extended-regexp '^\s*uses: [^.]' "$workflow")
done < <(find .github/workflows -name '*.yml' | sort)

if [ "$failures" -gt 0 ]; then
  printf '\n%s failed with %d error(s).\n' "$(basename "$0")" "$failures" >&2
  exit 1
fi

printf '%s: every pinned version is covered by Renovate.\n' "$(basename "$0")"
