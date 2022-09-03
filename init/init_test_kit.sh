#!/bin/bash

INIT_CREATE_GIT_DEP_FOLDER_COMMAND="mkdir -p %s/.git-deps"
INIT_TEMPLATE_JSON='{
  "dependencies": {
    "repos": [
      {
        "name": "%s",
        "url": "%s",
        "branch": "%s",
        "revision": "%s"
      }
    ]
  },
  "devDependencies": {
    "repos": [
      {
        "name": "%s",
        "localPath": "%s"
      }
    ]
  }
}'
