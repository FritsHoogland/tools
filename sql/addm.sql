select dbms_advisor.get_task_report(task_name,'TEXT','BASIC') as ADDM_report
from  dba_advisor_tasks
where task_id = (
	select max(t.task_id)
	from dba_advisor_tasks t, dba_advisor_log l
	where t.task_id = l.task_id
	and t.advisor_name = 'ADDM'
	and l.status = 'COMPLETED'
);
