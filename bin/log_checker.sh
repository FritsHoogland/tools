#!/bin/bash
#set -x

DIRS="
/u01/app/*/grid/rdbms/audit
/u01/app/oracle/admin/*/adump
/u01/app/oracle/diag/asm/*/*/trace
/u01/app/oracle/diag/rdbms/*/*/trace
"

for DIR in $DIRS; do
  if [ -d "$DIR" ]; then
    printf " $(du -sh $DIR ) "
    printf " Oldest: $(date -r $DIR/$(ls -tr $DIR | head -1)) "
    printf " # Files: $(ls -f $DIR | wc -l)\n"
  fi
done
