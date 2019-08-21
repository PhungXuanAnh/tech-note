- [1. swarm](#1-swarm)
  - [1.1. init swarm](#11-init-swarm)
  - [1.2. show token](#12-show-token)
- [2. stack](#2-stack)
  - [2.1. deploy using docker-compose file](#21-deploy-using-docker-compose-file)
  - [2.2. list the tasks in the stack](#22-list-the-tasks-in-the-stack)
  - [2.3. list the services in the stack](#23-list-the-services-in-the-stack)
- [3. service](#3-service)
  - [3.1. remove all service in warm](#31-remove-all-service-in-warm)
  - [3.2. list the tasks of one or more services](#32-list-the-tasks-of-one-or-more-services)
  - [3.3. Fetch the logs of a service or task](#33-fetch-the-logs-of-a-service-or-task)
  - [3.4. restart / force update](#34-restart--force-update)
  - [3.5. update](#35-update)
  - [3.6. scale](#36-scale)
- [4. Create service monitor swarm](#4-create-service-monitor-swarm)

# 1. swarm

## 1.1. init swarm

```shell
docker swarm init --advertise-addr=<ip-address>
docker swarm init --advertise-addr=192.168.1.201
```

## 1.2. show token

`docker swarm join-token worker`

it will show

```shell
# To add a worker to this swarm, run the following command:

docker swarm join --token SWMTKN-1-05mr233vlh8k3f1j688de8scf53sejunk43ymwyh9i76r097uz-2z79uque2ujwinas0xicg7pbk 192.168.1.201:2377
```

# 2. stack

## 2.1. deploy using docker-compose file

```shell
docker stack deploy --help
docker stack deploy -c docker-compose.yml getstartedlab
```

## 2.2. list the tasks in the stack

```shell
docker stack ps [stack-name]
# or
docker stack ps [stack-name] --no-trunc --format "table {{.Error}}\t{{.Name}}\t{{.ID}}"
# ex
docker stack ps sender --no-trunc --format "table {{.Error}}\t{{.Name}}\t{{.ID}}"
```

output:

```shell
ID                  NAME                      IMAGE                          NODE                DESIRED STATE       CURRENT STATE          ERROR               PORTS
a2z8sk2124q4        psn_crawl-data.1          polsatnews_crawl-data          b126                Running             Running 17 hours ago                       
rmcxgy84otfv        psn_push-notification.1   polsatnews_push-notification   b126                Running             Running 17 hours ago                       
9axob5u8ez9k        psn_gateway.1             nginx:latest                   b125                Running             Running 2 months ago                       
```

## 2.3. list the services in the stack

```shell
docker stack services [stack-name]
docker stack services sender
```

output:

```shell
ID                  NAME                    MODE                REPLICAS            IMAGE                          PORTS
1v7qve82mjdf        abc_db_slave            replicated          1/1                 mysql:5.5               
1k23odgsydpa        abc_gateway             replicated          1/1                 nginx:latest                   *:82->80/tcp,*:445->443/tcp
```

# 3. service

## 3.1. remove all service in warm

```shell
docker service rm $(docker service ls -q)
```

## 3.2. list the tasks of one or more services

```shell
docker service ps sender_sender --no-trunc --format "table {{.Error}}\t{{.Node}}\t{{.Name}}"
```

## 3.3. Fetch the logs of a service or task

```shell
docker service logs [sevice|tasks]
# service id or task id get from comment `docker stack services [stack-name]`
```

## 3.4. restart / force update

```shell
docker service update --force [service-id]
```

## 3.5. update

```shell
docker service update [service-id]
```

## 3.6. scale

```shell
docker service scale SERVICE=REPLICAS
docker service scale service-name=number-of-service
```

See update option here: https://docs.docker.com/engine/reference/commandline/service_update/#options


# 4. Create service monitor swarm

```shell
docker service create \
  --name=visualizer \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```


