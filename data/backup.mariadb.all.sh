#!/bin/bash

set -e
cd "$(dirname -- "$0")"

readarray -t envs < <(
    (cd /etc/fcchbackup && ls *.mariadb.env) |
    sed -e 's/.mariadb.env$//'
)

for env in "${envs[@]}"; do
    (set -x; ./backup.mariadb.one.sh "${env}")
done
