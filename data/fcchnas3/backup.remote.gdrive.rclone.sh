#!/bin/bash

set -ex

dir="$1"
if [ -z "${dir}" ]; then
    echo "ERROR: dir missing" > /dev/stderr
    exit 1
fi

cd -- "$(dirname -- "$0")"
rclone_config="/etc/fcchbackup/rclone.conf"
rclone_subdir=
rclone_opts=()
. "./conf.gdrive.${dir}.inc.sh"
if [ -z "${rclone_remote}" ]; then
    echo "ERROR: rclone_remote unset" > /dev/stderr
    exit 1
fi

fd="$(dirname -- "$0")/../../google-drive/${dir}"
mkdir -p "${fd}"
cd "${fd}"
rclone \
    --config "${rclone_config}" \
    -v \
    sync \
    "${rclone_remote}:/${rclone_subdir}" ./ \
    --drive-skip-dangling-shortcuts \
    --drive-skip-shortcuts \
    --drive-alternate-export \
    "${rclone_opts[@]}"
