- [1. Ngrok and same tools](#1-ngrok-and-same-tools)
  - [1.1. Install](#11-install)
  - [1.2. Add token](#12-add-token)
  - [1.3. sample how to run](#13-sample-how-to-run)
  - [1.4. Configuration file](#14-configuration-file)
  - [1.5. Ngrok api client](#15-ngrok-api-client)
  - [1.6. ngrok python](#16-ngrok-python)
  - [1.7. Document](#17-document)
- [2. Other services sample ngrok](#2-other-services-sample-ngrok)
  - [2.1. cloudflare](#21-cloudflare)
    - [2.1.1. install](#211-install)
    - [2.1.2. using](#212-using)
  - [2.2. staqlab-tunnel](#22-staqlab-tunnel)
    - [2.2.1. Install](#221-install)
    - [2.2.2. Using](#222-using)
  - [2.3. localtunnel](#23-localtunnel)
  - [2.4. Other](#24-other)


# 1. Ngrok and same tools
## 1.1. Install

Se in file: new-os-install.sh

## 1.2. Add token

Get token from [here](https://dashboard.ngrok.com/auth)

`ngrok authtoken <token>`

Or add to ngrok.yml

## 1.3. sample how to run


```shell
ngrok http 80
# or
ngrok http --region=us --host-header=rewrite 4200
# or secify a domain
ngrok http --region=us --host-header=site1.dev 4200
ngrok http --region=us --hostname *.example.com 80
ngrok http 192.168.1.1:8080
ngrok http -config=/opt/ngrok/conf/ngrok.yml 8000
ngrok start -config ~/ngrok.yml -config ~/projects/example/ngrok.yml demo admin
```

## 1.4. Configuration file

https://ngrok.com/docs#config-examples

https://www.dropbox.com/s/l94bvbo7cwu5qrl/ngrok.yml

## 1.5. Ngrok api client

https://github.com/PhungXuanAnh/python-note/blob/master/ngrok_sample/ngrok_client_api.py

https://ngrok.com/docs#client-api

## 1.6. ngrok python

https://github.com/PhungXuanAnh/python-note/blob/master/ngrok_sample/pyngrok_sample.py

## 1.7. Document

https://ngrok.com/docs

# 2. Other services sample ngrok

## 2.1. cloudflare

### 2.1.1. install 

Download deb file and install here: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/#linux

### 2.1.2. using

```
cloudflared tunnel --url http://localhost:3000
```

Visit the generated link and then do as guiden in this page to access your real page

refer: 

- https://developers.cloudflare.com/pages/how-to/preview-with-cloudflare-tunnel/#start-a-cloudflare-tunnel
- https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-local-tunnel/



## 2.2. staqlab-tunnel

https://tunnel.staqlab.com/

### 2.2.1. Install

```shell
# ubuntu
rm -rf ~/.local/bin/staqlab-tunnel*
wget https://raw.githubusercontent.com/abhishekq61/tunnel-client/master/linux/staqlab-tunnel.zip -P ~/.local/bin
unzip staqlab-tunnel.zip
chmod +x ~/.local/bin/staqlab-tunnel
rm -rf staqlab-tunnel.zip

# mac
rm -rf ~/.local/bin/staqlab-tunnel
wget https://raw.githubusercontent.com/cocoflan/Staqlab-tunnel/master/mac/staqlab-tunnel -P ~/.local/bin
unzip staqlab-tunnel.zip
chmod +x ~/.local/bin/staqlab-tunnel
rm -rf staqlab-tunnel.zip
```

### 2.2.2. Using

```shell
staqlab-tunnel <port> hostname=<desired-domain>
# ex:
staqlab-tunnel 8000 hostname=my-domain
# output domain:
https://my-domain.staqlab-tunnel.com/
```

## 2.3. localtunnel

https://github.com/localtunnel/localtunnel

## 2.4. Other

https://www.softwaretestinghelp.com/ngrok-alternatives/

