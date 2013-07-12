#!/bin/bash
# 168 = 24 * 7; a week
# 672 = 168 * 4; a month
HOURS=672
read -p "This script will remove all files and directories in exadata/OFA log directies with a modification date older than $HOURS hours. Press CTRL-c to abort or ANY key to continue."

DIRS="
/u01/app/*/grid/rdbms/audit
/u01/app/oracle/admin/*/adump
/u01/app/oracle/diag/asm/*/*/trace
/u01/app/oracle/diag/rdbms/*/*/trace
"

for DIR in $DIRS; do
  if [ -d "$DIR" ]; then
    printf "Doing: $DIR "
    /usr/sbin/tmpwatch -Mmaf $HOURS "$DIR"
    printf "OK\n"
  fi
done
