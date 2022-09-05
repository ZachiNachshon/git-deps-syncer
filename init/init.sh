#!/bin/bash

# Title         Initialize git-deps-syncer on working repository/folder path
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Create a fresh directory structure for git-deps-syncer
#==============================================================================
INIT_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
INIT_ROOT_FOLDER_ABS_PATH=$(dirname "${INIT_CURRENT_FOLDER_ABS_PATH}")

source "${INIT_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${INIT_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${INIT_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"

get_config_template_json() {
  echo -e '{
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
}'
}

run_init_command() {
  local git_deps_folder_path=$1
  local external_repos_json_path=$2

  if ! is_directory_exist "${git_deps_folder_path}"; then
    log_info "Creating a managed folder. path: ${git_deps_folder_path}"
    cmd_run "mkdir -p ${git_deps_folder_path}"
  else
    log_warning "Identified a managed folder. path: ${git_deps_folder_path}"
  fi

  if ! is_file_exist "${external_repos_json_path}"; then
    log_info "Creating a git-deps template. path: ${external_repos_json_path}"
    cmd_run "cat > ${external_repos_json_path} << EOF
$(get_config_template_json)
EOF"
    log_info "To list all declared git external dependencies run: git-deps-syncer show"
  else
    log_warning "Found an existing git-deps config file. path: ${external_repos_json_path}"
  fi
}
