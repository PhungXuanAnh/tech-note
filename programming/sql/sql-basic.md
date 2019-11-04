- [1. Prepare](#1-prepare)
  - [1.1. Install client for interact with database server](#11-install-client-for-interact-with-database-server)
  - [1.2. Interact with database server from client](#12-interact-with-database-server-from-client)
  - [1.3. Download sample database](#13-download-sample-database)
  - [Create database server using docker](#create-database-server-using-docker)
- [2. Database](#2-database)
  - [2.1. Create database](#21-create-database)
  - [2.2. List database](#22-list-database)
  - [2.3. Drop database](#23-drop-database)
  - [2.4. Use database](#24-use-database)
  - [2.5. Import dumped database](#25-import-dumped-database)
- [3. Table](#3-table)
  - [3.1. List tables](#31-list-tables)
- [4. Thao tác với dữ liệu](#4-thao-tác-với-dữ-liệu)
  - [4.1. UPDATE](#41-update)
- [5. references](#5-references)
- [6. sample database reference](#6-sample-database-reference)


# 1. Prepare

## 1.1. Install client for interact with database server

**PostgreSQL**

```shell
sudo apt install postgresql-client

# or using pgcli
sudo apt-get install libpq-dev -y
pip3 install pgcli --user
```

**MySQL**

```shell
sudo apt install mysql-client

# or using mycli
pip3 install -U mycli
```

## 1.2. Interact with database server from client

**PostgreSQL**

[How to use psql with no password prompt?](https://dba.stackexchange.com/a/14741)

```shell
# enter shell using postgres client official
export PGPASSWORD=123456
psql -p 5433 -h 127.0.0.1 -U postgres

# enter shell using postgres client with autocomplement
pgcli local_database
pgcli postgres://amjith:passw0rd@example.com:5432/app_db
pgcli -h localhost -p 5433 -U postgres app_db

# exit
\q
```

**MySQL**

```shell
# enter shell
 mysql -h127.0.0.1 -P 3389 -uroot -p123456

 # exit
 exit()
 ctrl + d
```

## 1.3. Download sample database

[postgresql](../sample/database/../../../sample/database/postgresql/dvdrental.zip)

## Create database server using docker

[postgresql](../../devops/docker/docker-command.md#postgresql)

[mysql](../../devops/docker/docker-command.md#mysql)

# 2. Database

## 2.1. Create database

```sql
CREATE DATABASE dvdrental;
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
DROP DATABASE dvdrental;

# or with postgresql
DROP DATABASE IF EXISTS dvdrental;
```

## 2.4. Use database

```shell
# postgresql
\c dvdrental;

# mysql
USE dvdrental;
```

## 2.5. Import dumped database


**postgresql**

```shell
psql -p 5433 -h 127.0.0.1 -U postgres -c "CREATE DATABASE dvdrental;"
psql -p 5433 -h 127.0.0.1 -U postgres -d dvdrental < dvdrental.tar
```

**mysql**

```shell
mysql -h127.0.0.1 -P 3389 -uroot -p123456 dvdrental < dvdrental.sql
```

# 3. Table

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
https://viettuts.vn/sql
http://www.postgresqltutorial.com

https://techmaster.vn/posts/34036/huong-dan-sql-cho-nguoi-moi-bat-dau


# 6. sample database reference

https://dev.mysql.com/doc/sakila/en/
https://dataedo.com/kb/databases/postgresql/sample-databases
http://postgresguide.com/setup/example.html
https://musicbrainz.org/doc/MusicBrainz_Database/Download
https://postgrespro.com/education/demodb

