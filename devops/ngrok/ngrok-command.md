- [1. Add token](#1-add-token)
- [2. Forward a port](#2-forward-a-port)
- [3. Forward a port and rewrite header](#3-forward-a-port-and-rewrite-header)
- [4. Configuration file](#4-configuration-file)
- [5. Document](#5-document)

# 1. Add token

`ngrok authtoken <token>`

# 2. Forward a port

`ngrok http 80`

# 3. Forward a port and rewrite header

```shell
ngrok http --region=us --host-header=rewrite 4200
# or secify a domain
ngrok http --region=us --host-header=site1.dev 4200
ngrok http --region=us --hostname *.example.com 80
ngrok http 192.168.1.1:8080
ngrok http -config=/opt/ngrok/conf/ngrok.yml 8000
ngrok start -config ~/ngrok.yml -config ~/projects/example/ngrok.yml demo admin
```

# 4. Configuration file

https://ngrok.com/docs#config-examples


# 5. Document

https://ngrok.com/docs
