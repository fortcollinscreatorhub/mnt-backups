#!/bin/bash

set -e
cd -- "$(dirname -- "$0")"

host=ssh.fortcollinscreatorhub.org
port=18765
user=u930-v2vbn3xb6dhb
home=/home/u930-v2vbn3xb6dhb
sshkey_run_backups=/etc/fcchbackup/id_ed25519_siteground_run_backups
sshkey_rsync_pull=/etc/fcchbackup/id_ed25519_siteground_rsync_pull

(set -x; 
    ssh \
        -p "${port}" \
        -i "${sshkey_run_backups}" \
        "${user}@${host}" \
        "${home}/swarren-run-backups.sh")
(set -x;
    rsync \
        -arHc \
        --delete \
        --delete-excluded \
        --exclude /tmp/ \
        --exclude /.opcache/ \
        --exclude error_log \
        -e "ssh -p ${port} -i \"${sshkey_rsync_pull}\"" \
        "${user}@${host}:${home}/" \
        ../../siteground/)
