# Publira base images

Prebuilt development images shared by Publira repositories. GitHub Actions
publishes `ghcr.io/publira/base-images/publira-dev:latest`.

This project is licensed under the [Apache License 2.0](LICENSE).

## Contents

- Go development environment, Flutter SDK, PostgreSQL client, and the Go CLIs
  used by the project
- Node.js with a preinstalled pnpm, AWS CLI, GitHub CLI, Codex, and Grok Build

Every tool is installed directly by
[`dev/Dockerfile`](dev/Dockerfile). The image can be consumed
by setting it as a Dev Container `image`.

## Claude Code

Claude Code is deliberately not included. Anthropic distributes it under
commercial terms and does not provide an express permission to redistribute
the CLI in this public image. Install it separately with Anthropic's official
native installer in the consuming Dev Container.

## Third-party software

License notices and source locations are available in
[`dev/THIRD_PARTY_NOTICES.md`](dev/THIRD_PARTY_NOTICES.md) and are included in
the image at `/usr/local/share/licenses/publira-base-images/`. They are checked
against [`dev/third-party.json`](dev/third-party.json), which records the build
argument, license, and upstream source location of every redistributed tool.

The Corresponding Source of the redistributed GPL-3.0 components is published
beside each image and shares its tags, so it stays available for as long as the
matching image:

```sh
oras pull ghcr.io/publira/base-images/publira-dev-corresponding-source:latest
```

## Supply chain

Each published image carries a SLSA provenance attestation and an SPDX SBOM per
platform, and the publishing workflow fails if either is missing from the
manifest it just pushed:

```sh
docker buildx imagetools inspect \
  --format '{{ json .SBOM }}' \
  ghcr.io/publira/base-images/publira-dev:latest
```

The published manifest is additionally attested by GitHub, which binds it to
the workflow run that produced it:

```sh
gh attestation verify \
  oci://ghcr.io/publira/base-images/publira-dev:latest \
  --repo publira/base-images
```

Every pull request runs [`.github/workflows/verify.yml`](.github/workflows/verify.yml),
which checks the metadata those guarantees depend on:

- [`scripts/check-renovate-coverage.sh`](scripts/check-renovate-coverage.sh)
  confirms that every version argument carries a Renovate annotation, that base
  images are pinned by digest, and that workflow actions are pinned to a commit.
- [`scripts/check-third-party-notices.sh`](scripts/check-third-party-notices.sh)
  confirms that the notices describe exactly the tools and versions the image
  installs, that the license texts ship inside the image, and that every
  documented source location still exists upstream.
- [`scripts/collect-corresponding-source.sh`](scripts/collect-corresponding-source.sh)
  downloads the Corresponding Source archives that the publishing workflow
  stores next to the image.

## Publishing

Pushing changes to `dev/`, `scripts/`, or the publishing workflow on `main`
publishes the `latest` tag to GitHub Container Registry. A weekly scheduled run
rebuilds and republishes every image without the layer cache, so images keep
picking up operating-system and upstream tool updates even when this repository
has no source change. The same cache-free rebuild can be requested manually
when running the workflow. After the first publication, configure the package
visibility so that Publira repositories can pull it.

To validate the image locally, run:

```sh
docker build --tag publira-base-images:test dev
```

Versions are declared as Dockerfile build arguments and maintained by Renovate.

## Development

This repository includes a lightweight Dev Container based on the standard
`devcontainers/base` Trixie image. It adds Docker-in-Docker without Moby so
contributors can build and test the images locally.
