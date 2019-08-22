MySQL: Backup and Restore
---
- [1. Add login path](#1-add-login-path)
- [2. Backup and restore single table from .sql](#2-backup-and-restore-single-table-from-sql)
  - [2.1. Backup a database](#21-backup-a-database)
  - [2.2. Backup multiple databases in separate files](#22-backup-multiple-databases-in-separate-files)
  - [2.3. Restore](#23-restore)
- [3. Backup and restore a single table from a compressed (.sql.gz) format](#3-backup-and-restore-a-single-table-from-a-compressed-sqlgz-format)
  - [3.1. Backup](#31-backup)
  - [3.2. Restore](#32-restore)
  - [3.3. Backup and restore script](#33-backup-and-restore-script)
  - [3.4. Using mysql without warning](#34-using-mysql-without-warning)

# 1. Add login path

```shell
mysql_config_editor set \
  --login-path=My_Path \
  --host=127.0.0.1 \
  --port=3306 \
  --user=username \
  --password
```

# 2. Backup and restore single table from .sql

## 2.1. Backup a database

```shell
mysqldump -u <db_username> -h <db_host> -P <port> -p<pass-word> db_name table_name > table_name.sql
# or
mysqldump --login-path=My_Path db_name table_name > table_name.sql
```

If you are dumping tables t1, t2, and t3 from mydb

```shell
mysqldump -u <db_username> -h <db_host> -P <port> -p<pass-word> mydb t1 t2 t3 > mydb_tables.sql
# or
mysqldump --login-path=My_Path mydb t1 t2 t3 > mydb_tables.sql
```

If you have a ton of tables in mydb and you want to dump everything except t1, t2, and t3, do this:

```shell
DBTODUMP=mydb
SQL="SET group_concat_max_len = 10240;"
SQL="${SQL} SELECT GROUP_CONCAT(table_name separator ' ')"
SQL="${SQL} FROM information_schema.tables WHERE table_schema='${DBTODUMP}'"
SQL="${SQL} AND table_name NOT IN ('t1','t2','t3')"
TBLIST=`mysql -u... -p... -AN -e"${SQL}"`
mysqldump -u... -p... ${DBTODUMP} ${TBLIST} > mydb_tables.sql
```

## 2.2. Backup multiple databases in separate files

```shell
mysql -u <db_username> -h <db_host> -P <port> -p<pass-word> -Bse 'show databases' | \
while read dbname;
do
mysqldump -u <db_username> -h <db_host> -P <port> -p<pass-word> \
--complete-insert --routines --triggers --single-transaction \
"$dbname" > "$dbname".sql;
done

# or

mysql --login-path=My_Path -Bse 'show databases' | \
while read dbname;
do
mysqldump --login-path=My_Path \
--complete-insert --routines --triggers --single-transaction \
"$dbname" > "$dbname".sql;
done
```

## 2.3. Restore

```shell
mysql -u <db_username> -h <db_host> -P <port> -p<pass-word>
mysql> source <full_path>/table_name.sql
```

or in one line

```shell
mysql -u <db_username> -h <db_host> -P <port> -p<pass-word> db_name < /path/to/table_name.sql

# or

mysql --login-path=My_Path db_name < /path/to/table_name.sql
```

# 3. Backup and restore a single table from a compressed (.sql.gz) format

## 3.1. Backup

```shell
mysqldump --login-path=My_Path db_name table_name | gzip > table_name.sql.gz
```

## 3.2. Restore

```shell
gunzip < table_name.sql.gz | mysql --login-path=My_Path db_name
```

## 3.3. Backup and restore script

[mysql-backup-restore](../../sample/database/mysql/mysql-backup-restore)

## 3.4. Using mysql without warning

```shell
mysql_config_editor set \
  --login-path=My_Path \
  --host=127.0.0.1 \
  --port=3306 \
  --user=username \
  --password
```

Then enter **password**, it will create a file **.mylogin.cnf** at **Home** on Linux or at **%APPDATA%\MySQL** on Window

To see all login path:

```shell
mysql_config_editor print --all
```

Next time, just add **--login-path** as declared in the above command to **mysql** command or **mysqldumps** command. For example:

```shell
mysql --login-path=My_Path -Bse "show databases;"
```

Reference: [https://dev.mysql.com/doc/refman/5.7/en/mysql-config-editor.html](https://dev.mysql.com/doc/refman/5.7/en/mysql-config-editor.html)
