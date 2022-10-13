sample using webhook to setup auto deploy when push code to github

- [1. install webhook on remote servers](#1-install-webhook-on-remote-servers)
- [2. create configurations for webhook](#2-create-configurations-for-webhook)
- [3. add to github](#3-add-to-github)
- [4. reference](#4-reference)

# 1. install webhook on remote servers

```shell
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install webhook
```

# 2. create configurations for webhook

```shell
mkdir ~/.webhooks
touch ~/.webhooks/hooks.json
touch ~/.webhooks/deploy.sh
chmod +x ~/.webhooks/deploy.sh

vim ~/.webhooks/hooks.json
```

add below to hooks.json

```json
[{
    "id": "deployment-castnet",
    "execute-command": "/home/ubuntu/./webhooks/deploy.sh",
    "command-working-directory": "/home/ubuntu/castnet",
    "response-message": "Executing deploy script...",
}]
```

or using secret to make our webhooks more secure

```json
[{
    "id": "deployment-castnet",
    "execute-command": "/home/ubuntu/./webhooks/deploy.sh",
    "command-working-directory": "/home/ubuntu/castnet",
    "response-message": "Executing deploy script...",
    "trigger-rule": {
        "match": {
            "type": "payload-hmac-sha1",
            "secret": "secret@2721991",
            "parameter": {
                "source": "header",
                "name": "X-Hub-Signature"
            }
        }
    }
}]
```

`vim ~/.webhooks/deploy.sh`

add command to deploy to above script, for example:

```shell
#!/bin/bash
cd /home/ubuntu/castnet

git pull xuananh dev
git pull origin dev
git push xuananh dev
git push origin dev

docker-compose exec -it postgres pg_dump postgres://test:test@localhost:5432/test > db_backup/castnet_`date +%d-%m-%Y"_"%H_%M_%S`.sql
docker-compose exec -it app python manage.py migrate
docker-compose -f docker-compose.yml -f docker-compose.local.yml up -d
```

run webhook

```shell
webhook -hooks ~/.webhooks/hooks.json -verbose
```

# 3. add to github

![](../../images/devops/remote_tools/github_webhook.png)

# 4. reference

https://github.com/adnanh/webhook

https://betterprogramming.pub/how-to-automatically-deploy-from-github-to-server-using-webhook-79f837dcc4f4

