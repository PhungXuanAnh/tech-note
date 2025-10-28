- [1. Run project with sonarqube](#1-run-project-with-sonarqube)
  - [1.1. issues and how to fix](#11-issues-and-how-to-fix)
- [2. Create sonarqube project](#2-create-sonarqube-project)
- [3. Run sonarqube client](#3-run-sonarqube-client)
  - [3.1. Install sonarqube client](#31-install-sonarqube-client)
  - [3.2. Run with config](#32-run-with-config)
  - [3.3. Run directly](#33-run-directly)
  - [3.4. See test result](#34-see-test-result)
- [4. Config quality gates](#4-config-quality-gates)
- [5. Config slack alert](#5-config-slack-alert)
- [6. Steps to run sonarqube in a project](#6-steps-to-run-sonarqube-in-a-project)


# 1. Run project with sonarqube

in Makefile, change SONARQUBE_PROJECT_NAME, then run docker compose up -d

Access: http://localhost:9000

Default account : admin/admin

## 1.1. issues and how to fix

**bootstrap checks failed | max > virtual memory areas vm.max_map_count [65530] is too low, increase to > at least [262144]**

fix: `sudo sysctl -w vm.max_map_count=262144`

refer: https://stackoverflow.com/questions/57998092/docker-compose-error-bootstrap-checks-failed-max-virtual-memory-areas-vm-ma


# 2. Create sonarqube project 

http://localhost:9000/projects/create?mode=manual

enter project key, display name and token name, for ex: django_project, then click Set Up / Generate 

![](images/create-project.png)

save this token for replace in file [sonar-project.properties](sonar-project.properties) then click Continue:

![](images/gen-token.png)

Then, at step 2, choose Other and OS is Linux

![](images/gen-token-2.png)

For more information, access this link for guide how to run install and run sonarqube scanner:

http://localhost:9000/documentation/analysis/scan/sonarscanner/

# 3. Run sonarqube client

## 3.1. Install sonarqube client

On client where you want to run sonarqube client :

```shell
# --------- for linux
cd ~/Downloads
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.1.0.4477-linux-x64.zip
unzip sonar-scanner-cli-6.1.0.4477-linux-x64.zip

~/Downloads/sonar-scanner-6.1.0.4477-linux-x64/bin/sonar-scanner

```

## 3.2. Run with config

Add config as file [sonar-project.properties](../sonar-project.properties) to your project folder, change `sonar.login` value by `token` that you generated in step 2

then run :

```shell
~/Downloads/sonar-scanner-6.1.0.4477-linux-x64/bin/sonar-scanner
# or for debug
~/Downloads/sonar-scanner-6.1.0.4477-linux-x64/bin/sonar-scanner -X
```

## 3.3. Run directly 

NOTE: This command temporary error, fix it

```shell
cd django-rest-framework-sample
~/Downloads/sonar-scanner-6.1.0.4477-linux-x64/bin/sonar-scanner \
  -Dsonar.projectKey=django_project \
  -Dsonar.sources=. \   
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=e1383f4cc2855787495ade5fd9ea3d03c42eb252
```

## 3.4. See test result

http://localhost:9000/project/issues?id=django_project&resolved=false

See part: Critical, Major

![](images/test-result.png)

# 4. Config quality gates

config how to scan and test source code

http://localhost:9000/quality_gates

copy already built-in config **Sonar way** and set another name 

![](images/config-quality-gate.png)

Add and remove some conditions as below :

![](images/config-quality-gate-1.png)

There are to part to apply a condition, apply a condition to **Conditions on New Code** or **Conditions on Overall Code**


# 5. Config slack alert

Get webhook:

        1. How to get webhook, go to: https://api.slack.com/apps
        2. Choose your app in below of website
        3. Choose `In-comming Webhooks` , at left side
        4. Choose `Activate Incoming Webhooks` button if it not enabled yet
        5. Move to below, Choose `Add New Webhook to Workspace`

http://localhost:9000/admin/settings?category=slack

![](images/slack-config.png)

# 6. Steps to run sonarqube in a project

Copy 2 sona command in Makefile

Update SONARQUBE_PROJECT_NAME in make file to this format: sona_project-name

Start sona services

```
make sonarqube-start
```

Access sona web and then create new project http://localhost:9000

Update this file: .vscode/local_files/sonarqube/scripts/scan.env
    