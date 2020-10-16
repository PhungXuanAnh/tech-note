# NOTE 

- It need to wait a few minutes for replica set is setuped, then connect to mongodb server
- version of mongodb server must be same in container: mongo1, mongo2, mongo3, rsinit
- Cannot create replica set in `docker-entrypoint-initdb.d`, for more detail, see [here](https://github.com/docker-library/mongo/issues/246#issuecomment-500303852)

# Test:

Ensure that the replica set has a primary.

```shell
docker exec local-mongo1 mongo --eval "rs.status()" | grep -C 5 PRIMARY
docker exec local-mongo2 mongo --eval "rs.status()" | grep -C 5 PRIMARY   
docker exec local-mongo3 mongo --eval "rs.status()" | grep -C 5 PRIMARY  
```

result from 3 above commands should be same and be:

```json              
{
        "_id" : 0,
        "name" : "mongo1:27017",
        "health" : 1,
        "state" : 1,
        "stateStr" : "PRIMARY",
        "uptime" : 418,
        "optime" : {
                "ts" : Timestamp(1602831348, 1),
                "t" : NumberLong(3)
        },
```

Check replica set is not configured:

```shell
docker exec local-mongo1 mongo --eval "rs.status()" | grep -C 5 "no replset config has been received"
```

# Reference

https://docs.mongodb.com/manual/tutorial/deploy-replica-set/

https://gist.github.com/crapthings/71fb6156a8e9b31a2fa7946ebd7c4edc

https://gist.github.com/asoorm/7822cc742831639c93affd734e97ce4f


