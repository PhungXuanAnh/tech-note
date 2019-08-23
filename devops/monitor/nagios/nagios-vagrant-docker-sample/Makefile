DCOMPOSE_DIR  = plusfun
DESTINATION_PATH=/deploy/nagios
RSYNC_PARAMS = -avlP \
 				--exclude-from='deploy/rsync-excluded.txt' \

DESTINATION_SERVER1=ubunu@192.168.1.211
DESTINATION_SERVER2=ubunu@192.168.1.211

DEPLOY_COMMAND='cd /deploy/plusfun && docker restart plusfun_nginx_1'

all: up

up:
	docker-compose up -d

down1: 
	docker-compose -f docker-compose.staging.yml -f docker-compose.1.sigma-local.yml -f docker-compose.1.monitor.yml down -v

down2: 
	docker-compose -f docker-compose.staging.yml -f docker-compose.2.sigma-local.yml -f docker-compose.2.monitor.yml down -v

ps1: 
	docker-compose -f docker-compose.staging.yml -f docker-compose.1.sigma-local.yml -f docker-compose.1.monitor.yml ps

ps2: 
	docker-compose -f docker-compose.staging.yml -f docker-compose.2.sigma-local.yml -f docker-compose.2.monitor.yml ps

restart:
	docker-compose restart

init-db:
	docker exec -it $(DCOMPOSE_DIR)_registration_1 alembic --config plusfun_reg/configuration/etc-staging/alembic.ini upgrade head

chmod-logbin:
	chmod 777 -R mysql-1/mysql-logbin mysql-2/mysql-logbin

# rsync commands
upload:
	rsync $(RSYNC_PARAMS) ./ $(DESTINATION_SERVER1):$(DESTINATION_PATH)
	rsync $(RSYNC_PARAMS) ./ $(DESTINATION_SERVER2):$(DESTINATION_PATH)

download:
	rsync $(RSYNC_PARAMS) $(DESTINATION_SERVER):$(DESTINATION_PATH) ./

remote-deploy:
	ssh $(DESTINATION_SERVER1) -t $(DEPLOY_COMMAND)
	ssh $(DESTINATION_SERVER2) -t $(DEPLOY_COMMAND)

updep: upload remote-deploy
	