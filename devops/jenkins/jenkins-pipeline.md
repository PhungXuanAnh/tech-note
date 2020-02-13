- [1. Setup jenkins using Docker](#1-setup-jenkins-using-docker)
- [2. Add plugins](#2-add-plugins)
  - [2.1. SSH Pipeline Steps](#21-ssh-pipeline-steps)
  - [2.2. Slack Notification](#22-slack-notification)
- [Create Jenkins pipeline](#create-jenkins-pipeline)
- [3. Jenkinfile sample](#3-jenkinfile-sample)
- [4. Reference](#4-reference)

# 1. Setup jenkins using Docker

```shell

JENKINS_NAME=test-jenkins3
JENKINS_PORT=8021

mkdir -p /tmp/$JENKINS_NAME
docker run -d --name $JENKINS_NAME \
				-p $JENKINS_PORT:8080 \
				-p 50000:50000 \
				-v /tmp/$JENKINS_NAME:/var/jenkins_home \
				jenkins/jenkins

## open jenkins in default browser
sensible-browser "http://$(ip route get 8.8.8.8 | awk '{print $7; exit}'):$JENKINS_PORT"

# get initial password for jenkins then fill to browser
docker exec -it $JENKINS_NAME cat /var/jenkins_home/secrets/initialAdminPassword

```

Then choose **Install suggested plugins**, wait a few menutes

Then create new Admin user

# 2. Add plugins

Go to **Manager Jenkins** -> **Manager Plugins** -> **Available**

Then choose bellow plugin to install

## 2.1. SSH Pipeline Steps

After plugin installed

Add ssh key:

```shell
docker exec $JENKINS_NAME cat > /var/jenkins_home/id_rsa <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAwT7UgQjF/nwMrFHnFz1BzK1bAzUaxAarm5v++k121w94WrR5
lXrVTrimCy/WE5EmOHGErBIqXX5So32a3KLpH8VjzN8lYkJRsluPlranmQGrOSpP
SyTnCnX+oLV2yxxS1fZiJvD1VwLtukqzPAkKWnmy+VzO7Kh3LMaQI5VcEDCvlzCF
n/joHPNY7ItHlFv4Yy+I3GIkKUYJQNyHMsZSvbxjjpuwRG9IgyANpBPYBsojBPK+
eZ17z9e9407NzyyCNOTa1gdTWoh4d2hXrmWw08+F/LPUTD5luV+SlGpfUcFYNqrQ
8RJHIoPh2pFTwSY+nGSFlD2rExiHkGBKUlvJbQIDAQABAoIBAQCgRIyXi4Ax5A3a
qH6g3nQA3VFbIqLVKrcOcl0QmEhUaoclqwIfP+VCyY8kPgMs7TemnjcrQlGSgp7k
6toR3Ka9a8aude8aQ+hfpOI8W7Y6BpFL8tQafTuEiIGqJXWlVBM7UoDqzPKcvFgP
Jb7qrpDAoqgVeaw/yCQ2pWOLr2bQIS8YjZtuWFs1SlbR7mfVgEVXhDb4MBg88+yi
3dCa0oYnOPvjBeyE5mPOAuOCQzwXAipZDJ+Fl9mnVre97nh9DE69h2+83/PCXH49
In4nazuhfRROnH5Y0e5FKe8Bb/80fafPS9SCUFDqibEWl6usILEIn6H3wsGNEHls
5DNddjihAoGBAOwW5WiTJm97pgpgo6RiM/392EZbBIxHgj9alqLi+k20ixkAHa6n
+DGJiZa2LNscULK+NFZjQ9hjPfr34+QRp4Pr25xgKq6XxortGs+3ouR53BOB+cHT
wML7IlyfI2TksMcjTtgQjyLwMJJzvQpCp5NCJPhbYc2pk6bc5I8tMB3lAoGBANGK
8aq3WztBoYBbkMcU3Bn9wJTY9zc8+OUzCdQMybFtEQEGWhmLFMj3gxl5RpMjgFKm
VRbhy3U5Mci88Fbbp5zJDUA62P/0EJhrRmOz0Qp45FpN/1PVemBByrOeLRWoG/ym
sWXBmzyGMB6Bnt7Khp1BENJJd6n2Jg80mCKzJQTpAoGARFgseSWADu3gl0h6lu/G
1VRS86sNmf5peiWjTewfQbduPQKHlTQS6WRDbFm4ioWb5uKhDBEYZt/z5V81naRu
tgXlQVOlh31wgG87P76NbU7JouwRfUbrmoZQ4DdBa8e4VS2neWzxws99gCf5Jas+
D6cqRKtPmNXqZHe1wqz2LPECgYAnoXrBifo0Q95ys163eGeEduy0ejCPfvWoC7Yh
J+YBq5oasoPZ7ucYd0+RQtGpRH6hoxnWwQ/E9PNIfwuJsfOKgLAD5N1j01pMKYXf
l4PC0kiGF9hhl6+Ugvz+ab0nKmtYpoJIt4xPryVsr6FHi9BX75Vp4EFEoOxj1dOs
RGuM+QKBgQC0akAL1qlBvz7HS3EwvtpDAqUbz0Kzp58P1SaeZQhlOHof0PSrjhTH
5QFpzw4ZJ4FeYC9Lyzp/ATXysW9s1dqtUqGWyW0HArKc+viud3I8yTvAy/utkpVt
WI55Snpj+PwZ065jqYn1EtTkAi7Osdfsfssdfdsfj5VFZVsSrj01Vgf8+w==
-----END RSA PRIVATE KEY-----

EOF

# check result
docker exec $JENKINS_NAME cat /var/jenkins_home/id_rsa
```

Then, configure ssh remote as [Jenkinsfile](#3-jenkinfile-sample)

Reference:

https://jenkins.io/doc/pipeline/steps/ssh-steps/

https://github.com/jenkinsci/ssh-steps-plugin


## 2.2. Slack Notification

After install config slack as [Jenkins configure notification](jenkins-configure-notification.md)

# Create Jenkins pipeline

Click **New Item**, enter pipeline name (For example **test**), choose **Mutibranch Pipeline**, click **OK**

Click **Add source**, choose your **Git**

![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-1.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-2.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-3.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-4.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-5.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-6.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-7.png)


![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-8.png)

![img](../image/devops/jenkins/../../../../images/devops/jenkins/jenkins-pipeline-9.png)


# 3. Jenkinfile sample

```Groovy
def remote = [:]
remote.name = 'kidssy-manager'
remote.host = '178.128.82.0'
remote.user = 'root'
// remote.password = 'sigma2020'
remote.identityFile = '/var/jenkins_home/id_rsa'
remote.allowAnyHosts = true

pipeline {
    agent any
    // agent { docker { image 'python:3.5.1' } }

    environment {
        DISABLE_AUTH = 'true'
        DB_ENGINE    = 'sqlite'
        // handly for Makefile
    }
    stages {
        stage('Build') {
            steps {
                echo "Database engine is ${DB_ENGINE}"
                echo "DISABLE_AUTH is ${DISABLE_AUTH}"
                sh 'printenv'
            }
        }
        stage('Test Unit') {
            steps {
                // sh 'echo "Fail!"; exit 1'
                sh 'echo "Success!"; exit 0'
            }
        }

        stage('Deploy - Staging') {
            steps {
                sh 'echo "Deploying staging"'
                sshCommand remote: remote, command: "ls -lrt /root/Kidssy"
                sshCommand remote: remote, command: "cd /root/Kidssy && git pull && docker-compose build app-sample"
                // sh 'Get all swarm node ip'
                // sh 'Pull new code on all swarm nodes'
                // sh 'Build/Pull new image on earch swarm node, build/pull image đúng node type, ví dụ chỉ pull user image cho node user'
                // sshCommand remote: remote, command: 'cd /root/Kidssy && docker stack deploy -c docker-compose.yml -c docker-compose.staging.swarm.yml kidssy'
                sshCommand remote: remote, command: 'docker service update --force kidssy_app-sample && docker service update --force kidssy_kong'
                sshCommand remote: remote, command: 'cd /root/Kidssy && python3 deploy/deploy.py'
                sh 'echo "Running smoke tests"'
            }
        }

        stage('Sanity check') {
            steps {
                input "Does the staging environment look ok?"
                // sh 'echo "Sanity check"'
            }
        }

        stage('Deploy - Production') {
            steps {
                sh 'echo "Deploying production"'
            }
        }
    }
    post {
        always {
            echo 'This will always run'
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'This will run only if successful'
            // slackSend channel: '#general',
            //       color: 'good',
            //       message: "The pipeline ${currentBuild.fullDisplayName} completed successfully."
        }
        failure {
            echo 'This will run only if failed'
            // slackSend channel: '#general',
            //       color: 'bad',
            //       message: "The pipeline ${currentBuild.fullDisplayName} completed successfully."
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}
```

# 4. Reference

https://jenkins.io/doc/pipeline/
