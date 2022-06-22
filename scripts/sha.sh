#!/bin/bash

source ./scripts/logger.sh

calculate_shasum() {
  local url=$1
  local filename=$(basename ${url})

  local download_path=$(mktemp -d ${TMPDIR:-/tmp}/git-deps-syncer-shasum.XXXXXX)
  cwd=$(pwd)
  cd ${download_path}
  curl -s ${url} \
       -L -o "${filename}"

  log_info "SHA 256:"
  shasum -a 256 "${download_path}/${filename}"
  cd ${cwd}
}

main() {
  local action=$1

  if [[ "${action}" == "--commit" ]]; then

    printf "Enter commit hash: " commit_hash
    read commit_hash

    local url="https://github.com/ZachiNachshon/git-deps-syncer/archive/"${commit_hash}".zip"
    calculate_shasum "${url}"

  elif [[ "${action}" == "--tag" ]]; then

    printf "Enter tag: v" tag
    read tag
    tag="v${tag}"

    local url="https://github.com/ZachiNachshon/git-deps-syncer/releases/download/${tag}/git-deps-syncer.sh"
    calculate_shasum "${url}"

  else
    log_fatal "Invalid action flag, supported flags: --create, --delete."
  fi
}

main "$@"