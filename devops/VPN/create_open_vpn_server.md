- [1. Clone](#1-clone)
  - [1.2. Auto setup and create user](#12-auto-setup-and-create-user)
  - [Choose option by your self](#choose-option-by-your-self)
- [2. Other repo also help to install vpn server](#2-other-repo-also-help-to-install-vpn-server)



## 1. Setup EC2 security group

![](images/create_open_vpn_server1.png)


# 1. Clone

```
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
```

## 1.2. Auto setup and create user

auto accept all the option and create a new user. client.opvn will be generated in /home/username/client.opvn

```shell
AUTO_INSTALL=y ./openvpn-install.sh
```

## Choose option by your self

```shell
./openvpn-install.sh
```


# 2. Other repo also help to install vpn server

https://github.com/Nyr/openvpn-install
