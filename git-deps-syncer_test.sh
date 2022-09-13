#!/bin/bash

# Title         Git Deps Syncer tests
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Run git-deps-syncer tests suite
#==============================================================================
GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")

# TODO: Need to run in a container with bash installed

source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/git-deps-syncer_test_kit.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/syncer/syncer_test_kit.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/init/init_test_kit.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/shell.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/test_lib/init.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/test_lib/assert.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/test_lib/assert.sh"
source "${GIT_DEPS_SYNCER_TEST_CURRENT_FOLDER_ABS_PATH}/external/shell_scripts_lib/test_lib/test_logs.sh"

TEST_DATA_GIT_DEPS_SYNCER_FRESH_REPO_PATH="${PWD}/test_data/fresh_repo"
TEST_DATA_GIT_DEPS_SYNCER_MANAGED_REPO_PATH="${PWD}/test_data/managed_repo"
TEST_DATA_GIT_DEPS_SYNCER_MANAGED_REPO_NO_LINKS_PATH="${PWD}/test_data/managed_repo_no_links"
TEST_DATA_GIT_DEPS_SYNCER_MANAGED_REPO_BROKEN_SYNC_PATH="${PWD}/test_data/managed_repo_broken_sync"
TEST_DATA_GIT_DEPS_SYNCER_CLI_REPO_PATH="${PWD}"

export GIT_DEPS_SYNCER_CLI_INSTALL_PATH="${TEST_DATA_GIT_DEPS_SYNCER_CLI_REPO_PATH}"

get_path_for_fresh_test_repository() {
  echo "${TEST_DATA_GIT_DEPS_SYNCER_FRESH_REPO_PATH}"
}

get_path_for_managed_repo() {
  echo "${TEST_DATA_GIT_DEPS_SYNCER_MANAGED_REPO_PATH}"
}

get_path_for_managed_repo_no_links() {
  echo "${TEST_DATA_GIT_DEPS_SYNCER_MANAGED_REPO_NO_LINKS_PATH}"
}

get_path_for_managed_repo_broken_links() {
  echo "${TEST_DATA_GIT_DEPS_SYNCER_MANAGED_REPO_BROKEN_SYNC_PATH}"
}

before_test() {
  test_set_up
  TEST_name=$1
  TEST_passed="True"
  test_log_print_test_name "${TEST_name}"
}

after_test() {
  test_tear_down
}

test_git_deps_syncer_version() {
  before_test "test_git_deps_syncer_version"

  # Given I read the version from version.txt file
  local expected_version=$(cat ./resources/version.txt)

  # And I check the git-deps-syncer CLI version
  ./git-deps-syncer.sh version >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect the version to be equal
  assert_expect_log "${expected_version}"
  after_test
}

test_sync_fix_broken_repo_link() {
  before_test "test_sync_fix_broken_repo_link"

  local working_dir=$(get_path_for_managed_repo_broken_links)

  # Given I arrange test data
  local dep_name_1="dummy_dep"
  local dep_url_1="https://github.com/test/dummy_dep.git"
  local dep_revision_1="1234abcd4321dcba"

  # And I run a sync all command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync-all --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect the broken repo link to get symlinked to correct path
  assert_expect_log "$(printf "${SYNCER_UNLINK_ABS_DEP_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEP_COMMAND}" "${dep_name_1}" "${dep_name_1}")"

  after_test
}

test_sync_all_multiple_repos() {
  before_test "test_sync_all_multiple_repos"

  local working_dir=$(get_path_for_managed_repo_no_links)

  # Given I arrange test data
  local dep_name_1="dummy_dep_1"
  local dep_url_1="https://github.com/test/dummy_dep_1.git"
  local dep_revision_1="abcdefghijk"

  local dep_name_2="dummy_dep_2"
  local dep_url_2="https://github.com/test/dummy_dep_2.git"
  local dep_revision_2="1234567890"

  # And I run a sync all command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync-all --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect all sync all commands to get executed
  assert_expect_log "${SYNCER_CREATE_CACHE_DIR_COMMAND}"
  assert_expect_log "$(printf "${SYNCER_CREATE_CACHE_DEP_COMMAND}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_INIT_COMMAND}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_FETCH_COMMAND}" "${dep_name_1}" "${dep_url_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_RESET_COMMAND}" "${dep_name_1}" "${dep_revision_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_CLEAN_COMMAND}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_REMOVE_EXTERNAL_DEP_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_CREATE_EXTERNAL_DEP_FOLDER_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_RSYNC_COMMAND}" "${dep_name_1}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_GRANT_OWNERSHIP_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEP_COMMAND}" "${dep_name_1}" "${dep_name_1}")"

  assert_expect_log "$(printf "${SYNCER_CREATE_CACHE_DEP_COMMAND}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_GIT_INIT_COMMAND}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_GIT_FETCH_COMMAND}" "${dep_name_2}" "${dep_url_2}")"
  assert_expect_log "$(printf "${SYNCER_GIT_RESET_COMMAND}" "${dep_name_2}" "${dep_revision_2}")"
  assert_expect_log "$(printf "${SYNCER_GIT_CLEAN_COMMAND}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_REMOVE_EXTERNAL_DEP_COMMAND}" "${working_dir}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_CREATE_EXTERNAL_DEP_FOLDER_COMMAND}" "${working_dir}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_RSYNC_COMMAND}" "${dep_name_2}" "${working_dir}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_GRANT_OWNERSHIP_COMMAND}" "${working_dir}" "${dep_name_2}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEP_COMMAND}" "${dep_name_2}" "${dep_name_2}")"

  after_test
}

test_sync_all_multiple_dev_repos() {
  before_test "test_sync_all_multiple_dev_repos"

  local working_dir=$(get_path_for_managed_repo_no_links)

  # Given I arrange test data
  local dev_dep_name_1="dev_dummy_dep_1"
  local dev_dep_local_path_1="/path/to/dev_dummy_dep_1"

  local dev_dep_name_2="dev_dummy_dep_2"
  local dev_dep_local_path_2="/path/to/dev_dummy_dep_2"

  # And I run a sync all DEV deps command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync-all --save-dev --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect all sync all DEV devs commands to get executed
  assert_expect_log "$(printf "${SYNCER_CREATE_EXTERNAL_FOLDER_COMMAND}" "${working_dir}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEV_DEP_COMMAND}" "${dev_dep_local_path_1}" "${dev_dep_name_1}")"

  assert_expect_log "$(printf "${SYNCER_CREATE_EXTERNAL_FOLDER_COMMAND}" "${working_dir}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEV_DEP_COMMAND}" "${dev_dep_local_path_2}" "${dev_dep_name_2}")"

  after_test
}

test_sync_all_removes_stale_deps() {
  before_test "test_sync_all_removes_stale_deps"

  local working_dir=$(get_path_for_managed_repo)

  # Given I arrange test data
  local stale_dep_name="stale_dep"

  # And I run a sync all deps command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync-all --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect the stale dependency to get removed
  assert_expect_log "$(printf "${SYNCER_UNLINK_ABS_DEP_COMMAND}" "${working_dir}" "${stale_dep_name}")"

  after_test
}

test_sync_a_single_repo() {
  before_test "test_sync_a_single_repo"

  local working_dir=$(get_path_for_managed_repo_no_links)

  # Given I arrange test data
  local dep_name_1="dummy_dep_1"
  local dep_url_1="https://github.com/test/dummy_dep_1.git"
  local dep_revision_1="abcdefghijk"

  local dep_name_2="dummy_dep_2"

  # And I sync a single repo command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync "${dep_name_1}" --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect sync single repo commands to get executed
  assert_expect_log "${SYNCER_CREATE_CACHE_DIR_COMMAND}"
  assert_expect_log "$(printf "${SYNCER_CREATE_CACHE_DEP_COMMAND}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_INIT_COMMAND}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_FETCH_COMMAND}" "${dep_name_1}" "${dep_url_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_RESET_COMMAND}" "${dep_name_1}" "${dep_revision_1}")"
  assert_expect_log "$(printf "${SYNCER_GIT_CLEAN_COMMAND}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_REMOVE_EXTERNAL_DEP_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_CREATE_EXTERNAL_DEP_FOLDER_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_RSYNC_COMMAND}" "${dep_name_1}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_GRANT_OWNERSHIP_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEP_COMMAND}" "${dep_name_1}" "${dep_name_1}")"

  assert_not_expect_log "$(printf "${dep_name_2}")"

  after_test
}

test_sync_a_single_dev_repo() {
  before_test "test_sync_a_single_dev_repo"

  local working_dir=$(get_path_for_managed_repo_no_links)

  # Given I arrange test data
  local dev_dep_name_1="dev_dummy_dep_1"
  local dev_dep_local_path_1="/path/to/dev_dummy_dep_1"

  local dev_dep_name_2="dev_dummy_dep_2"

  # And I sync a single dev repo command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync "${dev_dep_name_1}" --save-dev --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect sync single dev repo commands to get executed
  assert_expect_log "$(printf "${SYNCER_CREATE_EXTERNAL_FOLDER_COMMAND}" "${working_dir}")"
  assert_expect_log "$(printf "${SYNCER_LINK_DEV_DEP_COMMAND}" "${dev_dep_local_path_1}" "${dev_dep_name_1}")"

  assert_not_expect_log "$(printf "${dev_dep_name_2}")"

  after_test
}

test_sync_single_repo_requires_repo_name() {
  before_test "test_sync_single_repo_requires_repo_name"

  local working_dir=$(get_path_for_managed_repo)

  # And I sync a single repo command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh sync --save-dev --dry-run -y -v >&"${TEST_log}"

  # Then I expect the command to fail on missing repo name
  assert_expect_log "Missing\/invalid argument value. usage: sync \[dep-name\]"

  after_test
}

test_show_all_declared_repos() {
  before_test "test_show_all_declared_repos"

  local working_dir=$(get_path_for_managed_repo)

  # Given I arrange test data
  local dep_name_1="dummy_dep_1"
  local dep_url_1="https://github.com/test/dummy_dep_1.git"
  local dep_revision_1="abcdefghijk"

  local dep_name_2="dummy_dep_2"
  local dep_url_2="https://github.com/test/dummy_dep_2.git"
  local dep_revision_2="1234567890"

  # And I print all declared repos
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh show >&"${TEST_log}"

  # Then I expect the output to contains all the expected repos
  assert_expect_log_exact_text "$(printf "${GDS_SHOW_REPOS_JSON}" \
    "${dep_name_1}" "${dep_url_1}" "${dep_revision_1}" \
    "${dep_name_2}" "${dep_url_2}" "${dep_revision_2}")"

  after_test
}

test_clear_all_repos() {
  before_test "test_clear_all_repos"

  local working_dir=$(get_path_for_managed_repo)

  # Given I arrange test data
  local dep_name_1="dummy_dep_1"
  local dep_name_2="dummy_dep_2"

  # And I clear all repo dependencies
  ./git-deps-syncer.sh clear-all --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect to unlink all repo dependencies
  assert_expect_log "$(printf "${SYNCER_UNLINK_ABS_DEP_COMMAND}" "${working_dir}" "${dep_name_1}")"
  assert_expect_log "$(printf "${SYNCER_UNLINK_ABS_DEP_COMMAND}" "${working_dir}" "${dep_name_2}")"

  after_test
}

test_clear_single_repo_requires_repo_name() {
  before_test "test_clear_single_repo_requires_repo_name"

  local working_dir=$(get_path_for_managed_repo)

  # And I clear a single repo command
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh clear --save-dev --dry-run -y -v >&"${TEST_log}"

  # Then I expect the command to fail on missing repo name
  assert_expect_log "Missing\/invalid argument value. usage: clear \[dep-name\]"

  after_test
}

test_clear_a_single_repo() {
  before_test "test_clear_a_single_repo"

  local working_dir=$(get_path_for_managed_repo)

  # Given I arrange test data
  local dep_name_1="dummy_dep_1"
  local dep_name_2="dummy_dep_2"

  # And I clear a single repo dependency
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh clear "${dep_name_1}" --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect a single repo dependency to get removed
  assert_expect_log "$(printf "${SYNCER_UNLINK_ABS_DEP_COMMAND}" "${working_dir}" "${dep_name_1}")"

  # And the other repo dependency should stay intanct
  assert_not_expect_log "$(printf "${dep_name_2}")"

  after_test
}

test_init_git_deps_config() {
  before_test "test_init_git_deps_config"

  local working_dir=$(get_path_for_fresh_test_repository)

  # Given I arrange test data
  local example_dep_name_1="REPOSITORY_NAME"
  local example_dep_url_1="https://github.com/<organization>/REPOSITORY_NAME.git"
  local example_dep_branch_1="master"
  local example_dep_revision_1="ab23fdr87..."
  local example_dev_dep_name_1="REPOSITORY_NAME"
  local example_dev_dep_path_1="/path/to/local/clone/of/REPOSITORY_NAME"

  # When I init a new .git-deps folder and config file
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh init --dry-run -y -v >&"${TEST_log}" ||
    echo "Failed to run git-deps-syncer command"

  # Then I expect a .git-deps folder to get created
  assert_expect_log "$(printf "${INIT_CREATE_GIT_DEP_FOLDER_COMMAND}" "${working_dir}")"

  # And all template values to exist
  assert_expect_log "${example_dep_name_1}"
  assert_expect_log "${example_dep_url_1}"
  assert_expect_log "${example_dep_branch_1}"
  assert_expect_log "${example_dep_revision_1}"
  assert_expect_log "${example_dev_dep_name_1}"
  assert_expect_log "${example_dev_dep_path_1}"

  # TODO: Need to figure out how to verify if a test log output contians a JSON w/out escaping
  #       characters (similar to 'assert_expect_log_exact_text')

  after_test
}

test_config_output() {
  before_test "test_config_output"

  local working_dir=$(get_path_for_managed_repo)

  # Given I print git-deps-syncer config
  export GIT_DEPS_REPO_WORKING_PATH="${working_dir}" &&
    ./git-deps-syncer.sh config >&"${TEST_log}"

  # Then I expect the output to contains all the expected location paths
  assert_expect_log_exact_text "$(printf "${GDS_CONFIG_OUTPUT}" "$HOME")"

  after_test
}

main() {
  test_env_setup

  test_git_deps_syncer_version
  test_sync_fix_broken_repo_link
  test_sync_all_multiple_repos
  test_sync_all_multiple_dev_repos
  test_sync_all_removes_stale_deps
  test_sync_a_single_repo
  test_sync_a_single_dev_repo
  test_sync_single_repo_requires_repo_name
  test_show_all_declared_repos
  test_clear_all_repos
  test_clear_single_repo_requires_repo_name
  test_clear_a_single_repo
  test_init_git_deps_config
  test_config_output
}

main "$@"
