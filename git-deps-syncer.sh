#!/bin/bash

# Make sure to update the version as-well on file: resources/version.txt
VERSION="0.2.0"

# git-deps-syncer is a lightweight CLI tool used for syncing git repositories as
# external source dependencies into any working directory.
#
# It offers a simple alternative to git submodule / subtree by allowing a
# drop-in-replacement of any git repository as an immutable source dependency
# that is part of the actual working repository source code,
# files are located and managed within a dedicated external folder.

SCRIPT_NAME="Git External Deps Syncer"

CLI_ARGUMENT_SYNC_ALL_DEPS=""
CLI_ARGUMENT_SYNC_DEP=""
CLI_ARGUMENT_SHOW_DEPS=""
CLI_ARGUMENT_CLEAR_ALL_DEPS=""
CLI_ARGUMENT_CLEAR_DEP=""
CLI_ARGUMENT_LOCATIONS=""
CLI_ARGUMENT_INIT=""
CLI_ARGUMENT_UPDATE_CLIENT=""
CLI_ARGUMENT_VERSION=""

CLI_OPTION_DEPS_TYPE="" # default is --save-prod
CLI_OPTION_OPEN_GITHUB_PR=""
CLI_OPTION_SKIP_PROMPT=""
CLI_OPTION_VERBOSE=""
CLI_OPTION_SILENT=""

CLI_VALUE_SYNC_DEP=""
CLI_VALUE_CLEAR_DEP=""

is_silent() {
  [[ -n ${CLI_OPTION_SILENT} ]]
}

is_debug() {
  [[ -n ${CLI_OPTION_VERBOSE} ]]
}

is_skip_prompt() {
  [[ -n ${CLI_OPTION_SKIP_PROMPT} ]]
}

is_print_version() {
  [[ -n ${CLI_ARGUMENT_VERSION} ]]
}

is_update_client() {
  [[ -n ${CLI_ARGUMENT_UPDATE_CLIENT} ]]
}

is_print_locations() {
  [[ -n ${CLI_ARGUMENT_LOCATIONS} ]]
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

is_valid_sync_dep_value() {
  [[ -n "${CLI_VALUE_SYNC_DEP}" && "${CLI_VALUE_SYNC_DEP}" != "-"* ]]
}

is_valid_clear_dep_value() {
  [[ -n "${CLI_VALUE_CLEAR_DEP}" && "${CLI_VALUE_CLEAR_DEP}" != "-"* ]]
}

GIT_DEPS_MANAGED_FOLDER=".git-deps"
GIT_DEPS_CONFIG_FILENAME="config.json"
EXTERNAL_REPOS_JSON_PATH="${GIT_DEPS_MANAGED_FOLDER}/${GIT_DEPS_CONFIG_FILENAME}"
EXTERNAL_FOLDER_FROM_GIT_DEPS="${GIT_DEPS_MANAGED_FOLDER}/external"
EXTERNAL_FOLDER_FROM_CONTENT_ROOT="external"
CACHED_REPO_CLONE_ROOT="${HOME}/.git-deps-cache"

# Excluded files and folder should have the full path from the root folder of the repository
# Example:
#   To exclude 'b' from path <repo>/a/b we'll have to add "a/b" to the array.
#   This script will append the absolute path for <ABS_PATH>/<REPO_ROOT>/a/b
EXCLUDED_FILE_AND_DIRS_ARRAY=( ".git" ".idea" ".git-deps" "external" ".gitignore" ".DS_Store")

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW="\033[0;33m"
COLOR_WHITE='\033[1;37m'
COLOR_LIGHT_CYAN='\033[0;36m'
COLOR_NONE='\033[0m'

print_logo_syncer() {
  if ! is_silent; then
    echo -e """${COLOR_YELLOW}
██████╗ ███████╗██████╗ ███████╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗███████╗██████╗
██╔══██╗██╔════╝██╔══██╗██╔════╝    ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██╔════╝██╔══██╗
██║  ██║█████╗  ██████╔╝███████╗    ███████╗ ╚████╔╝ ██╔██╗ ██║██║     █████╗  ██████╔╝
██║  ██║██╔══╝  ██╔═══╝ ╚════██║    ╚════██║  ╚██╔╝  ██║╚██╗██║██║     ██╔══╝  ██╔══██╗
██████╔╝███████╗██║     ███████║    ███████║   ██║   ██║ ╚████║╚██████╗███████╗██║  ██║
╚═════╝ ╚══════╝╚═╝     ╚══════╝    ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝

                                                                             (SHELL: ${SHELL})
${COLOR_NONE}""" >&2
  fi
}

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

print_instructions() {
  local repo_name=$(basename ${PWD})

  if is_dev_dependencies; then
    print_dev_instructions_syncer "${repo_name}"
  else
    print_instructions_syncer "${repo_name}"
  fi
}

print_instructions_syncer() {
  local repo_name=$1

  if ! is_silent; then

    local pr_creation_alert=""

    if should_open_github_pr && ! is_dev_dependencies; then
      pr_creation_alert="

  ${COLOR_RED}Important !
  New GitHub branch will get created and a PR will be opened upon every external git dependency sync.${COLOR_YELLOW}"
    fi

    echo -e """${COLOR_YELLOW}
  ================================================================================================
  This script syncs external git dependencies for the repository ${COLOR_GREEN}${repo_name}${COLOR_YELLOW}.

  What are dependencies?
  These are source dependant git repositories that are getting cloned locally and their files are
  being copied directly to this repository.

  Locations:
    • Repositories content path - ${COLOR_WHITE}<REPO-ROOT>/${EXTERNAL_FOLDER_FROM_GIT_DEPS}/${COLOR_YELLOW}
    • Repositories symlink path - ${COLOR_WHITE}<REPO-ROOT>/${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}/${COLOR_YELLOW}

  How to declare a dependency?
  To add/remove an external git dependency, update the JSON file ${COLOR_WHITE}<ROOT>/${EXTERNAL_REPOS_JSON_PATH}${COLOR_YELLOW}${pr_creation_alert}
  ================================================================================================${COLOR_NONE}
"""  >&2
  fi
}

print_dev_instructions_syncer() {
  local repo_name=$1

  if ! is_silent; then

    local pr_creation_alert=""

    echo -e """${COLOR_YELLOW}
  ================================================================================================
  This script syncs external ${COLOR_GREEN}DEV${COLOR_YELLOW} dependencies for the repository ${COLOR_GREEN}${repo_name}${COLOR_YELLOW}.

  What are dev dependencies?
  These are source dependant local git repositories that are getting symlinked to the external
  folder of this repository.

  Locations:
    • Repositories symlink path - ${COLOR_WHITE}<ROOT>/${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}/${COLOR_YELLOW}

  How to declare a dev dependency?
  To add/remove an external dev dependency, update the JSON file ${COLOR_WHITE}<ROOT>/${EXTERNAL_REPOS_JSON_PATH}${COLOR_YELLOW}
  under the json path ${COLOR_GREEN}.devDependencies.repos${COLOR_YELLOW}
  ================================================================================================${COLOR_NONE}
"""  >&2
  fi
}

print_dependency_sync_title() {
  local name=$1
  if ! is_silent; then
    local dev_indicator=""
    if is_dev_dependencies; then
      dev_indicator="[DEV] "
    fi
    log_info "${COLOR_GREEN}${dev_indicator}Syncing dependency - ${name}...${COLOR_NONE}"
  fi
}

print_stale_dependency_cleanup_title() {
  if ! is_silent && ! is_dev_dependencies; then
    new_line
    log_info "${COLOR_GREEN}${dev_indicator}Removing stale dependencies...${COLOR_NONE}"
  fi
}

print_stale_symlinks_cleanup_title() {
  if ! is_silent && ! is_dev_dependencies; then
    new_line
    log_info "${COLOR_GREEN}${dev_indicator}Removing stale symlinks...${COLOR_NONE}"
  fi
}

prompt_yes_no() {
  local message=$1
  local level=$2

  local prompt=""
  if [[ ${level} == "critical" ]]; then
    prompt="${COLOR_RED}${message}? (y/n):${COLOR_NONE} "
  elif [[ ${level} == "warning" ]]; then
    prompt="${COLOR_YELLOW}${message}? (y/n):${COLOR_NONE} "
  else
    prompt="${message}? (y/n): "
  fi

  printf "${prompt}" >&0
  read input
  if [[ "${input}" != "y" ]]; then
    input=""
  fi

  echo "${input}"
}

exit_on_error() {
    exit_code=$1
    message=$2
    if [ $exit_code -ne 0 ]; then
#        >&2 echo "\"${message}\" command failed with exit code ${exit_code}."
#        >&2 echo "\"${message}\""
        exit $exit_code
    fi
}

is_symlink() {
  local abs_path=$1
  [[ -L "${abs_path}" ]]
}

is_symlink_target() {
  local symlink=$1
  local target=$2
  local link_dest=$(readlink "${symlink}")
  local result="${target}"
  if [[ "${link_dest}" != "${target}" ]]; then
    result=""
  fi
  echo "${result}"
}

_log_base() {
  prefix=$1
  shift
  echo -e "${prefix}$*" >&2
}

log_info() {
  if ! is_silent; then
    _log_base "${COLOR_GREEN}INFO${COLOR_NONE}: " "$@"
  fi
}

log_warning() {
  if ! is_silent; then
    _log_base "${COLOR_YELLOW}WARNING${COLOR_NONE}: " "$@"
  fi
}

log_error() {
  _log_base "${COLOR_RED}ERROR${COLOR_NONE}: " "$@"
}

log_fatal() {
  _log_base "${COLOR_RED}ERROR${COLOR_NONE}: " "$@"
  message="$@"
  exit_on_error 1 "${message}"
}

new_line() {
  echo -e "" >&2
}

get_cached_repo_clone_path() {
  local repo_name=$1
  if [[ -z "${CACHED_REPO_CLONE_ROOT}" ]]; then
    mkdir -p "${CACHED_REPO_CLONE_ROOT}"
  fi
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

get_dep_symlink_from_content_root() {
  local dep_name=$1
  echo "${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}/${dep_name}"
}

get_config_path_from_content_root() {
  echo "${EXTERNAL_REPOS_JSON_PATH}"
}

clone_repository() {
  local clone_path=$1
  local dep_url=$2
  local dep_branch=$3
  local dep_revision=$4

  log_info "Creating a new repository clone path. path: ${clone_path}"
  mkdir -p "${clone_path}"

  log_info "Cloning repository. url: ${dep_url}, branch: ${dep_branch}, revision: ${dep_revision}"
  git -C "${clone_path}" init --quiet
  git -C "${clone_path}" fetch --depth 1 --force "${dep_url}" "refs/heads/${dep_branch}" --quiet
  git -C "${clone_path}" reset --hard "${dep_revision}" --quiet
  git -C "${clone_path}" clean -xdf
}

sync_repository() {
  local clone_path=$1
  local dep_url=$2
  local dep_branch=$3
  local dep_revision=$4

  log_info "Updating existing repository. path: ${clone_path}"
  local prev_revision=$(git -C "${clone_path}" rev-parse "${dep_branch}")

  log_info "Fetching repository changes. url: ${dep_url}, branch: ${dep_branch}, revision: ${dep_revision}"
  git -C "${clone_path}" fetch --depth 1 --force "${dep_url}" "refs/heads/${dep_branch}" --quiet
  git -C "${clone_path}" reset --hard "${dep_revision}" --quiet
  git -C "${clone_path}" clean -xdf

  local new_revision=$(git -C "${clone_path}" rev-parse "${dep_branch}")
  if [[ "${prev_revision}" != ${new_revision} ]]; then
#      echo "prev_revision: ${prev_revision}"
#      echo "new_revision: ${new_revision}"
    echo -e "\nCommits:\n"
    git -C "${clone_path}" --no-pager log \
--oneline \
--graph \
--pretty='%C(Yellow)%h%Creset %<(5) %C(auto)%s%Creset %Cgreen(%ad) %C(bold blue)<%an>%Creset' \
--date=short ${prev_revision}..${new_revision}
    echo -e "\n"
  else
    echo -e "\nNo changes found for revision.\n"
  fi
}

copy_repo_content_as_external_dependency() {
  local dep_name=$1
  local clone_path=$2
  local copy_path=$3
  local includes=$4
  local excludes=$5

  if [[ -n "${copy_path}" && "${copy_path}" == *"${dep_name}"* ]]; then
    log_info "Clearing external git dependency copy destination. path: ${copy_path}"
    rm -rf "${copy_path}"
  else
    log_fatal "Invalid external git dependency copy destination. path: ${copy_path}"
  fi

  log_info "Updating external git dependency files. path: ${copy_path}"
  mkdir -p "${copy_path}"

  # Must use an array for includes when running rsync from a script
  local includes_array=()
  if [[ -n "${includes}" ]]; then
    for incl in ${includes}; do
      includes_array+=( --include=${incl} )
    done
  fi

  # Must use an array for exclusions when running rsync from a script
  local exclusion_array=()
  for (( i=0; i < ${#EXCLUDED_FILE_AND_DIRS_ARRAY[@]}; i++ )); do
    local item=${EXCLUDED_FILE_AND_DIRS_ARRAY[i]}
    exclusion_array+=( --exclude=${item} )
  done

  if [[ -n "${excludes}" ]]; then
    for excl in ${excludes}; do
      exclusion_array+=( --exclude=${excl} )
    done
  fi

  if [[ -n "${includes}" && -n "${excludes}" ]]; then
    exclusion_array+=( --exclude=*/ )
  fi

  if is_debug; then
    echo """
    rsync -a "${includes_array[@]}" "${exclusion_array[@]}" "${clone_path}/" "${copy_path}/"
    """
  fi

  # Example used from the shell (in-process shouldn't have commas):
  #   rsync -a \
  #     --include='golang*/' \
  #     --exclude=.git \
  #     --exclude=.idea \
  #     --exclude=.git-deps \
  #     --exclude=.external \
  #     --exclude=.DS_Store \
  #     --exclude=.gitignore \
  #     --exclude='*_tests*' \
  #     --exclude='*/' \
  #     /path/to/source/dir/ \
  #     /path/to/destination/dir/
  # 
  # Reason for using an array for both includes and excludes:
  #   https://stackoverflow.com/questions/69297946/rsync-ignores-exclude-options-being-run-in-bash-script
  rsync -a "${includes_array[@]}" "${exclusion_array[@]}" "${clone_path}/" "${copy_path}/"
}

check_or_create_external_folder_under_content_root() {
  local dep_symlink_folder=$(get_external_folder_from_content_root)
  if [[ ! -d "${dep_symlink_folder}" ]]; then
    # Create the external folder for symlinks if it doesn't exist yet
    mkdir -p "${dep_symlink_folder}"
  fi
}

_set_dependency_symlink() {
  local dep_name=$1
  local dep_path=$2
  local dep_type=$3
  local dep_symlink_path=$(get_dep_symlink_from_content_root "${dep_name}")

  check_or_create_external_folder_under_content_root

  if is_symlink "${dep_symlink_path}"; then
    local is_same_target=$(is_symlink_target "${dep_symlink_path}" "${dep_path}")
    if [[ -z "${is_same_target}" ]]; then
      log_info "Dependency ${dep_type}is not symlinked to expected target, re-linking. name: ${dep_name}, path: ${dep_path}"
      unlink "${dep_symlink_path}"
      if is_debug; then
        echo """
        ln -sf "../${dep_path}" "${dep_symlink_path}"
        """
      fi

      # Must use relative path to the repo content root for the symlink to 
      # stay valid on other system such as GitHub
      ln -sf "../${dep_path}" "${dep_symlink_path}"

    else
      log_info "Dependency ${dep_type}is symlinked to expected target. name: ${dep_name}, path: ${dep_path}"
    fi
  else
    log_info "Creating a symlink to ${dep_type}dependency. name: ${dep_name}, path: ${dep_path}"
    if is_debug; then
      echo """
      ln -sf "../${dep_path}" "${dep_symlink_path}"
      """
    fi

    # Must use relative path to the repo content root for the symlink to 
    # stay valid on other system such as GitHub
    ln -sf "../${dep_path}" "${dep_symlink_path}"

  fi
}

set_external_dev_dependency_symlink() {
  local dep_name=$1
  local local_path=$2
  _set_dependency_symlink "${dep_name}" "${local_path}" "DEV "
}

set_external_dependency_symlink() {
  local dep_name=$1
  local dep_path=$(get_dep_path_from_git_deps "${dep_name}")
  _set_dependency_symlink "${dep_name}" "${dep_path}"
}

extract_repo_name_from_repo_url() {
  local repo_url=$1
  local git_repo_name=$(basename "${repo_url}")
  # Remove the .git extension from repo-name.git
  local repo_name=${git_repo_name%.*}
  echo "${repo_name}"
}

add_or_sync_dependency() {
  local dep_name=$1
  local dep_url=$2
  local dep_branch=$3
  local dep_revision=$4
  local includes=$5
  local excludes=$6

  local git_repo_name=$(extract_repo_name_from_repo_url "${dep_url}")
  local clone_path=$(get_cached_repo_clone_path "${git_repo_name}")
  local copy_path=$(get_dep_path_from_git_deps "${dep_name}")

  if [[ ! -d "${clone_path}" ]]; then
    clone_repository "${clone_path}" "${dep_url}" "${dep_branch}" "${dep_revision}"
  else
    sync_repository "${clone_path}" "${dep_url}" "${dep_branch}" "${dep_revision}"
  fi

  if [[ -z "${clone_path}" || "${clone_path}" != *"${git_repo_name}"* ]]; then
    log_fatal "Invalid external git dependency clone source. path: ${clone_path}"
  else
    copy_repo_content_as_external_dependency "${dep_name}" "${clone_path}" "${copy_path}" "${includes}" "${excludes}"
  fi

  log_info "Elevating execution permissions ${COLOR_YELLOW}(might prompt for password)${COLOR_NONE}"
  chmod -R +x "${copy_path}"
}

ask_for_sync_approval() {
  if ! is_skip_prompt; then
    local yes_no_response=$(prompt_yes_no "  Sync external git dependencies (enter to skip)" "warning")
    if [[ -z "${yes_no_response}" ]]; then
      echo -e "\n    Nothing has changed.\n"
      exit 0
    fi
  fi
}

ask_for_sync_single_approval() {
  local dep_name=$1
  if ! is_skip_prompt; then
    local yes_no_response=$(prompt_yes_no "  Sync external git dependency '${dep_name}' (enter to skip)" "warning")
    if [[ -z "${yes_no_response}" ]]; then
      echo -e "\n    Nothing has changed.\n"
      exit 0
    fi
  fi
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

# Extract includes JSON array to a simple space delimited string
# ["one", "two", "three"] --> "one two three"
extract_includes() {
  local config_file_path=$1
  local repo_key=$2
  local includes=""

  for inc_key in $(jq ".dependencies.repos[${repo_key}].includes | keys | .[]" "${config_file_path}"); do
    include=$(jq -r ".dependencies.repos[].includes[$inc_key]" "${config_file_path}")
    includes+="${include} "
  done

  echo "${includes}"
}

# Extract includes JSON array to a simple space delimited string
# ["one", "two", "three"] --> "one two three"
extract_excludes() {
  local config_file_path=$1
  local repo_key=$2
  local excludes=""

  for excl_key in $(jq ".dependencies.repos[${repo_key}].excludes | keys | .[]" "${config_file_path}"); do
    exclude=$(jq -r ".dependencies.repos[].excludes[$excl_key]" "${config_file_path}")
    excludes+="${exclude} "
  done

  echo "${excludes}"
}

sync_external_dep() {
  local dep_name=$1
  local sync_at_least_one=""

  new_line
  local config_file_path=$(get_config_path_from_content_root)
  if is_dev_dependencies; then
    for key in $(jq '.devDependencies.repos | keys | .[]' "${config_file_path}"); do
      repo=$(jq -r ".devDependencies.repos[$key]" "${config_file_path}")
      name=$(jq -r '.name' <<< "${repo}")

      if [[ "${dep_name}" == "all" || "${dep_name}" == "${name}" ]]; then
        local_path=$(jq -r '.localPath' <<< "${repo}")

        if [[ -n "${name}" ]]; then
          print_dependency_sync_title "${name}"
          set_external_dev_dependency_symlink "${name}" "${local_path}"
          sync_at_least_one="true"
        else
          log_warning "Failed to identify and sync dev repository. name: ${name}"
        fi
      fi
    done
  else
    for key in $(jq '.dependencies.repos | keys | .[]' "${config_file_path}"); do
      repo=$(jq -r ".dependencies.repos[$key]" "${config_file_path}")
      name=$(jq -r '.name' <<< "${repo}")

      if [[ "${dep_name}" == "all" || "${dep_name}" == "${name}" ]]; then
        url=$(jq -r '.url' <<< "${repo}")
        branch=$(jq -r '.branch' <<< "${repo}")
        revision=$(jq -r '.revision' <<< "${repo}")

        if [[ -n "${name}" ]]; then
          includes=$(extract_includes "${config_file_path}" "${key}")
          excludes=$(extract_excludes "${config_file_path}" "${key}")        

          print_dependency_sync_title "${name}"
          add_or_sync_dependency "${name}" "${url}" "${branch}" "${revision}" "${includes}" "${excludes}"
          set_external_dependency_symlink "${name}"
          sync_at_least_one="true"
        else
          log_warning "Failed to identify and sync repository. name: ${name}"
        fi
      fi
    done
  fi

  if [[ -z "${sync_at_least_one}" ]];  then
    log_warning "Nothing was synced, no sync target(s) could be found."
  fi
}

remove_stale_git_external_deps() {
  local config_file_path=$1
  local removed_at_least_one=""

  print_stale_dependency_cleanup_title
  local declared_deps_paths_array=()
  local external_folder_path=$(get_external_folder_from_content_root)

  # Create a strings array from all external git deps directories names
  for key in $(jq '.dependencies.repos | keys | .[]' "${config_file_path}"); do
    repo=$(jq -r ".dependencies.repos[$key]" "${config_file_path}")
    name=$(jq -r '.name' <<< "${repo}")
    declared_deps_paths_array+=( "${external_folder_path}/${name}" )
  done

  # Remove git repository content
  local existing_deps_array=(${external_folder_path}/*)
  for (( i=0; i < ${#existing_deps_array[@]}; i++ ))
  do
    local existing_dep_dir_path=${existing_deps_array[i]}
    # Check if array of external git deps does not contain the dependency
    if [[ "${declared_deps_paths_array[*]}" != "${existing_dep_dir_path}" ]]; then
        local existing_dep_name=$(basename "${existing_dep_dir_path}")
        if [[ -n "${existing_dep_name}" && -d "${existing_dep_dir_path}" ]]; then
          log_info "Removing git dependency. name: ${existing_dep_name}"
          rm -rf "${existing_dep_dir_path}"
          removed_at_least_one="true"
        fi
    fi
  done

  if [[ -z "${removed_at_least_one}" ]];  then
    log_info "No stale git dependencies were found for removal"
  fi
}

remove_stale_git_external_symlinks() {
  local config_file_path=$1
  local removed_at_least_one=""

  print_stale_symlinks_cleanup_title
  local declared_deps_symlink_paths_array=()
  local external_folder_symlink_path=$(get_external_folder_from_content_root)

  # Create a strings array from all external symlink folder directories names
  for key in $(jq '.dependencies.repos | keys | .[]' "${config_file_path}"); do
    repo=$(jq -r ".dependencies.repos[$key]" "${config_file_path}")
    name=$(jq -r '.name' <<< "${repo}")
    declared_deps_symlink_paths_array+=( "${external_folder_symlink_path}/${name}" )
  done

  # Remove symlinks
  local existing_deps_symlinks_array=(${external_folder_symlink_path}/*)
  for (( i=0; i < ${#existing_deps_symlinks_array[@]}; i++ ))
  do
    local existing_dep_symlink_path=${existing_deps_symlinks_array[i]}
    # Check if array of external git symlinks does not contain the dependency
    if [[ "${declared_deps_symlink_paths_array[*]}" != "${existing_dep_symlink_path}" ]]; then
        local existing_dep_symlink_name=$(basename "${existing_dep_symlink_path}")
        if [[ -n "${existing_dep_symlink_name}" ]]; then
          remove_symlink "${existing_dep_symlink_path}"
          removed_at_least_one="true"
        fi
    fi
  done

  if [[ -z "${removed_at_least_one}" ]];  then
    log_info "No stale git symlinks were found for removal"
  fi
}

remove_stale_external_deps() {
  local config_file_path=$(get_config_path_from_content_root)

  # Clearing stale dependencies only for prod deps (non-dev local symlinks)
  if ! is_dev_dependencies; then
    remove_stale_git_external_deps "${config_file_path}"
    remove_stale_git_external_symlinks "${config_file_path}"
  fi
}

print_help_menu_and_exit() {
  exec_filename=$1
  echo -e "${SCRIPT_NAME} - syncs git repos as external source dependencies into a working repository"
  echo -e " "
  echo -e "${COLOR_WHITE}USAGE${COLOR_NONE}"
  echo -e "  $(basename "${exec_filename}") [command] [flag]"
  echo -e " "
  echo -e "${COLOR_WHITE}AVAILABLE COMMANDS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}sync-all${COLOR_NONE}                  sync external git dependencies based on revisions declared on ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}sync${COLOR_NONE} [name]               sync a specific external git dependency based on revisions declared on ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}show${COLOR_NONE}                      print the external git dependencies from the JSON config file"
  echo -e "  ${COLOR_LIGHT_CYAN}clear-all${COLOR_NONE}                 remove all symlinks from external folder"
  echo -e "  ${COLOR_LIGHT_CYAN}clear${COLOR_NONE} [name]              remove a specific symlink from external folder"
  echo -e "  ${COLOR_LIGHT_CYAN}locations${COLOR_NONE}                 print locations used for config/repositories/symlinks/clone-path"
  echo -e "  ${COLOR_LIGHT_CYAN}init${COLOR_NONE}                      create an empty ${COLOR_GREEN}${GIT_DEPS_MANAGED_FOLDER}${COLOR_NONE} folder with a ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE} template file"
  echo -e "  ${COLOR_LIGHT_CYAN}update${COLOR_NONE}                    update client to latest version"
  echo -e "  ${COLOR_LIGHT_CYAN}version${COLOR_NONE}                   print deps-syncer client versions"
  echo -e " "
  echo -e "${COLOR_WHITE}FLAGS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}-h${COLOR_NONE} (--help)               show available actions and their description"
  echo -e "  ${COLOR_LIGHT_CYAN}-v${COLOR_NONE} (--verbose)            output debug logs for deps-syncer client commands executions"
  echo -e "  ${COLOR_LIGHT_CYAN}-s${COLOR_NONE} (--silent)             do not output logs for deps-syncer client commands executions"
  echo -e "  ${COLOR_LIGHT_CYAN}-y${COLOR_NONE}                        do not prompt for approval and accept everything"
  echo -e "  ${COLOR_LIGHT_CYAN}--save-dev${COLOR_NONE}                sync ${COLOR_GREEN}devDependencies${COLOR_NONE} local symlinks as declared on ${COLOR_GREEN}${GIT_DEPS_CONFIG_FILENAME}${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}--open-github-pr${COLOR_NONE}          open a GitHub PR for git changes after running ${COLOR_GREEN}sync-all${COLOR_NONE}"
  echo -e " "
  exit 0
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
      CLI_VALUE_SYNC_DEP=$1
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
      CLI_VALUE_CLEAR_DEP=$1
      shift
      ;;
    version)
      CLI_ARGUMENT_VERSION="version"
      shift
      ;;
    update)
      CLI_ARGUMENT_UPDATE_CLIENT="update"
      shift
      ;;
    locations)
      CLI_ARGUMENT_LOCATIONS="locations"
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
    -y)
      CLI_OPTION_SKIP_PROMPT="y"
      shift
      ;;
    -v | --verbose)
      CLI_OPTION_VERBOSE="verbose"
      shift
      ;;
    -s | --silent)
      CLI_OPTION_SILENT="silent"
      shift
      ;;
    *)
      print_help_menu_and_exit "$0"
      shift
      ;;
    esac
  done
}

print_deps_config_json_and_exit() {
  local config_file_path=$(get_config_path_from_content_root)
  jq '.dependencies.repos | .[]' "${config_file_path}"
  exit 0
}

remove_symlink() {
  local dep_abs_path=$1
  local is_removal_success=""
  local name=""

  # Unlink only if file is a symbolic link to a directory
  if is_symlink "${dep_abs_path}"; then
    name=$(basename "${dep_abs_path}")
    log_info "Unlinking git repository. name: ${name}"
    unlink "${dep_abs_path}"
    is_removal_success="true"
  fi

  if [[ -z "${is_removal_success}" ]];  then
    log_warning "Invalid symlink path, cannot clear. path: ${dep_abs_path}"
  fi
}

clear_external_folder_symlinks_and_exit() {
  local external_symlinks_folder_path=$(get_external_folder_from_content_root)
  for dep_abs_path in "${external_symlinks_folder_path}"/* ; do
    # If directory is empty there is an empty iteration on a stale path, skip that
    if [[ "${dep_abs_path}" != "${external_symlinks_folder_path}/*" ]]; then
      remove_symlink "${dep_abs_path}"
    fi
  done

  log_info "Removed all external git repositories symlinks"
  exit 0
}

clear_external_symlink_and_exit() {
  local dep_name=$1
  local external_symlinks_folder_path=$(get_external_folder_from_content_root)
  remove_symlink "${external_symlinks_folder_path}/${dep_name}"
  exit 0
}

print_local_versions_and_exit() {
  echo -e "git-deps-syncer ${VERSION}"
  exit 0
}

update_client_to_latest_and_exit() {
  # TODO: implement
  log_warning "Update client to latest version: Not yet implemented..."
  exit 0
}

print_cli_used_locations_and_exit() {
  echo -e "${COLOR_WHITE}LOCATIONS${COLOR_NONE}"
  echo -e "  • Config........: ${COLOR_GREEN}<PROJECT_ROOT_FOLDER>/${EXTERNAL_REPOS_JSON_PATH}${COLOR_NONE}"
  echo -e "  • Repositories..: ${COLOR_GREEN}<PROJECT_ROOT_FOLDER>/${EXTERNAL_FOLDER_FROM_GIT_DEPS}${COLOR_NONE}"
  echo -e "  • Symlinks......: ${COLOR_GREEN}<PROJECT_ROOT_FOLDER>/${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}${COLOR_NONE}"
  echo -e "  • Clone Path....: ${COLOR_GREEN}${CACHED_REPO_CLONE_ROOT}${COLOR_NONE}"
  echo -e " "
  exit 0
}

init_git_deps_directory_and_exit() {
  if [[ ! -d "${GIT_DEPS_MANAGED_FOLDER}" ]]; then
    log_info "Creating a managed folder. path: ${PWD}/${GIT_DEPS_MANAGED_FOLDER}"
    mkdir -p "${GIT_DEPS_MANAGED_FOLDER}"
  else
    log_warning "Found an existing managed folder. path: ${PWD}/${GIT_DEPS_MANAGED_FOLDER}"
  fi

  if [[ ! -f "${EXTERNAL_REPOS_JSON_PATH}" ]]; then
    log_info "Creating a ${GIT_DEPS_CONFIG_FILENAME} template. path: ${PWD}/${EXTERNAL_REPOS_JSON_PATH}"
    cat > ${EXTERNAL_REPOS_JSON_PATH} << EOF
$(get_config_template_json)
EOF
  log_info "To list all declared git external dependencies run: git-deps-syncer show"
  else
    log_warning "Found an existing ${GIT_DEPS_CONFIG_FILENAME} file. path: ${PWD}/${EXTERNAL_REPOS_JSON_PATH}"
  fi

  exit 0
}

prerequisites() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "Missing mandatory utility. name: jq"
    exit 1
  fi
}

verify_git_syncer_supported_repository() {
  local config_file_path=$(get_config_path_from_content_root)
  if [[ ! -f "${config_file_path}" ]]; then
    log_fatal "Not a valid git syncer supported repository (missing: <REPO_ROOT>/${EXTERNAL_REPOS_JSON_PATH})"
  fi
}

main() {
  parse_program_arguments "$@"

  if is_print_version; then
    print_local_versions_and_exit
  fi

  if is_update_client; then
    update_client_to_latest_and_exit
  fi

  if is_print_locations; then
    print_cli_used_locations_and_exit
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
    clear_external_folder_symlinks_and_exit
  fi

  if is_clear_dep; then
    if is_valid_clear_dep_value; then
      clear_external_symlink_and_exit "${CLI_VALUE_CLEAR_DEP}"
    else
      log_fatal "Missing argument value. usage: clear [dep-name]"
    fi
  fi

  if is_sync_dep; then
    if is_valid_sync_dep_value; then
      print_logo_syncer
      ask_for_sync_single_approval "${CLI_VALUE_SYNC_DEP}"
      sync_external_dep "${CLI_VALUE_SYNC_DEP}"
    else
      log_fatal "Missing/invalid argument value. usage: sync [dep-name]"
    fi
  fi

  if is_sync_all_deps; then
    print_logo_syncer
    print_instructions
    ask_for_sync_approval
    sync_external_dep "all"
    remove_stale_external_deps
    open_github_pr
  fi
}

main "$@"