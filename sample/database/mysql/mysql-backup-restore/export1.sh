#!/bin/bash
# Each backup is keeped in directory structure YEAR/MONTH/DAY/HOUR/DB_NAME.sql.gz
# You can specify which DB you don't want to backup in variable BLACKLIST.
echo "Starting..."
ROOTDIR="/backup/mysql/es2"
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%H`
SERVER="mysql.local"
BLACKLIST="information_schema performance_schema"
if [ ! -d "$ROOTDIR/$YEAR/$MONTH/$DAY/$HOUR" ]; then
    mkdir -p "$ROOTDIR/$YEAR/$MONTH/$DAY/$HOUR"
fi
echo "running dump"
dblist=`mysql -u backuper -pXXXXXXXXXXX -h $SERVER -e "show databases" | sed -n '2,$ p'`
for db in $dblist; do
    echo "Backuping $db"
    isBl=`echo $BLACKLIST |grep $db`
    if [ $? == 1 ]; then
        mysqldump --single-transaction -u backuper -pXXXXXXXXXX -h $SERVER $db | gzip --best > "$ROOTDIR/$YEAR/$MONTH/$DAY/$HOUR/$db.sql.gz"
        echo "Backup $db ends with return code $?"
    else
        echo "Database $db is on blacklist, skip"
    fi
done

echo "dump completed"