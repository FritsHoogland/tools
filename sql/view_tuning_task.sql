set serveroutput on
set linesize 200
set pages 2000
set long 1000000 longchunksize 1000
select owner, execution_end, task_name, status from dba_advisor_log where task_name not like 'ADDM%' order by execution_end;
select dbms_sqltune.report_tuning_task('&&task_name') as recommendations from dual;
