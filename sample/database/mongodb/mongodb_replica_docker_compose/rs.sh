#!/bin/bash

echo "prepare rs initiating !!!"

check_replica_status() {
  echo "checking replica set status ..."
  primary=$(mongo --host mongo1 --port 27017 --eval "rs.status()" | grep -C 5 PRIMARY)
  if [ -z "$primary" ]
  then
        init_rs
        check_replica_status
  else
        echo $primary
  fi
}

init_rs() {
  sleep 1
  ret=$(mongo --host mongo1 --port 27017 --eval "rs.initiate({ _id: 'rs0', members: [{ _id: 0, host: 'mongo1:27017' }, { _id: 1, host: 'mongo2:27017' }, { _id: 2, host: 'mongo3:27017' } ] })")
}

check_replica_status

echo "rs initiating finished."
exit 0


