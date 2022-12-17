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
| `config` | Print config / paths / symlinks / clone-path |
| `init` | Create an empty **.git-deps** folder with a **config.json** template file |
| `version` | Print deps-syncer client versions |
{{< /bs-table >}}

## Flags

Available flags to control commands execution.

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `--save-dev` | Sync **devDependencies** local symlinks as declared on **config.json** |
| `--skip-symlinks` | Skip symlinks and sync sources directly to the external folder |
| `--open-github-pr` | Open a GitHub PR for git changes after running **sync-all** |
| `--dry-run` | Run all commands in dry-run mode **without file system changes** 
| `-y` | Do not prompt for approval and accept everything |
| `-h (--help)` | Show available actions and their description |
| `-v (--verbose)` | Output debug logs for deps-syncer client commands executions |
| `-s (--silent)` | Do not output logs for deps-syncer client commands executions |
{{< /bs-table >}}
