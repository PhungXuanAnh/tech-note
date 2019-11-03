- [1. Database](#1-database)
  - [1.1. Download sample database](#11-download-sample-database)
  - [1.2. Create database](#12-create-database)
  - [List database](#list-database)
  - [Drop database](#drop-database)
  - [Use database](#use-database)
- [2. Import database](#2-import-database)
- [3. references](#3-references)
- [4. sample database](#4-sample-database)

This practices do with postgresql, to access postgresql console, using command:

```shell
psql -p 5433 -h 127.0.0.1 -U postgres
```

# 1. Database
## 1.1. Download sample database

Download sample database from [here](../sample/database/../../../sample/database/postgresql/dvdrental.zip)

## 1.2. Create database

```sql
CREATE DATABASE dvdrental;
```

## List database

```shell
# postgresql
\l

# mysql
SHOW DATABASES;
```

## Drop database
```sql
DROP DATABASE dvdrental;

# or with postgresql
DROP DATABASE IF EXISTS dvdrental;
```

## Use database

```shell
# postgresql
\c dvdrental;

# mysql
USE dvdrental;
```

# 2. Import database

[See here](../database/../../database/postgresql/postgresql-psql-command.md)

# 3. references

https://vietjack.com/sql/
https://viettuts.vn/sql
https://techmaster.vn/posts/34036/huong-dan-sql-cho-nguoi-moi-bat-dau

# 4. sample database

https://dev.mysql.com/doc/sakila/en/
https://dataedo.com/kb/databases/postgresql/sample-databases
http://postgresguide.com/setup/example.html
https://musicbrainz.org/doc/MusicBrainz_Database/Download
https://postgrespro.com/education/demodb
http://www.postgresqltutorial.com/postgresql-sample-database/

