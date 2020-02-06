- [1. Install](#1-install)
  - [1.1. Requirement resourses](#11-requirement-resourses)
- [2. Deploy and test](#2-deploy-and-test)
  - [2.1. Start registry](#21-start-registry)
  - [2.2. Test](#22-test)
  - [2.3. Remove registry](#23-remove-registry)
- [3. Setup secure for registry server](#3-setup-secure-for-registry-server)
- [4. Sample docker compose](#4-sample-docker-compose)

# 1. Install

## 1.1. Requirement resourses

4G Ram
CPU is not matter
Bandwidth

https://success.docker.com/article/what-are-the-minimum-requirements-for-docker-trusted-registry-dtr

# 2. Deploy and test

## 2.1. Start registry

```shell
docker run -d -p 5000:5000 --name registry registry:2
```

## 2.2. Test

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

## 2.3. Remove registry

```shell
docker container stop registry && docker container rm -v registry
```

https://docs.docker.com/registry/

https://docs.docker.com/registry/deploying/

# 3. Setup secure for registry server

https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04

https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04
https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

# 4. Sample docker compose

[sample about docker registry here](../../sample/devops/docker/docker-registry/Readme.md)