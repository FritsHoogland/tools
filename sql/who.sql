set pagesize 999
set lines 999
set verify off
col username format a13
col inst format a5
col sid_serial_inst format a15
col ospid format a8
-- trickery to suppress asking for the first parameter if not provided.
-- don't worry: if you don't get it, I got it off the internet, I did not came up with it myself.
set termout off
col p1 new_value 1
select null p1 from dual where 1=2;
select nvl('&1','short') p1 from dual;
set termout on
select
-- things we always want
	a.sid||','||a.serial#||',@'||a.inst_id as sid_serial_inst,
	d.spid as ospid,
	a.username as username,
	a.server as server,
	a.program as program,
-- case statements for the extra column
	case lower('&1')
	when 'long' then a.module||','||a.action||','||a.resource_consumer_group
	when 'active' then 'time:'||round(a.wait_time_micro/1000,2)||'ms,event:'||decode(a.plsql_object_id,null,decode(a.wait_time,0,decode(a.blocking_session,null,a.event,a.event||'> Blocked by (inst:sid): '||a.final_blocking_instance||':'||a.final_blocking_session),'ON CPU:SQL'),(select 'ON CPU:PLSQL:'||object_name from dba_objects where object_id=a.plsql_object_id))||',seq#:'||a.seq#
	when 'activeall' then 'time:'||round(a.wait_time_micro/1000,2)||'ms,event:'||decode(a.plsql_object_id,null,decode(a.wait_time,0,decode(a.blocking_session,null,a.event,a.event||'> Blocked by (inst:sid): '||a.final_blocking_instance||':'||a.final_blocking_session),'ON CPU:SQL'),(select 'ON CPU:PLSQL:'||object_name from dba_objects where object_id=a.plsql_object_id))||',seq#:'||a.seq#
	when 'sql' then 'sql_id:'||a.sql_id||',child#:'||a.sql_child_number
	end extra
from 	gv$session a,
	gv$process d
where 1=1
and a.inst_id = d.inst_id
and a.paddr = d.addr
and a.sid like case lower('&1') when 'ami' then sys_context('USERENV', 'SID') else '%' end
and a.type like case when lower('&1') in ('short','long','active','sql') then 'USER' else '%' end
and a.type like case lower('&1') when 'bg' then 'BACKGROUND' else '%' end
/
undef 1
