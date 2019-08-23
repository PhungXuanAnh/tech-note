HOSTNAME := $(shell cat /etc/hostname)

DESTINATION_PATH=/deploy/telegraf
RSYNC_PARAMS = -rvl
DESTINATION_SERVER1=ubuntu@192.168.1.211
DESTINATION_SERVER2=ubuntu@192.168.1.212

up:
	HOSTNAME=$(HOSTNAME) docker-compose -f docker-compose.yml -f docker-compose.single.yml up -d
down:
	HOSTNAME=$(HOSTNAME) docker-compose -f docker-compose.yml -f docker-compose.single.yml down
ps:
	HOSTNAME=$(HOSTNAME) docker-compose -f docker-compose.yml -f docker-compose.single.yml ps

stack-deploy:
	docker stack deploy -c docker-compose.yml -c docker-compose.swarm.yml monitor
stack-rm:
	docker stack rm monitor

upload:
	rsync $(RSYNC_PARAMS) ./ $(DESTINATION_SERVER1):$(DESTINATION_PATH)
	rsync $(RSYNC_PARAMS) ./ $(DESTINATION_SERVER2):$(DESTINATION_PATH)
download:
	rsync $(RSYNC_PARAMS) $(DESTINATION_SERVER):$(DESTINATION_PATH) ./

clone-plugin:
	cd plugins; \
	git clone https://github.com/grafana/piechart-panel.git	