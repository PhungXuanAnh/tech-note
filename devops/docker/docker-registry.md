- [1. Deploy and test](#1-deploy-and-test)
  - [1.1. Start registry](#11-start-registry)
  - [1.2. Fix ERROR: Private registry push fail: server gave HTTP response to HTTPS client](#12-fix-error-private-registry-push-fail-server-gave-http-response-to-https-client)
  - [1.3. Test](#13-test)
  - [1.4. Remove registry](#14-remove-registry)
- [2. Setup secure for registry server](#2-setup-secure-for-registry-server)
- [3. Sample docker compose](#3-sample-docker-compose)
- [4. Requirement resourses](#4-requirement-resourses)

# 1. Deploy and test

## 1.1. Start registry

```shell
docker run -d -p 5000:5000 --name registry registry:2

# or add volume to save data

docker run -d --name sigma-docker-registry \
    -p 5000:5000 \
    --restart=always \
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
    -v docker-registry-data:/data \
    registry:2
```

## 1.2. Fix ERROR: Private registry push fail: server gave HTTP response to HTTPS client

This error occure when pull/push from our registry server without https

```shell
vim /etc/docker/daemon.json

# then, add content:
{ "insecure-registries":["157.234.256.23:5000"] }

# then restart docker service
service docker restart
```

## 1.3. Test

Create image and push to registry

```shell
docker pull ubuntu
docker image tag ubuntu localhost:5000/myfirstimage
docker push localhost:5000/myfirstimage
```

Check on registry, get repo

```shell
curl -i http://localhost:5000/v2/_catalog 
curl -i http://localhost:5000/v2/kidssy/app-sample/tags/list
# Reference registry api: https://docs.docker.com/registry/spec/api/#listing-repositories
```

Pull image from registry

```shell
docker rmi localhost:5000/myfirstimage:latest
docker pull localhost:5000/myfirstimage
docker images | grep myfirstimage
```

## 1.4. Remove registry

```shell
docker container stop registry && docker container rm -v registry

# or

docker run -d --name sigma-docker-registry \
    -p 5000:5000 \
    --restart=always \
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
    -v docker-registry-data:/data \
    registry:2

```

https://docs.docker.com/registry/

https://docs.docker.com/registry/deploying/

# 2. Setup secure for registry server

https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04

https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04
https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

# 3. Sample docker compose

[sample about docker registry here](../../sample/devops/docker/docker-registry/Readme.md)

# 4. Requirement resourses

4G Ram
CPU is not matter
Bandwidth

https://success.docker.com/article/what-are-the-minimum-requirements-for-docker-trusted-registry-dtr
