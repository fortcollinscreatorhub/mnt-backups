#!/bin/bash

set -e
cd -- "$(dirname -- "$0")"

export GITHUB_USER=$(cat /etc/fcchbackup/github-user)
export GITHUB_TOKEN=$(cat /etc/fcchbackup/github-token)
nestedlog run-as-block "org fortcollinscreatorhub" ../github/github-backup-org.py fortcollinscreatorhub ../../git/github
