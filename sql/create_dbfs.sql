create bigfile tablespace dbfs datafile '+DBFS_DG' size 10g autoextend on next 1g maxsize &dbfs_maxsize nologging extent management local autoallocate segment space management auto;
create user dbfs identified by dbfs default tablespace dbfs temporary tablespace temp quota unlimited on dbfs;
grant create session, create table, create view, create procedure, dbfs_role to dbfs;
rem
rem tablespace and user created. 
rem now create the database filesystem as dbfs:
rem $ cd $ORACLE_HOME/rdbms/admin
rem sqlplus dbfs/dbfs
rem start dbfs_create_filesystem dbfs fs1
