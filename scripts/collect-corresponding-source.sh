#!/usr/bin/env bash
# Collect the Corresponding Source of the copyleft components an image
# redistributes.
#
# GPL-3.0 requires the exact source of the conveyed binaries to stay available
# for as long as the image is offered. Relying on the upstream repository alone
# would put that obligation in someone else's hands, so the publishing workflow
# stores the archives this script produces beside the image itself.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: collect-corresponding-source.sh --output DIR [options]

Options:
  --output DIR           Directory to write the archives and the index into.
  --image-directory DIR  Image directory to collect for (default: dev).
  --image-reference REF  Image reference the source corresponds to. May be
                         repeated; recorded in the index.
  -h, --help             Show this help.
USAGE
}

image_directory=dev
output=
image_references=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output)
      output="${2:?--output requires a value}"
      shift 2
      ;;
    --image-directory)
      image_directory="${2:?--image-directory requires a value}"
      shift 2
      ;;
    --image-reference)
      image_references+=("${2:?--image-reference requires a value}")
      shift 2
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

if [ -z "$output" ]; then
  printf 'error: --output is required\n' >&2
  usage >&2
  exit 2
fi

cd "$(dirname "$0")/.."

manifest="${image_directory}/third-party.json"
dockerfile="${image_directory}/Dockerfile"

mkdir -p "$output"
output="$(cd "$output" && pwd)"

index="${output}/CORRESPONDING_SOURCE.md"
{
  printf '# Corresponding Source\n\n'
  printf 'This archive set is the complete Corresponding Source of the copyleft\n'
  printf 'components redistributed in the %s image. Each archive is the\n' "$image_directory"
  printf 'unmodified upstream source of the exact version installed in the image, and\n'
  printf 'is offered under the license of the component it belongs to.\n\n'
  if [ "${#image_references[@]}" -gt 0 ]; then
    printf 'It corresponds to:\n\n'
    # shellcheck disable=SC2016 # The backticks are Markdown, not a subshell.
    printf -- '- `%s`\n' "${image_references[@]}"
    printf '\n'
  fi
  printf '| Component | Version | License | Upstream tag | Commit | Archive | SHA-256 |\n'
  printf '| --- | --- | --- | --- | --- | --- | --- |\n'
} > "$index"

collected=0

while IFS=$'\t' read -r component build_arg license repository tag_template; do
  version="$(sed -n "s/^ARG ${build_arg}=\\(.*\\)\$/\\1/p" "$dockerfile")"
  if [ -z "$version" ]; then
    printf 'error: %s does not declare ARG %s\n' "$dockerfile" "$build_arg" >&2
    exit 1
  fi

  tag="${tag_template//\{version\}/${version}}"
  refs="$(git ls-remote --tags "$repository" "refs/tags/${tag}" "refs/tags/${tag}^{}")"
  # An annotated tag resolves to the tag object, so prefer the peeled
  # reference, which names the commit the archive was made from.
  commit="$(awk -v ref="refs/tags/${tag}^{}" '$2 == ref { print $1 }' <<<"$refs")"
  if [ -z "$commit" ]; then
    commit="$(awk -v ref="refs/tags/${tag}" '$2 == ref { print $1 }' <<<"$refs")"
  fi
  if [ -z "$commit" ]; then
    printf 'error: %s has no tag %s\n' "$repository" "$tag" >&2
    exit 1
  fi

  archive="$(basename "$repository")-${version}.tar.gz"
  printf 'Downloading the Corresponding Source of %s %s\n' "$component" "$version"
  curl --fail --silent --show-error --location \
    --output "${output}/${archive}" \
    "${repository}/archive/refs/tags/${tag}.tar.gz"
  tar --list --file "${output}/${archive}" > /dev/null

  checksum="$(cd "$output" && sha256sum "$archive" | cut -d ' ' -f 1)"
  # shellcheck disable=SC2016 # The backticks are Markdown, not a subshell.
  printf '| %s | %s | %s | `%s` | `%s` | `%s` | `%s` |\n' \
    "$component" "$version" "$license" "$tag" "$commit" "$archive" "$checksum" >> "$index"
  collected=$((collected + 1))
done < <(
  jq -r '
    .[]
    | select(.correspondingSource)
    | [.component, .buildArg, .license, .sourceRepository, .sourceTag]
    | @tsv
  ' "$manifest"
)

if [ "$collected" -eq 0 ]; then
  printf 'error: %s declares no component that needs Corresponding Source\n' \
    "$manifest" >&2
  exit 1
fi

printf '\nCollected the Corresponding Source of %d component(s) into %s.\n' \
  "$collected" "$output"
