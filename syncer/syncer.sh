#!/bin/bash

# Title         Sync external git dependencies
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Clone and symlink external git dependencies folder
#==============================================================================
SYNCER_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
SYNCER_ROOT_FOLDER_ABS_PATH=$(dirname "${SYNCER_CURRENT_FOLDER_ABS_PATH}")

source "${SYNCER_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${SYNCER_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${SYNCER_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"

DEV_INDICATOR="[DEV] "

# Excluded files and folder should have the full path from the root folder of the repository
# Example:
#   To exclude 'b' from path <repo>/a/b we'll have to add "a/b" to the array.
#   This script will append the absolute path for <ABS_PATH>/<REPO_ROOT>/a/b
EXCLUDED_FILE_AND_DIRS_ARRAY=( ".git" ".idea" ".git-deps" "external" ".gitignore" ".DS_Store")

print_logo_syncer() {
  if ! is_silent; then
    echo -e "
  ██████╗ ███████╗██████╗ ███████╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗███████╗██████╗
  ██╔══██╗██╔════╝██╔══██╗██╔════╝    ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██╔════╝██╔══██╗
  ██║  ██║█████╗  ██████╔╝███████╗    ███████╗ ╚████╔╝ ██╔██╗ ██║██║     █████╗  ██████╔╝
  ██║  ██║██╔══╝  ██╔═══╝ ╚════██║    ╚════██║  ╚██╔╝  ██║╚██╗██║██║     ██╔══╝  ██╔══██╗
  ██████╔╝███████╗██║     ███████║    ███████║   ██║   ██║ ╚████║╚██████╗███████╗██║  ██║
  ╚═════╝ ╚══════╝╚═╝     ╚══════╝    ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═╝

                                                                              (SHELL: ${SHELL})
" >&2
  fi
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
  New GitHub branch will get created and a PR will be opened upon every external git dependency sync.${COLOR_NONE}"
    fi

    echo -e """
  ================================================================================================
  This script syncs external git dependencies for the repository ${COLOR_PURPLE}${repo_name}${COLOR_NONE}.

  ${COLOR_LIGHT_CYAN}What are git dependencies?${COLOR_NONE}
  These are source dependant git repositories that are getting cloned locally and their files are
  being copied directly to this repository.

  ${COLOR_LIGHT_CYAN}Locations:${COLOR_NONE}
    • Repositories content path - ${COLOR_PURPLE}<REPO_ROOT>/${EXTERNAL_FOLDER_FROM_GIT_DEPS}/${COLOR_NONE}
    • Repositories symlink path - ${COLOR_PURPLE}<REPO_ROOT>/${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}/${COLOR_NONE}

  ${COLOR_LIGHT_CYAN}How to declare a dependency?${COLOR_NONE}
  To add/remove an external git dependency, update the JSON file ${COLOR_PURPLE}<REPO_ROOT>/${EXTERNAL_REPOS_JSON_PATH}${COLOR_NONE}${pr_creation_alert}
  ================================================================================================
"""  >&2
  fi
}

print_dev_instructions_syncer() {
  local repo_name=$1

  if ! is_silent; then

    local pr_creation_alert=""

    echo -e """
  ================================================================================================
  This script syncs external ${COLOR_PURPLE}DEV${COLOR_NONE} dependencies for the repository ${COLOR_PURPLE}${repo_name}${COLOR_NONE}.

  ${COLOR_LIGHT_CYAN}What are git dev dependencies?${COLOR_NONE}
  Those are source dependant local git repositories that are getting symlinked to the external
  folder of this repository.

  Locations:
    • Repositories symlink path - ${COLOR_PURPLE}<REPO_ROOT>/${EXTERNAL_FOLDER_FROM_CONTENT_ROOT}/${COLOR_NONE}

  ${COLOR_LIGHT_CYAN}How to declare a dev dependency?${COLOR_NONE}
  To add/remove an external dev dependency, update the JSON file ${COLOR_PURPLE}<REPO_ROOT>/${EXTERNAL_REPOS_JSON_PATH}${COLOR_NONE}
  under path ${COLOR_PURPLE}.devDependencies.repos${COLOR_NONE}
  ================================================================================================
"""  >&2
  fi
}

print_dependency_sync_title() {
  local name=$1
  local prefix=""
  if is_dev_dependencies; then
    prefix="${DEV_INDICATOR}"
  fi
  log_info "${COLOR_GREEN}Syncing ${prefix}dependency - ${name}...${COLOR_NONE}"
}

add_or_sync_dependency() {
  local dep_name=$1
  local dep_url=$2
  local dep_branch=$3
  local dep_revision=$4
  local includes=$5
  local excludes=$6

  if ! is_directory_exist "${CACHED_REPO_CLONE_ROOT}"; then
    cmd_run "mkdir -p ${CACHED_REPO_CLONE_ROOT}"
  fi

  local git_repo_name=$(extract_repo_name_from_repo_url "${dep_url}")
  local clone_path=$(get_cached_repo_clone_path "${git_repo_name}")
  local copy_path=$(get_git_deps_dep_abs_path "${dep_name}")

  if ! is_directory_exist "${clone_path}"; then
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
  cmd_run "chmod -R +x ${copy_path}"
}

clone_repository() {
  local clone_path=$1
  local dep_url=$2
  local dep_branch=$3
  local dep_revision=$4

  log_info "Creating a new repository clone path. path: ${clone_path}"
  cmd_run "mkdir -p ${clone_path}"

  log_info "Cloning repository. url: ${dep_url}, branch: ${dep_branch}, revision: ${dep_revision}"
  cmd_run "git -C \"${clone_path}\" init --quiet"
  cmd_run "git -C \"${clone_path}\" fetch --depth 1 --force \"${dep_url}\" \"refs/heads/${dep_branch}\" --quiet"
  cmd_run "git -C \"${clone_path}\" reset --hard \"${dep_revision}\" --quiet"
  cmd_run "git -C \"${clone_path}\" clean -xdf"
}

sync_repository() {
  local clone_path=$1
  local dep_url=$2
  local dep_branch=$3
  local dep_revision=$4

  log_info "Updating existing repository. path: ${clone_path}"
  local prev_revision=$(cmd_run "git -C \"${clone_path}\" rev-parse \"${dep_branch}\"")

  log_info "Fetching repository changes. url: ${dep_url}, branch: ${dep_branch}, revision: ${dep_revision}"
  cmd_run "git -C \"${clone_path}\" fetch --depth 1 --force \"${dep_url}\" \"refs/heads/${dep_branch}\" --quiet"
  cmd_run "git -C \"${clone_path}\" reset --hard "${dep_revision}" --quiet"
  cmd_run "git -C \"${clone_path}\" clean -xdf"

  local new_revision=$(cmd_run "git -C \"${clone_path}\" rev-parse \"${dep_branch}\"")
  if [[ "${prev_revision}" != ${new_revision} ]]; then
#      echo "prev_revision: ${prev_revision}"
#      echo "new_revision: ${new_revision}"
    echo -e "\nCommits:\n"
    cmd_run "git -C \"${clone_path}\" --no-pager log \
--oneline \
--graph \
--pretty='%C(Yellow)%h%Creset %<(5) %C(auto)%s%Creset %Cgreen(%ad) %C(bold blue)<%an>%Creset' \
--date=short ${prev_revision}..${new_revision}"
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
    cmd_run "rm -rf ${copy_path}"
  else
    log_fatal "Invalid external git dependency copy destination. path: ${copy_path}"
  fi

  log_info "Updating external git dependency files. path: ${copy_path}"
  cmd_run "mkdir -p ${copy_path}"

  # Must use an array for includes when running rsync from a script
  local includes_array=()
  if [[ -n "${includes}" ]]; then
    includes_array=( "${includes}" )
  fi

  local exclusion_array=()
  if [[ -n "${excludes}" ]]; then
    exclusion_array=( "${excludes}")
  fi

  # Must use an array for exclusions when running rsync from a script
  for (( i=0; i < ${#EXCLUDED_FILE_AND_DIRS_ARRAY[@]}; i++ )); do
    local item=${EXCLUDED_FILE_AND_DIRS_ARRAY[i]}
    exclusion_array+=( --exclude=${item} )
  done

  if [[ -n "${includes}" && -n "${excludes}" ]]; then
    exclusion_array+=( --exclude=*/ )
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
  cmd_run "rsync -a \"${includes_array[@]} ${exclusion_array[@]}\" \"${clone_path}/\" \"${copy_path}/\""
}

check_or_create_external_folder_under_content_root() {
  local dep_symlink_folder=$(get_external_folder_symlink_abs_path)
  if ! is_directory_exist "${dep_symlink_folder}"; then
    # Create the external folder for symlinks if it doesn't exist yet
    cmd_run "mkdir -p ${dep_symlink_folder}"
  fi
}

_set_dependency_symlink() {
  local dep_name=$1
  local dep_path=$2
  local dep_type=$3
  local dep_symlink_relative_path=$(get_external_dep_symlink_relative_path "${dep_name}")
  local dep_symlink_abs_path=$(get_external_dep_symlink_abs_path "${dep_name}")

  check_or_create_external_folder_under_content_root

  if is_symlink "${dep_symlink_abs_path}"; then
    if is_symlink_target "${dep_symlink_abs_path}" "${dep_path}"; then
      log_info "Dependency ${dep_type}is not symlinked to expected target, re-linking. name: ${dep_name}, path: ${dep_path}"
      remove_symlink "${dep_symlink_abs_path}"
      create_symlink "${dep_symlink_relative_path}" "${dep_path}" 
    else
      log_info "${dep_type}Dependency is symlinked to expected target. name: ${dep_name}, path: ${dep_path}"
    fi

  else
    log_info "Creating a symlink to ${dep_type}dependency. name: ${dep_name}, path: ${dep_path}"
    create_symlink "${dep_symlink_relative_path}" "${dep_path}" 
  fi
}

set_external_dev_dependency_symlink() {
  local dep_name=$1
  local local_path=$2
  _set_dependency_symlink "${dep_name}" "${local_path}" "${DEV_INDICATOR}"
}

set_external_dependency_symlink() {
  local dep_name=$1
  # Must use relative path to the repo content root for the symlink to 
  # stay valid on other system such as GitHub
  local dep_relative_path=$(get_git_deps_dep_relative_path "${dep_name}")
  _set_dependency_symlink "${dep_name}" "${dep_relative_path}"
}

extract_repo_name_from_repo_url() {
  local repo_url=$1
  local git_repo_name=$(basename "${repo_url}")
  # Remove the .git extension from repo-name.git
  local repo_name=${git_repo_name%.*}
  echo "${repo_name}"
}

# Prepare rsync includes from JSON array
# ["one", "two", "three"] --> "--include=one --include=two --include=three"
extract_includes() {
  local config_file_path=$1
  local repo_key=$2
  local includes=""

  for inc_key in $(jq ".dependencies.repos[${repo_key}].includes | keys | .[]" "${config_file_path}"); do
    include=$(jq -r ".dependencies.repos[${repo_key}].includes[$inc_key]" "${config_file_path}")
    includes+=" --include=${include} "
  done

  echo "${includes}" | xargs
}

# Prepare rsync excludes from JSON array
# ["one", "two", "three"] --> "--exclude=one --exclude=two --exclude=three"
extract_excludes() {
  local config_file_path=$1
  local repo_key=$2
  local excludes=""

  for excl_key in $(jq ".dependencies.repos[${repo_key}].excludes | keys | .[]" "${config_file_path}"); do
    exclude=$(jq -r ".dependencies.repos[${repo_key}].excludes[$excl_key]" "${config_file_path}")
    excludes+=" --exclude=${exclude} "
  done

  echo "${excludes}" | xargs
}

remove_stale_git_external_deps() {
  local config_file_path=$1
  local removed_at_least_one=""

  print_stale_dependency_cleanup_title
  local declared_deps_paths_array=()
  local external_folder_path=$(get_external_folder_symlink_abs_path)

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
      if [[ -n "${existing_dep_name}" && -d "${existing_dep_dir_path}" && 
            "${existing_dep_dir_path}" == */external/* ]]; then
        log_info "Removing git dependency. name: ${existing_dep_name}"
        cmd_run "rm -rf ${existing_dep_dir_path}"
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
  local external_folder_symlink_path=$(get_external_folder_symlink_abs_path)

  # Create a strings array from all symlinks from the external folder directories names
  for key in $(jq '.dependencies.repos | keys | .[]' "${config_file_path}"); do
    repo=$(jq -r ".dependencies.repos[$key]" "${config_file_path}")
    name=$(jq -r '.name' <<< "${repo}")
    declared_deps_symlink_paths_array+=( "${external_folder_symlink_path}/${name}" )
  done

  # Remove stale/broken symlinks
  local existing_deps_symlinks_array=(${external_folder_symlink_path}/*)
  for (( i=0; i < ${#existing_deps_symlinks_array[@]}; i++ ))
  do
    local existing_dep_symlink_path=${existing_deps_symlinks_array[i]}
    if ! is_symlink "${existing_dep_symlink_path}"; then
      continue
    fi

    # Check if array of external git symlinks does not contain the dependency
    if [[ "${declared_deps_symlink_paths_array[*]}" != "${existing_dep_symlink_path}" && 
          "${existing_dep_symlink_path}" == */external/* ]]; then
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

run_sync_single_dep() {
  local dep_name=$1
  print_logo_syncer
  if [[ $(prompt_yes_no "Sync external git dependency '${dep_name}' (enter to skip)" "warning") == "y" ]]; then
    sync_external_dep "${dep_name}"
  else
    new_line
    log_info "Nothing has changed."
  fi
}

run_sync_all_deps() {
  print_logo_syncer
  print_instructions
  if [[ $(prompt_yes_no "Sync external git dependencies (enter to skip)" "warning") == "y" ]]; then
    sync_external_dep "all"
    remove_stale_external_deps
    open_github_pr
  else
    new_line
    log_info "Nothing has changed."
  fi
}