#!/bin/bash

# Requirements :mysqldump (sudo apt-get install mysql-client)
# Upzip file: gzip -d ${DIR_BACKUP}/${FILE_BACKUP}.sql.gz
#
# Add cronjob Every 1 hour
# 0 * * * * /path/to/export.sh
# -----------------------------------------------------------

MYSQL_HOST='127.0.0.1'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD=123456
MYSQL_DATABASE=demo

DIR_BACKUP='/tmp'
DATE_BACKUP=`date +%Y-%m-%d"_"%H-%M-%S`
FILE_BACKUP=${MYSQL_DATABASE}_${DATE_BACKUP}

KEEP_NEWEST=3

echo "Start export..."
mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} | gzip > ${DIR_BACKUP}/${FILE_BACKUP}.sql.gz

echo "Remove old file"
cd ${DIR_BACKUP} && ls -1tr | head -n -${KEEP_NEWEST} | xargs -d '\n' rm -f --

echo "Done!"