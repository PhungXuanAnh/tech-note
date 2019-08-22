#!/bin/bash

# Requirements :mysqldump (sudo apt-get install mysql-client)
# Upzip file: gzip -d ${DIR_BACKUP}/${FILE_BACKUP}.sql.gz
# -----------------------------------------------------------

MYSQL_HOST='127.0.0.1'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD=123456
MYSQL_DATABASE=demo

DIR_BACKUP='/tmp'
FILE_IMPORT=$1

echo "Start import..."
gzip -d ${FILE_IMPORT} | mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE}

echo "Done!"