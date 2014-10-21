set head off pages 0 lines 200 term off echo off
spool /tmp/look_tracefile.sh
select 'less '||value from v$diag_info where name = 'Default Trace File';
select 'rm /tmp/look_tracefile.sh' from dual;
spool off
host sh /tmp/look_tracefile.sh
