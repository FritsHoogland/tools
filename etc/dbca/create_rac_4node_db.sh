#!/bin/bash
[ "$USER" != "oracle" ] && echo "Error: userid should be oracle." && exit 1
####
# For RAC, set -gdbname and -sid to be the same, DBCA numbers the instances according to the nodes in -nodeinfo
####
if eval which dbca >& /dev/null; then
	dbca -silent -createdatabase \
	-templatename /u01/tools/etc/dbca/create_rac_4node_db.dbt \
	-gdbname db -sid db \
	-syspassword oracle -systempassword oracle -dbsnmppassword oracle \
	-nodeinfo dm01db01,dm01db02,dm01db03,dm01db04 \
	-asmsyspassword welcome1 -storagetype asm -diskgroupname data -recoverygroupname reco
else
	echo "Error: dbca not in path."
	exit 1
fi
# 1. add instance name to oratab (dbca does database name)
# echo "db1:/u01/app/oracle/product/11.2.0.2/dbhome_1:N" >> /etc/oratab
# ssh dm01db02 echo "db2:/u01/app/oracle/product/11.2.0.2/dbhome_1:N" >> /etc/oratab
# ssh dm01db03 echo "db3:/u01/app/oracle/product/11.2.0.2/dbhome_1:N" >> /etc/oratab
# ssh dm01db04 echo "db4:/u01/app/oracle/product/11.2.0.2/dbhome_1:N" >> /etc/oratab
#
# 2. set remote_listener to scan listener
# sqlplus / as sysdba 
# SQL> alter system set remote_listener='dm01-scan:1521' scope=both sid='*';
#
# 3. set cluster_interconnects to result of get_interconnect.sh script
# sqlplus / as sysdba
# SQL> alter system set cluster_interconnects='192.168.100.1' scope=spfile sid='db1';
# SQL> alter system set cluster_interconnects='192.168.100.2' scope=spfile sid='db2';
# SQL> alter system set cluster_interconnects='192.168.100.3' scope=spfile sid='db3';
# SQL> alter system set cluster_interconnects='192.168.100.4' scope=spfile sid='db4';
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
# dbca -silent -deletedatabase -sourcedb db -sysdbausername sys -sysdbapassword oracle
