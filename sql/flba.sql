rem find latch by address
rem frits hoogland
set termout off
col p1 new_value 1
select null p1 from dual where 1=2;
select nvl('&1','short') p1 from dual;
set termout on
select addr, name from v$latch where to_number(addr,'XXXXXXXXXXXXXXXX') = to_number('&1','XXXXXXXX')
union all
select addr, name from v$latch_children where to_number(addr,'XXXXXXXXXXXXXXXX') = to_number('&1','XXXXXXXX')
union all
select addr, name from v$latch_parent where to_number(addr,'XXXXXXXXXXXXXXXX') = to_number('&1','XXXXXXXX')
/
undef 1
