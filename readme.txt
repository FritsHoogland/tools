#########
# Tools #
#########

This is a simple toolset for use with Linux systems and Oracle databases.
It is known to work on Unix systems (HPUX, AIX, Solaris), as long as there's a bash shell.
Some functions probably do not work out of the box (rlwrap/libreadline support for example).

Created and maintained by Klaas-Jan Jongsma and Frits Hoogland of VX Company.
Any comments can be mailed to kjjongsma@vxcompany.com or fhoogland@vxcompany.com

The focus lies a bit on Oracle's Exadata nowadays (it's Oracle Linux).

1. Installation
2. What profile arranges for you


1. Installation
If you've received or downloaded tools as a gzipped tarball, upload it to a unix/linux server you want this to work on, and log in as the 'oracle' user. Next, make sure '/u01' is writable for 'oracle', and if so, install it:
$ tar xzf ~/tools.tgz -C /u01

In order to get everything setup in the bash shell, add the following line to ~/.bash_profile:
. /u01/tools/bin/profile

If your platform has its oratab in /etc/oratab, you do not need to do anything. If your platform has its oratab in /var/opt (solaris), modify the symlink the following way:
$ ln -sf /var/opt/oratab /u01/tools/etc/oratab

If the 'rlwrap' utility is not installed (which isn't by default), install it using the rpm (RHEL/OL 5 or 6 x86_64 only) in /u01/tools/rpm/x86_64.
Additionally, you could install a few more rpm's if you wish, most notably the 'screen' package, to make your session survive network failure. Screen seems to have made the OL repository with OL6.
Please mind installing rpm packages requires root privileges, either via becoming root, or via privileges delegated via sudo.

That's all, now if you create a new session, tools will show you the currently installed databases (via /u01/tools/etc/oratab), if they are up or down, and have all the aliasses in place.

2. What profile arranges for you
If you log in, the /u01/tools/bin/profile script is executed if you log in via a terminal. If TERM starts with 'xterm', profile should understand. If your terminal is a little more exotic, profile will not understand you are a terminal, and display nothing. In order to get that fixed, you could either get your terminal type set to xterm, or modify the source to include your terminal.

The first row profile outputs displays the hostname, architecture and operating system. This is to make sure you've logged on to the correct machine, and understand on what type of machine you are.
The second row displays the output of the uptime command. Most important are the load figures here, so you get an understanding of the business of the operating system.

If oraenv is not installed in /usr/local/bin, profile will generate a message. It will not stop, and continue to execute. 
The next steps it reads the /u01/tools/etc/oratab link to your oratab file, and display the database names in it, and if they are up or down (done in a simple way by looking if the pmon process exist for the database name), and generating a set of shell aliases in order to set the environment.

The aliasses use the default, generic way to set the environment (set ORACLE_SID and ORACLE_HOME) by executing oraenv. 

If you've looked closely, you see that tools generated an extra set of brackets in the shell prompt: []. If you set an database environment by typing the database name, the INSTANCE name (ORACLE_SID) is placed between the brackets. Additionally, the present working directory, ORACLE_SID and ORACLE_HOME are displayed in the window header too.

If an environment is set, the ORACLE_HOME is added to the CDPATH shell variable, along with the trace directory of the instance in the diagnostics repository. This means you can jump to any directory in the ORACLE_HOME or the database or ASM diag dest home from anywhere.

A besides all the database settings, a set of aliasses is added to make common administration commands shorter:
sq              rsqlplus '/ as sysdba'
sqa             rsqlplus '/ as sysasm'
cstat           ASM_HOME/bin/crsctl status resource -t
rs      :        rlwrap sqlplus
rr              rlwrap rman target /
rd              rlwrap dgmgrl /
oh              cd $ORACLE_HOME
reprofile		execute bin/profile again, mostly for re-reading oratab

3. And further
There's a lot more to find and use in tools:
- Exadata (or: OFA installed linux) post-installation setup:
add_symlinks_cron.daily_logrotate.d.exadata
add_wheel_to_oracle.exadata
get_interconnect.sh
- Exadata (or: linux and ASM) tools
exaclone
testcasebuilder.sh
- A screenrc file to configure screen: etc/dot_screenrc (copy to ~/.screenrc)
- Templates in etc/dbca with accompanying shell script to install databases. These templates are heavily focussed on Exadata
- sql scripts in sql/ (profile sets up SQLPATH to sql/ and changes the sqlplus prompt)
addm			run ADDM on a series of AWR snapshots
as			active sessions
dplan			display execution plan of a sql_id
dplan_allstats		display execution plan with all stats 
export_sql_profile	export sql profile hints as script
fd			find in dictionary
find_sql		find a SQL statement in the SQL-area
parms			display values of parameters, including underscore ones if you want
reclaimable_space	show amounts of reclaimable space
run_tuning_task		..
segment_advisor		run segment advisor on a certain segment
sql_monitor		run sql_monitor report for a given sid or sid and sql_id (sql_id in the past)
view_tuning_task	view output of a certain tuning task


