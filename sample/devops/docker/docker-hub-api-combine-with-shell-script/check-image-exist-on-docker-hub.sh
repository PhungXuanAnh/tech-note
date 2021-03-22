#!/bin/bash


check-image-exist-on-remote-docker-hub-using-docker-command() {
	IMAGE_URL=$1
	if DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect $IMAGE_URL >>/dev/null; then
		echo "Image $IMAGE_URL is EXIST on remote dockerhub"
	else
		echo "Image $IMAGE_URL NOT FOUND on remote dockerhub"
	fi
}

check-image-exist-on-remote-docker-hub-using-api() {
  IMAGE_NAME=$1
  IMAGE_TAG=$2
  DOCKER_HUB_USERNAME=""
  DOCKER_HUB_PASSWORD=""

  TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_HUB_USERNAME}'", "password": "'${DOCKER_HUB_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | awk -F\" '{print $4}')    
  STATUS_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/$IMAGE_NAME/tags/$IMAGE_TAG/)

  if [[ $STATUS_CODE == 200 ]]; then
      echo "          Image $IMAGE_NAME:$IMAGE_TAG exist on Docker hub"
      exit 1
  elif [[ $STATUS_CODE == 404 ]]; then
      echo "          Image $IMAGE_NAME:$IMAGE_TAG DOES NOT exist on Docker hub"
  else
      echo "          Error when get image info from docker hub: $STATUS_CODE"
      exit 1
  fi
}

# check-image-exist-on-remote-docker-hub-using-docker-command alpine:latest
# check-image-exist-on-remote-docker-hub-using-docker-command alpine:invalid

check-image-exist-on-remote-docker-hub-using-api xuananh/kafdrop 2.0.6
check-image-exist-on-remote-docker-hub-using-api xuananh/kafdrop invalid-tag
