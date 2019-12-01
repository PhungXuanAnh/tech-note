This document for practices with Relational Database Management System (RDBMS): PostgeSQL and MySQL
---

- [1. Prepare](#1-prepare)
  - [1.1. Create database server using docker](#11-create-database-server-using-docker)
  - [1.2. Install client](#12-install-client)
    - [1.2.1. GUI client - DBeaver](#121-gui-client---dbeaver)
    - [1.2.2. Command line client](#122-command-line-client)
  - [1.3. Connect to database server from client command line](#13-connect-to-database-server-from-client-command-line)
- [2. Database](#2-database)
  - [2.1. Create database](#21-create-database)
  - [2.2. List database](#22-list-database)
  - [2.3. Drop database](#23-drop-database)
  - [2.4. Use database](#24-use-database)
  - [2.5. Export database](#25-export-database)
  - [2.6. Import database](#26-import-database)
- [3. Table](#3-table)
  - [Create table](#create-table)
  - [Drop table](#drop-table)
  - [3.1. List tables](#31-list-tables)
- [4. Thao tác với dữ liệu](#4-thao-tác-với-dữ-liệu)
  - [4.1. UPDATE](#41-update)
- [5. references](#5-references)
- [6. sample database reference](#6-sample-database-reference)


# 1. Prepare


## 1.1. Create database server using docker

[postgresql](../../devops/docker/docker-command.md#43-postgresql)

[mysql](../../devops/docker/docker-command.md#44-mysql)



## 1.2. Install client

### 1.2.1. GUI client - DBeaver

Using **DBeaver** from [this link](https://gist.github.com/PhungXuanAnh/0a86ed25a70000d1dd6d52ce622fdb36)

### 1.2.2. Command line client
**PostgreSQL**

```shell
sudo apt install postgresql-client

# or using pgcli
sudo apt-get install libpq-dev -y
pip3 install pgcli --user
```

**MySQL**

```shell
sudo apt install mysql-client -y

# or using mycli
pip3 install -U mycli
```

## 1.3. Connect to database server from client command line

**PostgreSQL**

[How to use psql with no password prompt?](https://dba.stackexchange.com/a/14741)

```shell
# enter shell using postgres client official
export PGPASSWORD=123456
psql -p 5433 -h 127.0.0.1 -U postgres

# enter shell using postgres client with autocomplement
pgcli local_database
# or
export POSTGRES_USER=postgres
export POSTGRES_PASS=123456
export POSTGRES_DB=dvdrental
pgcli postgres://{POSTGRES_USER}:{POSTGRES_PASS}@example.com:5432/{POSTGRES_DB}
# or
export PGPASSWORD=123456
pgcli -h localhost -p 5433 -U postgres dvdrental

# exit
\q
```

**MySQL**

```shell
# enter shell
 mysql -h127.0.0.1 -P 3308 -uroot -p123456
# or
 mycli -h localhost -P 3308 -u root -p 123456

 # exit
 exit()
 ctrl + d
```

# 2. Database

## 2.1. Create database

```sql
CREATE DATABASE test_db;
```

## 2.2. List database

```shell
# postgresql
\l
# or
select datname FROM pg_database;

# mysql
SHOW DATABASES;
```

## 2.3. Drop database

```sql
DROP DATABASE test_db;

# or with postgresql
DROP DATABASE IF EXISTS test_db;

# if see ERROR:
# database "test_db" is being accessed by other users
# DETAIL:  There are 2 other sessions using the database.
REVOKE CONNECT ON DATABASE test_db FROM public;
# then
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'test_db';
```

## 2.4. Use database

```shell
# postgresql
\c dvdrental;

# mysql
USE dvdrental;
```

## 2.5. Export database

**postgres**

```shell
pg_dump -p 5433 -h 127.0.0.1 -U postgres -d sakila >> sakila.sql
docker exec -t test-postgresql pg_dumpall -c -U postgres > all_`date +%d-%m-%Y"_"%H_%M_%S`.sql
docker exec -t test-postgresql pg_dump -c -U postgres -d sakila > sakila_`date +%d-%m-%Y"_"%H_%M_%S`.sql
```

**mysql**

```shell
mysqldump -u <db_username> -h <db_host> -P <port> -p<pass-word> db_name table_name > table_name.sql
mysqldump --login-path=My_Path db_name table_name > table_name.sql

# If you are dumping tables t1, t2, and t3 from mydb
mysqldump -u <db_username> -h <db_host> -P <port> -p<pass-word> mydb t1 t2 t3 > mydb_tables.sql

# in docker container
docker exec CONTAINER /usr/bin/mysqldump -u root --password=root DATABASE > backup.sql
```

## 2.6. Import database

**postgresql**

```shell
git clone https://github.com/jOOQ/jOOQ.git
cd jOOQ/jOOQ-examples/Sakila/postgres-sakila-db/
docker exec -i test-postgresql psql -U postgres -c "DROP DATABASE sakila;"
docker exec -i test-postgresql psql -U postgres -c "CREATE DATABASE sakila;"
docker exec -i test-postgresql psql -U postgres -d sakila < postgres-sakila-delete-data.sql
docker exec -i test-postgresql psql -U postgres -d sakila < postgres-sakila-drop-objects.sql
docker exec -i test-postgresql psql -U postgres -d sakila < postgres-sakila-schema.sql
docker exec -i test-postgresql psql -U postgres -d sakila < postgres-sakila-insert-data.sql

# check result
docker exec -i test-postgresql psql -U postgres -d sakila -c "SELECT COUNT(*) FROM film;"
# output
 count 
-------
  1000
(1 row)
```

**mysql**

```shell
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 -e 'DROP DATABASE sakila;'
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 -e 'CREATE DATABASE sakila;'

# import jOOQ sakila database
git clone https://github.com/jOOQ/jOOQ.git
cd jOOQ/jOOQ-examples/Sakila/mysql-sakila-db/
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila < mysql-sakila-delete-data.sql
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila < mysql-sakila-drop-objects.sql
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila < mysql-sakila-schema.sql
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila < mysql-sakila-insert-data.sql

# import offical sakila
wget https://downloads.mysql.com/docs/sakila-db.zip
unzip sakila-db.zip
cd sakila-db
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila < sakila-schema.sql
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila < sakila-data.sql

# check result
docker exec -i test-mysql /usr/bin/mysql -u root --password=123456 sakila -e 'SELECT COUNT(*) FROM film;'
# output
COUNT(*)
1000
```

# 3. Table

## Create table

```sql
# mysql
CREATE TABLE test_db.SINHVIEN(
   ID   INT              NOT NULL,
   TEN VARCHAR (20)     NOT NULL,
   TUOI  INT              NOT NULL,
   KHOAHOC  CHAR (25) ,
   HOCPHI   DECIMAL (18, 2),       
   PRIMARY KEY (ID)
);

DESCRIBE test_db.SINHVIEN;
```

## Drop table

```sql
# mysql
DROP TABLE test_db.SINHVIEN;
```

## 3.1. List tables

```shell
# postgresql
\dt

# mysql
SHOW TABLES;
```

# 4. Thao tác với dữ liệu

## 4.1. UPDATE

```sql
UPDATE table
set column1 = value1,
    column2 = value2, ...
WHERE
    condition;
```

# 5. references

https://vietjack.com/sql/
https://www.tutorialspoint.com/sql/index.htm
http://www.postgresqltutorial.com

https://techmaster.vn/posts/34036/huong-dan-sql-cho-nguoi-moi-bat-dau


# 6. sample database reference

![sakila](../../image/../images/programming/sql/sakila.png)

https://dev.mysql.com/doc/sakila/en/
https://www.jooq.org/sakila
https://musicbrainz.org/doc/MusicBrainz_Database/Download

