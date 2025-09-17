#!/bin/bash

cd -- "$(dirname -- "$0")"
ret=0

dirs=()
dirs+=(fcch-public)
dirs+=(fcch-private)

for dir in "${dirs[@]}"; do
    nestedlog run-as-block "${dir}" \
        ./backup.remote.gdrive.rclone.sh "${dir}"
    if [ $? -ne 0 ]; then
        ret=1
    fi
done

exit $ret
