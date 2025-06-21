#!/bin/bash

cd -- "$(dirname -- "$0")"
ret=0

nestedlog run-as-block "github" \
    ./backup.remote.github.sh
if [ $? -ne 0 ]; then
    ret=1
fi

exit $ret
