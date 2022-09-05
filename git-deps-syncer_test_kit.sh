#!/bin/bash

GDS_SHOW_REPOS_JSON='{
  "name": "%s",
  "url": "%s",
  "branch": "master",
  "revision": "%s",
  "includes": [
    "parent_folder*/",
    "parent_folder/child_folder*"
  ],
  "excludes": [
    "*_tests*"
  ]
}
{
  "name": "%s",
  "url": "%s",
  "branch": "master",
  "revision": "%s",
  "includes": [
    "parent_folder*/",
    "parent_folder/child_folder*"
  ],
  "excludes": [
    "*_tests*"
  ]
}'

GDS_CONFIG_OUTPUT=' 
LOCATIONS:

  Config........: <REPO_ROOT_FOLDER>/.git-deps/config.json
  Repositories..: <REPO_ROOT_FOLDER>/.git-deps/external
  Symlinks......: <REPO_ROOT_FOLDER>/external
  Clone Path....: %s/.git-deps-syncer-cache

'
