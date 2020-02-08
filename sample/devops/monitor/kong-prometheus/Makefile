SHELL := /bin/bash
KONG_SERVICE_NAME=user-service
KONG_SERVICE_HOST=user-service.com
SERVICE_IP=user-service
SERVICE_PORT=8123

test-service-directly:
	curl http://localhost:8123
	curl http://localhost:8123/api/user1
	curl http://localhost:8123/api/user2

service-up:
	docker-compose up -d user-service
	sleep 3
	$(MAKE) test-service-directly

kong-test-services:
	docker exec -it kong kong health
	docker exec -it kong kong version
	docker exec -it kong kong roar
	curl -i http://localhost:8001/

kong-database:
	docker-compose up -d kong-database
	sleep 5
	docker-compose up -d kong-migration
	docker-compose up -d konga-prepare 

kong-konga-up:
	docker-compose up -d kong konga
	sleep 15
	$(MAKE) kong-test-services
	sensible-browser http://$(shell ip route get 8.8.8.8 | awk '{print $$7; exit}'):1337

kong-add-service:
	curl -i -X POST --url http://localhost:8001/services/ \
    	--data 'name=${KONG_SERVICE_NAME}' \
		--data 'host=${SERVICE_IP}' \
		--data 'port=${SERVICE_PORT}'

kong-add-route:
	curl -i -X POST  --url http://localhost:8001/services/${KONG_SERVICE_NAME}/routes  \
		--data 'name=${KONG_SERVICE_NAME}_route' \
		--data 'hosts[]=${KONG_SERVICE_HOST}' \
		--data 'strip_path=false'

kong-test-user-service:
	curl -i -XGET --url http://localhost:8000 --header 'Host: ${KONG_SERVICE_HOST}'
	curl -i -XGET --url http://localhost:8000/api/user1 --header 'Host: ${KONG_SERVICE_HOST}'
	curl -i -XGET --url http://localhost:8000/api/user2 --header 'Host: ${KONG_SERVICE_HOST}'

kong-prometheus-enable:
	curl -i -X POST http://localhost:8001/services/${KONG_SERVICE_NAME}/plugins \
		--data "name=prometheus"

kong-prometheus-get-metrics:
	curl -i http://localhost:8001/metrics

kong-prometheus-generate-traffic:
	while true; do curl -XGET --url http://localhost:8000 --header 'Host: ${KONG_SERVICE_HOST}'; sleep 0.1; done

kong-prometheus-generate-traffic1:
	while true; do curl -XGET --url http://localhost:8000/api/user2 --header 'Host: ${KONG_SERVICE_HOST}'; sleep 0.1; done

# ----------------------------------------------------------------------------------------------------
kong-create-consumer-and-key:
	curl -i -X POST --url http://localhost:8001/consumers --data 'username=api-user'
	curl -i -X POST --url http://localhost:8001/consumers/api-user/key-auth --data 'key=secret_key'

kong-add-auth:
	curl -i -X POST --url http://localhost:8001/services/${KONG_SERVICE_NAME}/plugins --data 'name=key-auth'
