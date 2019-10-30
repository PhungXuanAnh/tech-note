MySQL: Replication
---

- [1. Master Master](#1-master-master)
- [2. Master Slave](#2-master-slave)
- [3. Resync master-slave](#3-resync-master-slave)
  - [3.1. Step by step](#31-step-by-step)
  - [3.2. Briefly](#32-briefly)
- [4. Resync master-master](#4-resync-master-master)
- [5. Sample configuration for mysql replication](#5-sample-configuration-for-mysql-replication)
- [6. Script check status and auto fix Duplicate_entry_Error](#6-script-check-status-and-auto-fix-duplicate_entry_error)
- [Common issue](#common-issue)
- [7. Reference](#7-reference)

# 1. Master Master

Cấu hình trên docker cần mount volumes cho các thư mục:

- `/var/log/mysql/` : để lưu các file mysql-logbin tránh cho chúng khỏi bị mất khi container bị xóa

- `/var/lib/mysql/`: giữ các database khi container bị xóa (cái này thì không tạo replicate cũng phải làm)

- `/etc/mysql/conf.d/`: để custom một số cấu hình replication, mặc định mysql service sẽ quét và đọc tất cả các file \*.cnf trong thư mục này, file này sẽ ghi đè các cấu hình có sẵn.

- `/docker-entrypoint-initdb.d`: chứa file _.sql, các file này chứa các câu lệnh sql để cấu hình replication, giải thích chi tiết các câu lệnh sql được comment chi tiết trong file _.sql

Tất cả đã được cấu hình sẵn trong file docker compose

**Tham khảo link:** https://www.digitalocean.com/community/tutorials/how-to-set-up-mysql-master-master-replication

**Chú ý:** Ta có thể cấu hình theo cách khác hiệu quả hơn với những version mysql mới theo hướng dẫn sau:
https://www.digitalocean.com/community/tutorials/how-to-configure-mysql-group-replication-on-ubuntu-16-04

# 2. Master Slave

TODO

# 3. Resync master-slave

**Note:** to resync master-master, run below steps at both servers

## 3.1. Step by step

1. Add login path
  ```shell
  mysql_config_editor set \
    --login-path=My_Path \
    --host=127.0.0.1 \
    --port=3306 \
    --user=username \
    --password
  ```
2. At the master
  ```sql
  RESET MASTER;
  FLUSH TABLES WITH READ LOCK;
  SHOW MASTER STATUS;
  ```
  It will show:
  ```shell
  +------------------+----------+--------------+------------------+
  | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
  +------------------+----------+--------------+------------------+
  | mysql-bin.000003 | 73       | test         | manual,mysql     |
  +------------------+----------+--------------+------------------+
  ```
  Save value of colume **File** and **Position** for command run in slave
  Without closing the connection to the client (because it would release the read lock) issue the command to get a dump of the master:
  ```shell
  mysqldump --login-path=My_Path --all-databases > /a/path/all_database.sql
  mysqldump --login-path=My_Path db_name > /a/path/db_name.sql
  ```
  Now you can release the lock, even if the dump hasn't ended yet. To do it, perform the following command in the MySQL client:
  ```sql
  UNLOCK TABLES;
  ```
  Now copy the dump file to the slave using scp or your preferred tool.
3. At the slave
  Open a connection to mysql and type:
  ```shell
  STOP SLAVE;
  ```
  Load master's data dump with this console command:
  ```shell
  mysql --login-path=My_Path < all_database.sql
  # or
  mysql --login-path=My_Path -Bse "create database db_name; create database db_name CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
  mysql --login-path=My_Path db_name < /path/to/db_name.sql
  ```
  Sync slave and master logs:
  ```sql
  RESET SLAVE;
  CHANGE MASTER TO MASTER_HOST='10.23.24.66',MASTER_USER='replicator',MASTER_PASSWORD='15c6SVns55qs', MASTER_PORT=3309, MASTER_CONNECT_RETRY=30, MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;
  ```
  Where **MASTER_LOG_FILE** and **MASTER_LOG_POS** is propriately **File** and **Position** which saved from above command at master
  Finally, type:
  ```sql
  START SLAVE;
  ```
  To check that everything is working again, after typing:
  ```sql
  SHOW SLAVE STATUS;
  ```
  you should see:
  ```yml
  Slave_IO_Running: Yes
  Slave_SQL_Running: Yes
  ```
  That's it!

## 3.2. Briefly

```shell
# On master
mysql --login-path=My_Path -Bse "RESET MASTER;"
mysql --login-path=My_Path -Bse "FLUSH TABLES WITH READ LOCK;"
mysql --login-path=My_Path -Bse "SHOW MASTER STATUS;"
mysqldump --login-path=My_Path --all-databases > /a/path/all_database.sql
mysqldump --login-path=My_Path db_name > /a/path/db_name.sql
mysql --login-path=My_Path -Bse "UNLOCK TABLES;"
# copy file all_database.sql or db_name.sql to slave
# On slave
mysql --login-path=My_Path -Bse "STOP SLAVE;"
mysql --login-path=My_Path -Bse "drop database plusfun;create database plusfun CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --login-path=My_Path < all_database.sql
mysql --login-path=My_Path -Bse "create database db_name; create database db_name CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --login-path=My_Path db_name < /path/to/db_name.sql.sql
mysql --login-path=My_Path -Bse "RESET SLAVE;"
mysql --login-path=My_Path -Bse "RESET SLAVE ALL;"
mysql --login-path=My_Path -Bse "CHANGE MASTER TO MASTER_HOST='10.23.24.66',MASTER_USER='replicator',MASTER_PASSWORD='15c6SVns55qs', MASTER_PORT=3309, MASTER_CONNECT_RETRY=30, MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;"
mysql --login-path=My_Path -Bse "START SLAVE;"
mysql --login-path=My_Path -Bse "SHOW SLAVE STATUS\G;"
```

# 4. Resync master-master

Do **resync master-slave** on both servers to resync master-master

The following explain how it work. Choose one server as Good Server(GS) and other as Bad Server(BS)

1. Stop all queries to BS (stop service, firewall, etc)
2. On the BS, run:
  * prevent it replicating from the GS during the process. 
      ```sql
      STOP SLAVE;
      ```
  * backup database
      ```shell
      mysqldump --login-path=My_Path --all-databases > /a/path/all_database.sql
      ```
  * copy **all_database.sql** to BS
3. On the GS, run:
  * stop it taking replication information from the BS
    ```shell
    STOP SLAVE;
    ```
  * stop it updating for a moment
    ```sql
    FLUSH TABLES WITH READ LOCK; 
    ```
  * check output
    ```shell
    SHOW MASTER STATUS;
    ```
4. On the BS, import data from GS, run
  ```shell  
  mysql --login-path=My_Path < all_database.sql
  ```
5. On the GS, allow it process quries again, run
  ```sql
  UNLOCK TABLES;
  ```
6. On the BS, to set master status
  ```sql
  CHANGE MASTER TO MASTER_HOST='10.23.24.66',MASTER_USER='replicator',MASTER_PASSWORD='15c6SVns55qs', MASTER_PORT=3309, MASTER_CONNECT_RETRY=30, MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;
  START SLAVE;
  SLAVE STATUS;
  ```
7. Setup GS replicate from BS again. On the GS, run:
  ```shell
  CHANGE MASTER TO MASTER_HOST='10.23.24.66',MASTER_USER='replicator',MASTER_PASSWORD='15c6SVns55qs', MASTER_PORT=3309, MASTER_CONNECT_RETRY=30, MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=154;
  START SLAVE;
  SHOW SLAVE STATUS;
  ```

# 5. Sample configuration for mysql replication


[mysql-replication](../../sample/database/mysql/mysql-replication)


# 6. Script check status and auto fix Duplicate_entry_Error

[check_replication_status.sh](../../sample/database/mysql/mysql-replication/check_replication_status.sh)


# Common issue

```shell
$ mysql --login-path=My_Path -Bse "START SLAVE;"

ERROR 1794 (HY000) at line 1: Slave is not configured or failed to initialize properly. You must at least set --server-id to enable either a master or a slave. Additional error messages can be found in the MySQL error log.

# ===> check configuration file inside container in folder /etc/mysql/conf.d, this folder is mounted to
# ./mysql-conf/mysql-1/mysql-conf (see docker compose), but for some unknow reason, it is not mounted
```




# 7. Reference

[https://dev.mysql.com/doc/refman/5.7/en/sql-syntax-replication.html](https://dev.mysql.com/doc/refman/5.7/en/sql-syntax-replication.html)
[https://dev.mysql.com/doc/refman/5.7/en/replication.html](https://dev.mysql.com/doc/refman/5.7/en/replication.html)
[https://dev.mysql.com/doc/refman/5.7/en/group-replication.html](https://dev.mysql.com/doc/refman/5.7/en/group-replication.html)
[https://stackoverflow.com/questions/2366018/how-to-re-sync-the-mysql-db-if-master-and-slave-have-different-database-incase-o](https://stackoverflow.com/questions/2366018/how-to-re-sync-the-mysql-db-if-master-and-slave-have-different-database-incase-o)
[https://www.barryodonovan.com/2013/03/23/recovering-mysql-master-master-replication](https://www.barryodonovan.com/2013/03/23/recovering-mysql-master-master-replication)
