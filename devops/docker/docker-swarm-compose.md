- [1. swarm](#1-swarm)
  - [1.1. init swarm](#11-init-swarm)
  - [1.2. show token](#12-show-token)
  - [1.3. node label](#13-node-label)
  - [1.4. node list](#14-node-list)
- [2. stack](#2-stack)
  - [2.1. deploy using docker-compose file](#21-deploy-using-docker-compose-file)
  - [2.2. list the tasks in the stack](#22-list-the-tasks-in-the-stack)
  - [2.3. list the services in the stack](#23-list-the-services-in-the-stack)
- [3. service](#3-service)
  - [3.1. Run command](#31-run-command)
  - [3.2. remove all service in warm](#32-remove-all-service-in-warm)
  - [3.3. list the tasks of one or more services](#33-list-the-tasks-of-one-or-more-services)
  - [3.4. Fetch the logs of a service or task](#34-fetch-the-logs-of-a-service-or-task)
  - [3.5. restart / force update](#35-restart--force-update)
  - [3.6. update](#36-update)
  - [3.7. scale](#37-scale)
- [4. Create service monitor swarm](#4-create-service-monitor-swarm)
- [5. Docker compose file](#5-docker-compose-file)
  - [5.1. deploy - placement - constraints](#51-deploy---placement---constraints)
  - [deploy - mode](#deploy---mode)
  - [5.2. Pass node information to service through environment variable](#52-pass-node-information-to-service-through-environment-variable)
- [Debug docker swarm](#debug-docker-swarm)
  - [Get log of service](#get-log-of-service)
  - [Change command of a service in docker compose](#change-command-of-a-service-in-docker-compose)

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

## 1.3. node label

```shell
docker node update --label-add node_name=kidssy_gateway [hostname/id]
# ex:
docker node ls             
ID                            HOSTNAME                   STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
r739x77y80bp2p1lqblsu8yr2     sender1      Ready               Active                                  19.03.5
1dnm8jpbdwldjbx09aplctild *   sender2   Ready               Active              Leader              19.03.5
im4xtpncpulz4tf3o4p72dro8     sender3 

docker node update --label-add node_name=kidssy_gateway sender3
```

## 1.4. node list

```shell
docker node ls

# reference: https://stackoverflow.com/a/42419060/7639845
# list by label and hostname
docker node ls -q | xargs docker node inspect \
  -f '{{ .ID }}	[{{ .Description.Hostname }}]:	{{ .Spec.Labels }}'

# You can adjust that to use a range for prettier formatting instead of printing the default map:
docker node ls -q | xargs docker node inspect \
  -f '{{ .ID }}	[{{ .Description.Hostname }}]:				{{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }} {{end}}'
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

## 3.1. Run command

```shell
docker exec $(docker ps -q -f name=[regex to filter container]) command
# ex
docker exec $(docker ps -q -f name=kidssy_kong.1) kong health
```

## 3.2. remove all service in warm

```shell
docker service rm $(docker service ls -q)
```

## 3.3. list the tasks of one or more services

```shell
docker service ps sender_sender --no-trunc --format "table {{.Error}}\t{{.Node}}\t{{.Name}}"
```

## 3.4. Fetch the logs of a service or task

```shell
docker service logs [sevice|tasks]
# service id or task id get from comment `docker stack services [stack-name]`
```

## 3.5. restart / force update

```shell
docker service update --force [service-id]
```

## 3.6. update

```shell
docker service update [service-id]
```

## 3.7. scale

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

# 5. Docker compose file

## 5.1. deploy - placement - constraints

```yaml
deploy:
  placement:
      constraints:
        - node.labels.label_name == label_value
        - node.role == manager/worker
        - node.hostname == server-1
        - node.hostname != server-2
        - engine.labels.lable_name == label_value  # start docker engine with labels, e.g. dockerd --label lable_name=label_value
```

## deploy - mode

```yaml
deploy:
  mode: global
  mode: replicas    # default mode
```

## 5.2. Pass node information to service through environment variable

```yaml
        environment:
            HOST_NAME: "node-{{.Node.Hostname}}"
```            

# Debug docker swarm

## Get log of service

When a service fail to start docker swarm will try to re-create a new service continously so we cannot get log of that service, let's using bellow command, change service name by yours:

```shell

# es_master1 is your service name, change it to yours
while true; do docker logs -f $(docker ps -q -f name=es_master1); sleep 1; done

# or command:

swarm-container-log() {
    container_name_regex=$1
    # for example if container name is kidssy_app-sample.1.dyyc32fb8alty3wbhbxmo5k4l
    # then docker_name_regex is kidssy_app-sample.1
    # call this command: swarm-container-log kidssy_app-sample.1

    while true; 
    do 
        container_id=$(docker ps -q -f name=$container_name_regex);
        line2=$(echo $container_id | awk 'NR==2');

        if [ -z "$container_id" ]
        then
            echo "service is removed"
        elif ! [ -z "$line2" ]
        then
            echo "There are multiple container with regex: '$container_name_regex'"
        else
            docker logs -f $container_id; 
        fi
        sleep 1; 
    done
}

swarm-container-log kidssy_app-sample.1

```

## Change command of a service in docker compose

Add command field to docker-compose to replace default command in Dockerfile

```yml
command: while true; do echo ""; sleep 2; done
```