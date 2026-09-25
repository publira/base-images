# Third-Party Notices

This image is an aggregate of independently licensed software. This file
identifies the directly installed tools, their source locations, and their
applicable licenses. It does not replace the notices included by Debian
packages under `/usr/share/doc/<package>/copyright` or by the upstream tools.

The Apache-2.0, BSD-3-Clause, and GPL-3.0 license texts are installed beside
this file. The MIT license text is also installed beside this file. The
copyright notices for the directly redistributed MIT-licensed tools follow.

- Task: Copyright (c) 2016 Andrey Nering
- sqlc: Copyright (c) 2024 Riza, Inc.
- golang-migrate: Copyright (c) 2016 Matthias Kadenbach and Copyright (c) 2018
  Dale Hui
- GitHub CLI: Copyright (c) 2019 GitHub Inc.
- Node.js: Copyright Node.js contributors.
- pnpm: Copyright (c) 2015-2016 Rico Sta. Cruz and other contributors and
  Copyright (c) 2016-2026 Zoltan Kochan and other contributors
- actionlint: Copyright (c) 2021 rhysd

## Base image and operating-system packages

- `mcr.microsoft.com/devcontainers/base:2-trixie` is built from
  [devcontainers/images](https://github.com/devcontainers/images) (MIT).
- Debian Trixie and the packages installed with `apt` are subject to their
  individual copyright and license notices under `/usr/share/doc`.

## Languages and frameworks

| Component | Version | License | Corresponding source |
| --- | --- | --- | --- |
| Go | 1.27.0 | BSD-3-Clause | <https://github.com/golang/go/tree/go1.27.0> | <!-- renovate: datasource=golang-version depName=go -->
| Flutter | 3.47.5 | BSD-3-Clause | <https://github.com/flutter/flutter/tree/3.47.5> | <!-- renovate: datasource=flutter-version depName=flutter -->
| Node.js | 24.21.0 | MIT and third-party notices | <https://github.com/nodejs/node/tree/v24.21.0> | <!-- renovate: datasource=node-version depName=node -->

## Command-line tools

| Component | Version | License | Corresponding source |
| --- | --- | --- | --- |
| Task | 3.53.1 | MIT | <https://github.com/go-task/task/tree/v3.53.1> | <!-- renovate: datasource=github-releases depName=go-task/task versioning=semver-coerced -->
| sqlc | 1.31.1 | MIT | <https://github.com/sqlc-dev/sqlc/tree/v1.31.1> | <!-- renovate: datasource=github-releases depName=sqlc-dev/sqlc versioning=semver-coerced -->
| Buf | 1.73.0 | Apache-2.0 | <https://github.com/bufbuild/buf/tree/v1.73.0> | <!-- renovate: datasource=github-releases depName=bufbuild/buf versioning=semver-coerced -->
| golang-migrate | 4.20.1 | MIT | <https://github.com/golang-migrate/migrate/tree/v4.20.1> | <!-- renovate: datasource=github-releases depName=golang-migrate/migrate versioning=semver-coerced -->
| golangci-lint | 2.14.0 | GPL-3.0-only | <https://github.com/golangci/golangci-lint/tree/v2.14.0> | <!-- renovate: datasource=github-releases depName=golangci/golangci-lint versioning=semver-coerced -->
| ShellCheck | 0.11.0 | GPL-3.0-or-later | <https://github.com/koalaman/shellcheck/tree/v0.11.0> | <!-- renovate: datasource=github-releases depName=koalaman/shellcheck versioning=semver-coerced -->
| shfmt | 3.14.1 | BSD-3-Clause | <https://github.com/mvdan/sh/tree/v3.14.1> | <!-- renovate: datasource=github-releases depName=mvdan/sh versioning=semver-coerced -->
| actionlint | 1.7.12 | MIT | <https://github.com/rhysd/actionlint/tree/v1.7.12> | <!-- renovate: datasource=github-releases depName=rhysd/actionlint versioning=semver-coerced -->
| wait4x | 3.7.1 | Apache-2.0 | <https://github.com/wait4x/wait4x/tree/v3.7.1> | <!-- renovate: datasource=github-releases depName=wait4x/wait4x versioning=semver-coerced -->
| AWS CLI | 2.36.33 | Apache-2.0 and third-party notices | <https://github.com/aws/aws-cli/tree/2.36.33> | <!-- renovate: datasource=github-tags depName=aws/aws-cli versioning=semver-coerced -->
| GitHub CLI | 2.101.0 | MIT | <https://github.com/cli/cli/tree/v2.101.0> | <!-- renovate: datasource=github-releases depName=cli/cli versioning=semver-coerced -->
| pnpm | 12.5.1 | MIT | <https://github.com/pnpm/pnpm/tree/v12.5.1> | <!-- renovate: datasource=npm depName=pnpm -->

## AI agent CLIs

| Component | Version | License | Corresponding source |
| --- | --- | --- | --- |
| Codex | 0.155.1 | Apache-2.0 and third-party notices | <https://github.com/openai/codex/tree/rust-v0.155.1> | <!-- renovate: datasource=npm depName=@openai/codex -->
| Grok Build | 1.0.40 | Apache-2.0 and third-party notices | <https://github.com/xai-org/grok-build> | <!-- renovate: datasource=npm depName=@xai-official/grok -->

`golangci-lint` and ShellCheck are distributed as unmodified, separate GPL-3.0
programs. Their exact Corresponding Source is available at the versioned URLs
above at no charge. A copy of that source is also published beside the image as
`ghcr.io/publira/base-images/publira-dev-corresponding-source`, tagged exactly
like the image version it belongs to, so it remains available on equivalent
terms for as long as that image version is offered.
