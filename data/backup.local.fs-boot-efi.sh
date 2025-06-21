#!/bin/bash
set -e
cd -- "$(dirname -- "$0")"/..
sudo /usr/bin/rsync \
    -acHx \
    --numeric-ids \
    --inplace \
    --delete \
    /boot/efi/ \
    "$(pwd)/fs-boot-efi/"
