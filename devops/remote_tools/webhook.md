sample using webhook to setup auto deploy when push code to github

- [1. install webhook on remote servers](#1-install-webhook-on-remote-servers)
- [2. create script that will run by webhook](#2-create-script-that-will-run-by-webhook)
- [3. create configurations for webhook](#3-create-configurations-for-webhook)
  - [3.1. simple webhook config](#31-simple-webhook-config)
  - [3.2. using secret to make our webhooks more secure](#32-using-secret-to-make-our-webhooks-more-secure)
  - [3.3. add more conditions to trigger webhook and pass arguments to commands that in webhook](#33-add-more-conditions-to-trigger-webhook-and-pass-arguments-to-commands-that-in-webhook)
- [4. add to github](#4-add-to-github)
- [5. reference](#5-reference)

# 1. install webhook on remote servers

```shell
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install webhook
```

# 2. create script that will run by webhook

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

# 3. create configurations for webhook

```shell
mkdir ~/.webhooks
touch ~/.webhooks/hooks.json
touch ~/.webhooks/deploy.sh
chmod +x ~/.webhooks/deploy.sh

vim ~/.webhooks/hooks.json
```

## 3.1. simple webhook config

```json
[{
    "id": "deployment-castnet",
    "execute-command": "/home/ubuntu/./webhooks/deploy.sh",
    "command-working-directory": "/home/ubuntu/castnet",
    "response-message": "Executing deploy script...",
}]
```

## 3.2. using secret to make our webhooks more secure

```json
[{
    "id": "deployment-castnet",
    "execute-command": "/home/ubuntu/./webhooks/deploy.sh",
    "command-working-directory": "/home/ubuntu/castnet",
    "response-message": "Executing deploy script...",
    "trigger-rule": {
        "match": {
            "type": "payload-hmac-sha1",
            "secret": "your-password",
            "parameter": {
                "source": "header",
                "name": "X-Hub-Signature"
            }
        }
    }
}]
```

## 3.3. add more conditions to trigger webhook and pass arguments to commands that in webhook

reference: https://github.com/adnanh/webhook/blob/master/docs/Hook-Examples.md#incoming-github-webhook

to see github webhook payload, After setup and trigger webhook for the first time, go to webhook -> Recent Deliveries

```json
[{
    "id": "deployment-ink",
    "execute-command": "/home/ubuntu/.webhooks/deploy.sh",
    "command-working-directory": "/home/ubuntu/ink",
    "response-message": "Executing deploy script...",
    "pass-arguments-to-command": [
        {
            "source": "payload",
            "name": "head_commit.message"
        }
    ],
    "trigger-rule": {
        "and": [
            {
                "match": {
                    "type": "payload-hmac-sha1",
                    "secret": "your-password",
                    "parameter": {
                        "source": "header",
                        "name": "X-Hub-Signature"
                    }
                }
            },
            {
                "match":
                    {
                        "type": "value",
                        "value": "refs/heads/staging",
                        "parameter": {
                            "source": "payload",
                            "name": "ref"
                        }
                    }
            }
        ]
    }
}]
```

# 4. add to github

![](../../images/devops/remote_tools/github_webhook.png)

# 5. reference

https://github.com/adnanh/webhook

https://betterprogramming.pub/how-to-automatically-deploy-from-github-to-server-using-webhook-79f837dcc4f4

