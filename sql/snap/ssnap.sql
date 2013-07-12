rem snap v1.1 fritshoogland 14112010
create or replace procedure ssnap ( snap_sid in number ) as
	nr_records	number;
        time_diff       interval day(6) to second(6);
        calc_diff       number;
	cursor		read_stats is
		select * from snaptemp where sid = snap_sid and be = 'R' order by sid,statistic#;
begin
	select count(*) into nr_records from snaptemp where sid = snap_sid;
	if nr_records = 0 then
		dbms_output.put_line('No result records found for SID '||snap_sid||'.');
		raise NO_DATA_FOUND;
	end if;
        dbms_output.put_line('---------------------------------------------------------------------------------------------------------');
        dbms_output.put_line('SID  Stat Name                                  Diff                    Diff/Sec');
        dbms_output.put_line('---------------------------------------------------------------------------------------------------------');
	for stat_diffs in read_stats loop
		time_diff := stat_diffs.valueps;
		calc_diff := extract(hour from time_diff)*60*60+extract(minute from time_diff)*60+extract( second from time_diff);
                if stat_diffs.stype = 'WAIT' or stat_diffs.stype = 'TIME' then
                        dbms_output.put_line(stat_diffs.sid||','||stat_diffs.stype||' '||substr(stat_diffs.name,1,40)||' '||to_char((stat_diffs.value/1000000),'9,999,999,999,999.999')||' '||to_char(stat_diffs.value/(calc_diff*1000000),'9,999,999,999,999.999'));
                else
                        dbms_output.put_line( stat_diffs.sid||','||stat_diffs.stype||' '||substr(stat_diffs.name,1,40)||' '||to_char(stat_diffs.value,'9,999,999,999,999')||'     '||to_char(stat_diffs.value/calc_diff,'9,999,999,999,999.999'));
                end if;
	end loop;
        dbms_output.put_line('--------------------');
        dbms_output.put_line('Time in snapshot: '||to_char((calc_diff*1000000),'9,999,999,999')||' usec');
        dbms_output.put_line('WAIT and TIME values are in sec');
        dbms_output.put_line('--------------------');
end;
/
