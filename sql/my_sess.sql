col sid format a60
col host format a60
col instance_name format a60
col module format a60
col service_name format a60

set head off
set feedback off
set newpage none

prompt
prompt This session info:

select 'SID                = '||sys_context('USERENV', 'SID') SID from dual;
select 'OS PID             = '||p.spid from v$session s, v$process p where s.paddr = p.addr and s.sid=sys_context('USERENV', 'SID');
select 'DB PID             = '||p.pid from v$session s, v$process p where s.paddr = p.addr and s.sid=sys_context('USERENV', 'SID');
select 'tracefile          = '||p.tracefile from v$session s, v$process p where s.paddr = p.addr and s.sid=sys_context('USERENV', 'SID');
select 'Current host       = '||sys_context('USERENV', 'HOST') HOST from dual;
select 'Connected instance = '||sys_context('USERENV', 'INSTANCE_NAME') INSTANCE_NAME from dual;
select 'Service used       = '||sys_context('USERENV', 'SERVICE_NAME') SERVICE_NAME from dual;

prompt

set newpage 1
set feedback on
set head on
clear col
