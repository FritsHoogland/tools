#!/bin/bash
[ "$USER" != "oracle" ] && echo "Error: userid should be oracle." && exit 1
if eval which dbca >& /dev/null; then
	dbca -silent -createdatabase \
	-templatename /u01/tools/etc/dbca/db_nonrac_template.dbt \
	-gdbname db -sid db \
	-syspassword oracle -systempassword oracle -dbsnmppassword oracle \
	-asmsyspassword welcome1 -storagetype asm -diskgroupname data -recoverygroupname reco
else
	echo "Error: dbca not in path."
	exit 1
fi
# 1. set remote_listener to scan listener
# sqlplus / as sysdba 
# SQL> alter system set remote_listener='dm01-scan:1521' scope=both sid='*';
#
# 2. block change tracking
# sqlplus / as sysdba
# SQL> alter database enable block change tracking;
#
# 3. disable case sensitive passwords
# sqlplus / as sysdba
# SQL> alter system set sec_case_sensitive_logon = false;
#
# 4. disable password aging
# sqlplus / as sysdba
# SQL> alter profile default limit PASSWORD_LIFE_TIME unlimited;
#
##########################
# delete database:
# dbca -silent -deletedatabase -sourcedb db -sysdbausername sys -sysdbapassword oracle
