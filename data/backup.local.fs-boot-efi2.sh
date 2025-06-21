#!/bin/bash
set -e
cd -- "$(dirname -- "$0")"/..
sudo /usr/bin/rsync \
    -acHx \
    --numeric-ids \
    --inplace \
    --delete \
    /boot/efi2/ \
    "$(pwd)/fs-boot-efi2/"
