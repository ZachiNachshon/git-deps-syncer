---
layout: docs
title: Locations
description: Locations used by `git-deps-syncer` for config / repositories / symlinks / clone-path.
group: content
toc: true
aliases: "/docs/latest/configuration/"
---

## Locations

`git-deps-syncer` is using different paths on local disk for storing content. 

{{< bs-table >}}
| Name | Path |
| --- | --- |
| Config | `<PROJECT_ROOT_FOLDER>/.git-deps/config.json` |
| Repositories | `<PROJECT_ROOT_FOLDER>/.git-deps/external` |
| Symlinks | `<PROJECT_ROOT_FOLDER>/external` |
| Clone Path | `$HOME/.git-deps-cache` |
{{< /bs-table >}}

{{< callout info >}}
Type `git-deps-syncer config` to get a list of commonly used paths.
{{< /callout >}}
