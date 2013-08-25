select
	    substr(a.spid,1,9) pid,
	    substr(b.sid,1,5) sid,
	    substr(b.serial#,1,5) serial#,
	    substr(b.machine,1,20) machine,
	    substr(b.username,1,10) username,
	    b.server, server,
	    substr(b.osuser,1,15) osuser,
	    substr(b.program,1,30) program
from v$session b, v$process a
where
b.paddr = a.addr
and type='USER'
order by spid
/
