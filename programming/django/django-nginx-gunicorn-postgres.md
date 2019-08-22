Deploy django app with nginx, gunicorn and multiple postgres using Docker
---

- [1. Overview: to get a better understanding of the whole thing](#1-overview-to-get-a-better-understanding-of-the-whole-thing)
- [2. Create your project](#2-create-your-project)
- [3. Add Dockerfile](#3-add-dockerfile)
- [4. Add Docker-compose](#4-add-docker-compose)
  - [4.1. Add django-nginx-gunicorn-postgres service](#41-add-django-nginx-gunicorn-postgres-service)
  - [4.2. Add nginx service](#42-add-nginx-service)
- [5. Add containers for one or more Postgres databases](#5-add-containers-for-one-or-more-postgres-databases)
- [6. Prepare for production](#6-prepare-for-production)
  - [6.1. Merge develop branch to master branch](#61-merge-develop-branch-to-master-branch)
  - [6.2. Run django app with gunicorn](#62-run-django-app-with-gunicorn)
  - [6.3. Static files: collecting, storing and serving](#63-static-files-collecting-storing-and-serving)
  - [6.4. Disable debug option in **setting.py**](#64-disable-debug-option-in-settingpy)
  - [6.5. Run Gunicorn using Supervisor](#65-run-gunicorn-using-supervisor)
- [7. Reference](#7-reference)

# 1. Overview: to get a better understanding of the whole thing

We want 3 containers:

- NginX
- Django + Gunicorn (they always go together)
- PostgreSQL

The NginX container communicate with the Django+Gunicorn one, which itself connects to the Postgres container.

![](../../images/programming/django/2018-07-16-django-nginx-gunicorn-postgres-00.png)

In docker-compose.yml, we will delare 3 services corresponding with 3 containers.
To communicate them, let's create network bridge

![](../../images/programming/django/2018-07-16-django-nginx-gunicorn-postgres-01.png)

If you need serveral databases for your project:

![](../../images/programming/django/2018-07-16-django-nginx-gunicorn-postgres-03.png)

Each time you restart your containers or services, the data in the Postgres databases will be lost. In production, we need these data to be permanent. To do this, we will use volumes:

![](../../images/programming/django/2018-07-16-django-nginx-gunicorn-postgres-04.png)

# 2. Create your project

I will deploy my already exist project [django-ckeditor-sample](https://github.com/PhungXuanAnh/django-ckeditor-sample) with nginx and gunicorn

- Change project name and all other config from **django-ckeditor-sample** to **django-nginx-gunicorn-postgres**, then run `python manage.py runserver` to test
- Create another project name **django-nginx-gunicorn-postgres** in github
- Change remote

  ```shell
  git remote -v
  git remote remove origin
  git remote add origin git@github.com:PhungXuanAnh/django-nginx-gunicorn-postgres.git
  ```

- Create branch **develop**

Branch **develop** will be reserved test and deploy to staging server
Branch **master** will be deployed to production server.

```shell
git checkout -b develop
git push origin develop
```

# 3. Add Dockerfile

Create a Dockerfile in root folder of project:

```shell
# start from an official image
FROM python:3.6

# arbitrary location choice: you can change the directory
RUN mkdir -p /deploy/django-nginx-gunicorn-postgres/
WORKDIR /deploy/django-nginx-gunicorn-postgres/

# copy our project code
COPY . /deploy/django-nginx-gunicorn-postgres/

# install our two dependencies
RUN pip install -r requirement.txt

# define the default command to run when starting the container
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]
```

# 4. Add Docker-compose

Create your **docker-compose.yml** file at the root of the project.

We are gonna use the version 3 of the configuration syntax.

## 4.1. Add django-nginx-gunicorn-postgres service

Change some config in **setting.py** to use config in variable enviroment:

```python
SLACK_API_KEY = os.getenv('SLACK_API_KEY', 'your api key')
SLACK_USERNAME = os.getenv('SLACK_USERNAME', "django-nginx-gunicorn-postgres")
```

Create a variable environment file for this service

```shell
mkdir -p config/app
touch config/app/docker-env
```

Add to file **config/app/docker-env**:

```conf
SLACK_API_KEY="your-api-key"
SLACK_USERNAME="django-nginx-gunicorn-postgres"
```

```yml
version: '3'

services:
  django-nginx-gunicorn-postgres:
    build: .
    env_file:
      - config/app/docker-env
    volumes:
      - .:/deploy/django-nginx-gunicorn-postgres/
    ports:
      - 8001:8001
```

- **build .** mean looking Dockerfile in current dir for build **django-nginx-gunicorn-postgres** image
- **env_file** specify evironment file that we created above
- **volumes** directive tells to bind the current directory of the host to the /deploy/django-nginx-gunicorn-postgres/ directory of the container. The changes in our current directory will be reflected in real-time in the container directory. And reciprocally, changes that occur in the container directory will occur in our current directory as well.

## 4.2. Add nginx service

```yml
version: '3'

services:

  django-nginx-gunicorn-postgres:
    build: .
    env_file:
      - config/app/docker-env
    volumes:
      - .:/deploy/django-nginx-gunicorn-postgres/

  nginx:
    image: nginx:1.13
    ports:
      - 81:80
    volumes:
      - ./config/nginx/conf.d:/etc/nginx/conf.d
    depends_on:  # <-- wait for django-nginx-gunicorn-postgres to be "ready" before starting this service
      - django-nginx-gunicorn-postgres
```

Note that we removed the ports directive from our django-nginx-gunicorn-postgres service. Indeed we will not communicate directly with django anymore, but with **NginX**. We still want to access our app at [http://localhost:81](http://localhost:81), and we want **NginX** to listen to the port 80 in the container, so we use ports: - 81:80.

We also bind a local directory to the **/etc/nginx/conf.d** container directory. Let’s create it:

```shell
mkdir -p config/nginx/conf.d
touch config/nginx/conf.d/local.conf
```

Add to file **config/nginx/conf.d/local.conf**:

```conf
# first we declare our upstream server, which is our Gunicorn application
upstream django_server {
    # docker will automatically resolve this to the correct address
    # because we use the same name as the service: "django-nginx-gunicorn-postgres"
    server django-nginx-gunicorn-postgres:8001;
}

# now we declare our main server
server {

    listen 80;
    server_name localhost;

    location / {
        # everything is passed to Gunicorn
        proxy_pass http://django_server;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }
}
```

But before we try this out, remember that we need a **bridge** to make our services able to communicate

Update your docker-compose.yml as follow:

```yml
version: '3'

services:

  django-nginx-gunicorn-postgres:
    build: .
    env_file:
      - config/app/docker-env
    volumes:
      - .:/deploy/django-nginx-gunicorn-postgres/
    networks:  # <-- here
      - nginx_network

  nginx:
    image: nginx:1.13
    ports:
      - 81:80
    volumes:
      - ./config/nginx/conf.d:/etc/nginx/conf.d
    depends_on:
      - django-nginx-gunicorn-postgres
    networks:  # <-- here
      - nginx_network

networks:  # <-- and here
  nginx_network:
    driver: bridge
```

# 5. Add containers for one or more Postgres databases

Change your **settings.py**:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'database1',
        'USER': 'database1_role',
        'PASSWORD': 'database1_password',
        'HOST': 'database1',  # <-- IMPORTANT: same name as docker-compose service!
        'PORT': '5432',
    }
}
```

Create a db directory and config env file:

```shell
mkdir config/db
touch config/db/database1_env
```

and to **config/db/database1_env**:

```conf
POSTGRES_USER=database1_role
POSTGRES_PASSWORD=database1_password
POSTGRES_DB=database1
```

These variable are used by the Postgres Docker image.

It means that, when started, the Postgres container will create a database called **database1**, assigned to the role **database1_role** with password **database1_password**. If you change these values, remember to also change them in the **DATABASES** setting.

We are now ready to add our service in **docker-compose.yml**. The added service must have the same name than what is declared in the **DATABASES** setting:

```yml
version: '3'

services:

  django-nginx-gunicorn-postgres:
    build: .
    env_file:
      - config/app/docker-env
    volumes:
      - .:/deploy/django-nginx-gunicorn-postgres/
    networks:
      - nginx_network
      - database1_network  # <-- connect to the bridge
    depends_on:  # <-- wait for db to be "ready" before starting the app
      - database1

  nginx:
    image: nginx:1.13
    ports:
      - 81:80
    volumes:
      - ./config/nginx/conf.d:/etc/nginx/conf.d
    depends_on:
      - django-nginx-gunicorn-postgres
    networks:
      - nginx_network

  database1:  # <-- IMPORTANT: same name as in DATABASES setting, otherwise Django won't find the database!
    image: postgres:10
    env_file:  # <-- we use the previously defined values
      - config/db/database1_env
    networks:  # <-- connect to the bridge
      - database1_network
    volumes:
      - database1_volume:/var/lib/postgresql/data

networks:
  nginx_network:
    driver: bridge
  database1_network:  # <-- add the bridge
    driver: bridge

volumes:
  database1_volume:
```

we added two new things:

- **database1_volumes**: You need to declare your volumes in the root **volumes**: directive if you want them to be kept permanently.
- Then, you can bind a volume to a directory in the container. Here, we bind our declared **database1_volume** to the **database1** container’s **/var/lib/postgresql/data** directory. Everything added to this directory will be permanently stored in the volume called database1_volume. So each subsequent run of the container will have access to the previous data! It means you can stop and restart your service without losing the data.

OK, run **migrate** database, and test our system

```shell
docker-compose build
docker-compose up -d
docker-compose run --rm django-nginx-gunicorn-postgres /bin/bash -c "python manage.py migrate"
```

**NOTE**: The name of the image will be automatically chosen by Docker Compose (it will be the name of the current directory with \_service_name appended).

From now on, it should be really easy to add other databases: just add other database services (database2) with their networks volumes (remember to connect the networks and bind the volumes), update your DATABASES setting in the Django project, and create the environment file for each database in config/db.

Now access this link: [http://0.0.0.0:81/admin/](http://0.0.0.0:81/admin/) to see your admin app.

# 6. Prepare for production

## 6.1. Merge develop branch to master branch

First, we need merge **develop** branch to **master** branch and change some config for production

```shell
git checkout master
git merge develop
git push origin master
```

Now, we will work with **master** branch

## 6.2. Run django app with gunicorn

Add **Gunicorn** to **requirement.txt**:

```conf
gunicorn==19.9.0
```

Change **CMD** of Dockerfile:

```shell
CMD ["gunicorn", "--chdir", "django-nginx-gunicorn-postgres", "--bind", ":8001", "django-nginx-gunicorn-postgres.wsgi:application"]
```

Build image again and run test:

```shell
docker-compose down
docker-compose build django-nginx-gunicorn-postgres
docker-compose up -d
docker-compose run --rm django-nginx-gunicorn-postgres /bin/bash -c "python manage.py migrate"
```

Access link [http://0.0.0.0:81/admin/](http://0.0.0.0:81/admin/), you will see that browser can not get static file of admin page. Next, we will make some change to serve static file.

## 6.3. Static files: collecting, storing and serving

- In order for **NginX** to serve static files, we will change 3 file: **config/nginx/conf.d/local.conf**, **Dockerfile** and **docker-compose.yml** file.

- Static files will be stored in **volumes**. We also need to set the **STATIC_ROOT** variable in the Django project settings.

Do it through 5 step below:

- change nginx configuration

```conf
upstream django_server {
    server django-nginx-gunicorn-postgres:8001;
}

server {

    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://django_server;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    location /static/ {
        alias /deploy/django-nginx-gunicorn-postgres/static/;
    }

    location /media/ {
        alias /deploy/django-nginx-gunicorn-postgres/MEDIA/;
    }
}
```

- change settings.py

```python
# as declared in NginX conf, it must match /deploy/django-nginx-gunicorn-postgres/static/
STATIC_ROOT = os.path.join(os.path.dirname(os.path.dirname(BASE_DIR)), 'static')
STATIC_URL = '/static/'

# do the same for media files, it must match /deploy/django-nginx-gunicorn-postgres/MEDIA/
MEDIA_ROOT = os.path.join(os.path.dirname(os.path.dirname(BASE_DIR)), 'MEDIA')
MEDIA_URL = '/media/'
```

- Collect the static files in the Dockerfile

```shell
# start from an official image
FROM python:3.6

# arbitrary location choice: you can change the directory
RUN mkdir -p /deploy/django-nginx-gunicorn-postgres/
WORKDIR /deploy/django-nginx-gunicorn-postgres/

# copy our project code
COPY . /deploy/django-nginx-gunicorn-postgres/

# install our two dependencies
RUN pip install -r requirement.txt

RUN python manage.py collectstatic --no-input

# define the default command to run when starting the container
CMD ["gunicorn", "--chdir", "django-nginx-gunicorn-postgres", "--bind", ":8001", "django-nginx-gunicorn-postgres.wsgi:application"]
```

- Add media volumes and static volume in docker-compose.yml

```yml
version: '3'

services:

  django-nginx-gunicorn-postgres:
    build: .
    env_file:
      - config/app/docker-env
    volumes:
      - .:/deploy/django-nginx-gunicorn-postgres/
      - static_volume:/deploy/django-nginx-gunicorn-postgres/static  # <-- bind the static volume
      - media_volume:/deploy/django-nginx-gunicorn-postgres/MEDIA  # <-- bind the media volume
    networks:
      - nginx_network
      - database1_network
    depends_on:
      - database1

  nginx:
    image: nginx:1.13
    ports:
      - 81:80
    volumes:
      - ./config/nginx/conf.d:/etc/nginx/conf.d
      - static_volume:/deploy/django-nginx-gunicorn-postgres/static  # <-- bind the static volume
      - media_volume:/deploy/django-nginx-gunicorn-postgres/MEDIA  # <-- bind the media volume
    depends_on:
      - django-nginx-gunicorn-postgres
    networks:
      - nginx_network

  database1:
    image: postgres:10
    env_file:
      - config/db/database1_env
    networks:
      - database1_network
    volumes:
      - database1_volume:/var/lib/postgresql/data

networks:
  nginx_network:
    driver: bridge
  database1_network:
    driver: bridge

volumes:
  database1_volume:
  static_volume:  # <-- declare the static volume
  media_volume:  # <-- declare the media volume
```

- Rebuild and test:

```shell
docker-compose down
docker-compose build
docker-compose up -d
```

Access link: [http://0.0.0.0:81/admin/](http://0.0.0.0:81/admin/) to test

**Note**: Check file volume in host at **/var/lib/docker/volumes/**

## 6.4. Disable debug option in **setting.py**

```python
DEBUG = False
```

## 6.5. Run Gunicorn using Supervisor

We need to make sure that it starts automatically with the system and that it can automatically restart if for some reason it exits unexpectedly. These tasks can easily be handled by a service called supervisord.

Do it through 4 step below:

- Change Dockerfile

```shell
# .....

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor

# .....
CMD ["/usr/bin/supervisord", "-n"]
```

- Add run.sh file and create supervisor config file

```shell
touch run.sh
mkdir -p config/supervisor
touch config/supervisor/supervisor.conf
```

Add to **run.sh**:

```shell
gunicorn --chdir django-nginx-gunicorn-postgres --bind :8001 django-nginx-gunicorn-postgres.wsgi:application
```

Add execute permission for this file:

```shell
chmod +x run.sh
```

Add to file **config/supervisor/supervisor.ini**:

```conf
[unix_http_server]
file=/var/run/supervisor.sock

[supervisord]
logfile = /var/log/supervisord.log
logfile_maxbytes = 50MB
logfile_backups=10
loglevel = info
pidfile = /supervisord.pid
nodaemon = false
minfds = 1024
minprocs = 200
umask = 022
identifier = supervisor_test
nocleanup = true
childlogdir = /var/log
strip_ansi = false

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl = unix:///var/run/supervisor.sock
prompt = django-server

[program:django_app]
directory=/deploy/django-nginx-gunicorn-postgres
command=/deploy/django-nginx-gunicorn-postgres/run.sh
stdout_logfile=/var/log/django_app.out
stderr_logfile=/var/log/django_app.err
environment=PYTHONDONTWRITEBYTECODE=1
autostart=True
autorestart=True
stopasgroup=True
```

- Mount supervisor.conf in docker-compose.yml in django-nginx-gunicorn-postgres service part

```yml
  django-nginx-gunicorn-postgres:
    build: .
    env_file:
      - config/app/docker-env
    volumes:
      - .:/deploy/django-nginx-gunicorn-postgres/
      - ./config/supervisor/supervisor.conf:/etc/supervisor/conf.d/supervisord.conf # <-- here
      - static_volume:/deploy/django-nginx-gunicorn-postgres/static  
      - media_volume:/deploy/django-nginx-gunicorn-postgres/MEDIA  
    networks:
      - nginx_network
      - database1_network
    depends_on:
      - database1
```

- Rebuild and test:

```shell
docker-compose down
docker-compose build
docker-compose up -d
```

Access link: [http://0.0.0.0:81/admin/](http://0.0.0.0:81/admin/) to test

**Note**: if access link [http://0.0.0.0:81](http://0.0.0.0:81) you can see error 404 not found from **nginx**, because this url is not config in nginx yet
# 7. Reference

[http://pawamoy.github.io/2018/02/01/docker-compose-django-postgres-nginx.html#static-files-collecting-storing-and-serving](http://pawamoy.github.io/2018/02/01/docker-compose-django-postgres-nginx.html#static-files-collecting-storing-and-serving)
[https://github.com/andrecp/django-tutorial-docker-nginx-postgres](https://github.com/andrecp/django-tutorial-docker-nginx-postgres)
[http://ruddra.com/2016/08/14/docker-django-nginx-postgres/index.html](http://ruddra.com/2016/08/14/docker-django-nginx-postgres/index.html)
