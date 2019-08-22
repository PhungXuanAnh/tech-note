Content
- [install on ubuntu](#install-on-ubuntu)
- [testing mysql](#testing-mysql)
- [access mysql shell](#access-mysql-shell)
- [run mysql command without shell](#run-mysql-command-without-shell)

###### install on ubuntu

```shell
Sudo apt-get update
Sudo apt-get install -y mysql-server mysql-client
mysql_secure_installation
```

###### testing mysql

```shell
systemctl status mysql.service
mysqladmin -p -u root version
```

###### access mysql shell

```shell
MYSQL_USER='root'
MYSQL_PASS='1'
MYSQL_PORT=3306
MYSQL_HOST='127.0.0.1'
mysql -u $MYSQL_USER -p$MYSQL_PASS -P $MYSQL_PORT -h $MYSQL_HOST
```

###### run mysql command without shell

```shell
MYSQL_USER='root'
MYSQL_PASS='1'
MYSQL_PORT=3306
MYSQL_HOST='127.0.0.1'
mysql -u $MYSQL_USER -p$MYSQL_PASS -P $MYSQL_PORT -h $MYSQL_HOST \
     -Bse "create database test1;"
```
