- [1. container](#1-container)
	- [1.1. list](#11-list)
	- [1.2. create a container from an image](#12-create-a-container-from-an-image)
	- [1.3. attach a container](#13-attach-a-container)
	- [1.4. deattach a container and keep it still running](#14-deattach-a-container-and-keep-it-still-running)
	- [1.5. delete all stopped containers](#15-delete-all-stopped-containers)
	- [1.6. Statistic resource using by container](#16-statistic-resource-using-by-container)
- [2. images](#2-images)
	- [2.1. list all image on local](#21-list-all-image-on-local)
	- [2.2. list all images on docker hub](#22-list-all-images-on-docker-hub)
	- [2.3. pull image](#23-pull-image)
	- [2.4. save the change in already exist image](#24-save-the-change-in-already-exist-image)
	- [2.5. push image to Docker hub](#25-push-image-to-docker-hub)
	- [2.6. save image to archive file](#26-save-image-to-archive-file)
	- [2.7. load image from archive file](#27-load-image-from-archive-file)
	- [2.8. build image from Dockerfile](#28-build-image-from-dockerfile)
	- [2.9. delete an image](#29-delete-an-image)
	- [2.10. check image exist on remote docker hub](#210-check-image-exist-on-remote-docker-hub)
- [3. Dockerfile sample](#3-dockerfile-sample)
- [4. Move docker's default /var/lib/docker to another directory on Ubuntu/Debian Linux](#4-move-dockers-default-varlibdocker-to-another-directory-on-ubuntudebian-linux)
- [5. Docker run commons images](#5-docker-run-commons-images)
	- [5.1. Redis](#51-redis)
	- [5.2. RabbitMQ](#52-rabbitmq)
	- [5.3. PostgreSQL](#53-postgresql)
	- [5.4. MySQL](#54-mysql)
	- [5.5. Kafka](#55-kafka)
	- [5.6. Kafdrop](#56-kafdrop)
	- [5.7. MongoDB](#57-mongodb)
	- [5.8. Jenkins](#58-jenkins)
- [6. Debug container](#6-debug-container)
- [7. Reference](#7-reference)


# 1. container

## 1.1. list

list all

```shell
docker ps
docker ps -a
docker container ls
```

list by name with regex pattern

```shell
docker ps -q -f name=<regex>
# ex:
docker ps -q -f name=es_master1.1
```

## 1.2. create a container from an image

https://docs.docker.com/engine/reference/run/

```Dockerfile
docker run -it --name {container_name} \
               --hostname {container_hostname} \
               --net=bridge \
			   --mac-address=00:00:00:00:00:11 \
               -p {host_port}:{container_port} \
               -v {abs_path_host}:}path_contain} \
               {IMAGE_NAME}:{TAG}
# example
docker run -it --name demo-container-1 \
               --hostname demo-container \
               --net=host \
               -p 12345:12345  \
               -v /media/xuananh/data/Downloads/test:/test \
               ubuntu:16.04

docker run -it --name demo-container-2 \
               --hostname demo-container \
			   --mac-address=00:00:00:00:00:11 \
               -p 12346:12345  \
               -v /media/xuananh/data/Downloads/test:/test \
               ubuntu:16.04
```

## 1.3. attach a container

docker exec -it container_name bash

## 1.4. deattach a container and keep it still running

ctrl + P and ctrl + Q

## 1.5. delete all stopped containers

```Dockerfile
docker rm `docker ps --no-trunc -aq`
```

## 1.6. Statistic resource using by container

```shell
docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
# or
docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" container_name1 container_name2
```
----------------------------------------------------------------

# 2. images

## 2.1. list all image on local

docker images

## 2.2. list all images on docker hub

see command in this file: [../../sample/devops/docker/docker-hub-api-combine-with-shell-script/list-all-images-on-docker-hub.sh](../../sample/devops/docker/docker-hub-api-combine-with-shell-script/list-all-images-on-docker-hub.sh)

## 2.3. pull image

```shell
docker pull ubuntu:14.04 # by default, it will download offical ubuntu
docker pull {USER_NAME}/{IMAGE_NAME} # ex: docker pull binhcao/docker-whale
```

## 2.4. save the change in already exist image

`docker commit {container_id} {USER_NAME}/{IMAGE_NAME}:{TAG}`

## 2.5. push image to Docker hub

Push an exist image to a repo in Docker hub

```Dockerfile
# step 1 : login docker hub
docker login {USER_NAME}
# step 2 : commit the change from a container into already exist image
docker commit {container_id} {USER_NAME}/{IMAGE_NAME}:{TAG}
# step 3: change tag of an exist image for new version
docker tag <image_id> {USER_NAME}/{IMAGE_NAME}:{TAG}
# step 4: push new image with new tag to docker hub
docker push {USER_NAME}/{IMAGE_NAME}
```

## 2.6. save image to archive file

```Dockerfile
docker save <IMAGE_NAME/image_id> > name_archive_file.tar
```

## 2.7. load image from archive file

```Dockerfile
docker load < name_archive_file.tar.gz
docker load --input name_archive_file.tar.gz
```

output:

```Dockerfile
d197921d5af2: Loading layer [==================================================>]    386kB/386kB
821d8d203aa6: Loading layer [==================================================>]  108.9MB/108.9MB
9b1c75c3a754: Loading layer [==================================================>]  3.584kB/3.584kB
bb8c4dfba3d8: Loading layer [==================================================>]  3.584kB/3.584kB
16de0644af74: Loading layer [==================================================>]  28.67kB/28.67kB
83b17dca85f8: Loading layer [==================================================>]  44.17MB/44.17MB
bdfede6a69de: Loading layer [==================================================>]  224.8MB/224.8MB
a4fb8f97cd43: Loading layer [==================================================>]  12.94MB/12.94MB
8bc5871427d5: Loading layer [==================================================>]   2.56kB/2.56kB
0d7964d8438e: Loading layer [==================================================>]   2.56kB/2.56kB
6f4312a566a3: Loading layer [==================================================>]  5.632kB/5.632kB
0ae87417ea93: Loading layer [==================================================>]  31.74kB/31.74kB
Loaded image ID: sha256:802ce49cc0586fa2ae51757aeba8352c9614822caa9c884f0b4ba284f023eca6
```

then rename image above image:

```Dockerfile
docker tag 802ce49cc0586fa2ae51757aeba8352c9614822caa9c884f0b4ba284f023eca6 test1:0.1
```

then run above image:

```Dockerfile
docker run -it --name test11 test1:0.1 bash
```

## 2.8. build image from Dockerfile

```Dockerfile
docker build -t {author}/{IMAGE_NAME}:{TAG} .   # chu y dau cham
```

## 2.9. delete an image

`docker rmi {image-id}`

## 2.10. check image exist on remote docker hub

check this file: 
[../../sample/devops/docker/docker-hub-api-combine-with-shell-script/check-image-exist-on-docker-hub.sh](../../sample/devops/docker/docker-hub-api-combine-with-shell-script/check-image-exist-on-docker-hub.sh)

# 3. Dockerfile sample

```Dockerfile
FROM ubuntu:16.04

Dockerfile ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y \
	wget \
	expect \
	curl gcc \
	git \
	sshpass \
	libffi-dev \
	libssl-dev \
	python \
	python-dev \
	libxml2-dev \
	libxslt1-dev \
	nginx \
	uwsgi \
	uwsgi-plugin-python \
	supervisor \
	python-setuptools

RUN easy_install -U setuptools \
	pip

RUN pip install virtualenv \
	pymodm \
	oslo.utils \
	oslo_config \
	python-openstackclient \
	ipaddress \
	python-neutronclient \
	python-subunit \
	paramiko \
	python-heatclient \
	python-novaclient \
	scp \
	jinja2 \
	paramiko \
	BeautifulSoup4 \
	flask \
	chainmap \
	kubernetes \
	mock \
	scp \
	pika

RUN cd ~/ &&\
	git clone https://validiumguest:validium123@github.com/viosoft-corp/validium-nsb-backend.git -b microservices

RUN cd ~/validium-nsb-backend &&\
	git clone https://validiumguest:validium123@github.com/viosoft-corp/nsb.git yardstick

RUN cd ~/validium-nsb-backend/yardstick &&\
	git checkout 8baeff36489971638f76155a5d4f3b5c95420631 &&\
	cp ../patchs/yardstick-patch/20171206.patch . &&\
	git apply 20171206.patch

EXPOSE 5000

CMD ["/bin/bash", "-c", "~/validium-nsb-backend/validium/microservices/onboad/onboard_microservice.sh"]
```

# 4. Move docker's default /var/lib/docker to another directory on Ubuntu/Debian Linux

Reference [here](https://linuxconfig.org/how-to-move-docker-s-default-var-lib-docker-to-another-directory-on-ubuntu-debian-linux)

```shell
sudo gedit /lib/systemd/system/docker.service
```

Then add **-g /new/path/docker** to **ExecStart**

Example 1:

```ini
FROM:
ExecStart=/usr/bin/docker daemon -H fd://
TO:
ExecStart=/usr/bin/docker daemon -g /new/path/docker -H fd://
```

Example 2:

```ini
FROM:
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
TO:
ExecStart=/usr/bin/dockerd -g /home/xuananh/data/.docker -H fd:// --containerd=/run/containerd/containerd.sock
```

Then stop docker service:

```shell
sudo systemctl stop docker
```

Ensure docker is stopped, check by command:

```shell
ps aux | grep -i docker | grep -v grep
```

Then reload system daemon

```shell
sudo systemctl daemon-reload
```

If new directory is not exist, create one and sync data to it

```shell
mkdir /new/path/docker
rsync -aqxP /var/lib/docker/ /new/path/docker
```

Start docker daemon

```shell
sudo systemctl start docker
```

Confirm that docker runs within a new data directory:

```shell
ps aux | grep -i docker | grep -v grep
# output
root      2095  0.2  0.4 664472 36176 ?        Ssl  18:14   0:00 /usr/bin/docker daemon -g  /new/path/docker -H fd://
root      2100  0.0  0.1 360300 10444 ?        Ssl  18:14   0:00 docker-containerd -l /var/run/docker/libcontainerd/docker-containerd.sock --runtime docker-runc
```

# 5. Docker run commons images
		   
## 5.1. Redis

```shell
docker run -it --name test-redis \
               -p 7379:6379  \
               redis
```

## 5.2. RabbitMQ

```shell
docker run -d --name test-rabbitmq \
               -p 15673:15672  \
			   -p 5673:5672  \
			   -e RABBITMQ_DEFAULT_USER=admin \
			   -e RABBITMQ_DEFAULT_PASS=admin \
               rabbitmq:3.8.0-management
```

## 5.3. PostgreSQL

```shell
docker run -d --name test-postgresql \
				-p 5433:5432 \
				-v /tmp/test-postgresql-data:/var/lib/postgresql/data \
				-e POSTGRES_PASSWORD=123456 \
				-e POSTGRES_USER=if_not_set_default_is_postgres \
		 		-e POSTGRES_DB=database_name_to_create \
				postgres:9.6
```

## 5.4. MySQL

```shell
docker run -d --name test-mysql \
				-p 3308:3306 \
				-v /tmp/test-mysql-data:/var/lib/mysql/ \
				-e MYSQL_ROOT_PASSWORD=123456 \
				-e MYSQL_USER=other_user \
				-e MYSQL_PASSWORD=password_for_other_user \
				-e MYSQL_DATABASE=database_name_to_create \
				mysql:5.7 \
				--character-set-server=utf8 \
         		--collation-server=utf8_unicode_ci
```

## 5.5. Kafka

```shell
docker run -d --name test-kafka \
            -p 2181:2181 \
            -p 9092:9092 \
            --env ADVERTISED_HOST=0.0.0.0\
            --env ADVERTISED_PORT=9092 \
            spotify/kafka
```

## 5.6. Kafdrop

```shell
docker run -d --name test-kafdrop \
            -p 9009:9000 \
            --env ZOOKEEPER_CONNECT=zookeeper:2181 \
            xuananh/kafdrop:2.0.6
```

## 5.7. MongoDB

```shell
docker run -d --name test-mongodb \
				-p 27018:27017 \
				-v /tmp/test-mongodb-data:/data/db \
				-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
				-e MONGO_INITDB_ROOT_PASSWORD=secret \
				mongo
```

## 5.8. Jenkins

```shell
mkdir -p /tmp/test-jenkins
docker run -d --name test-jenkins \
				-p 8080:8080 \
				-p 50000:50000 \
				-v /tmp/test-jenkins:/var/jenkins_home \
				jenkins/jenkins
```


# 6. Debug container

1. get entrypoint and cmd of container:

```shell
docker inspect container-name
# output
"Path": "/opt/bitnami/scripts/sonarqube/entrypoint.sh",
"Args": [
	"/opt/bitnami/scripts/sonarqube/run.sh"
],
...
```

2. from above we have :
   
		entrypoint: /opt/bitnami/scripts/sonarqube/entrypoint.sh
		cmd: /opt/bitnami/scripts/sonarqube/run.sh

3. add to docker-compose file at service that you want to debug:

```yml
	sonarqube:
		user: root
		entrypoint: bash -c # sh -c
		command:
		- while true; do echo "this is test command"; sleep 1; done
```

4. attach to shell of that service, then run entrypoint and cmd that we got above:

```shell
docker exec -it sonarqube bash
# then run entrypoint and cmd
/opt/bitnami/scripts/sonarqube/entrypoint.sh /opt/bitnami/scripts/sonarqube/run.sh
```

5. now see log output or any log file that you want 

# 7. Reference

This is a good website for undertanding all aspect of docker: https://vsupalov.com/articles/
