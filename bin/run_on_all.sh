#!/bin/bash
###################################################
#
# Run a SQL script on all available instances
#
###################################################

#set -x

### get istance name function from profile
get_instancename_from_dbname() {
        DB_ENV_TO_SET=$RUNDB
        ASMPATH=$( grep ^+ASM $TOOLS_HOME/etc/oratab | tail -1 | awk -F: '{ print $2 }' )
        if [ ! -f "$ASMPATH/bin/crsctl" ]; then
                ORA_INST_NAME=$DB_ENV_TO_SET
        else
                # beneath is a workaround to get through profile if the system is starting,
                # and the cluster is not up yet, or the cluster is turned off.
                if [ ! -z "$( pgrep -f asm_pmon_+.* )" ]; then
                	ORA_INST_NAME=$( $ASMPATH/bin/crsctl status resource ora.${DB_ENV_TO_SET}.db -f | grep GEN_USR_ORA_INST_NAME | grep $( hostname -s ) | sed 's/^.*=//' )
                	if [ -z "$ORA_INST_NAME" ]; then
                       		ORA_INST_NAME=$DB_ENV_TO_SET
                	fi
                else
                        ORA_INST_NAME=$DB_ENV_TO_SET
                fi
        fi
}

### Die process, die! ###
function die()
{
    echo "$*"
    exit 1
}

SQLFILE="`echo $1`"

# grep -wi "delete\|drop\|update\|truncate" "${SQLFILE}" >/dev/null

#if [ $? -eq 0 ]
#then
#  echo "DML command  found!"
#   exit 1 
#else

for RUNDB in `ps -ef | grep [o]ra_pmon | grep -o [o]ra_pmon.* | sed 's/[o]ra_pmon_//g'`;

do

get_instancename_from_dbname

export ORACLE_SID="$RUNDB"; export ORAENV_ASK=NO; . oraenv &>/dev/null; export ORACLE_SID=$ORA_INST_NAME

test -f $ORACLE_HOME/bin/sqlplus || die "SQL*Plus is not found!"
   
get_sqloutput(){
   sqlplus -S / as sysdba <<EOF
   @"${SQLFILE}" 
EOF
}

cSqloutput="`get_sqloutput`"

if [ ! -z "${cSqloutput}" ]
then
   echo
   echo database: $ORACLE_SID -  results:
   get_sqloutput
   echo
   echo
else
   echo database: $ORACLE_SID - No results
fi

done

#fi

set +x
