Monitor and statistic kong traffic using prometheus and grafana

# Start up service

```shell
docker-compose up -d user-service
make test-service-directly
```

# Start up kong

```shell
docker-compose up -d kong-database kong-migration kong
make kong-test-services
```

# Start up konga

Konga help to manage kong using web ui

```shell
docker-compose up -d konga-prepare konga
```

Access konga url: http://localhost:1337

Add connection
**NOTE**: kong url must be external ip, not using localhost

![img1](readme-images/kong-prometheus-1.png)
![img2](readme-images/kong-prometheus-2.png)

Thick click **Active**

# Config service in kong

```shell
make kong-add-service
make kong-add-route
```

See result on konga

![img3](readme-images/kong-prometheus-3.png)
![img4](readme-images/kong-prometheus-4.png)

Test new service call through kong

```shell
make kong-test-user-service
```

# Enable prometheus plugin for above service

```shell
make kong-prometheus-enable
```

Check on konga: http://localhost:1337/#!/plugins

![img5](readme-images/kong-prometheus-5.png)

Genarate traffic to service to test plugin

```shell
make kong-prometheus-generate-traffic
```

Get metrics

```shell
make kong-prometheus-get-metrics
```

# Start up prometheus

Change **targets** address on file [prometheus.yml](prometheus.yml)

```shell
docker-compose up -d prometheus
```

Web console: http://localhost:9090/graph

![img6](readme-images/kong-prometheus-6.png)

To check correct targets on file [prometheus.yml](prometheus.yml) , access http://localhost:9090/targets

![img7](readme-images/kong-prometheus-7.png)

# Start up grafana

Change url to prometheus datasource on file [datasources.yml](grafana/provisioning/datasources/datasources.yml)

```shell
docker-compose up -d grafana
```

Access http://localhost:3000/login

Login with account admin/admin

Access http://localhost:3000/dashboards

![img8](readme-images/kong-prometheus-8.png)

Click to Kong dashboard

Change time to **Last 15 menutes** and **Refresh after 5s** to see result

![img9](readme-images/kong-prometheus-9.png)
