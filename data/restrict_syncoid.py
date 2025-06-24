#!/usr/bin/env python3

import os
import re
import sys

def error(s):
    print(s, file=sys.stderr)
    sys.exit(1)

if len(sys.argv) != 3:
    error("Bad args")

dest_pool = sys.argv[1]
dest_path = sys.argv[2]
orig_cmd = os.environ.get('SSH_ORIGINAL_COMMAND', '').strip()

re_path='[-_/:.A-Za-z0-9]+'
legal_cmds = [
    f"^command -v lzop$",
    f"^command -v mbuffer$",
    f"^echo -n$",
    f"^exit$",
    f"^mbuffer  -q -s 128k -m 16M 2>/dev/null | lzop -dfc |  zfs receive  -s -F '{dest_pool}/{dest_path}/{re_path}' 2>&1$",
    f"^mbuffer  -q -s 128k -m 16M | lzop -dfc |  zfs receive  -s -F '${dest_pool}/{dest_path}/{re_path}' 2>&1$",
    f"^ps -Ao args=$",
    f"^zfs get -H name '{dest_pool}/{dest_path}/{re_path}'$",
    f"^zfs get -Hpd 1 -t snapshot guid,creation '{dest_pool}/{dest_path}/{re_path}'$",
    f"^zfs get -H -p used '{dest_pool}/{dest_path}/{re_path}'$",
    f"^zfs get -H receive_resume_token '{dest_pool}/{dest_path}/{re_path}'$",
    f"^zfs rollback -R '{dest_pool}/{dest_path}/{re_path}'@'{re_path}'$",
    f"^zfs hold {re_path} '{dest_pool}/{dest_path}/{re_path}'@'{re_path}'$",
    f"^zfs release {re_path} '{dest_pool}/{dest_path}/{re_path}'@'{re_path}'$",
    f"^zpool get -o value -H feature@extensible_dataset '{dest_pool}'$",
]
for legal_cmd in legal_cmds:
    if re.match(legal_cmd, orig_cmd):
        wait_stat = os.system(orig_cmd)
        sys.exit(os.waitstatus_to_exitcode(wait_stat))

with open("/tmp/log_ssh", "a") as f:
    f.write(orig_cmd)
    f.write("\n")
error("Bad command")
