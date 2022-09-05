---
layout: docs
title: Configuration
description: Set up git dependencies and manage their versioned sources.
group: content
toc: true
aliases: "/docs/latest/configuration/"
---

## Dependencies

`git-deps-syncer` is a CLI utility that can be used globally on any directory, though it should mainly be used on a git repository directory. 

It relies on pre-configured list of git repositories, those repositories source code ***without the `.git` index*** are being synced and stored within the working repository in a dedicated unique folder, making it available via symlinks for hot-swap if nessesary.

## The `config.json` file

This file contains the synced git dependencies information such as url / branch / commit-hash, check the [locations](/docs/{{< param docs_version >}}/configuration/locations/) section for the configuration file location.

```json
{
  "dependencies": {
    "repos": [
      {
         "name": "shell_scripts_lib",
         "url": "https://github.com/Organization/shell-scripts-lib.git",
         "branch": "master",
         "revision": "ab12cd...",
         "includes": ["golang*/"],
         "excludes": ["*_tests*"]
      }
    ]
  }
}
```

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `name` | name of the dependency which reflects on the folder / symlink names |
| `url` | url of the git repository |
| `branch` | branch of the git repository |
| `revision` | revision of the git repository branch |
| `includes` | [rsync](https://linux.die.net/man/1/rsync)'s supported `--include` patterns |
| `excludes` | [rsync](https://linux.die.net/man/1/rsync)'s supported `--exclude` patterns |
{{< /bs-table >}}

{{< callout info >}}
By default the following files / folders are being excluded from the sync action of all git repositories:<br>
`.git`, `.idea`, `.git-deps`, `external`, `.gitignore`, `.DS_Store`
{{< /callout >}}

### Dev dependencies

Hot-swapping is available for synced git dependency with a locally hosted one. It is useful to verify special cases, hot-fixes and such, ***mainly used for local development***.

When adding a git dependency under `devDependencies`, it syncs in conjunction with the rest of the git repositories declared under `dependencies`, it overrides only the same named git dependency from `dependencies`.

- Sync **a specific repository** as dev-dependency using the `--save-dev` flag:

   ```bash
   git-deps-syncer sync shell_scripts_lib --save-dev
   ```

- Sync **all repositories** using the `--save-dev` flag, `devDependencies` deps takes precedence:

   ```bash
   git-deps-syncer sync-all --save-dev
   ```

In the example below:
 - `python_scripts_lib` will be synced from remote git repository
 - `shell_scripts_lib` will be synced from the locally cloned repository

```json
{
  "dependencies": {
    "repos": [
      {
         "name": "shell_scripts_lib",
         "url": "https://github.com/Organization/shell-scripts-lib.git",
         "branch": "master",
         "revision": "ab12cd...",
      },
      {
         "name": "python_scripts_lib",
         "url": "https://github.com/Organization/python-scripts-lib.git",
         "branch": "master",
         "revision": "cd21ab...",
      }
    ]
  },
  "devDependencies": {
    "repos": [
      {
        "name": "shell_scripts_lib",
        "localPath": "/local/path/to/shell-scripts-lib"
      }
    ]
  }
}
```

## Initial sync

Follow these steps for a quick setup of 3rd party git dependencies:

1. Change directory into a working repository you plan to add the git dependencies

1. Auto generate a `.git-deps/config.json` file by running:

   ```bash
   git-deps-syncer init
   ```
   
1. Edit the `.git-deps/config.json` file with desired git dependencies 
1. Sync all git external dependencies into the working directory by running:

   ```bash
   git-deps-syncer sync-all
   ```

   {{< callout info >}}
   Add the flag `--open-github-pr` in order to automatically open a PR based on changes introduced by the `sync-all` action.
   {{< /callout >}}
   
1. For additional options run `git-deps-syncer -h` 