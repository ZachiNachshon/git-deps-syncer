#!/bin/bash

# Title         Clean external git dependencies
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Remove and unlink external git dependencies folder
#==============================================================================
CLEANER_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
CLEANER_ROOT_FOLDER_ABS_PATH=$(dirname "${CLEANER_CURRENT_FOLDER_ABS_PATH}")

source "${CLEANER_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${CLEANER_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"

clear_external_dependency_symlink() {
  local external_dep_symlink_path=$1
  remove_repository_symlink "${external_dep_symlink_path}"
}

clear_external_folder_symlinks() {
  local external_symlinks_folder_path=$1
  for dep_abs_path in "${external_symlinks_folder_path}"/*; do
    # If directory is empty there is an empty iteration on a stale path, skip that
    if [[ "${dep_abs_path}" != "${external_symlinks_folder_path}/*" ]]; then
      remove_repository_symlink "${dep_abs_path}"
    fi
  done

  log_info "Removed all external git repositories symlinks"
}

print_stale_dependency_cleanup_title() {
  if ! is_dev_dependencies; then
    new_line
    log_info "${COLOR_GREEN}${dev_indicator}Removing stale dependencies...${COLOR_NONE}"
  fi
}

print_stale_symlinks_cleanup_title() {
  if ! is_dev_dependencies; then
    new_line
    log_info "${COLOR_GREEN}${dev_indicator}Removing stale symlinks...${COLOR_NONE}"
  fi
}

remove_repository_symlink() {
  local dep_abs_path=$1
  local is_removal_success=""
  local name=""

  # Unlink only if file is a symbolic link to a directory
  if is_symlink "${dep_abs_path}"; then
    name=$(basename "${dep_abs_path}")
    log_info "Unlinking git repository. name: ${name}"
    remove_symlink "${dep_abs_path}"
    is_removal_success="true"
  fi

  if [[ -z "${is_removal_success}" ]]; then
    log_warning "Invalid symlink path, cannot clear. path: ${dep_abs_path}"
  fi
}
