# Base Images Agent Guide

## Language

Repository documentation, comments, commit messages, and pull request text are
written in English.

## Git and pull requests

- Commit subjects and pull request titles use English Conventional Commits
  (`type(scope): description`).
- AI-assisted commits include an `Assisted-by: <agent>:<model>` trailer. Never
  use an AI agent in a `Co-authored-by` trailer.
- Keep each commit focused and verify the changed image or configuration before
  committing.
- Pull request descriptions explain the motivation, the main changes, and the
  verification performed. Link issues only when the relationship is accurate.
- Pull request descriptions also end with the applicable `Assisted-by` trailer.

## Image conventions

- The Publira development image is defined in `dev/Dockerfile`. Add additional
  image directories under `dev/` only when their names distinguish a real
  separate image.
- Use a digest-pinned base image. Keep the readable tag before `@sha256:`.
- Keep version arguments in the three groups at the beginning of a Dockerfile:
  foundational languages and frameworks, CLI tools, and AI agent CLIs.
- Pin downloadable tool versions and retain their Renovate annotations.
- AI agent CLIs use their vendors' native installers, not npm packages.
- Claude Code is excluded from public images because its commercial terms do
  not grant an express redistribution permission. Do not add it without a
  written redistribution grant from Anthropic.
- Describe every redistributed tool in `<image>/third-party.json`. The build
  argument, license, and upstream source location live there, and
  `THIRD_PARTY_NOTICES.md` and the image copy are updated in the same change.
  `golangci-lint` is GPL-3.0: retain its license text, keep a precise
  Corresponding Source URL, and keep `correspondingSource` set so the
  publishing workflow mirrors its source beside the image.

## Development container

The repository's own Dev Container is intentionally lightweight. It uses the
Trixie `devcontainers/base` image and applies Docker-in-Docker with `moby`
disabled, because Moby does not support Trixie.

## Verification

After changing an image definition, run:

```sh
docker build --tag base-images-test dev
```

After changing `.devcontainer/`, validate the resolved configuration:

```sh
npx --yes @devcontainers/cli read-configuration --workspace-folder .
```

After changing an image, its third-party manifest, or the workflows, run the
supply-chain checks:

```sh
./scripts/check-renovate-coverage.sh
./scripts/check-third-party-notices.sh --verify-sources
./scripts/collect-corresponding-source.sh --output "$(mktemp -d)"
```

## Publishing

The publishing workflow builds every matrix entry as a multi-platform
(`linux/amd64`, `linux/arm64`) manifest. It publishes `latest`, a UTC date tag,
a date-and-run-number tag. Keep all of these tags and the per-image cache scope
when changing the workflow. Give each job only the permissions it needs.

Every image is published with per-platform SLSA provenance and SPDX SBOM
attestations, with GitHub build provenance for the merged manifest, and with
the Corresponding Source of its copyleft components under a matching
`-corresponding-source` package. Keep these outputs and their verification
steps when changing the workflow. A weekly schedule republishes every image
without the layer cache; that cache-free rebuild is what delivers upstream
operating-system updates, so keep it intact.
