#!/bin/bash

SYNCER_CREATE_CACHE_DIR_COMMAND="mkdir -p ${HOME}/.git-deps-syncer-cache"
SYNCER_CREATE_CACHE_DEP_COMMAND="mkdir -p ${HOME}/.git-deps-syncer-cache/%s"
SYNCER_GIT_INIT_COMMAND="git -C \"${HOME}/.git-deps-syncer-cache/%s\" init --quiet"
SYNCER_GIT_FETCH_COMMAND="git -C \"${HOME}/.git-deps-syncer-cache/%s\" fetch --depth 1 --force \"%s\" \"refs/heads/master\" --quiet"
SYNCER_GIT_RESET_COMMAND="git -C \"${HOME}/.git-deps-syncer-cache/%s\" reset --hard \"%s\" --quiet"
SYNCER_GIT_CLEAN_COMMAND="git -C \"${HOME}/.git-deps-syncer-cache/%s\" clean -xdf"
SYNCER_REMOVE_EXTERNAL_DEP_COMMAND="rm -rf %s/.git-deps/external/%s"
SYNCER_CREATE_EXTERNAL_DEP_FOLDER_COMMAND="mkdir -p %s/.git-deps/external/%s"
SYNCER_RSYNC_COMMAND="rsync -a \"--include=\*/ \
--include=parent_folder\*/ \
--include=parent_folder/child_folder\* \
--exclude=\*_tests\* \
--exclude=.git \
--exclude=.idea \
--exclude=.git-deps \
--exclude=external \
--exclude=.gitignore \
--exclude=.DS_Store \
--exclude=\*/\" \
\"${HOME}/.git-deps-syncer-cache/%s/\" \
\"%s/.git-deps/external/%s/\""
SYNCER_GRANT_OWNERSHIP_COMMAND="chmod -R +x %s/.git-deps/external/%s"
SYNCER_UNLINK_DEP_COMMAND="unlink external/%s 2>/dev/null"
SYNCER_UNLINK_ABS_DEP_COMMAND="unlink %s/external/%s 2>/dev/null"
SYNCER_LINK_DEP_COMMAND="ln -sfn ../.git-deps/external/%s external/%s"
SYNCER_CREATE_EXTERNAL_FOLDER_COMMAND="mkdir -p %s/external"
SYNCER_LINK_DEV_DEP_COMMAND="ln -sfn %s external/%s"