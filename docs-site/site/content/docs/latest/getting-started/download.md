---
layout: docs
title: Download
description: Download `git-deps-syncer` executable.
group: getting-started
toc: true
---

## Package Managers

Pull in `git-deps-syncer`'s executable using popular package managers.

### Homebrew

The fastest way (for `macOS` and `Linux`) to install `git-deps-syncer` is using [Homebrew](https://brew.sh/):

```bash
brew install ZachiNachshon/tap/git-deps-syncer
```

Alternatively, tap into the formula to have brew search capabilities on that tap formulas:

1. Tap into `ZachiNachshon` formula

    ```bash
    brew tap ZachiNachshon/tap
    ```

1. Install the latest `git-deps-syncer` binary

    ```bash
    brew install git-deps-syncer
    ```

## Released Version

Download and install `git-deps-syncer` executable (copy & paste into a terminal):

```bash
curl -sfLS https://raw.githubusercontent.com/ZachiNachshon/git-deps-syncer/master/install.sh | bash -
```

Available installation flags:
{{< bs-table >}}
| Flag | Description |
| --- | --- |
| `VERSION` | Specify the released version to install |
| `DRY_RUN` | Run all commands in dry-run mode without file system changes |
{{< /bs-table >}}

Example:

```bash
curl -sfLS \
  https://raw.githubusercontent.com/ZachiNachshon/git-deps-syncer/master/install.sh | \
  DRY_RUN=True \
  VERSION=0.7.0 \
  bash -
```

Alternatively, you can download a release directy from GitHub

<a href="{{< param "download.dist" >}}" class="btn btn-bd-primary" onclick="ga('send', 'event', 'Getting started', 'Download', 'Download Git Deps Syncer');" target="_blank">Download Specific Release</a>

{{< callout warning >}}
## `PATH` awareness

Make sure `${HOME}/.local/bin` exists on the `PATH` or sourced on every new shell session.
{{< /callout >}}

## Pre-Built Release

Clone `git-deps-syncer` repository into a directory of your choice:

```bash
git clone https://github.com/ZachiNachshon/git-deps-syncer.git; cd git-deps-syncer
```

## Uninstall

Instruction to uninstall `git-deps-syncer` based on installation method.

**Homebrew**

```bash
brew remove git-deps-syncer
```

**Released Version**

```bash
curl -sfLS https://raw.githubusercontent.com/ZachiNachshon/git-deps-syncer/master/uninstall.sh | bash -
```

Available flags:
{{< bs-table >}}
| Flag | Description |
| --- | --- |
| `DRY_RUN` | Run all commands in dry-run mode without file system changes |
{{< /bs-table >}}

Example:

```bash
curl -sfLS \
  https://raw.githubusercontent.com/ZachiNachshon/git-deps-syncer/master/uninstall.sh | \
  DRY_RUN=True \
  bash -
```