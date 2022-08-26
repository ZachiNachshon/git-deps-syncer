#!/bin/bash

# Title         Git Deps Syncer (https://github.com/ZachiNachshon/git-deps-syncer)
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Lightweight CLI tool used for syncing git repositories as
#               external source dependencies into any working directory.
#==============================================================================
CONFIG_FOLDER_PATH="${HOME}/.config"
GIT_DEPS_SYNCER_CLI_INSTALL_PATH=${GIT_DEPS_SYNCER_CLI_INSTALL_PATH:-"${CONFIG_FOLDER_PATH}/git-deps-syncer"}

GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH=$(dirname "$(readlink "${BASH_SOURCE[0]}")")

# Path resolution to support Homebrew installation.
# Homebrew is using multiple symlinks chains:
# /usr/local/bin/git-deps-syncer
#   ../Cellar/git-deps-syncer/0.x.0/bin/git-deps-syncer
#     ../Cellar/git-deps-syncer/0.x.0/bin
#       /usr/local/Cellar/git-deps-syncer/0.x.0/libexec
if [[ -n "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}" ]]; then
  if [[ "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}" == *Cellar* ]]; then
    if [[ "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}" == *bin ]]; then
      GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH="${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH/bin/libexec}"
    fi
    GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH="${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH/..\/Cellar//usr/local/Cellar}"
    GIT_DEPS_SYNCER_CLI_INSTALL_PATH="${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}"
  fi
fi

source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/init/init.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/syncer/syncer.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/cleaner/cleaner.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/checks.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/prompter.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/shell.sh"
source "${GIT_DEPS_SYNCER_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/os.sh"

GIT_DEPS_MANAGED_FOLDER=".git-deps"
GIT_DEPS_CONFIG_FILENAME="config.json"
EXTERNAL_REPOS_JSON_PATH="${GIT_DEPS_MANAGED_FOLDER}/${GIT_DEPS_CONFIG_FILENAME}"
EXTERNAL_REPOS_JSON_PATH="${GIT_DEPS_MANAGED_FOLDER}/${GIT_DEPS_CONFIG_FILENAME}"
EXTERNAL_FOLDER_FROM_GIT_DEPS="${GIT_DEPS_MANAGED_FOLDER}/external"
EXTERNAL_FOLDER_FROM_CONTENT_ROOT="external"
CACHED_REPO_CLONE_ROOT="${HOME}/.git-deps-syncer-cache"

SCRIPT_NAME="Git External Deps Syncer"

CLI_ARGUMENT_SYNC_ALL_DEPS=""
CLI_ARGUMENT_SYNC_DEP=""
CLI_ARGUMENT_SHOW_DEPS=""
CLI_ARGUMENT_CLEAR_ALL_DEPS=""
CLI_ARGUMENT_CLEAR_DEP=""
CLI_ARGUMENT_CONFIG=""
CLI_ARGUMENT_INIT=""
CLI_ARGUMENT_VERSION=""

CLI_OPTION_DEPS_TYPE="" # default is --save-prod
CLI_OPTION_OPEN_GITHUB_PR=""

CLI_VALUE_SYNC_DEP_NAME=""
CLI_VALUE_CLEAR_DEP_NAME=""

is_print_version() {
  [[ -n ${CLI_ARGUMENT_VERSION} ]]
}

is_print_config() {
  [[ -n ${CLI_ARGUMENT_CONFIG} ]]
}

is_init() {
  [[ -n ${CLI_ARGUMENT_INIT} ]]
}

is_show_deps() {
  [[ -n ${CLI_ARGUMENT_SHOW_DEPS} ]]
}

is_sync_all_deps() {
  [[ -n ${CLI_ARGUMENT_SYNC_ALL_DEPS} ]]
}

is_sync_dep() {
  [[ -n ${CLI_ARGUMENT_SYNC_DEP} ]]
}

is_clear_all_deps() {
  [[ -n ${CLI_ARGUMENT_CLEAR_ALL_DEPS} ]]
}

is_clear_dep() {
  [[ -n ${CLI_ARGUMENT_CLEAR_DEP} ]]
}

should_open_github_pr() {
  [[ -n ${CLI_OPTION_OPEN_GITHUB_PR} ]]
}

is_dev_dependencies() {
  [[ "${CLI_OPTION_DEPS_TYPE}" == "save-dev" ]]
}

get_cached_repo_clone_path() {
  local repo_name=$1
  echo "${CACHED_REPO_CLONE_ROOT}/${repo_name}"
}

get_external_folder_from_git_deps() {
  echo "${EXTERNAL_FOLDER_FROM_GIT_DEPS}"
}

get_dep_path_from_git_deps() {
  local dep_name=$1
  echo "${EXTERNAL_FOLDER_FROM_GIT_DEPS}/${dep_name}"
}

get_external_folder_from_content_root() {
  echo "${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}"
}

get_external_dep_symlink_from_content_root() {
  local dep_name=$1
  echo "${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}/${dep_name}"
}

get_config_path_from_content_root() {
  echo "${EXTERNAL_REPOS_JSON_PATH}"
}

open_github_pr() {
#  local short_revision=$(echo ${revision} | cut -c 1-7)

  if should_open_github_pr && ! is_dev_dependencies; then
#    local external_folder_path=$(get_external_folder_from_content_root)
#    log_info "Creating a PR from dependency vector update. name: ${dep_name}_${short_revision}"
#    git add "${external_folder_path}" --all

#    local external_folder_symlink_path=$(get_external_folder_from_content_root)
#    git add "${external_folder_symlink_path}" --all

    # Create branch
    # Open PR using GH cli
    # TODO: implement
    log_warning "Open GitHub PR: Not yet implemented..."
  fi
}

print_help_menu_and_exit() {
  local exec_filename=$1
  echo -e " "
  echo -e "${SCRIPT_NAME} - Syncs git repos as external source dependencies into a working repository"
  echo -e " "
  echo -e "${COLOR_WHITE}USAGE${COLOR_NONE}"
  echo -e "  $(basename "${exec_filename}") [command] [flag]"
  echo -e " "
  echo -e "${COLOR_WHITE}AVAILABLE COMMANDS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}sync-all${COLOR_NONE}                  Sync external git dependencies based on revisions declared on ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}sync${COLOR_NONE} <name>               Sync a specific external git dependency based on revisions declared on ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}show${COLOR_NONE}                      Print the external git dependencies from the JSON config file"
  echo -e "  ${COLOR_LIGHT_CYAN}clear-all${COLOR_NONE}                 Remove all symlinks from external folder"
  echo -e "  ${COLOR_LIGHT_CYAN}clear${COLOR_NONE} <name>              Remove a specific symlink from external folder"
  echo -e "  ${COLOR_LIGHT_CYAN}config${COLOR_NONE}                    Print config/paths/symlinks/clone-path"
  echo -e "  ${COLOR_LIGHT_CYAN}init${COLOR_NONE}                      Create an empty ${COLOR_GREEN}${GIT_DEPS_MANAGED_FOLDER}${COLOR_NONE} folder with a ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE} template file"
  echo -e "  ${COLOR_LIGHT_CYAN}version${COLOR_NONE}                   Print deps-syncer client versions"
  echo -e " "
  echo -e "${COLOR_WHITE}FLAGS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}--save-dev${COLOR_NONE}                Sync ${COLOR_GREEN}devDependencies${COLOR_NONE} local symlinks as declared on ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}--open-github-pr${COLOR_NONE}          Open a GitHub PR for git changes after running ${COLOR_GREEN}sync-all${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}--dry-run${COLOR_NONE}                 Run all commands in dry-run mode without file system changes"
  echo -e "  ${COLOR_LIGHT_CYAN}-y${COLOR_NONE}                        Do not prompt for approval and accept everything"
  echo -e "  ${COLOR_LIGHT_CYAN}-h${COLOR_NONE} (--help)               Show available actions and their description"
  echo -e "  ${COLOR_LIGHT_CYAN}-v${COLOR_NONE} (--verbose)            Output debug logs for deps-syncer client commands executions"
  echo -e "  ${COLOR_LIGHT_CYAN}-s${COLOR_NONE} (--silent)             Do not output logs for deps-syncer client commands executions"
  echo -e " "
  exit 0
}

print_deps_config_json_and_exit() {
  local config_file_path=$(get_config_path_from_content_root)
  cmd_run "jq '.dependencies.repos | .[]' "${config_file_path}""
  exit 0
}

clear_all_external_dependencies_and_exit() {
  local external_symlinks_folder_path=$(get_external_folder_from_content_root)
  clear_external_folder_symlinks "${external_symlinks_folder_path}"
  exit 0
}

clear_external_dependency_and_exit() {
  local external_dep_symlink_path=$(get_external_dep_symlink_from_content_root "${CLI_VALUE_CLEAR_DEP_NAME}")
  clear_external_dependency_symlink "${external_dep_symlink_path}"
  exit 0
}

sync_dep_and_exit() {
  run_sync_single_dep "${CLI_VALUE_SYNC_DEP_NAME}"
  exit 0
}

sync_all_deps_and_exit() {
  run_sync_all_deps
  exit 0
}

init_git_deps_directory_and_exit() {
  run_init_command "${GIT_DEPS_MANAGED_FOLDER}" \
    "${EXTERNAL_REPOS_JSON_PATH}" \
    "${GIT_DEPS_CONFIG_FILENAME}"
  exit 0
}

print_local_version_and_exit() {
  local version=$(cat ${GIT_DEPS_SYNCER_CLI_INSTALL_PATH}/resources/version.txt)
  echo -e "git-deps-syncer ${version}"
  exit 0
}

print_config_and_exit() {
  echo -e " "
  echo -e "${COLOR_WHITE}LOCATIONS:${COLOR_NONE}"
  echo -e " "
  echo -e "  ${COLOR_LIGHT_CYAN}Config${COLOR_NONE}........: <REPO_ROOT_FOLDER>/${EXTERNAL_REPOS_JSON_PATH}"
  echo -e "  ${COLOR_LIGHT_CYAN}Repositories${COLOR_NONE}..: <REPO_ROOT_FOLDER>/${EXTERNAL_FOLDER_FROM_GIT_DEPS}"
  echo -e "  ${COLOR_LIGHT_CYAN}Symlinks${COLOR_NONE}......: <REPO_ROOT_FOLDER>/${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}"
  echo -e "  ${COLOR_LIGHT_CYAN}Clone Path${COLOR_NONE}....: ${CACHED_REPO_CLONE_ROOT}"
  echo -e " "
  exit 0
}

prerequisites() {
  check_tool "jq"
}

verify_git_syncer_supported_repository() {
  local config_file_path=$(get_config_path_from_content_root)
  if ! is_file_exist "${config_file_path}"; then
    log_fatal "Not a valid git syncer supported repository (missing: <REPO_ROOT>/${EXTERNAL_REPOS_JSON_PATH})"
  fi
}

parse_program_arguments() {
  if [ $# = 0 ]; then
    print_help_menu_and_exit "$0"
  fi

  while test $# -gt 0; do
    case "$1" in
    -h | --help)
      print_help_menu_and_exit "$0"
      shift
      ;;
    sync-all)
      CLI_ARGUMENT_SYNC_ALL_DEPS="sync-all"
      shift
      ;;
    sync)
      CLI_ARGUMENT_SYNC_DEP="sync"
      shift
      CLI_VALUE_SYNC_DEP_NAME=$1
      shift
      ;;
    show)      
      CLI_ARGUMENT_SHOW_DEPS="show"
      shift
      ;;
    clear-all)
      CLI_ARGUMENT_CLEAR_ALL_DEPS="clear-all"
      shift
      ;;
    clear)
      CLI_ARGUMENT_CLEAR_DEP="clear"
      shift
      CLI_VALUE_CLEAR_DEP_NAME=$1
      shift
      ;;
    version)
      CLI_ARGUMENT_VERSION="version"
      shift
      ;;
    config)
      CLI_ARGUMENT_CONFIG="config"
      shift
      ;;
    init)
      CLI_ARGUMENT_INIT="init"
      shift
      ;;
    --save-dev)
      CLI_OPTION_DEPS_TYPE="save-dev"
      shift
      ;;
    --open-github-pr)
      CLI_OPTION_OPEN_GITHUB_PR="open-github-pr"
      shift
      ;;
    --dry-run)
      # Used by logger.sh
      export LOGGER_DRY_RUN="true"
      shift
      ;;
    -y)
      # Used by prompter.sh
      export PROMPTER_SKIP_PROMPT="y"
      shift
      ;;
    -v | --verbose)
      # Used by logger.sh
      export LOGGER_DEBUG="true"
      shift
      ;;
    -s | --silent)
      # Used by logger.sh
      export LOGGER_SILENT="true"
      shift
      ;;
    *)
      print_help_menu_and_exit "$0"
      shift
      ;;
    esac
  done
}

verify_program_arguments() {
  if check_invalid_sync_dep_value; then
    # Verify proper command args ordering: dotfiles sync <name> --dry-run -v
    log_fatal "Missing/invalid argument value. usage: sync [dep-name]"
  elif check_invalid_clear_dep_value; then
    # Verify proper command args ordering: dotfiles clear <name> --dry-run -v
    log_fatal "Missing argument value. usage: clear [dep-name]"
  fi
}

check_invalid_sync_dep_value() {
  # If sync command is not empty and its value is empty or a flag - not valid
  [[ -n "${CLI_ARGUMENT_SYNC_DEP}" && (-z "${CLI_VALUE_SYNC_DEP_NAME}" || "${CLI_VALUE_SYNC_DEP_NAME}" == -*) ]]
}

check_invalid_clear_dep_value() {
  [[ -n "${CLI_ARGUMENT_CLEAR_DEP}" && (-z "${CLI_VALUE_CLEAR_DEP_NAME}" || "${CLI_VALUE_CLEAR_DEP_NAME}" == -*) ]]
}

main() {  
  parse_program_arguments "$@"
  verify_program_arguments

  if is_print_version; then
    print_local_version_and_exit
  fi

  if is_print_config; then
    print_config_and_exit
  fi

  if is_init; then
    init_git_deps_directory_and_exit
  fi

  prerequisites
  verify_git_syncer_supported_repository

  if is_show_deps; then
    print_deps_config_json_and_exit
  fi

  if is_clear_all_deps; then
    clear_all_external_dependencies_and_exit
  fi

  if is_clear_dep; then
    clear_external_dependency_and_exit "${CLI_VALUE_CLEAR_DEP_NAME}"
  fi

  if is_sync_dep; then
    sync_dep_and_exit
  fi

  if is_sync_all_deps; then
    sync_all_deps_and_exit
  fi
}

main "$@"