# check replication status

check master:

```shell
make info-master
```

it should return log message:

```log
# Replication
role:master
connected_slaves:1
slave0:ip=172.25.0.3,port=6379,state=online,offset=322,lag=0
master_replid:480a9292a7d1404b1703ecc3a8b4016af7c36d2b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:322
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:322
```

check slave:

```shell
make info-replica
```

it should return: 

```log
# Replication
role:slave
master_host:redis-master
master_port:6379
master_link_status:up
master_last_io_seconds_ago:9
master_sync_in_progress:0
slave_repl_offset:532
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:480a9292a7d1404b1703ecc3a8b4016af7c36d2b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:532
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:532
```

# reference

https://hub.docker.com/r/bitnami/redis/

https://hub.docker.com/r/bitnami/redis-cluster/
