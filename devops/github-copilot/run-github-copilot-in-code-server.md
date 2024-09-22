- [1. preprare workspace](#1-preprare-workspace)
- [2. start code server](#2-start-code-server)
- [3. setup copilot](#3-setup-copilot)
- [4. Troubeshot](#4-troubeshot)
- [5. SSH to host from inside container](#5-ssh-to-host-from-inside-container)


# 1. preprare workspace

copy these files to your repo

- docker-compose.yml
- copilot-1.222.0_vsixhub.com.vsix
- copilot-chat-0.18.2024072603_vsixhub.com.vsix

# 2. start code server

docker compose up -d

# 3. setup copilot

Access code server in this link: http://localhost:8443

Install copilot from VSIX file as below image:

![alt text](readme_img/image.png)
![alt text](readme_img/image-1.png)

install copilot first, and then install copilot chat

![alt text](readme_img/image-2.png)
![alt text](readme_img/image-3.png)

# 4. Troubeshot

You can encountered the incompatible version between code server with copilot extension, or between copilot extension with copilot chat extension

Check version of code, code server, copilot extension, copilot chat extension as below images

![alt text](readme_img/image-4.png)
![alt text](readme_img/image-5.png)
![alt text](readme_img/image-6.png)
![alt text](readme_img/image-7.png)

and then go to these link to search the right version of them to install

https://www.vsixhub.com/s.php?s=GitHub+Copilot+chat#gsc.tab=0&gsc.q=GitHub%20Copilot%20chat&gsc.page=1

https://www.vsixhub.com/vsix/145948/

https://www.vsixhub.com/vsix/144782/

https://github.com/coder/code-server/discussions/5063

# 5. SSH to host from inside container

1. Add your publish key `id_rsa.pub` to authorized_keys
2. Inside docker container in the below command to ssh to host:
   1. Linux: `ssh -o "IdentitiesOnly=yes" DOCKER_HOST_USERNAME@172.17.0.1` -i /.ssh/id_rsa
   2. Mac: `ssh -o "IdentitiesOnly=yes" DOCKER_HOST_USERNAME@host.docker.internal` -i /.ssh/id_rsa

Reference: 
    https://medium.com/cloud-native-daily/ssh-to-docker-host-from-docker-container-e8ee0965802
