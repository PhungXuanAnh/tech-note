- [1. Change node config](#1-change-node-config)
- [2. Start base vm](#2-start-base-vm)
- [3. SSH into the Box and Customize It if need](#3-ssh-into-the-box-and-customize-it-if-need)
- [4. Make the Box as Small as possible](#4-make-the-box-as-small-as-possible)
- [5. Repackage the VM into a New Vagrant Box](#5-repackage-the-vm-into-a-new-vagrant-box)
- [6. Add the Box into Your Vagrant Install](#6-add-the-box-into-your-vagrant-install)
- [7. Testing the box](#7-testing-the-box)

# 1. Change node config

Modify [nodes_config.json](nodes_config.json)

# 2. Start base vm

```shell
cd create_base_box
vagrant up
```

# 3. SSH into the Box and Customize It if need

```shell
vagrant ssh
```


Change ssh publish key at last line in file [install_package.sh](install_package.sh)

Add more package to this file, then run it:

```shell
bash install_packages.sh
```

# 4. Make the Box as Small as possible

```shell
sudo apt-get clean
# "zero out" the drive (this is for Ubuntu):
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
# clear base history
cat /dev/null > ~/.bash_history && history -c && exit
```

# 5. Repackage the VM into a New Vagrant Box

```shell
vagrant package --output my-new.box
```

or package base on a vm

```shell
vagrant package --base my-virtual-machine
```

# 6. Add the Box into Your Vagrant Install

```shell
vagrant box add sigma/my-new-box my-new.box
vagrant box add sigma/ubuntu18.04 my-new.box
vagrant box list
```

# 7. Testing the box

```shell
vagrant init sigma/my-new-box
vagrant up
vagrant ssh
```