--------------------------------------------------------------------------
-- Shows the output of the v$session of a given sid in a columnar fashion
-- Usage @session_info SID e.g. @session_info 123
--------------------------------------------------------------------------

set serveroutput on size 1000000
set verify off

declare
v_query varchar2(3000);
v_output varchar2(3000);
v_pad number;
v_sid number := &1;

begin

select max(length(column_name)) into v_pad from dba_tab_cols where table_name ='V_$SESSION' order by column_id;

for col in (select column_name from dba_tab_cols where table_name ='V_$SESSION' order by column_id) loop
  v_query := 'select '||col.column_name||' from v$session where sid='||v_sid||'';
  execute immediate v_query into v_output;
  dbms_output.put_line(rpad(col.column_name, v_pad, ' ')||' = '|| v_output);
end loop;

end;
/