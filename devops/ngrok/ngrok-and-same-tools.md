- [1. Ngrok and same tools](#1-ngrok-and-same-tools)
  - [1.1. Install](#11-install)
  - [1.2. Add token](#12-add-token)
  - [1.3. Forward a port](#13-forward-a-port)
  - [1.4. Forward a port and rewrite header](#14-forward-a-port-and-rewrite-header)
  - [1.5. Configuration file](#15-configuration-file)
  - [1.6. Document](#16-document)
- [2. Other services sample ngrok](#2-other-services-sample-ngrok)
  - [2.1. staqlab-tunnel](#21-staqlab-tunnel)
    - [2.1.1. Install](#211-install)
    - [2.1.2. Using](#212-using)
  - [2.2. localtunnel](#22-localtunnel)
  - [2.3. Other](#23-other)


# 1. Ngrok and same tools
## 1.1. Install

Se in file: new-os-install.sh

## 1.2. Add token

Get token from [here](https://dashboard.ngrok.com/auth)

`ngrok authtoken <token>`

## 1.3. Forward a port

`ngrok http 80`

## 1.4. Forward a port and rewrite header

```shell
ngrok http --region=us --host-header=rewrite 4200
# or secify a domain
ngrok http --region=us --host-header=site1.dev 4200
ngrok http --region=us --hostname *.example.com 80
ngrok http 192.168.1.1:8080
ngrok http -config=/opt/ngrok/conf/ngrok.yml 8000
ngrok start -config ~/ngrok.yml -config ~/projects/example/ngrok.yml demo admin
```

## 1.5. Configuration file

https://ngrok.com/docs#config-examples


## 1.6. Document

https://ngrok.com/docs

# 2. Other services sample ngrok

## 2.1. staqlab-tunnel

https://tunnel.staqlab.com/

### 2.1.1. Install

```shell
# ubuntu
rm -rf ~/.local/bin/staqlab-tunnel
wget https://raw.githubusercontent.com/cocoflan/Staqlab-tunnel/master/linux/staqlab-tunnel -P ~/.local/bin
chmod +x ~/.local/bin/staqlab-tunnel

# mac
rm -rf ~/.local/bin/staqlab-tunnel
wget https://raw.githubusercontent.com/cocoflan/Staqlab-tunnel/master/mac/staqlab-tunnel -P ~/.local/bin
chmod +x ~/.local/bin/staqlab-tunnel
```

### 2.1.2. Using

```shell
staqlab-tunnel <port> hostname=<desired-domain>
# ex:
staqlab-tunnel 8000 hostname=my-domain
# output domain:
https://my-domain.staqlab-tunnel.com/
```

## 2.2. localtunnel

https://github.com/localtunnel/localtunnel

## 2.3. Other

https://www.softwaretestinghelp.com/ngrok-alternatives/

