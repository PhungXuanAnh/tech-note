#! /bin/bash

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