**Reference**: 

https://gist.github.com/crapthings/71fb6156a8e9b31a2fa7946ebd7c4edc

https://gist.github.com/asoorm/7822cc742831639c93affd734e97ce4f


**NOTE**: 

- It need to wait a few minutes for replica set is setuped, then connect to mongodb server
- version of mongodb server must be same in container: mongo1, mongo2, mongo3, rsinit
- Cannot create replica set in `docker-entrypoint-initdb.d`, for more detail, see [here](https://github.com/docker-library/mongo/issues/246#issuecomment-500303852)
