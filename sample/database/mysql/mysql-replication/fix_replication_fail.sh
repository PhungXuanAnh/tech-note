# On master
mysql --login-path=My_Path -Bse "RESET MASTER;"
mysql --login-path=My_Path -Bse "FLUSH TABLES WITH READ LOCK;"
mysql --login-path=My_Path -Bse "SHOW MASTER STATUS;"

    # backup database
mysqldump --login-path=My_Path --all-databases > all_database.sql
mysqldump --login-path=My_Path db_name > db_name.sql
mysql --login-path=My_Path -Bse "UNLOCK TABLES;"
    # copy file all_database.sql or db_name.sql to slave


# On slave
mysql --login-path=My_Path -Bse "STOP SLAVE;"

    # restore database
mysql --login-path=My_Path -Bse "drop database plusfun;create database plusfun CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --login-path=My_Path < all_database.sql
mysql --login-path=My_Path -Bse "create database db_name; create database db_name CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --login-path=My_Path db_name < /path/to/db_name.sql.sql

mysql --login-path=My_Path -Bse "RESET SLAVE;"
mysql --login-path=My_Path -Bse "RESET SLAVE ALL;"
mysql --login-path=My_Path -Bse "CHANGE MASTER TO MASTER_HOST='mysql-1',MASTER_USER='replicator',MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_CONNECT_RETRY=30, MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;"
mysql --login-path=My_Path -Bse "CHANGE MASTER TO MASTER_HOST='mysql-2',MASTER_USER='replicator',MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_CONNECT_RETRY=30, MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;"
mysql --login-path=My_Path -Bse "START SLAVE;"
mysql --login-path=My_Path -Bse "SHOW SLAVE STATUS\G;"
