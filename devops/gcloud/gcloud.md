# install glcoud command

```shell
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
sudo apt-get install google-cloud-sdk-app-engine-java
```

# login by command

```shell
gcloud auth activate-service-account --key-file /home/xuananh/Dropbox/Work/Other/Cloud-vision-development-2096468eacf7.json
```

# generate token

```shell
gcloud auth print-access-token
```

# Reference

https://cloud.google.com/sdk/docs/downloads-apt-get