# Change node config

Modify [nodes_config.json](nodes_config.json)

# Change provision

Add or remove package to install into this box in file [provision.sh](provision.sh)

# Start base vm

```shell
cd create_base_box
vagrant up
```

# SSH into the Box and Customize It if need

```shell
vagrant ssh
```

For example install more packages

```shell
sudo apt-get update
sudo apt-get upgrade
```

# Make the Box as Small as possible

```shell
sudo apt-get clean
# "zero out" the drive (this is for Ubuntu):
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
# clear base history
cat /dev/null > ~/.bash_history && history -c && exit
```

# Repackage the VM into a New Vagrant Box
