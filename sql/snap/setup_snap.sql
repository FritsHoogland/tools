rem snap v1.1 fritshoogland 14112010
/* begin and end snap
 *
 * this tool is STRONGLY inspired on Tanel Poder's snapper.
 * it als appears to be quite similar to a tool tom kyte wrote.
 * thank you, Tanel!
 *
 * SETUP/INSTALL
 * setup besnap using a database user which has DBA privileges: @setup_snap.sql
 * this should not lead to any errors!
 * if you snapped something, and try to reinstall, the installation produre cannot update the GTT.
 *
 * USAGE
 * exec bsnap(<SID>);
 *  begin snap.
 * exec esnap(<SID>);
 *  end snap: this lists the statistics which have been changed between begin and end snapshot time.
 * exec ssnap(<SID>);
 *  show snap result: this shows the result of the end snapshot again.
 * 
 * REMOVE/DEINSTALL
 * remove besnap temporary table and procedures: @remove_snap.sql
 *
 * NOTICE: use at your own risk!
 *
 * by frits hoogland
 * version 1.1
 * changelog:
 * 14112010	FH	major overhaul. added a per second column.
*/
drop table snaptemp;
create global temporary table snaptemp ( stype varchar2(5), sid number, statistic# number, value number, name char(64), snap_time timestamp, be varchar2(1), valueps interval day(6) to second(6) ) on commit preserve rows;
@bsnap
@esnap
@ssnap
