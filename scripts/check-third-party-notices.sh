#!/usr/bin/env bash
# Verify that an image still documents the third-party software it ships.
#
# The manifest at <image>/third-party.json is the single source of truth for
# the directly redistributed tools. This script compares it with the build
# arguments in the Dockerfile and with the tables in THIRD_PARTY_NOTICES.md,
# so a version bump cannot land without the matching notice update.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: check-third-party-notices.sh [options]

Options:
  --image-directory DIR  Image directory to check (default: dev).
  --verify-sources       Also confirm every documented source location exists
                         upstream. Requires network access.
  -h, --help             Show this help.
USAGE
}

image_directory=dev
verify_sources=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --image-directory)
      image_directory="${2:?--image-directory requires a value}"
      shift 2
      ;;
    --verify-sources)
      verify_sources=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$(dirname "$0")/.."

manifest="${image_directory}/third-party.json"
dockerfile="${image_directory}/Dockerfile"
notices="${image_directory}/THIRD_PARTY_NOTICES.md"

for required in "$manifest" "$dockerfile" "$notices"; do
  if [ ! -f "$required" ]; then
    printf 'error: %s does not exist\n' "$required" >&2
    exit 1
  fi
done

failures=0

fail() {
  printf 'error: %s\n' "$*" >&2
  failures=$((failures + 1))
}

# Resolve every build argument the manifest refers to.
versions="$(
  jq -r '.[].buildArg' "$manifest" | while read -r build_arg; do
    value="$(sed -n "s/^ARG ${build_arg}=\\(.*\\)\$/\\1/p" "$dockerfile")"
    if [ "$(printf '%s' "$value" | grep -c .)" -ne 1 ]; then
      printf 'error: %s does not declare exactly one ARG %s\n' \
        "$dockerfile" "$build_arg" >&2
      exit 1
    fi
    jq -n --arg name "$build_arg" --arg value "$value" '{($name): $value}'
  done | jq -s 'add // {}'
)"

# Expand each manifest entry into the row it must produce in the notices.
components="$(
  jq --argjson versions "$versions" '
    map(
      . as $component
      | $versions[$component.buildArg] as $version
      | $component
      + {
          version: $version,
          source: (
            if $component.sourceTag == null then
              $component.sourceRepository
            else
              "\($component.sourceRepository)/tree/\($component.sourceTag | sub("\\{version\\}"; $version))"
            end
          ),
          tag: (
            if $component.sourceTag == null then
              null
            else
              ($component.sourceTag | sub("\\{version\\}"; $version))
            end
          )
        }
    )
  ' "$manifest"
)"

# Every versioned build argument must be documented, and every documented
# component must exist in the Dockerfile.
if ! diff --unified --label "$manifest" --label "$dockerfile" \
  <(jq -r '.[].buildArg' "$manifest" | sort) \
  <(sed -n 's/^ARG \([A-Za-z0-9_]*\)=.*/\1/p' "$dockerfile" | sort); then
  fail "the build arguments in $dockerfile and $manifest differ"
fi

notices_rows() {
  awk -v heading="## $1" '
    $0 == heading { inside = 1; next }
    /^## / { inside = 0 }
    inside && /^\| / && $0 !~ /^\| Component / && $0 !~ /^\| --- / { print }
  ' "$notices"
}

expected_rows() {
  jq -r --arg section "$1" '
    map(select(.section == $section))
    | .[]
    | "| \(.component) | \(.version) | \(.license) | <\(.source)> |"
  ' <<<"$components"
}

while read -r section; do
  if ! diff --unified --label "expected ($manifest)" --label "actual ($notices)" \
    <(expected_rows "$section") <(notices_rows "$section"); then
    fail "the \"$section\" table in $notices is out of date"
  fi
done < <(jq -r '[.[].section] | unique | .[]' "$manifest")

# Catch rows that live outside a documented section as well.
if ! diff --unified --label "expected ($manifest)" --label "actual ($notices)" \
  <(jq -r '.[] | "| \(.component) | \(.version) | \(.license) | <\(.source)> |"' <<<"$components" | sort) \
  <(awk '/^\| / && $0 !~ /^\| Component / && $0 !~ /^\| --- / { print }' "$notices" | sort); then
  fail "$notices documents components that $manifest does not describe"
fi

# The license text of every declared license has to ship inside the image.
while read -r license_id; do
  if ! grep --quiet --fixed-strings "${license_id}.txt" "$dockerfile"; then
    fail "$dockerfile does not install a ${license_id}.txt license text"
  fi
done < <(
  jq -r '.[].license | split(" ")[0] | sub("-only$"; "") | sub("-or-later$"; "")' \
    "$manifest" | sort --unique
)

for license_file in "${image_directory}"/licenses/*.txt; do
  [ -e "$license_file" ] || continue
  if ! grep --quiet --fixed-strings "licenses/$(basename "$license_file")" "$dockerfile"; then
    fail "$dockerfile does not copy $license_file into the image"
  fi
done

# The notices name the base image, which is pinned by digest in the Dockerfile.
base_image="$(sed -n 's|^FROM \([^@ ]*\)@.*|\1|p' "$dockerfile" | head -n 1)"
if [ -z "$base_image" ]; then
  fail "$dockerfile does not pin its base image by digest"
elif ! grep --quiet --fixed-strings "$base_image" "$notices"; then
  fail "$notices does not mention the base image $base_image"
fi

if [ "$verify_sources" = true ]; then
  while IFS=$'\t' read -r component repository tag; do
    if [ "$tag" = "null" ]; then
      if [ -z "$(git ls-remote "$repository" HEAD)" ]; then
        fail "the source repository for $component is unavailable: $repository"
      fi
    elif [ -z "$(git ls-remote --tags "$repository" "refs/tags/${tag}")" ]; then
      fail "the source location for $component is unavailable: ${repository} ${tag}"
    fi
  done < <(jq -r '.[] | [.component, .sourceRepository, (.tag // "null")] | @tsv' <<<"$components")
fi

if [ "$failures" -gt 0 ]; then
  printf '\n%s failed with %d error(s).\n' "$(basename "$0")" "$failures" >&2
  exit 1
fi

printf '%s: %s matches %s and %s.\n' \
  "$(basename "$0")" "$notices" "$manifest" "$dockerfile"
