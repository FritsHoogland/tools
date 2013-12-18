set pagesize 999
set lines 999
col username format a13
col inst format a5
col sid_serial_inst format a15
col ospid format a8
col prog format a40 trunc
col sid format 9999
col child for 99999
col spid format 999999
col module format a60
col action format a20
col client_info format a30
select /*+ rule as.sql */ a.sid||','||a.serial#||',@'||a.inst_id as sid_serial_inst, 
	d.spid as ospid, 
	a.program prog, 
	a.module, a.action, a.client_info,
	a.server, a.username
--	'SQL:'||b.sql_id as sql_id, child_number child, plan_hash_value, executions execs,
--	(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
--	decode(a.plsql_object_id,null,sql_text,(select distinct sqla.object_name||'.'||sqlb.procedure_name from dba_procedures sqla, dba_procedures sqlb where sqla.object_id=a.plsql_object_id and sqlb.object_id = a.plsql_object_id and a.plsql_subprogram_id = sqlb.subprogram_id)) sql_text, 
--	(c.wait_time_micro/1000000) wait_s, 
--	decode(a.plsql_object_id,null,decode(c.wait_time,0,decode(a.blocking_session,null,c.event,c.event||'> Blocked by (inst:sid): '||a.final_blocking_instance||':'||a.final_blocking_session),'ON CPU:SQL'),(select 'ON CPU:PLSQL:'||object_name from dba_objects where object_id=a.plsql_object_id)) as wait_or_cpu
from gv$session a, gv$session_wait c, gv$process d
where 1=1
and a.sid = c.sid
and a.inst_id = c.inst_id
and a.inst_id = d.inst_id
and a.paddr = d.addr
/
