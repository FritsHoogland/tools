rem fd.sql -- find in dictionary
rem simple script to find dictionary tables 
rem

def dictionary_table=&1

select table_name from dict where upper(table_name) like upper('%&&dictionary_table%')
union
select name from v$fixed_table where upper(name) like upper('%&&dictionary_table%')
union 
select object_name from dba_objects where upper(object_name) like upper('CDB_%&&dictionary_table%');

undefine dictionary_table


