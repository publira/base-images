FROM mcr.microsoft.com/devcontainers/base:2-trixie@sha256:b8c3669fb4cc652621b3386517c40ab3e151e827de958d6fe75528798ffb5727

# Foundational languages and frameworks
# renovate: datasource=github-releases depName=golang/go versioning=semver-coerced
ARG GO_VERSION=1.27.0
# renovate: datasource=flutter-version depName=flutter
ARG FLUTTER_VERSION=3.47.2
# renovate: datasource=node-version depName=node
ARG NODE_VERSION=24.20.0

# CLI tools
# renovate: datasource=github-releases depName=go-task/task versioning=semver-coerced
ARG TASK_VERSION=3.53.1
# renovate: datasource=github-releases depName=sqlc-dev/sqlc versioning=semver-coerced
ARG SQLC_VERSION=1.31.1
# renovate: datasource=github-releases depName=bufbuild/buf versioning=semver-coerced
ARG BUF_VERSION=1.72.0
# renovate: datasource=github-releases depName=golang-migrate/migrate versioning=semver-coerced
ARG MIGRATE_VERSION=4.19.1
# renovate: datasource=github-releases depName=golangci/golangci-lint versioning=semver-coerced
ARG GOLANGCI_LINT_VERSION=2.13.2
# renovate: datasource=github-releases depName=wait4x/wait4x versioning=semver-coerced
ARG WAIT4X_VERSION=3.7.1
# renovate: datasource=github-releases depName=aws/aws-cli versioning=semver-coerced
ARG AWS_CLI_VERSION=2.36.33
# renovate: datasource=github-releases depName=cli/cli versioning=semver-coerced
ARG GITHUB_CLI_VERSION=2.99.0
# renovate: datasource=npm depName=pnpm
ARG PNPM_VERSION=11.25.0

# AI agent CLIs
# renovate: datasource=npm depName=@openai/codex
ARG CODEX_VERSION=0.151.0
# renovate: datasource=npm depName=@xai-official/grok
ARG GROK_VERSION=1.0.13

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install --no-install-recommends postgresql-client \
    clang cmake ninja-build pkg-config libgtk-3-dev libvips-dev unzip xz-utils

RUN set -eux; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
    amd64) go_arch="amd64" ;; \
    arm64) go_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch"; exit 1 ;; \
  esac; \
  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${go_arch}.tar.gz" \
    | tar -xz -C /usr/local; \
  ln -sf /usr/local/go/bin/go /usr/local/bin/go; \
  ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

RUN set -eux; \
  sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d v${TASK_VERSION}; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
    amd64) sqlc_arch="amd64"; buf_arch="x86_64"; migrate_arch="amd64" ;; \
    arm64) sqlc_arch="arm64"; buf_arch="aarch64"; migrate_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch"; exit 1 ;; \
  esac; \
  curl -fsSL "https://github.com/sqlc-dev/sqlc/releases/download/v${SQLC_VERSION}/sqlc_${SQLC_VERSION}_linux_${sqlc_arch}.tar.gz" \
    | tar -xz -C /tmp sqlc; \
  install -m 0755 /tmp/sqlc /usr/local/bin/sqlc; \
  rm -f /tmp/sqlc; \
  curl -fsSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-${buf_arch}.tar.gz" \
    | tar -xz -C /tmp buf/bin/buf; \
  install -m 0755 /tmp/buf/bin/buf /usr/local/bin/buf; \
  rm -rf /tmp/buf; \
  curl -fsSL "https://github.com/golang-migrate/migrate/releases/download/v${MIGRATE_VERSION}/migrate.linux-${migrate_arch}.tar.gz" -o /tmp/migrate.tgz; \
  tar -xzf /tmp/migrate.tgz -C /tmp migrate; \
  install -m 0755 /tmp/migrate /usr/local/bin/migrate; \
  rm -f /tmp/migrate /tmp/migrate.tgz; \
  golangci_lint_dir="golangci-lint-${GOLANGCI_LINT_VERSION}-linux-${arch}"; \
  curl -fsSL "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/${golangci_lint_dir}.tar.gz" \
    | tar -xz -C /tmp "${golangci_lint_dir}/golangci-lint"; \
  install -m 0755 "/tmp/${golangci_lint_dir}/golangci-lint" /usr/local/bin/golangci-lint; \
  rm -rf "/tmp/${golangci_lint_dir}"; \
  wait4x_archive="wait4x-linux-${arch}.tar.gz"; \
  curl -fsSL "https://github.com/wait4x/wait4x/releases/download/v${WAIT4X_VERSION}/${wait4x_archive}" \
    -o "/tmp/${wait4x_archive}"; \
  curl -fsSL "https://github.com/wait4x/wait4x/releases/download/v${WAIT4X_VERSION}/${wait4x_archive}.sha256sum" \
    -o "/tmp/${wait4x_archive}.sha256sum"; \
  (cd /tmp && sha256sum -c "${wait4x_archive}.sha256sum"); \
  tar -xzf "/tmp/${wait4x_archive}" -C /tmp wait4x; \
  install -m 0755 /tmp/wait4x /usr/local/bin/wait4x; \
  rm -f "/tmp/${wait4x_archive}" "/tmp/${wait4x_archive}.sha256sum" /tmp/wait4x

# Install Flutter from its version tag rather than the x64-only SDK archive.
# The Flutter tool downloads the architecture-specific Dart SDK when precached.
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH="/usr/local/go/bin:${FLUTTER_HOME}/bin:${PATH}"
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_HOME}" \
 && git -C "${FLUTTER_HOME}" switch -c stable

RUN set -eux; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
    amd64) node_arch="x64"; aws_arch="x86_64"; gh_arch="amd64" ;; \
    arm64) node_arch="arm64"; aws_arch="aarch64"; gh_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch"; exit 1 ;; \
  esac; \
  curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local; \
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}-${AWS_CLI_VERSION}.zip" \
    -o /tmp/awscliv2.zip; \
  unzip -q /tmp/awscliv2.zip -d /tmp; \
  /tmp/aws/install; \
  rm -rf /tmp/aws /tmp/awscliv2.zip; \
  curl -fsSL "https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_${gh_arch}.tar.gz" \
    | tar -xz -C /tmp; \
  install -m 0755 "/tmp/gh_${GITHUB_CLI_VERSION}_linux_${gh_arch}/bin/gh" /usr/local/bin/gh; \
  rm -rf "/tmp/gh_${GITHUB_CLI_VERSION}_linux_${gh_arch}"; \
  aws --version; \
  gh --version; \
  node --version; \
  go version

# pnpm is installed with its own POSIX installer rather than through Corepack
# or npm, so the pinned version is present without a network round trip on
# first use. For pnpm 11 the installer downloads the release archive from
# GitHub over HTTPS, the same trust boundary as the other tools above. pnpm
# still honours a repository's own "packageManager" field and fetches that
# version into PNPM_HOME when it differs, so PNPM_HOME belongs to the
# container user.
ENV PNPM_HOME=/usr/local/share/pnpm
ENV PATH="${PNPM_HOME}/bin:${PATH}"
RUN set -eux -o pipefail; \
  curl -fsSL https://get.pnpm.io/install.sh \
    | env PNPM_VERSION="${PNPM_VERSION}" \
      PNPM_HOME="${PNPM_HOME}" \
      SHELL="$(command -v sh)" \
      ENV=/tmp/pnpm-setup-shrc \
      sh -; \
  rm -f /tmp/pnpm-setup-shrc; \
  chown -R vscode:vscode "${PNPM_HOME}"; \
  ln -sf "${PNPM_HOME}/bin/pnpm" /usr/local/bin/pnpm; \
  ln -sf "${PNPM_HOME}/bin/pnpx" /usr/local/bin/pnpx; \
  installed_pnpm_version="$(pnpm --version)"; \
  test "${installed_pnpm_version}" = "${PNPM_VERSION}"

RUN set -eux; \
  install -d -m 0755 /usr/local/share/codex /usr/local/share/grok; \
  curl -fsSL https://chatgpt.com/codex/install.sh \
    | CODEX_HOME=/usr/local/share/codex \
      CODEX_INSTALL_DIR=/usr/local/bin \
      CODEX_NON_INTERACTIVE=true \
      CODEX_RELEASE="${CODEX_VERSION}" \
      sh; \
  curl -fsSL https://x.ai/cli/install.sh \
    | HOME=/usr/local/share/grok \
      GROK_BIN_DIR=/usr/local/bin \
      bash -s "${GROK_VERSION}"; \
  codex --version; \
  grok --version

RUN flutter precache \
 && flutter --disable-analytics \
 && dart --disable-analytics \
 && chown -R vscode:vscode "${FLUTTER_HOME}" \
 && ln -sf "${FLUTTER_HOME}/bin/flutter" /usr/local/bin/flutter \
 && ln -sf "${FLUTTER_HOME}/bin/dart" /usr/local/bin/dart

RUN install -d -m 0755 /usr/local/share/licenses/publira-base-images \
 && install -m 0644 /usr/share/common-licenses/Apache-2.0 \
    /usr/local/share/licenses/publira-base-images/Apache-2.0.txt \
 && install -m 0644 /usr/share/common-licenses/BSD \
    /usr/local/share/licenses/publira-base-images/BSD-3-Clause.txt \
 && install -m 0644 /usr/share/common-licenses/GPL-3 \
    /usr/local/share/licenses/publira-base-images/GPL-3.0.txt

COPY THIRD_PARTY_NOTICES.md /usr/local/share/licenses/publira-base-images/THIRD_PARTY_NOTICES.md
COPY licenses/MIT.txt /usr/local/share/licenses/publira-base-images/MIT.txt

USER vscode
