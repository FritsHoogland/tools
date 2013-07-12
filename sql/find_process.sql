---------------------------------------
-- find an oracle process
-- usage @process.sql SEARCHVALUE 
-- e.g. @process DBWR or @process 1234
---------------------------------------

set verify OFF

col pid form 9999999
col os_user form a10
col username form a10
col program form a60
col host form a30 

select
  p.spid os_pid,
  s.sid sid,
  p.serial# serial#,
  s.machine host,
  p.username os_user,
  s.username db_user,
  s.program program
from
  v$session s,
  v$process p
where
  s.paddr = p.addr
and
  (s.program like '%&1%' 
  or s.username like '%&1%' 
  or p.username like '%&1%' 
  or s.machine like '%&1%' 
  or p.serial# like '%&1%' 
  or s.sid like '%&1%' 
  or p.spid like '%&1%')
order by spid

/