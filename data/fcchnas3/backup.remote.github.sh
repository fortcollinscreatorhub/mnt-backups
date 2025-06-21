#!/bin/bash

# nestedlog will automatically mark this script as failed if any child block
# failed.
#
# set -e

cd -- "$(dirname -- "$0")"
cd ../github

export GITHUB_USER=$(cat /etc/fcchbackup/github-user)
export GITHUB_TOKEN=$(cat /etc/fcchbackup/github-token)
nestedlog run-as-block "org fortcollinscreatorhub" ./github-backup-org.py fortcollinscreatorhub ../../git/github
