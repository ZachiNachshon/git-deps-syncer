#!/bin/bash

# Title         GitHub versioned releases actions
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Create or delete a GitHub versioned release
#==============================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

# shellcheck source=../../logger.sh
source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
# shellcheck source=../../checks.sh
source "${ROOT_FOLDER_ABS_PATH}/checks.sh"
# shellcheck source=../../prompter.sh
source "${ROOT_FOLDER_ABS_PATH}/prompter.sh"

read_version_from_file() {
  cat "${version_file_path}"
}

upload_version() {
  local tag=$1
  local filepath=$2
  log_info "Uploading script file. tag: ${tag}, path: ${filepath}"
  if is_debug; then
    echo """
    gh release upload ${tag} ${filepath}
    """
  fi
  gh release upload "${tag}" "${filepath}"
}

create_release() {
  local tag=$1
  log_info "Creating a new GitHub release. tag: ${tag}"
  if is_debug; then
    echo """
    gh release create ${tag}
    """
  fi
  gh release create "${tag}"
}

create_release_version() {
  local tag="v$(read_version_from_file)"

  if [[ $(prompt_yes_no "Release tag ${tag}") == "y" ]]; then
    create_release "${tag}"
    upload_version "${tag}" "${artifact_file_path}"
  else
    log_info "Nothing was released."
  fi
}

delete_released_version() {
  local tag=$(prompt_user_input "Enter tag to delete")

  if [[ $(prompt_yes_no "Delete local and remote tag ${tag}" "critical") == "y" ]]; then
    log_info "Deleting local. tag: ${tag}"
    if is_debug; then
      echo """
      git tag -d ${tag}
      """
    fi
    git tag -d "${tag}"

    new_line
    log_info "Deleting remote. tag: ${tag}"
    if is_debug; then
      echo """
      git push origin :refs/tags/${tag}
      """
    fi
    git push origin ":refs/tags/${tag}"

  else
    log_info "Nothing was deleted."
  fi
}

parse_program_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      action*)
        action=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      version_file_path*)
        version_file_path=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      artifact_file_path*)
        artifact_file_path=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      debug*)
        debug="verbose"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  # Set defaults
  debug=${debug=''}
}

is_debug() {
  [[ -n "${debug}" ]]
}

verify_program_arguments() {
  if [[ -z "${action}" ]]; then
    log_fatal "Missing mandatory param. name: action"
  fi

  # Release version creation requires additional params
  if [[ "${action}" == "create" && -z "${version_file_path}" ]]; then
    log_fatal "Missing mandatory param. name: version_file_path"
  elif [[ "${action}" == "create" && -z "${artifact_file_path}" ]]; then
    log_fatal "Missing mandatory param. name: artifact_file_path"
  fi
}

prerequisites() {
  check_tool git
  check_tool gh
}

#######################################
# Create or delete a GitHub release version
# Globals:
#   None
# Arguments:
#   action              - create / delete
#   version_file_path   - (create only) path to the version file, numeric value only
#   artifact_file_path  - (create only) path to the artifact to upload
# Usage:
#   /shell-scripts-lib/github/release.sh \
#     action: create \
#     version_file_path: ./resources/version.txt \
#     artifact_file_path: git-deps-syncer.sh
#######################################
main() {
  parse_program_arguments "$@"
  verify_program_arguments

  prerequisites

  if [[ "${action}" == "create" ]]; then
    create_release_version
  elif [[ "${action}" == "delete" ]]; then
    delete_released_version
  else
    log_fatal "Invalid action, supported values: create, delete."
  fi
}

main "$@"
