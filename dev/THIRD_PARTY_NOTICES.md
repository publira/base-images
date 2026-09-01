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

## Base image and operating-system packages

- `mcr.microsoft.com/devcontainers/base:2-trixie` is built from
  [devcontainers/images](https://github.com/devcontainers/images) (MIT).
- Debian Trixie and the packages installed with `apt` are subject to their
  individual copyright and license notices under `/usr/share/doc`.

## Languages and frameworks

| Component | Version | License | Corresponding source |
| --- | --- | --- | --- |
| Go | 1.27.0 | BSD-3-Clause | <https://github.com/golang/go/tree/go1.27.0> |
| Flutter | 3.47.2 | BSD-3-Clause | <https://github.com/flutter/flutter/tree/3.47.2> |
| Node.js | 24.20.0 | MIT and third-party notices | <https://github.com/nodejs/node/tree/v24.20.0> |

## Command-line tools

| Component | Version | License | Corresponding source |
| --- | --- | --- | --- |
| Task | 3.53.1 | MIT | <https://github.com/go-task/task/tree/v3.53.1> |
| sqlc | 1.31.1 | MIT | <https://github.com/sqlc-dev/sqlc/tree/v1.31.1> |
| Buf | 1.72.0 | Apache-2.0 | <https://github.com/bufbuild/buf/tree/v1.72.0> |
| golang-migrate | 4.19.1 | MIT | <https://github.com/golang-migrate/migrate/tree/v4.19.1> |
| golangci-lint | 2.13.2 | GPL-3.0-only | <https://github.com/golangci/golangci-lint/tree/v2.13.2> |
| wait4x | 3.7.1 | Apache-2.0 | <https://github.com/wait4x/wait4x/tree/v3.7.1> |
| AWS CLI | 2.36.33 | Apache-2.0 and third-party notices | <https://github.com/aws/aws-cli/tree/2.36.33> |
| GitHub CLI | 2.97.0 | MIT | <https://github.com/cli/cli/tree/v2.97.0> |
| pnpm | 11.25.0 | MIT | <https://github.com/pnpm/pnpm/tree/v11.25.0> |

## AI agent CLIs

| Component | Version | License | Corresponding source |
| --- | --- | --- | --- |
| Codex | 0.150.1 | Apache-2.0 and third-party notices | <https://github.com/openai/codex/tree/rust-v0.150.1> |
| Grok Build | 1.0.13 | Apache-2.0 and third-party notices | <https://github.com/xai-org/grok-build> |

`golangci-lint` is distributed as an unmodified, separate GPL-3.0 program.
Its exact Corresponding Source is available at the versioned URL above at no
charge. The source must remain available on equivalent terms for as long as
this image version is offered.
