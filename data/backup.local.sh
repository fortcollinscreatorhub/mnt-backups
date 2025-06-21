#!/bin/bash

cd -- "$(dirname -- "$0")"
ret=0

nestedlog run-as-block "System configuration" \
    ./backup.local.config.sh
if [ $? -ne 0 ]; then
    ret=1
fi

nestedlog run-as-block "fs /boot/efi" \
    ./backup.local.fs-boot-efi.sh
if [ $? -ne 0 ]; then
    ret=1
fi

nestedlog run-as-block "fs /boot/efi2" \
    ./backup.local.fs-boot-efi2.sh
if [ $? -ne 0 ]; then
    ret=1
fi

exit $ret
