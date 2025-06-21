#!/bin/bash

cd -- "$(dirname -- "$0")"
ret=0

nestedlog run-as-block "Local (common)" ./backup.local.sh
if [ $? -ne 0 ]; then
    ret=1
fi

local_script="./$(hostname)/backup.local.sh"
if [ -x "${local_script}" ]; then
    nestedlog run-as-block "Local ($(hostname))" "${local_script}"
    if [ $? -ne 0 ]; then
        ret=1
    fi
fi

remote_script="./$(hostname)/backup.remote.sh"
if [ -x "${remote_script}" ]; then
    nestedlog run-as-block "Remote ($(hostname))" "${remote_script}"
    if [ $? -ne 0 ]; then
        ret=1
    fi
fi

exit $ret
