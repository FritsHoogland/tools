-- an alternative for DESCRIBE, show table and collumn comments if they are available
-- usage: @desc (<schema>).<table_name>

col value form a80
col table_name form a30
col name form a50
col comments form a80
col column_name form a30
col type form a20
col "Null?" form a8

def table_name=&1

set verify off head off feedback off 

-- get table comments --
prompt

select * from (
select s.owner, s.tablename, c.comments from 
(SELECT *
FROM
  ( WITH split_input AS
  (SELECT trim(trailing '.' FROM regexp_substr('&&table_name','^.*\.')) requested_owner, -- get table name from user.table input
    sys_context('USERENV', 'CURRENT_USER') current_user,                                 -- get name from currently connected user
    trim(leading '.' FROM regexp_substr('&&table_name','\..*')) requested_table          -- get table name from user.table input
  FROM dual
  )
SELECT 
  CASE
    WHEN requested_owner IS NULL
    THEN current_user
    ELSE requested_owner
  END "OWNER",                                                                           -- if no user is submitted get current user
  CASE
    WHEN requested_table IS NULL
    THEN '&&table_name'
    ELSE requested_table
  END "TABLENAME"                                                                        -- if we find now table name we assume the prompt is only  the tablename
FROM split_input)) s,
  dba_tab_comments c
WHERE upper(c.table_name)                 = upper(s.tablename)
AND upper(c.owner)                        = upper(s.owner))
UNPIVOT INCLUDE NULLS (VALUE FOR COL IN (TABLENAME,OWNER,COMMENTS));

prompt
prompt

-- get describe information  --

set head on
select a.column_name NAME,
       a.data_type||' ('||a.data_length||')' TYPE,
       case
         when a.nullable = 'Y' then NULL
         when a.nullable = 'N' then 'NOT NULL'
         else a.nullable end "Null?",
       b.comments
from dba_tab_cols a, dba_col_comments b,
(WITH split_input AS
  (SELECT trim(trailing '.'
  FROM regexp_substr('&&table_name','^.*\.')) requested_owner,
    sys_context('USERENV', 'CURRENT_USER') current_user,
    trim(leading '.'
  FROM regexp_substr('&&table_name','\..*')) requested_table
  FROM dual
  )
SELECT
  CASE
    WHEN requested_owner IS NULL
    THEN current_user
    ELSE requested_owner
  END "OWNER",
  CASE
    WHEN requested_table IS NULL
    THEN '&&table_name'
    ELSE requested_table
  END "TABLENAME"
FROM split_input) s
where a.column_name=b.column_name
and a.table_name=b.table_name
and upper(b.table_name)=upper(s.tablename)
and upper(b.owner)=upper(s.owner)
and upper(a.owner)=upper(s.owner);

undefine table_name
undefine 1
set verify on feedback on

clear columns

