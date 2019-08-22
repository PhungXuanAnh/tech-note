- [1. Create your own project](#1-create-your-own-project)
- [2. Create and config vm using Vagrant](#2-create-and-config-vm-using-vagrant)
- [3. Add more docker compose file for more config](#3-add-more-docker-compose-file-for-more-config)
- [4. Enable swarm mode and add node](#4-enable-swarm-mode-and-add-node)
- [5. Build images and create volume dir at all node (vm)](#5-build-images-and-create-volume-dir-at-all-node-vm)
- [6. Run deploy stack and fix error](#6-run-deploy-stack-and-fix-error)
  - [6.1. Fix network error](#61-fix-network-error)
  - [6.2. Migrate database](#62-migrate-database)
- [7. Check result](#7-check-result)

# 1. Create your own project

- I will you my already created project at [github repo](https://github.com/PhungXuanAnh/django-nginx-gunicorn-postgres) branch master
- This project has configured for deploy using Docker compose on single host, detail how to create this project [here]({{ site.url }}{{ site.baseurl }}/devops/django-nginx-gunicorn-postgres/)

# 2. Create and config vm using Vagrant

- I will use 2 host to deploy this django app. One for run django app and another for run database server
- Clone project to host at **/deploy/djangoapp**

```shell
mkdir -p /deploy
git clone https://github.com/PhungXuanAnh/django-nginx-gunicorn-postgres.git djangoapp
```

- Let's create 2 vm using Vagrantfile, detail how to use vagrant see [here]({{ site.url }}{{ site.baseurl }}/devops/vagrant-and-virtual-box/)

Run on host:

```shell
mkdir vm-djangoapp
cd vm-djangoapp
vagrant init

mkdir vm-database
cd vm-database
vagrant init
```

Replace Vagrantfile in 2 above dir appropriate:

```conf
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "vm-djangoapp"
  config.vm.network "public_network", ip: "192.168.1.115"
  config.vm.synced_folder "/deploy/djangoapp","/deploy/djangoapp"
  config.disksize.size = '20GB'
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.cpus = 2
  end
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    wget -qO- https://get.docker.com/ | sh
    usermod -aG docker vagrant
    apt-get install -y docker-compose
  SHELL
end
```

Using above Vagrantfile for vm run django app
Change 3 config for vm run postgres database:

```conf
  config.vm.hostname = "vm-database"
  config.vm.network "public_network", ip: "192.168.1.116"
  config.vm.synced_folder "/deploy/djangoapp","/deploy/djangoapp"
```

Run on host:

```shell
vagrant up
vagrant ssh
```

# 3. Add more docker compose file for more config

- Add file **docker-compose-vm-djangoapp.yml**, this file specify which service run on **vm-djangoapp**


```shell
touch docker-compose-vm-djangoapp.yml
```

```yml
version: '3'

services:

  django-nginx-gunicorn-postgres:
    deploy:
      placement:
        constraints:
          - node.hostname == vm-djangoapp

  nginx:
    deploy:
      placement:
        constraints:
          - node.hostname == vm-djangoapp
```

- Add file **docker-compose-vm-database.yml**, this file specify which service run on **vm-database**

```shell
touch docker-compose-vm-database.yml
```

```yml
version: '3'

services:

  database1:
    deploy:
      placement:
        constraints:
          - node.hostname == vm-database
```

# 4. Enable swarm mode and add node

Run on **vm-djangoapp** (it has ip 192.168.1.215):

```shell
docker swarm init --advertise-addr=192.168.1.115
```

it will show

```shell
# To add a worker to this swarm, run the following command:

docker swarm join --token SWMTKN-1-05mr233vlh8k3f1j688de8scf53sejunk43ymwyh9i76r097uz-2z79uque2ujwinas0xicg7pbk 192.168.1.201:2377
```

Run above command in vm-database to add this vm to swarm

# 5. Build images and create volume dir at all node (vm)

While deploy service on swarm, images and volume directories are not created automatically. So you must do it manually on earch node (vm)

```shell
docker build
```

# 6. Run deploy stack and fix error

```shell
cd /deploy/djangoapp
docker stack deploy -c docker-compose.yml -c docker-compose-vm-djangoapp.yml -c docker-compose-vm-database.yml djangoapp
```

## 6.1. Fix network error

You will encounter error:

`failed to create service djangoapp_database1: Error response from daemon: The network djangoapp_database1_network cannot be used with services. Only networks scoped to the swarm can be used, such as those created with the overlay driver.`

Fist, let's remove already exist network

```shell
docker network ls
docker network rm djangoapp_database1_network djangoapp_nginx_network
```

The above error happen because network is **bridge** driver, it must be type **overlay** driver or Only networks scoped to the swarm. It means there are 2 ways to fix this error as below.

- Way 1: change your network driver in docker compose file to **overlay** driver:

```yml
  nginx_network:
    driver: overlay
  database1_network:
    driver: overlay
```

- Way 2: don't change your docker compose create manually network with **--scopy swarm** option:

```shell
docker network create --scope=swarm --driver=bridge \
       --subnet=172.22.0.0/16 --gateway=172.22.0.1 nginx_network

docker network create --scope=swarm --driver=bridge \
       --subnet=172.22.0.0/16 --gateway=172.22.0.1 database1_network
```

Now, deploy start again:

```shell
cd /deploy/djangoapp
docker stack deploy -c docker-compose.yml -c docker-compose-vm-djangoapp.yml -c docker-compose-vm-database.yml djangoapp
```

## 6.2. Migrate database

Run in vm-djangoapp

```shell
docker ps  # then replace appropriate name of container below command
docker exec -ti djangoapp_django-nginx-gunicorn-postgres.1.0i06lovhz98xjm8o7vhfeasxo bash -c "python manage.py migrate"
```

# 7. Check result

```shell
docker stack ls
docker stack ps djangoapp
docker service ls
docker service ps djangoapp_django-nginx-gunicorn-postgres
```

Access app: [http://192.168.1.115:81/admin/](http://192.168.1.115:81/admin/) or [http://192.168.1.116:81/admin/](http://192.168.1.116:81/admin/)