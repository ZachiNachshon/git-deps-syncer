#!/bin/bash

source ./scripts/logger.sh

RELEASE_SCRIPT_FILEPATH="git-deps-syncer.sh"

read_tag_from_file() {
  echo $(cat ./resources/version.txt)
}

create_release() {
  local tag=$1
  log_info "Creating a new GitHub release. tag: ${tag}"
  gh release create "${tag}"
}

upload_version() {
  local tag=$1
  local filepath=$2
  log_info "Uploading script file. tag: ${tag}, path: ${filepath}"
  gh release upload "${tag}" "${filepath}"
}

delete_release() {
  local tag=$1

  log_info "Deleting local. tag: ${tag}"
  git tag -d "${tag}"
  new_line
  log_info "Deleting remote. tag: ${tag}"
  git push origin ":refs/tags/${tag}"
}

main() {
  local action=$1

  if [[ "${action}" == "--create" ]]; then

    local tag="v$(read_tag_from_file)"
    printf "Release tag ${tag} (y/n): " yn
    read yn
    new_line

    if [[ "${yn}" == "y" ]]; then
      create_release "${tag}"
      upload_version "${tag}" "${RELEASE_SCRIPT_FILEPATH}"
    else
      log_info "Nothing was released."
    fi

  elif [[ "${action}" == "--delete" ]]; then

    printf "Enter tag to delete: v" tag_to_del
    read tag_to_del
    tag_to_del="v${tag_to_del}"
    printf "Delete tag ${tag_to_del} (y/n): " yn
    read yn
    new_line

    if [[ "${yn}" == "y" ]]; then
      delete_release "${tag_to_del}"
    else
      log_info "Nothing was deleted."
    fi

  else
    log_fatal "Invalid action flag, supported flags: --create, --delete."
  fi
}

main "$@"