for resource in $(crsctl status resource -w "((TYPE = ora.database.type) AND (LAST_SERVER = $(hostname -s)))" | grep ^NAME | sed 's/.*=//'); do 
	full_resource=$(crsctl status resource -w "((NAME = $resource) AND (LAST_SERVER = $(hostname -s)))" -f)
	db_name=$(echo "$full_resource" | grep ^DB_UNIQUE_NAME | awk -F= '{ print $2 }')
	ora_home=$(echo "$full_resource" | grep ^ORACLE_HOME= | awk -F= '{ print $2 }')
	printf "%s:%s:N\n" $db_name $ora_home 
done
