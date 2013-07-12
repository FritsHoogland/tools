set serveroutput on
set feedback off
set verify off

variable id number;
begin
  declare
  	name varchar2(100);
  	descr varchar2(500);
  	current_sysdate varchar2(12);
	v_segment_name dba_advisor_objects.attr2%type;
  	v_partition dba_advisor_objects.attr3%type;
  	v_type dba_advisor_objects.type%type;
  	v_message dba_advisor_findings.message%type;
  	v_more_info dba_advisor_findings.more_info%type;
	v_how1 dba_advisor_actions.attr1%type;
	v_how2 dba_advisor_actions.attr2%type;
	v_how3 dba_advisor_actions.attr3%type;
  	obj_id number;
  begin

  select to_char(sysdate,'yyyymmddhh24mi') into current_sysdate from dual;
  name:='SA_'||current_sysdate;
  descr:='Run segment advisor manually for &&object_type &&owner..&&object_name..';

  dbms_advisor.create_task (
    advisor_name     => 'Segment Advisor',
    task_id          => :id,
    task_name        => name,
    task_desc        => descr);

  dbms_advisor.create_object (
    task_name        => name,
    object_type      => '&&object_type',
    attr1            => '&&owner',
    attr2            => '&&object_name',
    attr3            => NULL,
    attr4            => NULL,
    attr5            => NULL,
    object_id        => obj_id);

  dbms_advisor.set_task_parameter(
    task_name        => name,
    parameter        => 'recommend_all',
    value            => 'TRUE');

  dbms_advisor.execute_task(name);

select	ao.attr2, ao.attr3, ao.type, af.message, af.more_info, aa.attr1, aa.attr2, aa.attr3
  	into v_segment_name, v_partition, v_type, v_message, v_more_info, v_how1, v_how2, v_how3
from 	dba_advisor_findings af, 
	dba_advisor_objects ao,
	dba_advisor_actions aa
where 	ao.task_id = af.task_id
and 	ao.object_id = af.object_id
and	ao.task_id = aa.task_id
and	ao.object_id = aa.object_id
and	af.task_name = name;

dbms_output.put_line('Segment name       : '||v_segment_name);
dbms_output.put_line('Segment partition  : '||v_partition);
dbms_output.put_line('Segment type       : '||v_type);
dbms_output.put_line('Message            : '||v_message);
dbms_output.put_line('How                : '||v_how1);
dbms_output.put_line('.                  : '||v_how2);
dbms_output.put_line('.                  : '||v_how3);
dbms_output.put_line('More info          : '||v_more_info);

  end;
end; 
/
