#!/bin/bash

set -e

# Lock, so only one instance runs; see `man flock`.
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

cd "$(dirname "$0")"
ret=0
. "$(hostname)/syncoid.inc.sh"
for sync in "${syncs[@]}"; do
    IFS=' ' read pool identifier dest ssh_port <<< "${sync}"
    missing=0
    [ -z "${pool}" ] && missing=1
    [ -z "${identifier}" ] && missing=1
    [ -z "${ssh_port}" ] && missing=1
    [ -z "${dest}" ] && missing=1
    if [ ${missing} -ne 0 ]; then
        echo "ERROR: missing parameter in: ${sync}" > /dev/stderr
        ret=1
        continue
    fi
    (
        set -ex
        /usr/sbin/syncoid \
            --identifier "${identifier}" \
            --no-sync-snap \
            --create-bookmark \
            --use-hold \
            --sshport "${ssh_port}" \
            --sshkey /etc/fcchbackup/id_ed25519_syncoid \
            --recursive \
            --skip-parent \
            "${pool}" "${dest}"
    ) || ret=1
done
exit ${ret}
