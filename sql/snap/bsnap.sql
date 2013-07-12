rem snap v1.1 fritshoogland 14112010
create or replace procedure bsnap ( snap_sid in number ) as
	snap_date	date			:= sysdate;
	pls_adjust 	constant number(10,0)	:= power(2,31) - 1;
	sid_check	number;
begin
	select count(*) into sid_check from v$session where sid = snap_sid;
	if sid_check = 0 then
		dbms_output.put_line('Error: SID '||snap_sid||' not found.');
		raise NO_DATA_FOUND;
	end if;
	delete from snaptemp where sid=snap_sid and be in ('B','E');
	commit;
	insert into snaptemp
	select *
	from (
		SELECT 'STAT' STYPE,
			ss.SID SID,
			ss.STATISTIC# - PLS_ADJUST STATISTIC#,
			ss.VALUE, 
			sn.name,
			snap_date snap_time,
			'B',
			null
		FROM V$SESSTAT SS, V$STATNAME SN
			WHERE SS.STATISTIC#=SN.STATISTIC#
			AND SID = snap_sid
		UNION ALL
		--
		SELECT 'WAIT' STYPE, 
			SW.SID SID,
			EN.EVENT# + (SELECT COUNT(*) FROM V$STATNAME) + 1  - PLS_ADJUST STATISTIC#,
				--NVL(SE.TIME_WAITED_MICRO,0) + ( DECODE(SE.EVENT||SW.STATE, SW.EVENT||'WAITING', SW.SECONDS_IN_WAIT, 0) * 1000000 ) VALUE, --oracle 10
			NVL(SE.TIME_WAITED_MICRO,0)+ DECODE(SE.EVENT||SW.STATE, SW.EVENT||'WAITING',SW.WAIT_TIME_MICRO,0) VALUE, --oracle 11
			en.name,
			snap_date snap_time,
			'B',
			null
		from v$session_wait sw, v$session_event se, v$event_name en
			where sw.sid = se.sid
			AND   SE.EVENT = EN.NAME
			AND   SE.SID = snap_sid
		UNION ALL
		--
		SELECT 'TIME', 
			SID, 
			STAT_ID - pls_adjust statistic#, 
			VALUE, 
			stat_name,
			snap_date snap_time,
			'B',
			null
		FROM V$SESS_TIME_MODEL
			WHERE SID  = snap_sid
	);
	commit;
	dbms_output.put_line('Begin snapshot for SID '||snap_sid||' created.');
end;
/
