- [1. setup](#1-setup)
- [2. setup samba user](#2-setup-samba-user)
- [3. reference](#3-reference)

# 1. setup

```shell
sudo apt update
sudo apt install samba
# Check its service is active and running:
systemctl status smbd --no-pager -l
# To make the service enabled to start automatically with system boot, here is the command:
sudo systemctl enable --now smbd
# Allow samba in Ubuntu 22.04 Firewall
sudo ufw allow samba
```

# 2. setup samba user

```shell
sudo usermod -aG sambashare $USER
sudo smbpasswd -a $USER

# Alternatively, if you want to add some other users to the SAMBA group use:
sudo usermod -aG sambashare your-user
sudo smbpasswd -a your-user

# then restart samba
sudo systemctl restart smbd
```

# 3. reference

**how to setup samba to share file between iphone and ubuntu**


https://askubuntu.com/a/1350842/1077704

https://askubuntu.com/a/1406624/1077704

https://linux.how2shout.com/how-to-install-samba-on-ubuntu-22-04-lts-jammy-linux/

https://ubuntu.com/tutorials/install-and-configure-samba#4-setting-up-user-accounts-and-connecting-to-share

https://linuxconfig.org/how-to-configure-samba-server-share-on-ubuntu-22-04-jammy-jellyfish-linux

https://computingforgeeks.com/install-and-configure-samba-server-share-on-ubuntu/


