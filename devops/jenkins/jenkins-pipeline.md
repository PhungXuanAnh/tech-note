- [1. Setup jenkins using Docker](#1-setup-jenkins-using-docker)
- [2. Add plugins](#2-add-plugins)
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

SSH Pipeline Steps
https://jenkins.io/doc/pipeline/steps/ssh-steps/
https://github.com/jenkinsci/ssh-steps-plugin

Slack Notification

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
