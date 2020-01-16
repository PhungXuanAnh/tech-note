SHELL := /bin/bash
SERVICE_NAME=user-service
SERVICE_HOST=user-service
SERVICE_PORT=8123
SERVICE_HOST_KONG=user-service.com

test-service-directly:
	curl http://localhost:8123
	curl http://localhost:8123/api/user1
	curl http://localhost:8123/api/user2

kong-test-services:
	docker exec -it kong kong health
	docker exec -it kong kong version
	docker exec -it kong kong roar

kong-add-service:
	curl -i -X POST --url http://localhost:8001/services/ \
    	--data 'name=${SERVICE_NAME}' \
		--data 'host=${SERVICE_HOST}' \
		--data 'port=${SERVICE_PORT}'

kong-add-route:
	curl -i -X POST  --url http://localhost:8001/services/${SERVICE_NAME}/routes  \
		--data 'name=${SERVICE_NAME}_route' \
		--data 'hosts[]=${SERVICE_HOST_KONG}' \
		--data 'strip_path=false'

kong-test-user-service:
	curl -i -XGET --url http://localhost:8000 --header 'Host: ${SERVICE_HOST_KONG}'
	curl -i -XGET --url http://localhost:8000/api/user1 --header 'Host: ${SERVICE_HOST_KONG}'
	curl -i -XGET --url http://localhost:8000/api/user2 --header 'Host: ${SERVICE_HOST_KONG}'

kong-prometheus-enable:
	curl -i -X POST http://localhost:8001/services/${SERVICE_NAME}/plugins \
		--data "name=prometheus"

kong-prometheus-get-metrics:
	curl -i http://localhost:8001/metrics

kong-prometheus-generate-traffic:
	while true; do curl -XGET --url http://localhost:8000 --header 'Host: ${SERVICE_HOST_KONG}'; sleep 0.1; done

kong-prometheus-generate-traffic1:
	while true; do curl -XGET --url http://localhost:8000/api/user2 --header 'Host: ${SERVICE_HOST_KONG}'; sleep 0.1; done

# ----------------------------------------------------------------------------------------------------
kong-create-consumer-and-key:
	curl -i -X POST --url http://localhost:8001/consumers --data 'username=api-user'
	curl -i -X POST --url http://localhost:8001/consumers/api-user/key-auth --data 'key=secret_key'

kong-add-auth:
	curl -i -X POST --url http://localhost:8001/services/${SERVICE_NAME}/plugins --data 'name=key-auth'