<h3 align="center" id="git-deps-syncer-logo"><img src="docs-site/site/static/docs/latest/assets/brand/git-deps-syncer-readme.svg" height="300"></h3>

<p align="center">
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
  <a href="https://www.paypal.me/ZachiNachshon">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <a href="#requirements">Requirements</a> •
  <a href="#quickstart">QuickStart</a> •
  <a href="#overview">Overview</a> •
  <a href="#support">Support</a> •
  <a href="#license">License</a>
</p>
<br>

**git-deps-syncer** is a lightweight CLI tool used for syncing git repositories as external source dependencies into any working directory.

It offers a simple alternative to git `submodule` / `subtree` by allowing a drop-in-replacement of any git repository as an immutable source dependency that is part of the actual working repository source code, files are located and managed within a dedicated `external` folder using symlinks.

<br>

<h2 id="requirements">🏁 Requirements</h2>

- A Unix-like operating system: macOS, Linux
- `git` (recommended `v2.30.0` or higher)
- `jq` (for parsing JSON based config)
- gh` (**Optional:** GitHub client for opening PRs upon changes)

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
  - [Initial sync](#initial-sync)
- [Documentation](#documentation)

**Maintainers / Contributors:**

- [Contribute guides](https://zachinachshon.com/git-deps-syncer/docs/latest/getting-started/contribute/)

<br>

<h3 id="why-creating">💡 Why Creating <code>git-deps-syncer</code>?</h3>

Those are some of the requirements that lead me to implement a custom solution instead of using git `submodule` / `subtree`:

1. Merge any git repository into a working directory source code, treating it as external source dependency
1. Keep the external source dependencies immutable for changes
1. Having the external git repositories version controlled
1. Treat external git repositories as they were standard libraries imports
1. Having the ability to hot-swap git external dependencies easily with local paths for development

<br>

<h3 id="how-does-it-work">🔬 How Does It Work?</h3>

`git-deps-syncer` is a CLI utility that can be used globally on any directory, though it should mainly be used on a git repository directory. It relies on pre-configured list of git repositories, those are getting fetched and stored within the source code of the working repository within a dedicated unique folder, making them available via symlinks for hot-swap if nessesary. 

| :heavy_exclamation_mark: Note                                |
| :----------------------------------------------------------- |
| Every git repository is being cloned into a shared cache directory outside the working directory and its files and folders are being copied without the `git` index. |

<br>

<h4 id="initial-sync">Initial Sync</h4>

1. Change directory into a working repository you plan to add the git depdencies

1. Auto generate a `.git-deps/config.json` file by running:

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
   
1. Run `git-deps-syncer -h` for additional options

<br>

<h3 id="documentation">📖 Documentation</h3>

Please refer to the [documentation](https://zachinachshon.com/git-deps-syncer/docs/latest/getting-started/introduction/) for detailed explanation on how to configure and use `git-deps-syncer`.

<br>

<h2 id="support">Support</h2>

`git-deps-syncer` is an open source project that is currently self maintained in addition to my day job, you are welcome to show your appreciation by sending me cups of coffee using the the following link as it is a known fact that it is the fuel that drives software engineering ☕

<a href="https://www.buymeacoffee.com/ZachiNachshon" target="_blank"><img src="docs-site/site/static/docs/latest/assets/img/bmc-orig.svg" height="57" width="200" alt="Buy Me A Coffee"></a>

<br>

<h2 id="license">License</h2>

MIT

<br>
