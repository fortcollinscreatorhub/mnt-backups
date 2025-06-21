#!/bin/bash

set -e
cd "$(dirname "$0")"

envname="$1"
if [ -z "${envname}" ]; then
    echo "ERROR: usage: $0 envname" > /dev/stderr
    exit 1
fi

envfile="/etc/fcchbackup/${envname}.mariadb.env"
if [ ! -f "${envfile}" ]; then
    echo "ERROR: '${envfile}' missing" > /dev/stderr
    exit 1
fi
cnffile="/etc/fcchbackup/${envname}.mariadb.cnf"
if [ ! -f "${cnffile}" ]; then
    echo "ERROR: '${cnffile}' missing" > /dev/stderr
    exit 1
fi
sqlfile="../mariadb/${envname}.sql"
mkdir -p "$(dirname -- "${sqlfile}")"

. "${envfile}"
exec mariadb-dump "--defaults-extra-file=${cnffile}" --add-drop-table "${database}" > "${sqlfile}"
