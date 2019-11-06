- [1. container](#1-container)
	- [1.1. list all](#11-list-all)
	- [1.2. create a container from an image](#12-create-a-container-from-an-image)
	- [1.3. attach a container](#13-attach-a-container)
	- [1.4. deattach a container and keep it still running](#14-deattach-a-container-and-keep-it-still-running)
	- [1.5. delete all stopped containers](#15-delete-all-stopped-containers)
- [2. images](#2-images)
	- [2.1. list all image](#21-list-all-image)
	- [2.2. pull image](#22-pull-image)
	- [2.3. save the change in already exist image](#23-save-the-change-in-already-exist-image)
	- [2.4. push image to Docker hub](#24-push-image-to-docker-hub)
	- [2.5. save image to archive file](#25-save-image-to-archive-file)
	- [2.6. load image from archive file](#26-load-image-from-archive-file)
	- [2.7. build image from Dockerfile](#27-build-image-from-dockerfile)
	- [2.8. delete an image](#28-delete-an-image)
- [3. Dockerfile sample](#3-dockerfile-sample)
- [4. Docker run commons images](#4-docker-run-commons-images)
	- [4.1. Redis](#41-redis)
	- [4.2. RabbitMQ](#42-rabbitmq)
	- [4.3. PostgreSQL](#43-postgresql)
	- [4.4. MySQL](#44-mysql)
	- [4.5. Kafka](#45-kafka)
	- [4.6. MongoDB](#46-mongodb)


# 1. container

## 1.1. list all

docker ps
docker ps -a
docker container ls

## 1.2. create a container from an image

```Dockerfile
docker run -it --name {container_name} \
               --hostname {container_hostname} \
               --net=host \
               -p {host_port}:{container_port} \
               -v {abs_path_host}:}path_contain} \
               {image_name}:{tag}
# example
docker run -it --name demo-container \
               --hostname demo-container \
               --net=host \
               -p 12345:12345  \
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

----------------------------------------------------------------

# 2. images

## 2.1. list all image

docker images

## 2.2. pull image

```Dockerfile
docker pull ubuntu:14.04 (by default, it will download offical ubuntu)
docker pull {author_name}/{image_name} # ex: docker pull binhcao/docker-whale
```

## 2.3. save the change in already exist image

`docker commit {container_id} {author}/{image_name}:{tag}`

## 2.4. push image to Docker hub

Push an exist image to a repo in Docker hub

```Dockerfile
docker login <username>
# change tag of an exist image
docker tag <image_id> username/image_name:tag
docker push username/image_name
```

## 2.5. save image to archive file

```Dockerfile
docker save <image_name/image_id> > name_archive_file.tar
```

## 2.6. load image from archive file

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

## 2.7. build image from Dockerfile

```Dockerfile
docker build -t {author}/{image_name}:{tag} .   # chu y dau cham
```

## 2.8. delete an image

`docker rmi {image-id}`

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

# 4. Docker run commons images

## 4.1. Redis

```shell
docker run -it --name test-redis \
               -p 7379:6379  \
               redis
```			   

## 4.2. RabbitMQ

```shell
docker run -d --name test-rabbitmq \
               -p 15673:15672  \
			   -p 5673:5672  \
			   -e RABBITMQ_DEFAULT_USER=admin \
			   -e RABBITMQ_DEFAULT_PASS=admin \
               rabbitmq:3.8.0-management
```

## 4.3. PostgreSQL

```shell
docker run -d --name test-postgresql \
				-p 5433:5432 \
				-v /tmp/test-postgresql-data:/var/lib/postgresql/data \
				-e POSTGRES_PASSWORD=123456 \
				-e POSTGRES_USER=if_not_set_default_is_postgres \
		 		-e POSTGRES_DB=database_name_to_create \
				postgres:9.6
```

## 4.4. MySQL

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

## 4.5. Kafka

```shell
docker run -d --name kafka-test \
            -p 2181:2181 \
            -p 9092:9092 \
            --env ADVERTISED_HOST=0.0.0.0\
            --env ADVERTISED_PORT=9092 \
            spotify/kafka
```

## 4.6. MongoDB


```shell
docker run -d --name test-mongodb \
				-p 27018:27017 \
				-v /tmp/test-mongodb-data:/data/db \
				-e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
				-e MONGO_INITDB_ROOT_PASSWORD=secret \
				mongo
```