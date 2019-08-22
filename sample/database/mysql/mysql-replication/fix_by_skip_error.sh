#/bin/bash
#----------------------------------------------------------------
# MYSQL_IP=$(docker exec plusfun_mysql_1  bash -c "awk 'END{print $1}' /etc/hosts" | awk '{print $1}')
# MYSQL_PORT=3306
# MYSQL_PASS='pass'
# MYSQL_USER='user'
# MYSQL="mysql -u $MYSQL_USER -p$MYSQL_PASS -P $MYSQL_PORT -h $MYSQL_IP"
#----------------------------------------------------------------
# # mysql_config_editor set \
# #   --login-path=My_Path \
# #   --host=$(docker exec plusfun_mysql_1  bash -c "awk 'END{print $1}' /etc/hosts" | awk '{print $1}') \
# #   --port=3306 \
# #   --user=root \
# #   --password
# MYSQL="mysql --login-path=My_Path"

#----------------------------------------------------------------
MYSQL_AUTH_FILE=~/.mysql_auth.conf
if [ ! -f "$MYSQL_AUTH_FILE" ]
then
cat >"$MYSQL_AUTH_FILE" <<'EOF'
[client]
user = root
password = password
host = 127.0.0.1
port = 3309
EOF
fi
MYSQL="mysql --defaults-extra-file=$MYSQL_AUTH_FILE"

LAST_ERRNO=$($MYSQL -e "SHOW SLAVE STATUS\G" | grep "Last_Errno" | awk '{ print $2 }')

# while [ "$LAST_ERRNO" != 0 ]
while [ "$LAST_ERRNO" == 1032 ] || [ "$LAST_ERRNO" == 1062 ] 
do 
    $MYSQL -e "STOP SLAVE; SET GLOBAL SQL_SLAVE_SKIP_COUNTER=1; START SLAVE;";
    sleep 2;
    LAST_ERRNO=$($MYSQL -e "SHOW SLAVE STATUS\G" | grep "Last_Errno" | awk '{ print $2 }')
    echo $LAST_ERRNO
done


# mysql --defaults-extra-file=~/.mysql_auth.conf -Bse "STOP SLAVE;"
# mysql --defaults-extra-file=~/.mysql_auth.conf -Bse "SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;"
# mysql --defaults-extra-file=~/.mysql_auth.conf -Bse "START SLAVE;"
# mysql --defaults-extra-file=~/.mysql_auth.conf -Bse "SHOW SLAVE STATUS\G;"

