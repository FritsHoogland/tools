rem fd.sql -- find in dictionary
rem simple script to find dictionary tables 
rem
select table_name from dict where upper(table_name) like upper('%&&dictionary_table%')
union
select name from v$fixed_table where upper(name) like upper('%&&dictionary_table%');
undefine dictionary_table
