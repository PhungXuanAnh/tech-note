add-service() {
    NAME=$1
    curl -i -X POST --url http://localhost:8001/services/ \
            --data 'name=${NAME}' \
            --data 'url=http://localhost:8123/api/${NAME}'
}