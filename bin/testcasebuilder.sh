#!/bin/bash
#
#  DESCRIPTION
#    SQL Test Case Builder script.
#    Pass in the SQL_ID as the first parameter.
#    Assumes:
#    - you are using an user which can connect as sys,
#    - are on Unix (tested on Linux OL5u7),
#    - can write to the /tmp directory.
#
#  Created by Greg Rahn on 2011-08-19.
#  Copyright (c) 2011 Greg Rahn. All rights reserved.
#  Modified by Frits Hoogland
#
#  enable shell tracing if -x is set as first parameter.
[ "$1" = "-x" ] && set -x && shift
#
# $1 should contain something, hopefully an sql_id
[ -z "$1" ] && echo "Usage: $0 <sql_id>" && exit 1

# set BASE appropriately
BASE=$HOME
# in BASE we'll make a tcb directory and a directory for that SQL_ID
# first remove that directory if it exists already.
[ -d $BASE/tcb/$1 ] && rm -rf $BASE/tcb/$1
mkdir -p $BASE/tcb/$1

sqlplus / as sysdba <<EOF
set serveroutput on
spool /tmp/tcb$$.out
create or replace directory "$1" as '$BASE/tcb/$1';
declare
    l_tc clob;
    l_dump varchar2(4000);
    l_txt varchar2(4000);
begin
    dbms_sqldiag.export_sql_testcase(
        directory=>'$1',
        sql_id=>'$1',
        exportdata=>false,
        testcase=>l_tc);
    --
    -- this is a hack workaround for bug 11897651
    -- dbms_sqldiag.export_sql_testcase creates the CBO trace but does not copy it
    --
    select value into l_dump from v\$parameter where name='background_dump_dest';
    l_txt := xmltype(l_tc).extract('/SQL_TESTCASE/PARAMETER[@name="NAME"]/text()').getStringVal();
    dbms_output.put_line('mv '||l_dump||'/*'||trim(l_txt)||'.trc $BASE/tcb/$1');
end;
/
spool off
drop directory "$1" ;
EOF
#
# get & execute the mv command to move the trace file from background_dump_dest to $BASE/tcb/$1
#
grep ^mv /tmp/tcb$$.out > /tmp/getf$$.sh
sh /tmp/getf$$.sh
rm /tmp/tcb$$.out /tmp/getf$$.sh
#
# tar the directory for transportation
tar czvf ~/tcb_${1}.tgz $BASE/tcb/$1
