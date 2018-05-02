#!/bin/bash

db_host="localhost"
db_user="root"
db_pass="yourpassword"

datetime=$(date +"%d-%b-%Y-%H-%M-%S")

mysql_path="/var/lib/mysql/"
backups_path="/backups/mysql/daily"

dbs=( $(find $mysql_path -maxdepth 1 -type d -printf '%P\n') )

for db in "${dbs[@]}" 
do
	# performance_schema cannot be locked with LOCK TABLES so let's skip it
	# https://dev.mysql.com/doc/refman/5.6/en/performance-schema-restrictions.html
	if [ "$db" == "performance_schema" ]
	then
		continue
	fi

	while getopts ":dwm" opt; do
  		case $opt in
    			d)
				# Daily
				# Path already set as default in case script is called without arguments
				backup_type="daily"
      				;;
			w)
				# Weekly
				backup_type="weekly"
				backups_path="/backups/mysql/weekly"
				;;
                        m)
                                # Monthly
				backup_type="monthly"
                                backups_path="/backups/mysql/monthly"
                                ;;
    			\?)
      				echo "Invalid option: -$OPTARG" >&2
      				;;
  		esac
	done


        if [ ! -d $backups_path ]; then
	        mkdir -p $backups_path;
        fi

	mysqldump --user=$db_user --password=$db_pass --host=$db_host $db | gzip -c > $backups_path/$db-$datetime.gz

	# Backups rotation, we'll preserve:
	#
	# Monthly backups from the last 365 days 
	# Weekly backups from the last 30 days
	# Daily backups from the last 7 days
	#
	# And delete anything older 
	if [ "backup_type" == "monthly" ]; then
  		time=365
	elif [ "backup_type" == "weekly" ]; then
		time=30
        else
		time=7
        fi

	find $backups_path/ -mtime +${time} -exec rm {} \;
done
