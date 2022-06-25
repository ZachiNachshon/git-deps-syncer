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

1. Download and install `git-deps-syncer` executable (copy & paste into a terminal):

```bash
bash <<'EOF'

# Change Version accordingly
VERSION=0.1.0

# Create a temporary folder
download_temp_path=$(mktemp -d ${TMPDIR:-/tmp}/git-deps-syncer-temp.XXXXXX)
cwd=$(pwd)
cd ${download_temp_path}

# Download & extract
echo -e "\nDownloading git-deps-syncer to temp directory...\n"
curl -SL "https://github.com/ZachiNachshon/git-deps-syncer/releases/download/v${VERSION}/git-deps-syncer.sh"

# Create a dest directory and move the binary
echo -e "\nMoving executable to ~/.local/bin"
mkdir -p ${HOME}/.local/bin; mv git-deps-syncer.sh ${HOME}/.local/bin

# Create a dest directory and move the binary
echo "Elevating exec permissions (might prompt for password)"
chmod +x ${HOME}/.local/bin/git-deps-syncer.sh

# Add this line to your *rc file (zshrc, bashrc etc..) to make git-deps-syncer available on new sessions
echo "Exporting ~/.local/bin (make sure to have it available on PATH)"
export PATH="${PATH}:${HOME}/.local/bin"

cd ${cwd}

# Cleanup
if [[ ! -z ${download_temp_path} && -d ${download_temp_path} && ${download_temp_path} == *"git-deps-syncer-temp"* ]]; then
  echo "Deleting temp directory"
  rm -rf ${download_temp_path}
fi

echo -e "\nDone (type 'git-deps-syncer' for help)\n"

EOF
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
