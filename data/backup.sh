#!/bin/bash

set -ex
cd -- "$(dirname -- "$0")"

umask 077
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# FIXME: send to sysadmin@fortcollinscreatorhub.org
exec nestedlog-email \
    -f "$(id -un)@$(hostname)" \
    -t "s-cron-fcch@wwwdotorg.org" \
    -s "FCCH $(hostname) nightly backups" \
    ./backup.logged.sh
