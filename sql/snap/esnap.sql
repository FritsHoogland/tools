rem snap v1.1 fritshoogland 14112010
create or replace procedure esnap ( snap_sid in number, be in number default 0 ) as
	snap_date	date			:= sysdate;
	pls_adjust 	constant number(10,0)	:= power(2,31) - 1;
	nr_records	number;
	char_be		varchar2(1) := be;
	time_diff       interval day(6) to second(6);
        calc_diff       number;
	cursor 		read_stats is
		select e.stype "STYPE", e.sid "SID", e.statistic# "STATISTIC#", e.value-nvl(b.value,0) "VALUE", e.name "NAME", e.snap_time "ESNAP_TIME", b.snap_time "BSNAP_TIME", 'R' "BE"
		from (select * from snaptemp where be='B' and sid=snap_sid) b,
                     (select * from snaptemp where be='E' and sid=snap_sid) e
		where b.statistic# (+) = e.statistic#
		and e.value-nvl(b.value,0) <> 0
		order by 2,3;
begin
	select count(*) into nr_records from snaptemp where sid = snap_sid and be = 'B';
	if nr_records = 0 then
		dbms_output.put_line('No begin snapshot found of SID '||snap_sid||'.');
		raise NO_DATA_FOUND;
	end if;
	insert into snaptemp
	select *
	from (
		SELECT 'STAT' STYPE,
			ss.SID SID,
			ss.STATISTIC# - PLS_ADJUST STATISTIC#,
			ss.VALUE, sn.name,
			snap_date snap_time,
			'E',
			null
		FROM V$SESSTAT SS, V$STATNAME SN
			WHERE SS.STATISTIC#=SN.STATISTIC#
			AND SID = snap_sid
                UNION ALL
                --
                SELECT 'WAIT',
                        SW.SID,
                        EN.EVENT# + (SELECT COUNT(*) FROM V$STATNAME) + 1  - PLS_ADJUST,
                                --NVL(SE.TIME_WAITED_MICRO,0) + ( DECODE(SE.EVENT||SW.STATE, SW.EVENT||'WAITING', SW.SECONDS_IN_WAIT, 0) * 1000000 ) VALUE, --oracle 10
                        NVL(SE.TIME_WAITED_MICRO,0)+ DECODE(SE.EVENT||SW.STATE, SW.EVENT||'WAITING',SW.WAIT_TIME_MICRO,0) VALUE, --oracle 11
                        en.name,
                        snap_date,
                        'E',
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
                        'E',
			null
                FROM V$SESS_TIME_MODEL
                        WHERE SID  = snap_sid
	);
	commit;
	delete from snaptemp where sid=snap_sid and be = 'R';
	commit;
	if be != 0 then
		delete from snaptemp where be = char_be;
		commit;
	end if;
	dbms_output.put_line('---------------------------------------------------------------------------------------------------------');
	dbms_output.put_line('SID  Stat Name                                  Diff                    Diff/Sec');
	dbms_output.put_line('---------------------------------------------------------------------------------------------------------');
	for stat_diffs in read_stats loop
        	time_diff := (stat_diffs.esnap_time-stat_diffs.bsnap_time);
        	calc_diff := extract(hour from time_diff)*60*60+extract(minute from time_diff)*60+extract( second from time_diff);
                if stat_diffs.stype = 'WAIT' or stat_diffs.stype = 'TIME' then
                        dbms_output.put_line(to_char(stat_diffs.sid,'B9999')||','||stat_diffs.stype||' '||substr(stat_diffs.name,1,40)||' '||to_char((stat_diffs.value/1000000),'9,999,999,999,999.999')||' '||to_char(stat_diffs.value/(calc_diff*1000000),'9,999,999,999,999.999'));
                else
                        dbms_output.put_line(to_char(stat_diffs.sid,'B9999')||','||stat_diffs.stype||' '||substr(stat_diffs.name,1,40)||' '||to_char(stat_diffs.value,'9,999,999,999,999')||'     '||to_char(stat_diffs.value/calc_diff,'9,999,999,999,999.999'));
                end if;
		insert into snaptemp values ( stat_diffs.stype, stat_diffs.sid, stat_diffs.statistic#, stat_diffs.value, stat_diffs.name, stat_diffs.esnap_time, stat_diffs.be, time_diff );
		if be != 0 then
			insert into snaptemp values ( stat_diffs.stype, stat_diffs.sid, stat_diffs.statistic#, stat_diffs.value, stat_diffs.name, stat_diffs.esnap_time, be, time_diff );
		end if;
	end loop;
        dbms_output.put_line('--------------------');
        dbms_output.put_line('Time in snapshot: '||to_char((calc_diff*1000000),'9,999,999,999')||' usec');
        dbms_output.put_line('WAIT and TIME values are in sec');
        dbms_output.put_line('--------------------');
	commit;
	delete from snaptemp where sid = snap_sid and be in ('B','E');
	commit;
end;
/
