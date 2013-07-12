set pagesize 999
set lines 150
col username format a13
col inst format a5
col sid_serial_inst format a15
col ospid format a8
col prog format a10 trunc
col sql_text format a150 trunc
col sid format 9999
col child for 99999
col spid format 999999
col module format a20
col action format a20
col client_info format a30
col avg_etime for 999,999.99
col wait_s for 999,999.999
col wait_or_cpu for a80
select /*+ rule as.sql */ a.sid||','||a.serial#||',@'||a.inst_id as sid_serial_inst, 
	d.spid as ospid, 
	substr(a.program,1,19) prog, 
	a.module, a.action, a.client_info,
	'SQL:'||b.sql_id as sql_id, child_number child, plan_hash_value, executions execs,
	(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
	decode(a.plsql_object_id,null,sql_text,(select distinct sqla.object_name||'.'||sqlb.procedure_name from dba_procedures sqla, dba_procedures sqlb where sqla.object_id=a.plsql_object_id and sqlb.object_id = a.plsql_object_id and a.plsql_subprogram_id = sqlb.subprogram_id)) sql_text, 
	(c.wait_time_micro/1000000) wait_s, 
	decode(a.plsql_object_id,null,decode(c.wait_time,0,decode(a.blocking_session,null,c.event,c.event||'> Blocked by (inst:sid): '||a.final_blocking_instance||':'||a.final_blocking_session),'ON CPU:SQL'),(select 'ON CPU:PLSQL:'||object_name from dba_objects where object_id=a.plsql_object_id)) as wait_or_cpu
from gv$session a, gv$sql b, gv$session_wait c, gv$process d
where a.status = 'ACTIVE'
and a.username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sid = c.sid
and a.inst_id = c.inst_id
and a.inst_id = d.inst_id
and a.paddr = d.addr
and a.sql_child_number = b.child_number
and sql_text not like 'select /*+ rule as.sql */%' -- don't show this query
order by sql_id, sql_child_number
/
