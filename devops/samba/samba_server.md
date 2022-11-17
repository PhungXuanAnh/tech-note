- [1. setup](#1-setup)
- [2. setup samba user](#2-setup-samba-user)
- [3. reference](#3-reference)

# 1. setup

```shell
sudo apt update
sudo apt install samba
```

# 2. setup samba user

```shell
sudo smbpasswd -a xuananh   # it should be same current ubuntu user
# enter password should be same current user ubuntu

sudo systemctl restart smbd
```

# 3. reference

https://ubuntu.com/tutorials/install-and-configure-samba#4-setting-up-user-accounts-and-connecting-to-share

https://linuxconfig.org/how-to-configure-samba-server-share-on-ubuntu-22-04-jammy-jellyfish-linux

https://computingforgeeks.com/install-and-configure-samba-server-share-on-ubuntu/

https://askubuntu.com/a/1350842/1077704

https://askubuntu.com/a/1406624/1077704
