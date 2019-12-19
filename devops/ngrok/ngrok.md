- [1. Install](#1-install)
- [2. Add token](#2-add-token)
- [3. Forward a port](#3-forward-a-port)
- [4. Forward a port and rewrite header](#4-forward-a-port-and-rewrite-header)
- [5. Configuration file](#5-configuration-file)
- [6. Document](#6-document)
- [Other services sample ngrok](#other-services-sample-ngrok)

# 1. Install

[new-os-install.s](https://gist.github.com/PhungXuanAnh/0a86ed25a70000d1dd6d52ce622fdb36)

Nếu setup bằng file script bên trên thì đã có sẵn token trong thư mục ngrok2 rồi, bỏ qua bước 2

# 2. Add token

Get token from [here](https://dashboard.ngrok.com/auth)

`ngrok authtoken <token>`

# 3. Forward a port

`ngrok http 80`

# 4. Forward a port and rewrite header

```shell
ngrok http --region=us --host-header=rewrite 4200
# or secify a domain
ngrok http --region=us --host-header=site1.dev 4200
ngrok http --region=us --hostname *.example.com 80
ngrok http 192.168.1.1:8080
ngrok http -config=/opt/ngrok/conf/ngrok.yml 8000
ngrok start -config ~/ngrok.yml -config ~/projects/example/ngrok.yml demo admin
```

# 5. Configuration file

https://ngrok.com/docs#config-examples


# 6. Document

https://ngrok.com/docs

# Other services sample ngrok

https://www.softwaretestinghelp.com/ngrok-alternatives/

