- [1. Types of server](#1-types-of-server)
- [2. Local Forwarding](#2-local-forwarding)
- [3. reference](#3-reference)

# 1. Types of server

LOCAL SERVER - SSH SERVER - DESTINATION SERVER 
                tunnel
LOCAL SERVER ============== DESTINATION SERVER

# 2. Local Forwarding

This example opens a connection to the **gw.example.com** jump server, and forwards any connection to port **80** on the local machine to port **80** on **intra.example.com**.

```shell
LOCAL_HOST=localhost    # 192.168.1.2
LOCAL_PORT=8001
DESTINATION_HOST=intra.example
DESTINATION_PORT=80
SSH_HOST=gw.example.com
SSH_USER=user
ssh $SSH_USER@$SSH_HOST \
    -o ExitOnForwardFailure=yes \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -fN \
    -L $LOCAL_PORT:$DESTINATION_HOST:$DESTINATION_PORT

# or specify local host
ssh $SSH_USER@$SSH_HOST \
    -o ExitOnForwardFailure=yes \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -fN \
    -L $LOCAL_HOST:$LOCAL_PORT:$DESTINATION_HOST:$DESTINATION_PORT
    
# test:
telnet localhost $LOCAL_PORT <<EOF
ls
EOF
```

example

```shell
ssh xuananh@localhost \
    -o ExitOnForwardFailure=yes \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -fN \
    -L 8001:ubuntu.com:80
# now access: http://localhost:8001 it will redirect to http://ubuntu.com:80
```

you can open tunnel for multiple destination server, ex:

```shell
ssh xuananh@localhost \
    -o ExitOnForwardFailure=yes \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -fN \
    -L 12345:github.com:443 \
    -L 12346:ubuntu.com:443 \
    -L 12347:www.ubuntuforums.org:443 \
    -L 12348:google.com:443 \
    -L 12349:google.com:80

# now access: https://localhost:12345 it will redirect to https://github.com:443
# now access: https://localhost:12346 it will redirect to https://ubuntu.com:443
# now access: https://localhost:12347 it will redirect to http://httpbin.org:80
# now access: https://localhost:12348 it will redirect to https://google.com:443
# now access: http://localhost:12349 it will redirect to http://google.com:80

```

# 3. reference

https://www.ssh.com/academy/ssh/tunneling

https://www.ssh.com/academy/ssh/tunneling/example

https://www.ssh.com/academy/ssh/sshd_config#port-forwarding

https://transang.me/cach-tao-duong-ham-qua-ssh/

https://kipalog.com/posts/Tu-tao-SSH-tunnel-de-forward-port-ra-remote-server

https://tech.miichisoft.net/remote-port-forwarding-voi-ssh-tunnel/

https://bizflycloud.vn/tin-tuc/cac-ky-thuat-huu-ich-khi-su-dung-ssh-307.htm#2tunnelling