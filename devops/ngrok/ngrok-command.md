- [1. Add token](#1-add-token)
- [2. Forward a port](#2-forward-a-port)
- [3. Forward a port and rewrite header](#3-forward-a-port-and-rewrite-header)

# 1. Add token

`ngrok authtoken <token>`

# 2. Forward a port

`ngrok http 80`

# 3. Forward a port and rewrite header

`ngrok http --host-header=rewrite 4200`