# Deploy using docker command

```shell
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

# Test

Change config of docker service for run *docker pull/push* with http instead of https, it avoid error


{ "insecure-registries":["128.199.247.115:5000"] }