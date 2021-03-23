- [1. Install](#1-install)
- [2. Login](#2-login)
- [3. Droplet](#3-droplet)
  - [3.1. Create](#31-create)
  - [3.2. Get](#32-get)
  - [3.3. Delete](#33-delete)

# 1. Install

```shell
# mac
brew install doctl
# ubuntu
sudo snap install doctl
```

https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install/

# 2. Login

Create token from this site : https://cloud.digitalocean.com/account/api/tokens

```shell
doctl auth init --context <context_name> --access-token <token>
#ex:
doctl auth init --context xuananh --access-token adfasdfasfasfsa

doctl auth list
doctl auth switch --context xuananh
```

Test

`doctl account get`

https://www.digitalocean.com/docs/apis-clis/doctl/reference/auth/

# 3. Droplet

https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client

## 3.1. Create

```shell
doctl compute droplet create --region sfo2 --image ubuntu-18-04-x64 --size s-1vcpu-1gb <DROPLET-NAME>
doctl compute droplet create test --size s-1vcpu-1gb --image debian-8-x64 --region nyc1 --ssh-keys 4d:23:e6:e4:8c:17:d2:cf:89:47:36:b5:c7:33:40:4e --enable-backups

```

## 3.2. Get

```shell
# ---------------- json format
doctl compute droplet get droplet_id --output json

# ----------------- formating
doctl compute droplet list --format "ID,Name,PublicIPv4"
# Sample output
ID          Name       Public IPv4
50513569    doctl-1    67.205.152.65
50513570    test       67.205.148.128
50513571    node-1     67.205.131.88

# ----------------- template
doctl compute droplet get 12345678 --template "droplet_name: {{ .Name}}"
# Output
droplet_name: ubuntu-1gb-nyc3-01
```

## 3.3. Delete

```shell
doctl compute droplet delete <DROPLET-ID>
```