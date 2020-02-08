- [1.1. Install](#11-install)
  - [1.1.1. Install latest vagrant and virtualbox](#111-install-latest-vagrant-and-virtualbox)
  - [1.1.2. Update vagrant plugin when update latest version of vagrant](#112-update-vagrant-plugin-when-update-latest-version-of-vagrant)
  - [1.1.3. Install plugin disk size to specify disk size for vm](#113-install-plugin-disk-size-to-specify-disk-size-for-vm)
- [1.2. Vagrant command](#12-vagrant-command)
  - [1.2.1. Some vagrant basic commands](#121-some-vagrant-basic-commands)
  - [1.2.2. Start all shutdown vagrant VM](#122-start-all-shutdown-vagrant-vm)
  - [1.2.3. Stop all vagrant VM](#123-stop-all-vagrant-vm)
  - [1.2.4. Destroy all vagrant VM](#124-destroy-all-vagrant-vm)
- [1.3. Virtualbox command](#13-virtualbox-command)
  - [1.3.1. List vm](#131-list-vm)
  - [1.3.2. Remove vm](#132-remove-vm)
- [1.4. Sample create virtual machine](#14-sample-create-virtual-machine)
- [1.5. Configuration in Vagrant file](#15-configuration-in-vagrant-file)
  - [1.5.1. sync folder](#151-sync-folder)
  - [1.5.2. public network](#152-public-network)
- [1.6. Sample Vagrantfile](#16-sample-vagrantfile)
- [1.7. Change network interface name](#17-change-network-interface-name)

## 1.1. Install

### 1.1.1. Install latest vagrant and virtualbox

Download latest version of vagrant and virtualbox to prevent ERROR while instal vagrant plugin or when ERROR happen while using vagrant and virtualbox

[Download and Install latest vagrant](https://www.vagrantup.com/downloads.html)

[Download and Install latest virtualbox and VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads)

Install Virtualbox Extension Pack

```shell
sudo dpkg -i vagrant_*_x86_64.deb
vagrant plugin update
vagrant version

sudo dpkg -i virtualbox-*_amd64.deb
sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-*.vbox-extpack
vboxmanage --version
# list installed package
VBoxManage list extpacks
# uninstall package
# sudo VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
```

Nó sẽ liệt kê ra tất cả các command của vagrant, đọc cũng dễ hiểu :D

### 1.1.2. Update vagrant plugin when update latest version of vagrant

```shell
vagrant plugin update
```

### 1.1.3. Install plugin disk size to specify disk size for vm

```shell
vagrant plugin install vagrant-disksize
```

add to Vagrantfile

```conf
config.disksize.size = '50GB'
```

## 1.2. Vagrant command

### 1.2.1. Some vagrant basic commands

- **vagrant global-status** - list Vagrant VM đang chạy
- **vagrant init** - khởi tạo môi trường Vagrant mới và tạo Vagrantfile
- **vagrant box add** – Nạp box.
- **vagrant box list** – Xem danh sách các box.
- **vagrant suspend** – Cho máy ảo tạm nghỉ.
- **vagrant halt** – Cho máy ảo đi ngủ, shutdown đó.
- **vagrant destroy** – Cho máy ảo về vườn.
- **vagrant login** – Đăng nhập vào hệ thống Vagrant Cloud.
- **vagrant share --ssh**: Chia sẻ máy ảo của bạn cho người khác truy cập, bạn phải gõ lệnh vagrant login trước khi dùng tính năng này.
- **vagrant reload**: Tải lại các thiết lập trong file Vagrantfile của máy ảo, khi đổi nội dung file đó bạn phải sử dụng lệnh vagrant halt trước để tắt máy ảo, sau đó sử dụng lệnh reload này để nạp lại cấu hình.

### 1.2.2. Start all shutdown vagrant VM

```shell
for i in `vagrant global-status | grep 'virtualbox poweroff' | awk '{ print $1 }'` ; do vagrant up $i ; done
```

### 1.2.3. Stop all vagrant VM

```shell
for i in `vagrant global-status | grep 'virtualbox' | awk '{ print $1 }'` ; do vagrant halt -f $i ; done
```

### 1.2.4. Destroy all vagrant VM

```shell
for i in `vagrant global-status | grep virtualbox | awk '{ print $1 }'` ; do vagrant destroy $i ; done
```

## 1.3. Virtualbox command

### 1.3.1. List vm

```shell
VBoxManage list vms
```

output sample:

```shell
"vm_name" {vm-id}
"vm01_default_1532940664308_47624" {9a9bad00-d7be-4e44-8349-892eadb088db}
"vm02_default_1532940664308_10939" {ee5915f5-fb87-42e1-b0ea-ace6e3104e0f}
```

### 1.3.2. Remove vm

```shell
VBoxManage unregistervm     <uuid|vmname> [--delete]
VBoxManage unregistervm 9a9bad00-d7be-4e44-8349-892eadb088db  
```

## 1.4. Sample create virtual machine

Box name can be find in this [link](https://app.vagrantup.com/boxes/search?provider=virtualbox)

```shell
vagrant box add ubuntu/trusty64
vagrant box list

mkdir -p $HOME/test-vagrant/vm1
cd $HOME/test-vagrant/vm1
vagrant init [options] [name [url]]
# example
vagrant init ubuntu/trusty64
vagrant up
vagrant ssh
```

## 1.5. Configuration in Vagrant file

### 1.5.1. sync folder

Mặc định là thư mục **vm1** (thư mục chứa file Vagrant) sẽ đồng bộ với thư mục **/vagrant** trong vm
Thay đổi config

```conf
config.vm.synced_folder "../data", "/vagrant_data"
```

### 1.5.2. public network

tạo địa chỉ ip cùng dải với ip của máy host, ví dụ máy host có địa chỉ **192.168.1.200**

```conf
config.vm.network "public_network", ip:"192.168.1.201"
```

## 1.6. Sample Vagrantfile

```conf
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.disksize.size = '50GB'
  config.vm.hostname = "vm1"

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"
  # config.vm.box_url = "file:///home/sigma/vagrant_server/sigma-ubuntu.box"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network", ip: "192.168.1.125", bridge: "wlp3s0"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true

    vb.memory = "1024"
    vb.cpus = 2
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    wget -qO- https://get.docker.com/ | sh
    usermod -aG docker vagrant
    apt-get install -y docker-compose
  SHELL

  # Ssh to vm and add user ubuntu then uncomment below line to ssh using ubuntu username
  # config.ssh.username = "ubuntu"
end
```

## 1.7. Change network interface name 

Tested on ubuntu 16.04

Create file:

```shell
sudo vim /etc/udev/rules.d/10-rename-network.rules
```

add content:

```shell
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ff:ff:ff:ff:ff:ff", NAME="eth0"

# ex:

SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="08:00:27:d4:1a:cf", NAME="ens18"
```

change name of interface in file:

```shell
sudo vim /etc/network/interfaces
```

reboot server

```shell
sudo reboot
```

