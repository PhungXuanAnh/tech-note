#!/bin/bash

# =========================================================
# install mysql client: sudo apt install mysql-client -y
# =========================================================
# set -x
echo '==================================='
echo 'Checking mysql replication status..'
echo '==================================='

# MYSQL_AUTH_FILE=~/.mysql_auth.conf
# if [ ! -f "$MYSQL_AUTH_FILE" ]
# then
# cat >"$MYSQL_AUTH_FILE" <<'EOF'
# [client]
# user = root
# password = pass
# host = 127.0.0.1
# port = 3309
# EOF
# fi
# MYSQL="mysql --defaults-extra-file=$MYSQL_AUTH_FILE"

# MYSQL_IP=$(docker exec plusfun_mysql_1  bash -c "awk 'END{print $1}' /etc/hosts" | awk '{print $1}')
# MYSQL_PORT=3306
MYSQL_IP="127.0.0.1"
MYSQL_PORT=$1
MYSQL_PASS='dev@123'
MYSQL_USER='root'
MYSQL="mysql -u $MYSQL_USER -p$MYSQL_PASS -P $MYSQL_PORT -h $MYSQL_IP"

# mysql_config_editor set \
#   --login-path=My_Path \
#   --host=$(docker exec plusfun_mysql_1  bash -c "awk 'END{print $1}' /etc/hosts" | awk '{print $1}') \
#   --port=3306 \
#   --user=root \
#   --password
# or 
# mysql_config_editor set \
#   --login-path=My_Path \
#   --host="127.0.0.1"
#   --port=3309 \
#   --user=root \
#   --password
# MYSQL="mysql --login-path=My_Path"

MYSQL_CHECK=$($MYSQL -e "SHOW VARIABLES LIKE '%version%';" || echo 1)
LAST_ERRNO=$($MYSQL -e "SHOW SLAVE STATUS\G" | grep "Last_Errno" | awk '{ print $2 }')
SECONDS_BEHIND_MASTER=$($MYSQL -e "SHOW SLAVE STATUS\G"| grep "Seconds_Behind_Master" | awk '{ print $2 }')
IO_IS_RUNNING=$($MYSQL -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running" | awk '{ print $2 }')
SQL_IS_RUNNING=$($MYSQL -e "SHOW SLAVE STATUS\G" | grep "Slave_SQL_Running" | awk '{ print $2 }' | sed -ne '1p')
ERRORS=()


### Run Some Checks ###

## Check if I can connect to Mysql ##
if [ "$MYSQL_CHECK" == 1 ]
then
    ERRORS=("${ERRORS[@]}" "Can't connect to MySQL (Check Pass)")
fi

## Check For Last Error ##
if [ "$LAST_ERRNO" != 0 ]
then
    LAST_ERROR=$($MYSQL -e "SHOW SLAVE STATUS\G" | grep "Last_Error")
    ERRORS=("${ERRORS[@]}" "Error when processing relay log (Last_Errno)")
    ERRORS=("${ERRORS[@]}" "($LAST_ERROR)")
fi

## Check if IO thread is running ##
if [ "$IO_IS_RUNNING" != "Yes" ]
then
    ERRORS=("${ERRORS[@]}" "I/O thread for reading the master's binary log is not running (Slave_IO_Running)")
fi

## Check for SQL thread ##
if [ "$SQL_IS_RUNNING" != "Yes" ]
then
    ERRORS=("${ERRORS[@]}" "SQL thread for executing events in the relay log is not running (Slave_SQL_Running)")
fi

## Check how slow the slave is ##
if [ "$SECONDS_BEHIND_MASTER" == "NULL" ]
then
    ERRORS=("${ERRORS[@]}" "The Slave is reporting 'NULL' (Seconds_Behind_Master)")
elif [ "$SECONDS_BEHIND_MASTER" -gt 60 ]
then
    ERRORS=("${ERRORS[@]}" "The Slave is at least 60 seconds behind the master (Seconds_Behind_Master)")
fi

### Send and Email if there is an error ###
if [ "${#ERRORS[@]}" -gt 0 ]
then
    MESSAGE="An error has been detected on the mysql replciation. Below is a list of the reported errors:\n\n
    $(for i in $(seq 0 ${#ERRORS[@]}) ; do echo "\t${ERRORS[$i]}\n" ; done)
    Please correct this ASAP
    "
    echo -e $MESSAGE
    exit 1
fi

echo "Replication OK"
exit 0
