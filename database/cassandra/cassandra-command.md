## docker compose

```yaml
    cassandra:
        image: bitnami/cassandra:3.11.6-debian-10-r21
        volumes:
            - cassandra-data:/bitnami
            # init database will place in below folders, reference: https://hub.docker.com/r/bitnami/cassandra/
            - ./cassandra/init.d:/docker-entrypoint-initdb.d
        ports:
            - 7000:7000
            - 9042:9042
        networks:
            - back-tier
```

## reference

https://www.tutorialspoint.com/cassandra/cassandra_create_keyspace.htm

