scale-replica:
	docker-compose up --detach --scale redis-master=1 --scale redis-secondary=3

info-master:
	docker exec redis-master redis-cli --pass my_master_password info replication

info-replica:
	docker exec redis-replica redis-cli --pass my_replica_password info replication