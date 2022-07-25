---
layout: docs
title: Structure
description: Learn about the git dependencies structure
group: repository
toc: true
aliases: "/docs/latest/repository/"
---

## Overview

Dependencies sources are saved into `.git-deps/external` folder, references to those files are via symlinks from the `external` folder.

Example of such project layout:

```text
├── ...
├── .git-deps                       # Managed folder used by the git-deps-syncer CLI
│   ├── external                    # Location of the external git repositories source code (no git index)
│   │   ├── shell_scripts_lib       # Source code for repository: git@github.com:<organization>/shell_scripts_lib.git
│   │   ├── python_scripts_lib      # Source code for repository: git@github.com:<organization>/python_scripts_lib.git
│   │   └── ...       
│   └── config.json                 # Config file that defines which are the registered git repositories for this project
├── ...
├── <additional-files-and-folders>
├── ...
├── external                        # Location of symlinks pointing to actual git external dependencies source code
│   ├── shell_scripts_lib           # Links to --> .git-deps/external/shell_scripts_lib
│   └── python_scripts_lib          # Links to --> .git-deps/external/python_scripts_lib
├── ...
├── <additional-files-and-folders>
└── ...
```

## Examples

In order to **"import"** a git dependency into your source code, just refer to its sources using the `external` folder symlink in a relative path to the project content root folder.

### Shell script 

An example of invoking a `build.sh` script from a `makefile` (builds a `golang` project): 

```make
.PHONY: build
build: ## Build binary for current OS/Arch (destination: PWD)
  @sh -c "'./external/shell_scripts_lib/golang/build.sh' \
    'action: build' \
    'binary_name: my-project' \
    'dist_path: dist' \
    'go_files_path: ./cmd/my-project'"
```

### Python

An example of importing class types using the external symlink: 

```python
import typer
from loguru import logger
from tools.info.machine_info import MachineInfoArgs, MachineInfoCollaborators, MachineInfoRunner
from external.python_scripts_lib.cli.state import CliGlobalArgs
from external.python_scripts_lib.infra.context import Context
from external.python_scripts_lib.errors.cli_errors import CliApplicationException
```

