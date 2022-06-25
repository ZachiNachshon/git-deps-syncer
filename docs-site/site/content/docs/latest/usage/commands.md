---
layout: docs
title: Commands
description: Available `git-deps-syncer` commands and flags
toc: true
group: repository
---

## Available Commands

The `sync` / `sync-all` commands prompts for user approval before execution, to auto-approve use the `-y` flag.

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `sync-all` | Sync external git dependencies based on revisions declared on **config.json** |
| `sync [name]` | Sync a specific external git dependency based on revisions declared on **config.json** |
| `show` | Print the external git dependencies from the JSON config file |
| `clear-all` | Remove all symlinks from external folder |
| `clear [name]` | Remove a specific symlink from external folder |
| `locations` | Print locations used for config/repositories/symlinks/clone-path |
| `init` | Create an empty **.git-deps** folder with a **config.json** template file |
| `update` | Update client to latest version |
| `version` | Print deps-syncer client versions |
{{< /bs-table >}}

## Flags

Available flags to control commands execution.

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `-h (--help)` | Show available actions and their description |
| `-v (--verbose)` | Output debug logs for deps-syncer client commands executions |
| `-s (--silent)` | Do not output logs for deps-syncer client commands executions |
| `-y` | Do not prompt for approval and accept everything |
| `--save-dev` | Sync **devDependencies** local symlinks as declared on **config.json** |
| `--open-github-pr` | Open a GitHub PR for git changes after running **sync-all** |
{{< /bs-table >}}

<br>

Example of a user prompt message upon `sync-all`:

<div class="col-lg-6">
   <img style="vertical-align: top;" src="/docs/latest/assets/img/sync-all-prompt-message.svg" width="800" >
</div>