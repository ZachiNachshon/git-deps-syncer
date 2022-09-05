#!/bin/bash

# Installation commands:
#  Basic:
#    curl -sfL https://github.com/ZachiNachshon/git-deps-syncer/uninstall.sh | bash -
#  Options:
#    curl -sfL https://github.com/ZachiNachshon/git-deps-syncer/uninstall.sh | DRY_RUN=true -
#    DRY_RUN=true ./uninstall.sh

# Run the install script in dry-run mode, no file system changes
DRY_RUN=${DRY_RUN=""}

GIT_DEPS_SYNCER_INSTALL_PATH="${HOME}/.config/git-deps-syncer"
GIT_DEPS_SYNCER_EXECUTABLE_NAME=git-deps-syncer

DARWIN_BIN_DIR="$HOME/.local/bin"
LINUX_BIN_DIR="$HOME/.local/bin"

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW="\033[0;33m"
COLOR_NONE='\033[0m'

is_dry_run() {
  [[ -n ${DRY_RUN} ]]
}

exit_on_error() {
  exit_code=$1
  message=$2
  if [ $exit_code -ne 0 ]; then
    #        >&2 echo "\"${message}\" command failed with exit code ${exit_code}."
    # >&2 echo "\"${message}\""
    exit $exit_code
  fi
}

new_line() {
  echo -e "" >&2
}

_log_base() {
  prefix=$1
  shift
  echo -e "${prefix}$*" >&2
}

log_info() {
  local info_level_txt="INFO"
  if is_dry_run; then
    info_level_txt+=" (Dry Run)"
  fi

  _log_base "${COLOR_GREEN}${info_level_txt}${COLOR_NONE}: " "$@"
}

log_warning() {
  local warn_level_txt="WARNING"
  if is_dry_run; then
    warn_level_txt+=" (Dry Run)"
  fi

  _log_base "${COLOR_YELLOW}${warn_level_txt}${COLOR_NONE}: " "$@"
}

log_error() {
  local error_level_txt="ERROR"
  if is_dry_run; then
    error_level_txt+=" (Dry Run)"
  fi
  _log_base "${COLOR_RED}${error_level_txt}${COLOR_NONE}: " "$@"
}

log_fatal() {
  local fatal_level_txt="ERROR"
  if is_dry_run; then
    fatal_level_txt+=" (Dry Run)"
  fi
  _log_base "${COLOR_RED}${fatal_level_txt}${COLOR_NONE}: " "$@"
  message="$@"
  exit_on_error 1 "${message}"
}

cmd_run() {
  local cmd_string=$1
  if ! is_dry_run; then
    eval "${cmd_string}"
  else
    echo """
      ${cmd_string}
  """
  fi
}

is_tool_exist() {
  local name=$1
  [[ $(command -v "${name}") ]]
}

is_install_from_local_archive() {
  [[ -n "${LOCAL_ARCHIVE_FILEPATH}" ]]
}

is_symlink() {
  local abs_path=$1
  [[ -L "${abs_path}" ]]
}

is_file_exist() {
  local path=$1
  [[ -f "${path}" || $(is_symlink "${path}") ]]
}

is_file_contain() {
  local filepath=$1
  local text=$2
  grep -q -w "${text}" "${filepath}"
}

is_directory_exist() {
  local path=$1
  [[ -d "${path}" ]]
}

read_os_type() {
  if [[ "${OSTYPE}" == "linux"* ]]; then
    echo "linux"
  elif [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "darwin"
  else
    log_fatal "OS type is not supported. os: ${OSTYPE}"
  fi
}

calculate_git_deps_syncer_exec_symlink_path() {
  local os_type=$(read_os_type)
  if [[ "${os_type}" == "linux" ]]; then
    # $HOME/.local/bin/git-deps-syncer
    echo "${LINUX_BIN_DIR}/${GIT_DEPS_SYNCER_EXECUTABLE_NAME}"
  elif [[ "${os_type}" == "darwin" ]]; then
    # $HOME/.local/bin/git-deps-syncer
    echo "${DARWIN_BIN_DIR}/${GIT_DEPS_SYNCER_EXECUTABLE_NAME}"
  else
    echo ""
  fi
}

clear_previous_installation() {
  local git_deps_syncer_unpack_path="${GIT_DEPS_SYNCER_INSTALL_PATH}"
  log_info "Removing installation folder. path: ${git_deps_syncer_unpack_path}"

  if is_directory_exist "${git_deps_syncer_unpack_path}"; then
    cmd_run "rm -rf ${git_deps_syncer_unpack_path}"
  fi
}

main() {
  local git_deps_syncer_exec_bin_path=$(calculate_git_deps_syncer_exec_symlink_path)

  log_info "Unlinking exec bin. path: ${git_deps_syncer_exec_bin_path}"
  if is_file_exist "${git_deps_syncer_exec_bin_path}"; then
    cmd_run "unlink ${git_deps_syncer_exec_bin_path}"
  else
    log_warning "Cannot unlink file, 'git-deps-syncer' is not symlinked. path: ${git_deps_syncer_exec_bin_path}"
  fi

  clear_previous_installation
}

main "$@"
