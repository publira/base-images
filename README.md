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
the image at `/usr/local/share/licenses/publira-base-images/`.

## Publishing

Pushing changes to `dev/` or the publishing workflow on `main`
publishes the `latest` tag to GitHub Container Registry. After the first
publication, configure the package visibility so that Publira repositories can
pull it.

To validate the image locally, run:

```sh
docker build --tag publira-base-images:test dev
```

Versions are declared as Dockerfile build arguments and maintained by Renovate.

## Development

This repository includes a lightweight Dev Container based on the standard
`devcontainers/base` Trixie image. It adds Docker-in-Docker without Moby so
contributors can build and test the images locally.
