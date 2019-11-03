- [1. Access to postgresql](#1-access-to-postgresql)
- [2. run a command and exit](#2-run-a-command-and-exit)
- [3. Import already database](#3-import-already-database)
- [4. quit](#4-quit)
- [5. Database](#5-database)
  - [5.1. List](#51-list)

# 1. Access to postgresql 

```shell
psql -p 5433 -h 127.0.0.1 -U postgres
```

# 2. run a command and exit

```shell
psql -p 5433 -h 127.0.0.1 -U postgres -c "CREATE DATABASE dvdrental;"
```

# 3. Import already database

```shell
psql -p 5433 -h 127.0.0.1 -U postgres -d dvdrental < dvdrental.tar
```

# 4. quit

`\q`

# 5. Database

## 5.1. List

`\l`


