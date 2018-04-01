#!/bin/bash

db_host="localhost"
db_user="root"
db_pass="yourpassword"

date=$(date +"%d-%b-%Y")

mysql_path="/var/lib/mysql/"
backups_path="/backups/mysql"

dbs=( $(find $mysql_path -maxdepth 1 -type d -printf '%P\n') )

for db in "${dbs[@]}" 
do
	# performance_schema cannot be locked with LOCK TABLES so let's skip it
	# https://dev.mysql.com/doc/refman/5.6/en/performance-schema-restrictions.html
	if [ "$db" == "performance_schema" ]
	then
		continue
	fi

	mysqldump --user=$db_user --password=$db_pass --host=$db_host $db > $backups_path/$db-$date.sql
done
