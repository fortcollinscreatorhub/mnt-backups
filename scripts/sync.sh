#!/bin/bash

set -e
set -x

cd -- "$(dirname -- "$0")"

servers=()
servers+=("10.1.10.146") # fcchnas3
servers+=("10.1.10.152") # fcchsec3
servers+=("10.1.10.154") # fcchsec4

tgt_dir=/mnt/backups/bin

for server in "${servers[@]}"; do
    rsync \
        -avr \
        --chown fcchbackup:fcchbackup \
        --chmod og-rwx \
        --delete-after \
        -e ssh \
        ../data/ \
        "root@${server}:${tgt_dir}/"
done
