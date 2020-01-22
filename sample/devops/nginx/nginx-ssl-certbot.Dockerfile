FROM nginx:1.11.6

RUN apt update && apt upgrade -y

RUN add-apt-repository ppa:certbot/certbot -y && apt install -y python-certbot-nginx

