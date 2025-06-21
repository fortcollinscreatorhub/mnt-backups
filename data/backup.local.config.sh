#!/bin/bash

set -ex
cd -- "$(dirname -- "$0")"

dir="$(pwd)/../config"
mkdir -p "${dir}"
cd "${dir}"

mv_if_changed() {
    src="$1"
    dst="$2"
    cmp -s "${src}" "${dst}" && cmpeq=1 || cmpeq=0
    if [ ${cmpeq} -ne 1 ]; then
        mv -f "${src}" "${dst}"
    else
        rm -f "${src}"
    fi
}

run_redirect_mv_if_changed() {
    f="$1"; shift
    cmd=("$@")

    ftmp="${f}.tmp"
    rm -f "${ftmp}"
    "${cmd[@]}" > "${ftmp}"
    mv_if_changed "${ftmp}" "${f}"
}

case "$(hostname)" in
    fcchnas3)
        d1=0x5000cca224d99191
        d2=0x5000cca224ccf6b6
        ;;
    *)
        echo "Unknown hostname" > /dev/stderr
        exit 1
        ;;
esac

for d in "${d1}" "${d2}"; do
    run_redirect_mv_if_changed "./sfdisk-d-${d}.txt" sudo /usr/sbin/sfdisk -d "/dev/disk/by-id/wwn-${d}"
done

run_redirect_mv_if_changed ./blkid.txt                  sudo /usr/sbin/blkid
run_redirect_mv_if_changed ./dev-disk.txt               ls -lFaR /dev/disk
run_redirect_mv_if_changed ./proc-partitions.txt        cat /proc/partitions
run_redirect_mv_if_changed ./proc-mdstat.txt            cat /proc/mdstat
run_redirect_mv_if_changed ./mdadm-detail-scan.txt      sudo /usr/sbin/mdadm --detail --scan
run_redirect_mv_if_changed ./zpool-status.txt           sudo /usr/sbin/zpool status -P
run_redirect_mv_if_changed ./zfs-list.txt               sudo /usr/sbin/zfs list
run_redirect_mv_if_changed ./zfs-get-all.txt            sudo /usr/sbin/zfs get all
run_redirect_mv_if_changed ./apt-mark-show-manual.txt   apt-mark showmanual
