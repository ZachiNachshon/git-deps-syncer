<h3 id="logos" align="center">
  <div style="text-align: center; display: block;">
		<img src="assets/git.png" height="128">&nbsp;&nbsp;
  	<img src="assets/plus-small.png" height="48">&nbsp;&nbsp;&nbsp;
		<img src="assets/database.png" height="112">
  </div>
	<br><br>
	<p>Git Dependencies Syncer</p>
</h3>






<br>

<p align="center">
  <a href="#requirements">Requirements</a> •
  <a href="#quickstart">QuickStart</a> •
  <a href="#overview">Overview</a>
</p>
<br>

**git-deps-syncer** is a lightweight CLI tool used for synching git repositories as external source dependencies into any working directory.

It offers a simple alternative to git `submodule` / `subtree` by allowing a drop-in-replacement of any git repository as an immutable source dependency that is part of the actual working repository source code, files are located and managed within a dedicated `external` folder.

<br>

<h2 id="requirements">🏁 Requirements</h2>

- A Unix-like operating system: macOS, Linux
- `git` (recommended `v2.30.0` or higher)
- `jq` (for parsing JSON based config)
- `gh` (**Optional:** GitHub client for opening PRs upon changes)

<br>

<h2 id="quickstart">⚡️ Quick Start</h2>

The fastest way (for `macOS` and `Linux`) to install `git-deps-syncer` is using [Homebrew](https://brew.sh/):

```bash
brew install ZachiNachshon/tap/git-deps-syncer
```

Alternatively, tap into the formula to have brew search capabilities on that tap formulas:

```bash
# Tap
brew tap ZachiNachshon/tap

# Install
brew install git-deps-syncer
```

For additional installation methods [read here](docs/installation.md).

<br>

<h2 id="overview">🔍 Overview</h2>

- [Why creating `git-deps-syncer`?](#why-creating)
- [How does it work?](#how-does-it-work)
  - [Configuration](#config)
  - [Initial sync](#initial-sync)
  - [Dependencies structure](#deps-structure)
  - [Live demo](#live-demo)
- [Available commands](#commands)
- [Other installation methods](docs/installation.md)

**Maintainers / Contributors:**

- [Contribute guides](docs/contribute.md)

<br>

<h3 id="why-creating">💡 Why Creating <code>git-deps-syncer</code>?</h3>

These are some of the requirements I've had which lead me to implement a solution myself instead of using git `submodule` / `subtree`:

1. Merge any git repository into a working repository source code, treating it as external source dependency

1. Keep the external source dependencies immutable for changes

1. Having the external git repositories version controlled

1. Treat external git repositories as they were standard libraries imports

1. Having the ability to hot-swap git external dependencies easily with local paths for development

<br>

<h3 id="how-does-it-work">🔬 How Does It Work?</h3>

`git-deps-syncer` is a CLI utility that can be used globally on any directory, though it should mainly be used on a git repository directory. It relies on pre-configured list of git repositories intended for fetching and storing their source code into a dedicated unique folder, making them available via symlinks for hot-swap if nessesary. 

| :heavy_exclamation_mark: Note                                |
| :----------------------------------------------------------- |
| Every git repository is being cloned into a dedicated cache directory. Its files and folders are being copied flat without the `git` index. |

<br>

**Important locations:**

| **Item**          | **Location**                                                 |
| :------------------- | :----------------------------------------------------------- |
| Config file          | `<PROJECT_ROOT_FOLDER>/.git-deps/config.json`       |
| Repositories files | `<PROJECT_ROOT_FOLDER>/.git-deps/external/`       |
| Symlinks             | `<PROJECT_ROOT_FOLDER>/external/`                  |
| Repositories clone path | `${HOME}/.git-deps-cache/` |

<br>

<h4 id="config">Configuration</h4>

`git-deps-syncer` relies on a `config.json` file for defining which git repositories it should fetch and treat as external dependencies. The content of the file is as follows:

```json
{
  "dependencies": {
    "repos": [
      {
        "name": "REPOSITORY_NAME",
        "url": "https://github.com/<organization>/REPOSITORY_NAME.git",
        "branch": "master",
        "revision": "ab23fdr87..."
      }
    ]
  },
  "devDependencies": {
    "repos": [
      {
        "name": "REPOSITORY_NAME",
        "localPath": "/path/to/local/clone/of/REPOSITORY_NAME"
      }
    ]
  }
}
```

<br>

<h4 id="initial-sync">Initial Sync</h4>

1. Change directory to a destination directory you plan to add git depdencies to

1. Create a `.git-deps/config.json` file by running:

   ```bash
   git-deps-syncer init
   ```
   
1. Edit the `.git-deps/config.json` file with desired git dependencies 
1. Sync all git external dependencies into the working directory by running:

   ```
   git-deps-syncer sync-all
   ```
   
   | :bulb: Note |
   | :--------------------------------------- |
   | Add the flag `--open-github-pr` in order to automatically open a PR based on changes introduced by the `sync-all` action. |
   
   <br>

1. Run `git-deps-syncer -h` for additional options

<br>

<h4 id="deps-structure">Dependencies Structure</h4>

```
├── ...
├── .git-deps                    # Managed folder used by the git-deps-syncer CLI utility
│   └── external                 # Location of the external git repositories source code (no git index)
│       ├── dependency-1         # Source code for repository: git@github.com:<organization>/dependency-1.git
│       ├── dependency-2         # Source code for repository: git@github.com:<organization>/dependency-2.git
│       └── ... 
│   └── config.json              # Config file that defines which are the registered git repositories for this project
├── ...
├── external                     # Location of symlinks pointing to actual git external dependencies source code
│   ├── dependency-1 (symlink)   # Links to --> .git-deps/external/dependency-1
│   ├── dependency-2 (symlink)   # Links to --> .git-deps/external/dependency-2
│   └── ...
└── ...
```

<br>

<h4 id="live-demo">Live Demo</h4>

This is a live demo showcasing a `sync-all` action, fetching multiple git repositories as external dependencies.

<details><summary>Show</summary>
<img style="vertical-align: top;" src="assets/git.png" width="200" >
</details>
<br>

<h3 id="commands">Available Commands</h3>

Arguments:

| **Name**                                                     | **Description** |
| :----------------------------------------------------------- | :------- |
| `sync-all`                                                 | Sync external git dependencies based on revisions declared on `.git-deps/config.json` |
| `sync [name]`                                              | Sync a specific external git dependency based on revisions declared on `.git-deps/config.json` |
| `show`                                                  | Print the external git `dependencies` from the JSON config file |
| `clear-all`                                       | Remove all symlinks from external folder |
| `clear [name]`                                         | Remove a specific symlink from external folder |
| `locations`                                        | Print locations used for `config` / `repositories` / `symlinks` / `clone-path` |
| `init`                                               | create an empty .git-deps folder with a config.json template file |
| `update`                                               | Update client to latest version |
| `version`                                          | Print deps-syncer client versions |

Global Flags:

| **Name**           | **Type**                                                     |
| :----------------- | :----------------------------------------------------------- |
| `-h (--help)`      | Show available actions and their description                 |
| `-v (--verbose)`   | Output debug logs for deps-syncer client commands executions |
| `-s (--silent)`    | Do not output logs for deps-syncer client commands executions |
| `-y`               | Do not prompt for approval and accept everything             |
| `--save-dev`       | Sync devDependencies local symlinks as declared on .git-deps/config.json |
| `--open-github-pr` | Open a GitHub PR for git changes after running sync-all      |

<br>

<h2 id="support">Support</h2>

`git-deps-syncer` is an open source project that is currently self maintained in addition to my day job, you are welcome to show your appreciation by sending me cups of coffee using the the following link as it is a known fact that it is the fuel that drives software engineering ☕

<a href="https://www.buymeacoffee.com/ZachiNachshon" target="_blank"><img src="assets/bmc-orig.svg" height="57" width="200" alt="Buy Me A Coffee"></a>

<br>

<h2 id="licence">Licence</h2>

MIT

<br>
