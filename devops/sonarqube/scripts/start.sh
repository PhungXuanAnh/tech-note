#!/bin/bash

increase_max_map_count() {
    max_map_count=$(cat /etc/sysctl.conf | grep vm.max_map_count)
    if [ -n "$max_map_count" ]
    then
        echo "Current $max_map_count"
    else
        echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
    fi
}

check_sona_is_up() {
    status=$(curl -s -f http://localhost:9000/api/system/status | jq '.status')

    count=0

    while [ "$status" != "\"UP\"" ]; do
        echo "$count Waiting for SonarQube to be up..."
        sleep 1
        status=$(curl -s -f http://localhost:9000/api/system/status | jq '.status')
        count=$((count+1))
        if [ $count -eq 60 ]; then
            echo "SonarQube is not up. Please check the logs."
            exit 1
        fi
    done

    echo "SonarQube is up and running."
}

increase_max_map_count

cd ~/repo/tech-note/devops/sonarqube

docker compose --env-file env_file.sonarqube up -d

check_sona_is_up

google-chrome http://localhost:9000

# set admin password
curl -u admin:admin -X POST "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=Sona@1234567" ||:
