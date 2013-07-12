#!/bin/bash
set -x
[ "$USER" != "oracle" ] && echo "Error: userid should be oracle." && exit 1
####
# For RAC, set -gdbname and -sid to be the same, DBCA numbers the instances according to the nodes in -nodeinfo
####
if eval which dbca >& /dev/null; then
	dbca -silent -createdatabase \
	-templatename /u01/tools/etc/dbca/create_dbfs_2node.dbt \
	-gdbname dbfs -sid dbfs \
	-syspassword oracle -systempassword oracle -dbsnmppassword oracle \
	-nodeinfo dm0101,dm0102 \
	-asmsyspassword welcome1 -storagetype asm -diskgroupname dbfs_dg -recoverygroupname dbfs_dg
else
	echo "Error: dbca not in path."
	exit 1
fi
# 1. add instance name to oratab (dbca does database name)
# echo "db1:/u01/app/oracle/product/11.2.0.2/dbhome_1:N" >> /etc/oratab
# ssh dm01db02 echo "db2:/u01/app/oracle/product/11.2.0.2/dbhome_1:N" >> /etc/oratab
#
# 2. set remote_listener to scan listener
# sqlplus / as sysdba 
# SQL> alter system set remote_listener='dm01-scan:1521' scope=both sid='*';
#
# 3. set cluster_interconnects to result of get_interconnect.sh script
# sqlplus / as sysdba
# SQL> alter system set cluster_interconnects='192.168.100.1' scope=spfile sid='db1';
# SQL> alter system set cluster_interconnects='192.168.100.2' scope=spfile sid='db2';
#
# 4. block change tracking
# sqlplus / as sysdba
# SQL> alter database enable block change tracking;
#
# 5. disable case sensitive passwords
# sqlplus / as sysdba
# SQL> alter system set sec_case_sensitive_logon = false;
#
# 6. disable password aging
# sqlplus / as sysdba
# SQL> alter profile default limit PASSWORD_LIFE_TIME unlimited;
#
##########################
# delete database:
# !! This does not clean up the files in the data and reco diskgroups, that needs to be done manually !!
# dbca -silent -deletedatabase -sourcedb dbfs -sysdbausername sys -sysdbapassword oracle
