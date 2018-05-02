Set cronjobs this way to schedule daily, weekly and monthly backups

0 0 * * *  /path/to/the/script/mysql_backup.sh -d

15 0 * * 1 /path/to/the/script/mysql_backup.sh -w
-
30 0 1 * * /path/to/the/script/mysql_backup.sh -m
