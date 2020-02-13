- [1. Deploy](#1-deploy)
  - [1.1. Docker command](#11-docker-command)
  - [1.2. Docker compose](#12-docker-compose)
- [2. Test](#2-test)

# 1. Deploy

## 1.1. Docker command

```shell
docker run -d --name sigma-docker-registry \
    -p 5000:5000 \
    --restart=always \
    -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
    -v docker-registry-data:/data \
    registry:2
```

## 1.2. Docker compose

# 2. Test

Change config of docker service for run *docker pull/push* with http instead of https, it avoid error


{ "insecure-registries":["128.199.247.115:5000"] }